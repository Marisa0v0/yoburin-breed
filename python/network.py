import asyncio

from bilibili_api import Credential
from bilibili_api.live import LiveDanmaku
from websockets.asyncio.client import connect as ws_connect

from python.model import SendGiftModel
from python.log import logger
from python.config import settings

credential = Credential(**settings.bilibili.model_dump())


room_id = 23256987
room = LiveDanmaku(
    room_display_id=room_id,
    credential=credential,
)
logger.info(f"监视直播间：{room_id}")
GODOT_URL = "ws://127.0.0.1:52525"


async def send_to_godot(message: str):
    async with ws_connect(GODOT_URL) as ws_client:
        await ws_client.send(message)
        receive = await ws_client.recv()
        logger.info(f"收到返信：{receive}")


@room.on("DANMU_MSG")
async def _(event: dict):
    """发弹幕"""
    logger.info("收到弹幕")
    logger.debug(event)

    send = f"uid: {event['data']['info'][2][0]}, msg: {event['data']['info'][1]}"
    logger.info(send)
    await send_to_godot(send)


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

    send = f"sender: {sender_name}({sender_uid}), gift: {gift_name}, price: {price}"
    logger.info(send)
    await send_to_godot(send)


async def main():
    await room.connect()


if __name__ == '__main__':
    asyncio.get_event_loop().run_until_complete(main())
    asyncio.get_event_loop().run_forever()