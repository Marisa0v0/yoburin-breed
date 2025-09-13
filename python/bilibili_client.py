"""接收B站直播间推送的消息"""
import asyncio

from bilibili_api import Credential, sync
from bilibili_api.live import LiveDanmaku

from pathlib import Path

from python.model import SendGiftModel
from python.log import logger
from python.config import settings

from python.websocket_server import run_server

credential = Credential(**settings.bilibili.model_dump())


room_id = 22014628
room = LiveDanmaku(
    room_display_id=room_id,
    credential=credential,
)
logger.info(f"监视直播间：{room_id}")

@room.on("DANMU_MSG")
async def _(event: dict):
    """发弹幕"""
    ...
    # logger.info("收到弹幕")
    # logger.debug(event)
    # logger.info(f"uid: {event['data']['info'][2][0]}")
    # logger.info(f"msg: {event['data']['info'][1]}")


@room.on("SEND_GIFT")
async def _(event: dict):
    """送礼物"""
    model = SendGiftModel.model_validate(event)
    data = model.data.data

    gift_name = data.giftName   # 礼物名
    price = data.total_coin     # 礼物花费金瓜子 x 100
    sender_name = data.uname    # 送礼人昵称
    sender_uid = data.uid       # 送礼人 UID

    logger.info("收到礼物")
    logger.debug(event)
    # logger.info(f"礼物: {gift_name}")
    # logger.info(f"价格: {price}")
    # logger.info(f"发送: {sender_name}({sender_uid})")


@room.on("COMBO_SEND")
async def _(event: dict):
    """礼物连击"""
    logger.info("收到礼物连击")
    logger.debug(event)


@room.on("GUARD_BUY")
async def _(event: dict):
    """续费大航海"""
    logger.info("续费大航海")
    logger.debug(event)


@room.on("SUPER_CHAT_MESSAGE")
async def _(event: dict):
    """醒目留言"""
    logger.info("收到醒目留言")
    logger.debug(event)


@room.on("SUPER_CHAT_MESSAGE_JPN")
async def _(event: dict):
    """醒目留言 带日语翻译？"""
    logger.info("收到醒目留言 - 日翻")
    logger.debug(event)


async def main():
    await run_server()
    await room.connect()


if __name__ == '__main__':
    asyncio.get_event_loop().run_until_complete(run_server())
    asyncio.get_event_loop().run_until_complete(room.connect())
    asyncio.get_event_loop().run_forever()