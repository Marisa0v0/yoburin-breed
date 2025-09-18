from pydantic import BaseModel, Field

from datetime import datetime


""" 大航海相关"""
class GuardBuyDataDataModel(BaseModel, extra="allow"):
    uid: int | None = Field(default=None)
    username: str | None = Field(default=None)
    guard_level: int | None = Field(default=None)
    num: int | None = Field(default=None)
    price: int | None = Field(default=None)
    gift_id: int | None = Field(default=None)
    gift_name: str | None = Field(default=None)
    start_time: datetime | None = Field(default=None)
    end_time: datetime | None = Field(default=None)


class GuardBuyDataModel(BaseModel, extra="allow"):
    cmd: str | None = Field(default="GUARD_BUY")
    data: GuardBuyDataDataModel | None = Field(default=None)


class GuardBuyModel(BaseModel, extra="allow"):
    room_display_id: int | None = Field(default=None)
    room_real_id: int | None = Field(default=None)
    type: str | None = Field(default="GUARD_BUY")
    data: GuardBuyDataModel | None = Field(default=None)



""" 弹幕相关 """
""" 送礼物相关 """
class BlindGiftModel(BaseModel, extra="allow"):
    blind_gift_config_id: int | None = Field(default=None)
    from_: int | None = Field(default=None, alias="from")
    gift_action: str | None = Field(default=None)
    gift_tip_price: int | None = Field(default=None)
    original_gift_id: int | None = Field(default=None)
    original_gift_name: str | None = Field(default=None)
    original_gift_price: int | None = Field(default=None)


class SendGiftDataDataBatchComboSendModel(BaseModel, extra="allow"):
    action: str | None = Field(default=None)
    batch_combo_id: str | None = Field(default=None)
    batch_combo_num: int | None = Field(default=None)
    blind_gift: BlindGiftModel | None = Field(default=None)
    gift_id: int | None = Field(default=None)
    gift_name: str | None = Field(default=None)
    gift_num: int | None = Field(default=None)
    send_master: dict | None = Field(default=None)
    uid: int | None = Field(default=None)
    uname: str | None = Field(default=None)


class SendGiftDataDataComboSendModel(BaseModel, extra="allow"):
    action: str | None = Field(default=None)
    combo_id: str | None = Field(default=None)
    combo_num: int | None = Field(default=None)
    gift_id: int | None = Field(default=None)
    gift_name: str | None = Field(default=None)
    gift_num: int | None = Field(default=None)
    send_master: dict | None = Field(default=None)
    uid: int | None = Field(default=None)
    uname: str | None = Field(default=None)


class FaceEffectV2Model(BaseModel, extra="allow"):
    id: int | None = Field(default=None)
    type: int | None = Field(default=None)


class GiftInfoModel(BaseModel, extra="allow"):
    effect_id: int | None = Field(default=None)
    gif: str | None = Field(default=None)
    has_imaged_gift: int | None = Field(default=None)
    img_basic: str | None = Field(default=None)
    webp: str | None = Field(default=None)


class MedalInfoModel(BaseModel, extra="allow"):
    anchor_roomid: int | None = Field(default=None)
    anchor_uname: str | None = Field(default=None)
    guard_level: int | None = Field(default=None)
    icon_id: int | None = Field(default=None)
    is_lighted: int | None = Field(default=None)
    medal_color: int | None = Field(default=None)
    medal_color_border: int | None = Field(default=None)
    medal_color_end: int | None = Field(default=None)
    medal_color_start: int | None = Field(default=None)
    medal_level: int | None = Field(default=None)
    medal_name: str | None = Field(default=None)
    special: str | None = Field(default=None)
    target_id: int | None = Field(default=None)


class UserInfoModel(BaseModel, extra="allow"):
    uid: int | None = Field(default=None)
    uname: str | None = Field(default=None)


