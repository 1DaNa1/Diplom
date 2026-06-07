from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import create_db_and_tables
from app.routers import progress, quests, texts

# Важливо: імпорт моделей потрібен, щоб SQLAlchemy знав усі таблиці.
from app import models  # noqa: F401
from app.core.config import get_settings

settings = get_settings()

app = FastAPI(
    title=settings.PROJECT_NAME,
    description=(
        "Інтерактивна система ігрового навчання з алгоритмічним "
        "генеруванням контенту для заохочення дітей до читання."
    ),
    version="1.2.1",
)


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def on_startup():
    create_db_and_tables()


@app.get("/")
def root():
    return {
        "message": "ReadQuest AI backend is running",
        "docs": "/docs",
        "version": "1.2.1",
        "features": [
            "quest_generation",
            "openai_generation",
            "algorithmic_fallback",
            "text_library",
            "student_mode",
            "teacher_mode",
            "progress_tracking",
            "result_export",
            "leaderboard",
            "reading_streaks",
            "celebration_effects",
        ],
    }


app.include_router(quests.router)
app.include_router(progress.router)
app.include_router(texts.router)