"""从 Godot 收到的信息"""
from enum import Enum, auto
from pydantic import BaseModel, Field


class ReceptionType(Enum):
    """从 Godot 收到的信息类型"""
    """获取所有礼物信息"""
    GetAllGiftsData = auto()

    """获取给定ID礼物信息"""
    GetGiftData = auto()


class GodotReceptionModel(BaseModel, extra="allow"):
    type: str | None = Field(default=None)


__all__ = [
    "GodotReceptionModel",
    "ReceptionType",
]