class UInfoBaseModel(BaseModel, extra="allow"):
    face: str | None = Field(default=None)
    is_mystery: bool | None = Field(default=None)
    name: str | None = Field(default=None)
    name_color: int | None = Field(default=None)
    name_color_str: str | None = Field(default=None)
    official_info: dict | None = Field(default=None)
    origin_info: dict | None = Field(default=None)
    risk_ctrl_info: dict | None = Field(default=None)


class UInfoModel(BaseModel, extra="allow"):
    base: UInfoBaseModel | None = Field(default=None)
    guard: dict | None = Field(default=None)
    guard_leader: dict | None = Field(default=None)
    medal: dict | None = Field(default=None)
    title: dict | None = Field(default=None)
    uhead_frame: dict | None = Field(default=None)
    uid: int | None = Field(default=None)
    wealth: dict | None = Field(default=None)


class SendGiftDataDataModel(BaseModel, extra="allow"):
    action: str | None = Field(default=None)
    bag_gift: dict | None = Field(default=None)
    batch_combo_id: str | None = Field(default=None)
    batch_combo_send: SendGiftDataDataBatchComboSendModel | None = Field(default=None)
    beatId: str | None = Field(default=None)
    biz_source: str | None = Field(default=None)
    blind_gift: BlindGiftModel | None = Field(default=None)
    broadcast_id: int | None = Field(default=None)
    coin_type: str | None = Field(default=None)
    combo_resources_id: int | None = Field(default=None)
    combo_send: SendGiftDataDataComboSendModel | None = Field(default=None)
    combo_stay_time: int | None = Field(default=None)
    combo_total_coin: int | None = Field(default=None)
    crit_prob: int | None = Field(default=None)
    demarcation: int | None = Field(default=None)
    discount_price: int | None = Field(default=None)
    dmscore: int | None = Field(default=None)
    draw: int | None = Field(default=None)
    effect: int | None = Field(default=None)
    effect_block: int | None = Field(default=None)
    face: str | None = Field(default=None)
    face_effect: dict | None = Field(default=None)
    face_effect_id: int | None = Field(default=None)
    face_effect_type: int | None = Field(default=None)
    face_effect_v2: FaceEffectV2Model | None = Field(default=None)
    float_sc_resource_id: int | None = Field(default=None)
    giftId: int | None = Field(default=None)
    giftName: str | None = Field(default=None)
    giftType: int | None = Field(default=None)
    gift_info: GiftInfoModel | None = Field(default=None)
    gift_tag: list | None = Field(default=None)
    gold: int | None = Field(default=None)
    group_medal: dict | None = Field(default=None)
    guard_level: int | None = Field(default=None)
    is_first: bool | None = Field(default=None)
    is_join_receiver: bool | None = Field(default=None)
    is_naming: bool | None = Field(default=None)
    is_special_batch: int | None = Field(default=None)
    magnification: int | None = Field(default=None)
    medal_info: MedalInfoModel | None = Field(default=None)
    name_color: str | None = Field(default=None)
    num: int | None = Field(default=None)
    original_gift_name: str | None = Field(default=None)
    price: int | None = Field(default=None)
    rcost: int | None = Field(default=None)
    receive_user_info: UserInfoModel | None = Field(default=None)
    receiver_uinfo: UInfoModel | None = Field(default=None)
    remain: int | None = Field(default=None)
    rnd: str | None = Field(default=None)
    send_master: dict | None = Field(default=None)
    sender_uinfo: UInfoModel | None = Field(default=None)
    silver: int | None = Field(default=None)
    super: int | None = Field(default=None)
    super_batch_gift_num: int | None = Field(default=None)
    super_gift_num: int | None = Field(default=None)
    svga_block: int | None = Field(default=None)
    switch: bool | None = Field(default=None)
    tag_image: str | None = Field(default=None)
    tid: str | None = Field(default=None)
    timestamp: datetime | None = Field(default=None)
    top_list: list | None = Field(default=None)
    total_coin: int | None = Field(default=None)
    uid: int | None = Field(default=None)
    uname: str | None = Field(default=None)
    wealth_level: int | None = Field(default=None)


