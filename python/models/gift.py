from datetime import datetime

from Cryptodome.SelfTest.Protocol.test_KDF import scrypt_Tests
from pydantic import BaseModel, Field, Json


""" get_gift_config """
class _CountMapElementModel(BaseModel, extra="allow"):
    num: int | None = Field(default=None)
    text: str | None = Field(default=None)
    desc: str | None = Field(default=None)
    web_svga: str | None = Field(default=None)
    vertical_svga: str | None = Field(default=None)
    horizontal_svga: str | None = Field(default=None)
    special_color: str | None = Field(default=None)
    effect_id: int | None = Field(default=None)


class _WebLightDarkModel(BaseModel, extra="allow"):
    corner_mark: str | None = Field(default=None)
    corner_background: str | None = Field(default=None)
    corner_mark_color: str | None = Field(default=None)
    corner_color_bg: str | None = Field(default=None)


class GiftModel(BaseModel, extra="allow"):
    id: int | None = Field(default=None)
    name: str | None = Field(default=None)
    price: int | None = Field(default=None)
    type: int | None = Field(default=None)
    coin_type: str | None = Field(default=None)
    bag_gift: int | None = Field(default=None)
    effect: int | None = Field(default=None)
    corner_mark: str | None = Field(default=None)
    corner_background: str | None = Field(default=None)
    broadcast: int | None = Field(default=None)
    draw: int | None = Field(default=None)
    stay_time: int | None = Field(default=None)
    animation_frame_num: int | None = Field(default=None)
    desc: str | None = Field(default=None)
    rule: str | None = Field(default=None)
    rights: str | None = Field(default=None)
    privilege_required: int | None = Field(default=None)
    count_map: list[_CountMapElementModel] | None = Field(default=None)
    img_basic: str | None = Field(default=None)
    img_dynamic: str | None = Field(default=None)
    frame_animation: str | None = Field(default=None)
    gif: str | None = Field(default=None)
    webp: str | None = Field(default=None)
    full_sc_web: str | None = Field(default=None)
    full_sc_horizontal: str | None = Field(default=None)
    full_sc_vertical: str | None = Field(default=None)
    full_sc_horizontal_svga: str | None = Field(default=None)
    full_sc_vertical_svga: str | None = Field(default=None)
    bullet_head: str | None = Field(default=None)
    bullet_tail: str | None = Field(default=None)
    limit_interval: int | None = Field(default=None)
    bind_ruid: int | None = Field(default=None)
    bind_roomid: int | None = Field(default=None)
    gift_type: int | None = Field(default=None)
    combo_resources_id: int | None = Field(default=None)
    max_send_limit: int | None = Field(default=None)
    weight: int | None = Field(default=None)
    goods_id: int | None = Field(default=None)
    has_imaged_gift: int | None = Field(default=None)
    left_corner_text: str | None = Field(default=None)
    left_corner_background: str | None = Field(default=None)
    # gift_banner: Json | None = Field(default=None)  # FIXME 不知道是什么
    diy_count_map: int | None = Field(default=None)
    effect_id: int | None = Field(default=None)
    first_tips: str | None = Field(default=None)
    gift_attrs: list[int] | None = Field(default=None)
    corner_mark_color: str | None = Field(default=None)
    corner_color_bg: str | None = Field(default=None)
    web_light: _WebLightDarkModel | None = Field(default=None)
    web_dark: _WebLightDarkModel | None = Field(default=None)


__all__ = [
    "GiftModel",
]