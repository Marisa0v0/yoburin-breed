from datetime import datetime

from Cryptodome.SelfTest.Protocol.test_KDF import scrypt_Tests
from pydantic import BaseModel, Field, Json


""" LiveRoom """
class _FrameModel(BaseModel, extra="allow"):
    name: str | None = Field(default=None)
    value: str | None = Field(default=None)
    desc: str | None = Field(default=None)


class _PendantsModel(BaseModel, extra="allow"):
    frame: _FrameModel | None = Field(default=None)


class _RoomTypeModel(BaseModel, extra="allow"):
    ...


class _RoomInfoModel(BaseModel, extra="allow"):
    uid: int | None = Field(default=None)
    room_id: int | None = Field(default=None)
    short_id: int | None = Field(default=None)
    title: str | None = Field(default=None)
    cover: str | None = Field(default=None)
    tags: str | None = Field(default=None)
    background: str | None = Field(default=None)
    description: str | None = Field(default=None)
    live_status: int | None = Field(default=None)
    live_start_time: int | None = Field(default=None)
    live_screen_type: int | None = Field(default=None)
    lock_status: int | None = Field(default=None)
    lock_time: int | None = Field(default=None)
    hidden_status: int | None = Field(default=None)
    hidden_time: int | None = Field(default=None)
    area_id: int | None = Field(default=None)
    area_name: str | None = Field(default=None)
    parent_area_id: int | None = Field(default=None)
    parent_area_name: str | None = Field(default=None)
    keyframe: str | None = Field(default=None)
    special_type: int | None = Field(default=None)
    up_session: str | None = Field(default=None)
    pk_status: int | None = Field(default=None)
    is_studio: bool | None = Field(default=None)
    pendants: _PendantsModel | None = Field(default=None)
    on_voice_join: int | None = Field(default=None)
    online: int | None = Field(default=None)
    room_type: _RoomTypeModel | None = Field(default=None)
    sub_session_key: str | None = Field(default=None)
    live_id: int | None = Field(default=None)
    live_id_str: str | None = Field(default=None)
    official_room_id: int | None = Field(default=None)
    official_room_info: str | None = Field(default=None)
    voice_background: str | None = Field(default=None)
    live_model: int | None = Field(default=None)
    live_platform: str | None = Field(default=None)
    radio_background_type: int | None = Field(default=None)


class _OfficialInfoModel(BaseModel, extra="allow"):
    role: int | None = Field(default=None)
    title: str | None = Field(default=None)
    desc: str | None = Field(default=None)
    is_nft: int | None = Field(default=None)
    nft_dmark: str | None = Field(default=None)


class _BaseInfoModel(BaseModel, extra="allow"):
    name: str | None = Field(default=None)
    face: str | None = Field(default=None)
    gender: str | None = Field(default=None)
    official_info: _OfficialInfoModel | None = Field(default=None)


class _LiveInfoModel(BaseModel, extra="allow"):
    level: int | None = Field(default=None)
    level_color: int | None = Field(default=None)
    score: int | None = Field(default=None)
    upgrade_score: int | None = Field(default=None)
    current: list[int] | None = Field(default=None)
    next: list[int] | None = Field(default=None)
    rank: str | None = Field(default=None)


class _RelationInfoModel(BaseModel, extra="allow"):
    attention: int | None = Field(default=None)


class _MedalInfoModel(BaseModel, extra="allow"):
    medal_name: str | None = Field(default=None)
    medal_id: int | None = Field(default=None)
    fansclub: int | None = Field(default=None)


class _GiftInfoModel(BaseModel, extra="allow"):
    price: int | None = Field(default=None)
    price_update_time: int | None = Field(default=None)


class _AnchorInfoModel(BaseModel, extra="allow"):
    base_info: _BaseInfoModel | None = Field(default=None)
    live_info: _LiveInfoModel | None = Field(default=None)
    relation_info: _RelationInfoModel | None = Field(default=None)
    medal_info: _MedalInfoModel | None = Field(default=None)
    gift_info: _GiftInfoModel | None = Field(default=None)


class _NewsInfoModel(BaseModel, extra="allow"):
    uid: int | None = Field(default=None)
    ctime: datetime | None = Field(default=None)
    content: str | None = Field(default=None)


class _RankDBInfoModel(BaseModel, extra="allow"):
    roomid: int | None = Field(default=None)
    rank_desc: str | None = Field(default=None)
    color: str | None = Field(default=None)
    h5_url: str | None = Field(default=None)
    web_url: str | None = Field(default=None)
    timestamp: datetime | None = Field(default=None)


