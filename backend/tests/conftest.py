import os
import sys
from pathlib import Path
from typing import Any
from uuid import uuid4

import psycopg
import pytest
from fastapi.testclient import TestClient
from psycopg import sql
from sqlalchemy import create_engine
from sqlalchemy.engine import make_url
from sqlalchemy.orm import Session, sessionmaker

# Файл розміщується у backend/tests/conftest.py.
# Тому коренева папка backend знаходиться на один рівень вище.
BACKEND_DIR = Path(__file__).resolve().parents[1]

# Гарантуємо, що під час тестів імпортується саме локальний пакет backend/app.
sys.path.insert(0, str(BACKEND_DIR))

# Якщо в кеші імпортів уже є сторонній пакет app, видаляємо його.
if "app" in sys.modules:
    del sys.modules["app"]

TEST_DATABASE_URL = os.getenv(
    "TEST_DATABASE_URL",
    "postgresql+psycopg://postgres:postgres@127.0.0.1:5433/readquest_test_db",
)

# Змінні середовища потрібно встановити ДО імпорту app.database/app.main.
os.environ["PROJECT_NAME"] = "ReadQuest AI Test"
os.environ["DATABASE_URL"] = TEST_DATABASE_URL
os.environ["ALLOW_OPENAI"] = "false"
os.environ["OPENAI_API_KEY"] = ""
os.environ["OPENAI_MODEL"] = "gpt-4o"
os.environ["QUEST_QUESTION_COUNT"] = "5"

from app import models  # noqa: E402,F401
from app.database import Base, get_db  # noqa: E402
from app.main import app  # noqa: E402
from app.models import Question  # noqa: E402


def _to_psycopg_url(sqlalchemy_url: str) -> str:
    return sqlalchemy_url.replace("postgresql+psycopg://", "postgresql://")


def create_test_database_if_not_exists() -> None:
    """
    Створює окрему тестову БД, якщо її ще немає.
    Для запуску потрібен PostgreSQL із docker-compose проєкту.
    """

    url = make_url(TEST_DATABASE_URL)
    test_db_name = url.database

    if not test_db_name:
        raise RuntimeError("TEST_DATABASE_URL must contain database name")

    admin_url = url.set(database="postgres")
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
    Base.metadata.drop_all(bind=test_engine)
    Base.metadata.create_all(bind=test_engine)

    yield

    Base.metadata.drop_all(bind=test_engine)
    test_engine.dispose()


@pytest.fixture()
def db_session():
    """
    Для кожного тесту створюється чиста схема БД.
    Це робить тести незалежними один від одного.
    """

    Base.metadata.drop_all(bind=test_engine)
    Base.metadata.create_all(bind=test_engine)

    db = TestingSessionLocal()

    try:
        yield db
    finally:
        db.close()


@pytest.fixture()
def client(db_session: Session):
    """
    FastAPI TestClient із підміною dependency get_db.
    Усі API-запити працюють із тестовою БД.
    """

    def override_get_db():
        yield db_session

    app.dependency_overrides[get_db] = override_get_db

    with TestClient(app) as test_client:
        yield test_client

    app.dependency_overrides.clear()


@pytest.fixture()
def long_text() -> str:
    return (
        "Маленька дівчинка Марійка дуже любила читати книжки про далекі країни. "
        "Одного вечора вона знайшла у старій бібліотеці книгу з золотим ключиком "
        "на обкладинці. Коли Марійка відкрила першу сторінку, літери почали "
        "світитися, а перед нею з'явилася карта чарівного лісу. Щоб пройти "
        "стежкою, потрібно було уважно читати кожен розділ і відповідати на "
        "питання мудрої сови. Марійка зрозуміла, що читання може бути не лише "
        "корисним, а й захопливим. Вона пройшла перше випробування, отримала "
        "чарівну монету і пообіцяла повертатися до бібліотеки щодня."
    )


@pytest.fixture()
def quest_payload(long_text: str) -> dict[str, Any]:
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


@pytest.fixture()
def make_quest_payload(long_text: str):
    def factory(**overrides: Any) -> dict[str, Any]:
        payload = {
            "user_name": f"Reader {uuid4().hex[:8]}",
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
        payload.update(overrides)
        return payload

    return factory


@pytest.fixture()
def create_completed_quest(client: TestClient, db_session: Session):
    """
    Створює квест і надсилає відповіді.
    correct_count визначає, скільки перших відповідей буде правильними.
    """

    def factory(
        payload: dict[str, Any],
        correct_count: int | None = None,
    ) -> dict[str, Any]:
        generate_response = client.post(
            "/api/quests/generate",
            json=payload,
        )
        assert generate_response.status_code == 200, generate_response.text

        quest = generate_response.json()
        quest_id = quest["id"]
        user_id = quest["user_id"]

        questions = (
            db_session.query(Question)
            .filter(Question.quest_id == quest_id)
            .order_by(Question.order_number)
            .all()
        )

        if correct_count is None:
            correct_count = len(questions)

        answers = []
        for index, question in enumerate(questions):
            selected_answer = (
                question.correct_answer
                if index < correct_count
                else "Неправильна відповідь для тесту"
            )
            answers.append(
                {
                    "question_id": question.id,
                    "selected_answer": selected_answer,
                }
            )

        submit_response = client.post(
            f"/api/quests/{quest_id}/submit",
            json={
                "user_id": user_id,
                "answers": answers,
            },
        )
        assert submit_response.status_code == 200, submit_response.text

        return {
            "quest": quest,
            "result": submit_response.json(),
            "questions": questions,
        }

    return factory
