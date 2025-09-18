import asyncio
import ujson as json

from bilibili_api import Credential
from bilibili_api.live import (
    LiveRoom, get_gift_config
)

from python.config import settings
from python.models.gift import GiftModel
from python.models.live import RoomInfoResponseModel


ROOM_ID = 1854312761


async def main():
    credential = Credential(**settings.bilibili.model_dump())

    room = LiveRoom(room_display_id=ROOM_ID, credential=credential)
    room_info = await room.get_room_info()
    room_info_model = RoomInfoResponseModel.model_validate(room_info)
    title = room_info_model.room_info.title  # 直播标题
    cover = room_info_model.room_info.cover  # 直播封面

    area_id = room_info_model.room_info.area_id   # 分区ID
    parent_area_id =  room_info_model.room_info.parent_area_id  # ?

    with open("room_info.json", "w", encoding="utf-8") as fp:
        json.dump(room_info, fp, ensure_ascii=False, indent=2)

    gifts = await get_gift_config(room_id=ROOM_ID, area_id=area_id, area_parent_id=parent_area_id)
    gift_models = [GiftModel.model_validate(_) for _ in gifts['list']]

    with open("gifts.json", "w", encoding="utf-8") as fp:
        json.dump(gifts, fp, ensure_ascii=False, indent=2)


if __name__ == '__main__':
    asyncio.run(main())