from pathlib import Path

from dotenv import load_dotenv
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

load_dotenv()


class ProjectSettings(BaseSettings):
    """About this project"""
    model_config = SettingsConfigDict(env_prefix="PROJECT_")

    name: str = Field(default="Marisa-Bilibili-plugin")
    version: str = Field(default="0.0.1")
    username: str = Field(default="KirisameMarisa")
    email: str = Field(default="anonymous@email.com")
    log_level: str = Field(default="INFO")
    log_format: str = Field(
        default="<g>{time:HH:mm:ss}</g> | [<lvl>{level:^7}</lvl>] | {extra[project_name]}{message:<35}"
    )

    live_room_id: int = Field(default=1854312761)

    @property
    def user_agent(self) -> str:
        return (
            f"{self.username}/"
            f"{self.name}/"
            f"{self.version} "
            f"({self.email})"
        )


class FilepathSettings(BaseSettings):
    """About files / directories"""
    model_config = SettingsConfigDict(env_prefix="PATH_")

    root: Path = Field(default=Path(__file__).parent.parent)
    data: Path = Field(default=Path("data"))
    log: Path = Field(default=Path("data/log"))
    tmp: Path = Field(default=Path("data/tmp"))


class BilibiliSettings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix='bilibili_')
    sessdata: str = Field(default="")
    bili_jct: str = Field(default="")
    buvid3: str = Field(default="")
    dedeuserid: str = Field(default="")


class Settings(BaseSettings):
    """Main settings"""
    bilibili: BilibiliSettings = BilibiliSettings()

    project: ProjectSettings = ProjectSettings()
    filepath: FilepathSettings = FilepathSettings()


settings = Settings()
DIR_LOG = settings.filepath.root / settings.filepath.log


__all__ = [
    "Settings",
    "settings",

    "DIR_LOG",
]


if __name__ == '__main__':
    print(settings.model_dump())
