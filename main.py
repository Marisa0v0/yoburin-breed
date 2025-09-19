import asyncio
import ujson as json

from bilibili_api import Credential
from bilibili_api.live import (
    LiveDanmaku, LiveRoom,
    get_gift_config
)
from websockets.asyncio.client import connect

from python.log import logger
from python.config import settings
from python.models.live import RoomInfoResponseModel

credential = Credential(**settings.bilibili.model_dump())


room_id = 213
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
        receive = await ws_client.recv()


@room.on("VERIFICATION_SUCCESSFUL")
async def _(event: dict):
    """连接B站成功后主动向 Godot 发送消息"""

    """获取所有礼物信息，存至本地"""
    room_info = await LiveRoom(room_display_id=room_id, credential=credential).get_room_info()
    room_info_model = RoomInfoResponseModel.model_validate(room_info)
    area_id = room_info_model.room_info.area_id   # 分区ID
    parent_area_id =  room_info_model.room_info.parent_area_id  # ?
    gifts = await get_gift_config(room_id=area_id, area_id=area_id, area_parent_id=parent_area_id)

    with open("gifts.json", "w", encoding="utf-8") as fp:
        json.dump(gifts['list'], fp, ensure_ascii=False, indent=2)


@room.on("SEND_GIFT")
async def _(event: dict):
    """送礼物"""
    logger.info("收到礼物")
    logger.debug(event)

    uid = event['data']['data']['uid']
    uname = event['data']['data']['uname']
    price = event['data']['data']['price'] # 数值等于人民币*1000，金瓜子*100 （人民币 9.9，数值9900，金瓜子99）
    gname = event['data']['data']['giftName']
    gid = event['data']['data']['giftId']

    data = {
        "uid": uid,
        "user_name": uname,
        "price": price,
        "gname": gname,
        "gid": gid,
    }
    send = {"type": "SEND_GIFT", "message": json.dumps(data, ensure_ascii=False)}
    await send_to_godot(json.dumps(send, ensure_ascii=False))


@room.on("SUPER_CHAT_MESSAGE")
async def _(event: dict):
    """醒目留言"""
    logger.info("收到醒目留言")
    logger.debug(event)

    uid = event['data']['data']['uid']
    uname = event['data']['data']['uinfo']['base']['name']
    price = event['data']['data']['price']  # NOTE 这里数值又等于人民币了
    gname = event['data']['data']['gift']['gift_name']  # 醒目留言
    gid = event['data']['data']['gift']['gift_id']

    data = {
        "uid": uid,
        "user_name": uname,
        "price": price,
        'gname': gname,
        "gid": gid,
    }
    send = {"type": "SUPER_CHAT_MESSAGE", "message": json.dumps(data, ensure_ascii=False)}
    await send_to_godot(json.dumps(send, ensure_ascii=False))


@room.on("GUARD_BUY")
async def _(event: dict):
    """大航海"""
    logger.info("收到大航海")
    logger.debug(event)

    uid = event["data"]['data']["uid"]
    uname = event["data"]['data']["username"]
    price = event["data"]['data']["price"] # 数值等于人民币*1000，金瓜子*100 （人民币 198，数值198000，金瓜子1980）
    gname = event["data"]['data']['gift_name']  # 舰长、提督、总督
    gid = event['data']['data']['gift_id']

    data = {
        "uid": uid,
        "user_name": uname,
        "price": price,
        'gname': gname,
        "gid": gid,
    }
    send = {"type": "GUARD_BUY", "message": json.dumps(data, ensure_ascii=False)}
    await send_to_godot(json.dumps(send, ensure_ascii=False))


async def main():
    await room.connect()


if __name__ == '__main__':
    asyncio.get_event_loop().run_until_complete(main())
    asyncio.get_event_loop().run_forever()