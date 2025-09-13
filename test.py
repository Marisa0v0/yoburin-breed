import asyncio
import websockets
import json
import socket

from bilibili_api import Credential
from bilibili_api.live import LiveDanmaku, LiveRoom
from bilibili_api.utils.network import get_client, HEADERS, BiliWsMsgType

from pathlib import Path
from python.config import settings


credential = Credential(**settings.bilibili.model_dump())

ROOT = Path(r"D:\Tools\Codes\Python\bilibili-api-project").resolve()

room_id = 1820703922
room = LiveDanmaku(
    room_display_id=room_id,
    credential=credential,
)


# 处理B站WebSocket消息
async def bilibili_websocket_client():
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


def process_message(raw_data):
    # 这里实现你的消息处理逻辑
    # 返回处理后的数据
    return json.dumps({
        "type"   : "danmaku",
        "content": "示例弹幕内容",
        "user"   : "示例用户"
    })


# TCP服务器用于向Godot发送数据
def start_tcp_server():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind(('localhost', 9090))
    server_socket.listen(1)
    print("TCP服务器启动，等待Godot连接...")

    while True:
        client_socket, addr = server_socket.accept()
        print(f"Godot已连接: {addr}")

        # 这里需要维护连接并在有数据时发送
        # 实际实现可能需要多线程或异步处理


def send_to_godot(data):
    # 这里实现向已连接的Godot客户端发送数据
    pass


if __name__ == "__main__":
    # 启动TCP服务器线程
    import threading

    tcp_thread = threading.Thread(target=start_tcp_server)
    tcp_thread.daemon = True
    tcp_thread.start()

    # 启动WebSocket客户端
    asyncio.get_event_loop().run_until_complete(bilibili_websocket_client())