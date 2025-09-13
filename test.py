import asyncio
import websockets
import json
import socket
import time
import threading

from bilibili_api import Credential
from bilibili_api.live import LiveDanmaku, LiveRoom
from bilibili_api.utils.network import get_client, HEADERS, BiliWsMsgType

from pathlib import Path
from python.config import settings
from python.log import logger


credential = Credential(**settings.bilibili.model_dump())

room_id = 1820703922
room = LiveDanmaku(
    room_display_id=room_id,
    credential=credential,
)

@room.on("DANMU_MSG")
async def _(event: dict):
    logger.info("收到弹幕")
    logger.debug(event)
    godot_server.send_data(
        json.dumps(
            {
                "type": event["type"],
                "user": event["data"]["info"][2][1],
                "content": event["data"]["info"][1]
            },
            ensure_ascii=False
        )
    )


# 处理B站WebSocket消息
async def bilibili_websocket_client(godot_server):
    room._LiveDanmaku__status = room.STATUS_CONNECTING

    room.room = LiveRoom(
        room_display_id=room.room_display_id, credential=room.credential
    )

    room.logger.info(f"准备连接直播间 {room.room_display_id}")
    # 获取真实房间号
    room.logger.debug("正在获取真实房间号")
    room._LiveDanmaku__room_real_id = await room.room.get_room_id()
    room.logger.debug(f"获取成功，真实房间号：{room._LiveDanmaku__room_real_id}")

    # 获取直播服务器配置
    room.logger.debug("正在获取聊天服务器配置")
    conf = await room.room.get_danmu_info()
    room.logger.debug("聊天服务器配置获取成功")

    # 连接直播间
    room.logger.debug("准备连接直播间")
    room._LiveDanmaku__client = get_client()
    available_hosts: list[dict] = conf["host_list"][::-1]
    retry = room.max_retry
    host = None

    @room.on("TIMEOUT")
    async def on_timeout(ev):
        # 连接超时
        room.err_reason = "心跳响应超时"
        await room._LiveDanmaku__client.ws_close(room._LiveDanmaku__ws)  # type: ignore

    while True:
        room.err_reason = ""
        # 重置心跳计时器
        room._LiveDanmaku__heartbeat_timer = 0
        room._LiveDanmaku__heartbeat_timer_web = 0
        if not available_hosts:
            room.err_reason = "已尝试所有主机但仍无法连接"
            break

        if host is None or retry <= 0:
            host = available_hosts.pop()
            retry = room.max_retry

        port = host["wss_port"]
        protocol = "wss"
        uri = f"{protocol}://{host['host']}:{port}/sub"
        room._LiveDanmaku__status = room.STATUS_CONNECTING
        room.logger.info(f"正在尝试连接主机： {uri}")

        try:
            room._LiveDanmaku__ws = await room._LiveDanmaku__client.ws_create(uri, headers=HEADERS.copy())

            @room.on("VERIFICATION_SUCCESSFUL")
            async def on_verification_successful(data):
                # 新建心跳任务
                while len(room._LiveDanmaku__tasks) > 0:
                    room._LiveDanmaku__tasks.pop().cancel()
                room._LiveDanmaku__tasks.append(asyncio.create_task(room._LiveDanmaku__heartbeat()))
                room._LiveDanmaku__tasks.append(asyncio.create_task(room._LiveDanmaku__heartbeat_web()))

            room.logger.debug("连接主机成功, 准备发送认证信息")
            await room._LiveDanmaku__send_verify_data(conf["token"])

            while True:
                try:
                    data, flag = await room._LiveDanmaku__client.ws_recv(room._LiveDanmaku__ws)
                except Exception as e:
                    room._LiveDanmaku__status = room.STATUS_ERROR
                    room.logger.error("出现错误")
                    break

                if flag == BiliWsMsgType.BINARY:
                    room.logger.debug(f"收到原始数据：{data}")
                    await room._LiveDanmaku__handle_data(data)
                elif flag == BiliWsMsgType.CLOSING:
                    room.logger.debug("连接正在关闭")
                    room._LiveDanmaku__status = room.STATUS_CLOSING
                elif flag == BiliWsMsgType.CLOSED:
                    room.logger.info("连接已关闭")
                    room._LiveDanmaku__status = room.STATUS_CLOSED
                    break

            # 正常断开情况下跳出循环
            if room._LiveDanmaku__status != room.STATUS_CLOSED or room.err_reason:
                # 非用户手动调用关闭，触发重连
                room.logger.warning(
                    "非正常关闭连接" if not room.err_reason else room.err_reason
                )
            else:
                break

        except Exception as e:
            if room._LiveDanmaku__ws:
                await room._LiveDanmaku__client.ws_close(room._LiveDanmaku__ws)
            room.logger.warning(e)
            if retry <= 0 or len(available_hosts) == 0:
                room.logger.error("无法连接服务器")
                room.err_reason = "无法连接服务器"
                break

            room.logger.warning(f"将在 {room.retry_after} 秒后重新连接...")
            room._LiveDanmaku__status = room.STATUS_ERROR
            retry -= 1
            await asyncio.sleep(room.retry_after)