class _AreaRankModel(BaseModel, extra="allow"):
    index: int | None = Field(default=None)
    rank: str | None = Field(default=None)


class _LiveRankModel(BaseModel, extra="allow"):
    rank: str | None = Field(default=None)


class _AreaRankInfoModel(BaseModel, extra="allow"):
    areaRank: _AreaRankModel | None = Field(default=None)
    liveRank: _LiveRankModel | None = Field(default=None)


class _TabInfoListModel(BaseModel, extra="allow"):
    type: str | None = Field(default=None)
    desc: str | None = Field(default=None)
    isFirst: int | None = Field(default=None)
    isEvent: int | None = Field(default=None)
    eventType: str | None = Field(default=None)
    listType: str | None = Field(default=None)
    apiPrefix: str | None = Field(default=None)
    rank_name: str | None = Field(default=None)


class _TabInfoModel(BaseModel, extra="allow"):
    list_: list[_TabInfoListModel] | None = Field(default=None, alias="list")


class _StatusModel(BaseModel, extra="allow"):
    open: int | None = Field(default=None)
    anchor_open: int | None = Field(default=None)
    status: int | None = Field(default=None)
    uid: int | None = Field(default=None)
    user_name: str | None = Field(default=None)
    head_pic: str | None = Field(default=None)
    guard: int | None = Field(default=None)
    start_at: int | None = Field(default=None)
    current_time: datetime | None = Field(default=None)


class _IconsModel(BaseModel, extra="allow"):
    icon_close: str | None = Field(default=None)
    icon_open: str | None = Field(default=None)
    icon_wait: str | None = Field(default=None)
    icon_starting: str | None = Field(default=None)


class _VoiceJoinInfoModel(BaseModel, extra="allow"):
    status: _StatusModel | None = Field(default=None)
    icons: _IconsModel | None = Field(default=None)
    web_share_link: str | None = Field(default=None)


class _AdBannerInfoModel(BaseModel, extra="allow"):
    # data: Json | None = Field(default=None)  # FIXME 不知道是什么
    ...


class _SkinInfoModel(BaseModel, extra="allow"):
    id: int | None = Field(default=None)
    skin_name: str | None = Field(default=None)
    skin_config: str | None = Field(default=None)
    show_text: str | None = Field(default=None)
    skin_url: str | None = Field(default=None)
    start_time: int | None = Field(default=None)
    end_time: int | None = Field(default=None)
    current_time: datetime | None = Field(default=None)


class _SilentRoomInfoModel(BaseModel, extra="allow"):
    type: str | None = Field(default=None)
    level: int | None = Field(default=None)
    second: int | None = Field(default=None)
    expire_time: int | None = Field(default=None)


class _SwitchInfoModel(BaseModel, extra="allow"):
    close_guard: bool | None = Field(default=None)
    close_gift: bool | None = Field(default=None)
    close_online: bool | None = Field(default=None)
    close_danmaku: bool | None = Field(default=None)


class _RoomConfigInfoModel(BaseModel, extra="allow"):
    dm_text: str | None = Field(default=None)


