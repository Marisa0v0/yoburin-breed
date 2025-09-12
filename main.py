import asyncio
import websockets
from bilibili_api.live import LiveRoom
import json
from datetime import datetime

# 存储所有连接的客户端
connected_clients = set()


async def handle_client(websocket):
    # 添加新客户端到集合中
    connected_clients.add(websocket)
    client_ip = websocket.remote_address[0]
    print(f"[{datetime.now().strftime('%H:%M:%S')}] 客户端 {client_ip} 已连接")

    try:
        async for message in websocket:
            # 解析客户端发送的JSON消息
            try:
                data = json.loads(message)
                print(f"[{datetime.now().strftime('%H:%M:%S')}] 收到来自客户端的消息: {data}")

                # 处理不同类型的消息
                if data.get('type') == 'greeting':
                    # 回应客户端
                    response = {
                        'type'     : 'response',
                        'message'  : f'你好，客户端 {client_ip}!',
                        'timestamp': datetime.now().isoformat()
                    }
                    await websocket.send(json.dumps(response))
                    print(f"[{datetime.now().strftime('%H:%M:%S')}] 已向客户端发送问候响应")

                elif data.get('type') == 'broadcast_request':
                    # 广播消息给所有客户端
                    broadcast_msg = {
                        'type'     : 'broadcast',
                        'message'  : data.get('content', '默认广播消息'),
                        'from'     : client_ip,
                        'timestamp': datetime.now().isoformat()
                    }

                    # 向所有连接的客户端发送消息
                    if connected_clients:
                        await asyncio.gather(
                            *[client.send(json.dumps(broadcast_msg)) for client in connected_clients]
                        )
                        print(f"[{datetime.now().strftime('%H:%M:%S')}] 已向 {len(connected_clients)} 个客户端广播消息")

                else:
                    # 默认回应
                    default_response = {
                        'type'            : 'acknowledge',
                        'message'         : '收到你的消息',
                        'original_message': data,
                        'timestamp'       : datetime.now().isoformat()
                    }
                    await websocket.send(json.dumps(default_response))

            except json.JSONDecodeError:
                print(f"[{datetime.now().strftime('%H:%M:%S')}] 收到非JSON格式消息: {message}")
                error_response = {
                    'type'     : 'error',
                    'message'  : '消息必须是JSON格式',
                    'timestamp': datetime.now().isoformat()
                }
                await websocket.send(json.dumps(error_response))

    except websockets.exceptions.ConnectionClosed:
        print(f"[{datetime.now().strftime('%H:%M:%S')}] 客户端 {client_ip} 断开连接")
    finally:
        # 从客户端集合中移除
        connected_clients.remove(websocket)


async def main():
    # 启动WebSocket服务器
    server = await websockets.serve(handle_client, "localhost", 8765)
    print(f"[{datetime.now().strftime('%H:%M:%S')}] WebSocket服务器已启动，监听端口 8765")
    print("按 Ctrl+C 停止服务器")

    # 保持服务器运行
    await server.wait_closed()


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print(f"\n[{datetime.now().strftime('%H:%M:%S')}] 服务器已关闭")
