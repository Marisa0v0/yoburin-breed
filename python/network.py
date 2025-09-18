import asyncio
import ujson as json

from bilibili_api import Credential
from bilibili_api.live import (
    LiveDanmaku, LiveRoom,
    get_gift_config
)
from websockets.asyncio.client import connect

from python.model import SendGiftModel
from python.log import logger
from python.config import settings
from python.models.godot import GodotReceptionModel, ReceptionType
from python.models.live import RoomInfoResponseModel
from python.models.gift import GiftModel

credential = Credential(**settings.bilibili.model_dump())


room_id = 1854312761
room = LiveDanmaku(
    room_display_id=room_id,
    credential=credential,
)
logger.info(f"监视直播间：{room_id}")
GODOT_URL = "ws://127.0.0.1:52525"


async def send_to_godot(message: str):
    logger.info(f"向 Godot 发送消息: {message}")
    async with connect(GODOT_URL) as ws_client:
        # FIXME 目前没搞明白机制，必须godot向我发送信息后才能收到我的信息
        # FIXME 所以先发送一个空包，收到回复后再发送真正的信息
        await ws_client.send("", text=True)
        receive = await ws_client.recv()
        logger.info(f"收到 Godot 返信：{receive}")
        await ws_client.send(message, text=True)


@room.on("VERIFICATION_SUCCESSFUL")
async def _(event: dict):
    """连接B站成功后主动向 Godot 发送消息"""
    # send = {"type": "VERIFICATION_SUCCESSFUL", "message": "hello godot"}
    # await send_to_godot(json.dumps(send, ensure_ascii=False))

    """获取所有礼物信息，存至本地"""
    room_info = await LiveRoom(room_display_id=room_id, credential=credential).get_room_info()
    room_info_model = RoomInfoResponseModel.model_validate(room_info)
    area_id = room_info_model.room_info.area_id   # 分区ID
    parent_area_id =  room_info_model.room_info.parent_area_id  # ?
    gifts = await get_gift_config(room_id=area_id, area_id=area_id, area_parent_id=parent_area_id)

    with open("gifts.json", "w", encoding="utf-8") as fp:
        json.dump(gifts['list'], fp, ensure_ascii=False, indent=2)

    gift_models = [GiftModel.model_validate(_) for _ in gifts['list']]


@room.on("PREPARING")
async def _(event: dict):
    """直播准备中"""
    logger.info("直播准备中")
    logger.debug(event)

    # message = f"uid: {event['data']['info'][2][0]}, msg: {event['data']['info'][1]}"
    # send = {"type": "DANMU_MSG", "message": message}
    # logger.info(message)
    # await send_to_godot(json.dumps(send, ensure_ascii=False))


@room.on("LIVE")
async def _(event: dict):
    """直播开始"""
    logger.info("直播开始")
    logger.debug(event)

    # message = f"uid: {event['data']['info'][2][0]}, msg: {event['data']['info'][1]}"
    # send = {"type": "DANMU_MSG", "message": message}
    # logger.info(message)
    # await send_to_godot(json.dumps(send, ensure_ascii=False))



@room.on("DANMU_MSG")
async def _(event: dict):
    """发弹幕"""
    logger.info("收到弹幕")
    logger.debug(event)

    message = f"uid: {event['data']['info'][2][0]}, msg: {event['data']['info'][1]}"
    send = {"type": "DANMU_MSG", "message": message}
    logger.info(message)
    await send_to_godot(json.dumps(send, ensure_ascii=False))


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

    message = f"sender: {sender_name}({sender_uid}), gift: {gift_name}, price: {price}"
    logger.info(message)
    send = {"type": "SEND_GIFT", "message": message}
    await send_to_godot(send)


async def main():
    await room.connect()


if __name__ == '__main__':
    asyncio.get_event_loop().run_until_complete(main())
    asyncio.get_event_loop().run_forever()