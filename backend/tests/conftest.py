import os
import sys
from pathlib import Path

import psycopg
import pytest
from fastapi.testclient import TestClient
from psycopg import sql
from sqlalchemy import create_engine
from sqlalchemy.engine import make_url
from sqlalchemy.orm import sessionmaker

# Коренева папка backend:
# C:\Users\v0303\PycharmProjects\ReadQuestAI\backend
BACKEND_DIR = Path(__file__).resolve().parents[1]

# Додаємо backend у початок sys.path, щоб імпортувався саме backend/app,
# а не сторонній пакет app із site-packages.
sys.path.insert(0, str(BACKEND_DIR))

# Якщо Python уже випадково підхопив чужий пакет app,
# видаляємо його з кешу імпортів.
if "app" in sys.modules:
    del sys.modules["app"]

TEST_DATABASE_URL = os.getenv(
    "TEST_DATABASE_URL",
    "postgresql+psycopg://postgres:postgres@127.0.0.1:5433/readquest_test_db",
)

# Важливо задати змінні ДО імпорту app.database/app.main,
# бо налаштування читаються під час імпорту модулів.
os.environ["DATABASE_URL"] = TEST_DATABASE_URL
os.environ["ALLOW_OPENAI"] = "false"
os.environ["OPENAI_API_KEY"] = ""
os.environ["OPENAI_MODEL"] = "gpt-4.1-mini"
os.environ["QUEST_QUESTION_COUNT"] = "5"

from app import models  # noqa: E402,F401
from app.database import Base, get_db  # noqa: E402
from app.main import app  # noqa: E402


def _to_psycopg_url(sqlalchemy_url: str) -> str:
    """
    Перетворює SQLAlchemy URL:
    postgresql+psycopg://...
    у формат, який напряму розуміє psycopg:
    postgresql://...
    """

    return sqlalchemy_url.replace("postgresql+psycopg://", "postgresql://")


def create_test_database_if_not_exists() -> None:
    """
    Створює окрему тестову БД readquest_test_db, якщо її ще немає.
    """

    url = make_url(TEST_DATABASE_URL)
    test_db_name = url.database

    if not test_db_name:
        raise RuntimeError("TEST_DATABASE_URL must contain database name")

    admin_url = url.set(database="postgres")

    # Важливо:
    # str(admin_url) може приховати пароль як ***.
    # Тому потрібно використовувати render_as_string(hide_password=False).
    admin_sqlalchemy_url = admin_url.render_as_string(hide_password=False)
    admin_psycopg_url = _to_psycopg_url(admin_sqlalchemy_url)

    with psycopg.connect(admin_psycopg_url, autocommit=True) as connection:
        exists = connection.execute(
            "SELECT 1 FROM pg_database WHERE datname = %s",
            (test_db_name,),
        ).fetchone()

        if exists is None:
            connection.execute(
                sql.SQL("CREATE DATABASE {}").format(
                    sql.Identifier(test_db_name),
                )
            )


create_test_database_if_not_exists()

test_engine = create_engine(
    TEST_DATABASE_URL,
    pool_pre_ping=True,
)

TestingSessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=test_engine,
)


@pytest.fixture(scope="session", autouse=True)
def prepare_database():
    """
    Готує тестову базу перед запуском тестів і очищує її після завершення.
    """

    Base.metadata.drop_all(bind=test_engine)
    Base.metadata.create_all(bind=test_engine)

    yield

    Base.metadata.drop_all(bind=test_engine)
    test_engine.dispose()


@pytest.fixture()
def db_session():
    """
    Дає окрему чисту сесію БД для кожного тесту.
    """

    Base.metadata.drop_all(bind=test_engine)
    Base.metadata.create_all(bind=test_engine)

    db = TestingSessionLocal()

    try:
        yield db
    finally:
        db.close()


@pytest.fixture()
def client(db_session):
    """
    FastAPI TestClient з підміною dependency get_db.
    Усі API-запити в тестах працюють із тестовою БД.
    """

    def override_get_db():
        yield db_session

    app.dependency_overrides[get_db] = override_get_db

    with TestClient(app) as test_client:
        yield test_client

    app.dependency_overrides.clear()


@pytest.fixture()
def long_text() -> str:
    """
    Текст довший за 200 символів, щоб проходити Pydantic validation.
    """

    return (
        "Маленька дівчинка Марійка дуже любила читати книжки про далекі країни. "
        "Одного вечора вона знайшла у старій бібліотеці книгу з золотим ключиком "
        "на обкладинці. Коли Марійка відкрила першу сторінку, літери почали "
        "світитися, а перед нею з'явилася карта чарівного лісу. Щоб пройти "
        "стежкою, потрібно було уважно читати кожен розділ і відповідати на "
        "питання мудрої сови. Марійка зрозуміла, що читання може бути не лише "
        "корисним, а й захопливим."
    )


@pytest.fixture()
def quest_payload(long_text):
    return {
        "user_name": "Test Reader",
        "grade_level": 5,
        "title": "Чарівна бібліотека",
        "author": "Test Author",
        "text": long_text,
        "target_age": 10,
        "pages_read": 4,
        "difficulty": "medium",
        "question_count": 5,
        "generation_mode": "algorithm",
    }