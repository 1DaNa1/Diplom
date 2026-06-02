from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Головні налаштування проєкту.
    Дані беруться з .env, щоб не зберігати ключі API прямо в коді.
    """

    PROJECT_NAME: str = "ReadQuest AI"
    DATABASE_URL: str = "postgresql+psycopg://postgres:postgres@localhost:5432/readquest_db"

    OPENAI_API_KEY: str | None = None
    OPENAI_MODEL: str = "gpt-5.5"
    ALLOW_OPENAI: bool = True

    QUEST_QUESTION_COUNT: int = 5

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()