class SendGiftDataModel(BaseModel, extra="allow"):
    class DanmuModel(BaseModel, extra="allow"):
        area: int | None = Field(None)

    cmd: str | None = Field(default="SEND_GIFT")
    danmu: DanmuModel | None = Field(default=None)
    data: SendGiftDataDataModel | None = Field(default=None)
    msg_id: str | None = Field(default=None)
    p_is_ack: bool | None = Field(default=None)
    p_msg_type: int | None = Field(default=None)
    send_time: datetime | None = Field(default=None)


class SendGiftModel(BaseModel, extra="allow"):
    room_display_id: int | None = Field(default=None)
    room_real_id: int | None = Field(default=None)
    type: str | None = Field(default="SEND_GIFT")
    data: SendGiftDataModel | None = Field(default=None)


__all__ = [
    "SendGiftModel",
    "GuardBuyModel"
]


if __name__ == '__main__':
    import json
    from pprint import pprint
    data = """{
  "room_display_id": 1854312761,
  "room_real_id": 1854312761,
  "type": "SEND_GIFT",
  "data": {
    "cmd": "SEND_GIFT",
    "danmu": {
      "area": 0
    },
    "data": {
      "action": "投喂",
      "bag_gift": null,
      "batch_combo_id": "7b45235c-e957-4086-a1d2-3af038c9800a",
      "batch_combo_send": {
        "action": "投喂",
        "batch_combo_id": "7b45235c-e957-4086-a1d2-3af038c9800a",
        "batch_combo_num": 1,
        "blind_gift": {
          "blind_gift_config_id": 67,
          "from": 0,
          "gift_action": "爆出",
          "gift_tip_price": 2500,
          "original_gift_id": 32649,
          "original_gift_name": "星月盲盒",
          "original_gift_price": 5000
        },
        "gift_id": 32694,
        "gift_name": "星与月",
        "gift_num": 1,
        "send_master": null,
        "uid": 3493081087215880,
        "uname": "qslbt"
      },
      "beatId": "",
      "biz_source": "live",
      "blind_gift": {
        "blind_gift_config_id": 67,
        "from": 0,
        "gift_action": "爆出",
        "gift_tip_price": 2500,
        "original_gift_id": 32649,
        "original_gift_name": "星月盲盒",
        "original_gift_price": 5000
      },
      "broadcast_id": 0,
      "coin_type": "gold",
      "combo_resources_id": 1,
      "combo_send": {
        "action": "投喂",
        "combo_id": "80c520db-6769-434b-96f2-a66dc3d0126d",
        "combo_num": 1,
        "gift_id": 32694,
        "gift_name": "星与月",
        "gift_num": 1,
        "send_master": null,
        "uid": 3493081087215880,
        "uname": "qslbt"
      },
      "combo_stay_time": 5,
      "combo_total_coin": 2500,
      "crit_prob": 0,
      "demarcation": 2,
      "discount_price": 2500,
      "dmscore": 224,
      "draw": 0,
      "effect": 0,
      "effect_block": 0,
      "face": "https://i1.hdslb.com/bfs/face/c1699f57e72ef62a603a9745cc731babbab70882.jpg",
      "face_effect": {},
      "face_effect_id": 0,
      "face_effect_type": 0,
      "face_effect_v2": {
        "id": 0,
        "type": 0
      },
      "float_sc_resource_id": 0,
      "giftId": 32694,
      "giftName": "星与月",
      "giftType": 0,
      "gift_info": {
        "effect_id": 0,
        "gif": "https://i0.hdslb.com/bfs/live/89604a6696b6646c4d4508323e92ae04561650ad.gif",
        "has_imaged_gift": 0,
        "img_basic": "https://s1.hdslb.com/bfs/live/142bb568ea6f90af22a48945f47514d6151d0ac3.png",
        "webp": "https://i0.hdslb.com/bfs/live/d5c3d757f89efff2614fdbc03dc37a4e86549f19.webp"
      },
      "gift_tag": [],
      "gold": 0,
      "group_medal": null,
      "guard_level": 0,
      "is_first": true,
      "is_join_receiver": false,
      "is_naming": false,
      "is_special_batch": 0,
      "magnification": 1,
      "medal_info": {
        "anchor_roomid": 0,
        "anchor_uname": "",
        "guard_level": 0,
        "icon_id": 0,
        "is_lighted": 0,
        "medal_color": 6126494,
        "medal_color_border": 12632256,
        "medal_color_end": 12632256,
        "medal_color_start": 12632256,
        "medal_level": 6,
        "medal_name": "蜂群们",
        "special": "",
        "target_id": 3546729368520811
      },
      "name_color": "",
      "num": 1,
      "original_gift_name": "",
      "price": 2500,
      "rcost": 12854,
      "receive_user_info": {
        "uid": 337314027,
        "uname": "优布林yobu"
      },
      "receiver_uinfo": {
        "base": {
          "face": "https://i0.hdslb.com/bfs/face/8ec208af205a1b420485f5ed042537e1380e0c75.jpg",
          "is_mystery": false,
          "name": "优布林yobu",
          "name_color": 0,
          "name_color_str": "",
          "official_info": {
            "desc": "",
            "role": 0,
            "title": "",
            "type": -1
          },
          "origin_info": {
            "face": "https://i0.hdslb.com/bfs/face/8ec208af205a1b420485f5ed042537e1380e0c75.jpg",
            "name": "优布林yobu"
          },
          "risk_ctrl_info": null
        },
        "guard": null,
        "guard_leader": null,
        "medal": null,
        "title": null,
        "uhead_frame": null,
        "uid": 337314027,
        "wealth": null
      },
      "remain": 0,
      "rnd": "4676710408713717248",
      "send_master": null,
      "sender_uinfo": {
        "base": {
          "face": "https://i1.hdslb.com/bfs/face/c1699f57e72ef62a603a9745cc731babbab70882.jpg",
          "is_mystery": false,
          "name": "qslbt",
          "name_color": 0,
          "name_color_str": "",
          "official_info": {
            "desc": "",
            "role": 0,
            "title": "",
            "type": -1
          },
          "origin_info": {
            "face": "https://i1.hdslb.com/bfs/face/c1699f57e72ef62a603a9745cc731babbab70882.jpg",
            "name": "qslbt"
          },
          "risk_ctrl_info": null
        },
        "guard": null,
        "guard_leader": null,
        "medal": {
          "color": 6126494,
          "color_border": 6126494,
          "color_end": 6126494,
          "color_start": 6126494,
          "guard_icon": "",
          "guard_level": 0,
          "honor_icon": "",
          "id": 0,
          "is_light": 1,
          "level": 8,
          "name": "u布林",
          "ruid": 337314027,
          "score": 6900,
          "typ": 0,
          "user_receive_count": 0,
          "v2_medal_color_border": "#5866C799",
          "v2_medal_color_end": "#5866C799",
          "v2_medal_color_level": "#000B7099",
          "v2_medal_color_start": "#5866C799",
          "v2_medal_color_text": "#FFFFFFFF"
        },
        "title": null,
        "uhead_frame": null,
        "uid": 3493081087215880,
        "wealth": null
      },
      "silver": 0,
      "super": 0,
      "super_batch_gift_num": 1,
      "super_gift_num": 1,
      "svga_block": 0,
      "switch": true,
      "tag_image": "",
      "tid": "4676710408713717248",
      "timestamp": 1755959081,
      "top_list": null,
      "total_coin": 5000,
      "uid": 3493081087215880,
      "uname": "qslbt",
      "wealth_level": 6
    },
    "msg_id": "35339738337516545:1000:1000",
    "p_is_ack": true,
    "p_msg_type": 1,
    "send_time": 1755959081602
  }
}"""
    model = SendGiftModel.model_validate(json.loads(data))
    pprint(model.model_dump())