class RoomInfoResponseModel(BaseModel, extra="allow"):
    """ get_room_info() """
    room_info: _RoomInfoModel | None = Field(default=None)
    # anchor_info: _AnchorInfoModel = Field(default=None)
    # news_info: _NewsInfoModel | None = Field(default=None)
    # rankdb_info: _RankDBInfoModel | None = Field(default=None)
    # area_rank_info: _AreaRankInfoModel | None = Field(default=None)
    # battle_rank_entry_info: Json | None = Field(default=None)  # FIXME 不知道是什么
    # tab_info: _TabInfoModel | None = Field(default=None)
    # voice_join_info: _VoiceJoinInfoModel | None = Field(default=None)
    # ad_banner_info: _AdBannerInfoModel | None = Field(default=None)
    # skin_info: _SkinInfoModel | None = Field(default=None)
    # lol_info: Json | None = Field(default=None)  # FIXME 不知道是什么
    # pk_info: Json | None = Field(default=None)  # FIXME 不知道是什么
    # battle_info: Json | None = Field(default=None)  # FIXME 不知道是什么
    # silent_room_info: _SilentRoomInfoModel | None = Field(default=None)
    # switch_info: _SwitchInfoModel | None = Field(default=None)
    # record_switch_info: Json | None = Field(default=None)  # FIXME 不知道是什么
    # room_config_info: _RoomConfigInfoModel | None = Field(default=None)
    # gift_memory_info: Json | None = Field(default=None)
    # new_switch_info: Json | None = Field(default=None)
    # super_chat_info: Json | None = Field(default=None)
    # online_gold_rank_info_v2: Json | None = Field(default=None)  # FIXME 不知道是什么
    # dm_brush_info: Json | None = Field(default=None)
    # dm_emoticon_info: Json | None = Field(default=None)
    # dm_tag_info: Json | None = Field(default=None)
    # topic_info: Json | None = Field(default=None)
    # game_info: Json | None = Field(default=None)
    # watched_show: Json | None = Field(default=None)
    # topic_room_info: Json | None = Field(default=None)
    # show_reserve_status: Json | None = Field(default=None)
    # second_create_info: Json | None = Field(default=None)  # FIXME 不知道是什么
    # play_together_info: Json | None = Field(default=None)  # FIXME 不知道是什么
    # cloud_game_info: Json | None = Field(default=None)
    # like_info_v3: Json | None = Field(default=None)
    # live_play_info: Json | None = Field(default=None)
    # multi_voice: Json | None = Field(default=None)
    # popular_rank_info: Json | None = Field(default=None)
    # new_area_rank_info: Json | None = Field(default=None)
    # gift_star: Json | None = Field(default=None)
    # progress_for_widget: Json | None = Field(default=None)
    # revenue_demotion: Json | None = Field(default=None)
    # revenue_material_md5: Json | None = Field(default=None)  # FIXME 不知道是什么
    # block_info: Json | None = Field(default=None)
    # danmu_extra: Json | None = Field(default=None)
    # video_connection_info: Json | None = Field(default=None)  # FIXME 不知道是什么
    # player_throttle_info: Json | None = Field(default=None)
    # guard_info: Json | None = Field(default=None)
    # hot_rank_info: Json | None = Field(default=None)  # FIXME 不知道是什么
    # room_rank_info: Json | None = Field(default=None)
    # dm_reply: Json | None = Field(default=None)
    # dm_combo: Json | None = Field(default=None)  # FIXME 不知道是什么
    # dm_vote: Json | None = Field(default=None)  # FIXME 不知道是什么
    # location: Json | None = Field(default=None)  # FIXME 不知道是什么
    # interactive_game_tag: Json | None = Field(default=None)
    # video_enhancement: Json | None = Field(default=None)
    # guard_leader: Json | None = Field(default=None)
    # room_anonymous: Json | None = Field(default=None)
    # tab_switches: Json | None = Field(default=None)
    # universal_interact_info: Json | None = Field(default=None)  # FIXME 不知道是什么
    # pk_info_v2: Json | None = Field(default=None)  # FIXME 不知道是什么
    # area_mask_info: Json | None = Field(default=None)
    # xtemplate_config: Json | None = Field(default=None)
    # dm_activity: Json | None = Field(default=None)
    # dm_interaction_ab: Json | None = Field(default=None)
    # guard_intimacy_rank_status: Json | None = Field(default=None)
    # hot_rank_entrance_info: Json | None = Field(default=None)  # FIXME 不知道是什么
    # area_rank_info_v2: Json | None = Field(default=None)
    # transfer_flow_info: Json | None = Field(default=None)  # FIXME 不知道是什么
    # universal_interact_info_v2: Json | None = Field(default=None)  # FIXME 不知道是什么
    # play_together_voiceroom_dispatch: Json | None = Field(default=None)
    # cny: Json | None = Field(default=None)  # FIXME 不知道是什么
    # reenter_room_info: Json | None = Field(default=None)  # FIXME 不知道是什么
    # cny_quiz_guide: Json | None = Field(default=None)
    # fake_device: Json | None = Field(default=None)
    # pure_room_info: Json | None = Field(default=None)
    # hot_rank_info_v3: Json | None = Field(default=None)
    # charm_chat_rank: Json | None = Field(default=None)  # FIXME 不知道是什么
    # program_info: Json | None = Field(default=None)  # FIXME 不知道是什么
    # module_control_infos: Json | None = Field(default=None)
    # collaboration_live_info: Json | None = Field(default=None)  # FIXME 不知道是什么
    # player_watermark: Json | None = Field(default=None)


__all__ = [
    "RoomInfoResponseModel"
]