class GodotTCPServer:
    def __init__(self, host='localhost', port=9090):
        self.host = host
        self.port = port
        self.server_socket = None
        self.client_socket = None
        self.client_address = None
        self.is_running = False
        self.reconnect_interval = 5  # 重连间隔(秒)

    def start_server(self):
        """启动TCP服务器"""
        self.is_running = True
        while self.is_running:
            try:
                self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                self.server_socket.bind((self.host, self.port))
                self.server_socket.listen(1)
                logger.info(f"TCP服务器启动，等待Godot连接在 {self.host}:{self.port}...")

                # 等待客户端连接
                self.client_socket, self.client_address = self.server_socket.accept()
                logger.info(f"Godot已连接: {self.client_address}")

                # 保持连接直到断开
                self._keep_connection()

            except Exception as e:
                logger.error(f"服务器错误: {e}")
                time.sleep(self.reconnect_interval)
            finally:
                self._cleanup()

    def _keep_connection(self):
        """保持连接并处理心跳"""
        last_activity = time.time()
        while self.is_running and self.client_socket:
            try:
                # 检查是否有数据可读（可选，用于接收Godot的心跳或消息）
                # 这里我们主要关注发送数据，所以简单保持连接
                time.sleep(1)

                # 发送心跳包保持连接（可选）
                current_time = time.time()
                if current_time - last_activity > 30:  # 每30秒发送一次心跳
                    try:
                        self.client_socket.sendall(b'ping')
                        last_activity = current_time
                    except:
                        logger.warning("发送心跳失败，连接可能已断开")
                        break

            except Exception as e:
                logger.error(f"连接保持错误: {e}")
                break

    def send_data(self, data):
        """向Godot客户端发送数据"""
        if self.client_socket:
            try:
                if isinstance(data, str):
                    data = data.encode('utf-8')
                self.client_socket.sendall(data)
                return True
            except Exception as e:
                logger.error(f"发送数据失败: {e}")
                self.client_socket = None
                return False
        else:
            logger.warning("没有活动的Godot连接")
            return False

    def _cleanup(self):
        """清理资源"""
        if self.client_socket:
            try:
                self.client_socket.close()
            except:
                pass
            self.client_socket = None

        if self.server_socket:
            try:
                self.server_socket.close()
            except:
                pass
            self.server_socket = None

    def stop_server(self):
        """停止服务器"""
        self.is_running = False
        self._cleanup()


# 处理B站WebSocket消息
# async def bilibili_websocket_client(godot_server):
#     uri = "wss://your-bilibili-websocket-url"
#     reconnect_interval = 10  # 重连间隔(秒)
#
#     while True:
#         try:
#             logger.info("尝试连接B站WebSocket...")
#             async with websockets.connect(uri) as websocket:
#                 logger.info("已连接到B站WebSocket")
#                 while True:
#                     try:
#                         message = await websocket.recv()
#                         processed_data = process_message(message)
#                         # 发送到Godot客户端
#                         if not godot_server.send_data(processed_data):
#                             logger.warning("发送到Godot失败，但继续接收B站数据")
#                     except websockets.exceptions.ConnectionClosed:
#                         logger.warning("B站WebSocket连接已关闭，尝试重连...")
#                         break
#                     except Exception as e:
#                         logger.error(f"处理B站消息错误: {e}")
#                         break
#         except Exception as e:
#             logger.error(f"连接B站WebSocket失败: {e}")
#
#         logger.info(f"{reconnect_interval}秒后尝试重连B站WebSocket...")
#         await asyncio.sleep(reconnect_interval)


def process_message(raw_data):
    """处理B站消息"""
    # 这里实现你的消息处理逻辑
    # 返回处理后的数据
    return json.dumps({
        "type"     : "danmaku",
        "content"  : "示例弹幕内容",
        "user"     : "示例用户",
        "timestamp": time.time()
    })


if __name__ == "__main__":
    # 创建Godot TCP服务器
    godot_server = GodotTCPServer()

    # 启动TCP服务器线程
    tcp_thread = threading.Thread(target=godot_server.start_server)
    tcp_thread.daemon = True
    tcp_thread.start()

    try:
        # 启动WebSocket客户端
        asyncio.get_event_loop().run_until_complete(bilibili_websocket_client(godot_server))
    except KeyboardInterrupt:
        logger.info("正在关闭服务器...")
        godot_server.stop_server()