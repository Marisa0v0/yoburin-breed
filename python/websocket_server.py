"""向 Godot 客户端推送消息"""
import ujson as json
import asyncio
import websockets
from python.log import logger
from pydantic import BaseModel, Field


# 所有连接到服务端的客户端
CLIENTS: set[websockets.ServerConnection] = set()


class MessageModel(BaseModel, extra="allow"):
    """收发信息"""
    type: str = Field(default="test", description="信息类型")
    message: str = Field(default="hello", description="信息本体")
    data: dict | None = Field(default=None, description="额外信息")


async def handler(connection: websockets.ServerConnection):
    """处理函数"""
    CLIENTS.add(connection)
    client_address = connection.remote_address[0]
    logger.success(f"客户端 {client_address} 已连接")

    try:
        # 解析客户端信息
        async for message in connection:
            try:
                ...
            except json.JSONDecodeError as e:
                logger.error(f"接收到非 JSON 格式消息: {message}")
                await connection.send(json.dumps({"type": "error", "message": "消息必须为JSON格式"}))

    except websockets.exceptions.ConnectionClosed as e:
        logger.warning(f"客户端 {client_address} 已断开连接")
    finally:
        CLIENTS.remove(connection)


async def run_server():
    server: websockets.Server = await websockets.serve(..., "localhost", 8765)
    logger.success(f"WebSocket 服务器已启动，监听端口 8765")

    # 持久化运行
    await server.wait_closed()


if __name__ == '__main__':
    asyncio.run(run_server())
