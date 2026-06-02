from datetime import datetime

from sqlalchemy import (
    Boolean,
    DateTime,
    ForeignKey,
    Integer,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    username: Mapped[str] = mapped_column(String(80), unique=True, index=True)
    grade_level: Mapped[int] = mapped_column(Integer, default=5)

    total_xp: Mapped[int] = mapped_column(Integer, default=0)
    coins: Mapped[int] = mapped_column(Integer, default=0)

    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    quests = relationship("Quest", back_populates="user")
    cosmetics = relationship(
        "UserCosmetic",
        back_populates="user",
        cascade="all, delete-orphan",
    )


class ReadingText(Base):
    __tablename__ = "reading_texts"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)

    title: Mapped[str] = mapped_column(String(200), index=True)
    author: Mapped[str | None] = mapped_column(String(120), nullable=True)
    content: Mapped[str] = mapped_column(Text)

    target_age: Mapped[int] = mapped_column(Integer, default=10)
    pages_read: Mapped[int] = mapped_column(Integer, default=1)

    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    quests = relationship("Quest", back_populates="reading_text")


class Quest(Base):
    __tablename__ = "quests"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)

    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    reading_text_id: Mapped[int] = mapped_column(ForeignKey("reading_texts.id"))

    title: Mapped[str] = mapped_column(String(200))
    scenario: Mapped[str] = mapped_column(Text)
    difficulty: Mapped[str] = mapped_column(String(30), default="medium")

    generated_by: Mapped[str] = mapped_column(String(40), default="algorithm")
    status: Mapped[str] = mapped_column(String(40), default="active")

    xp_reward: Mapped[int] = mapped_column(Integer, default=50)
    coins_reward: Mapped[int] = mapped_column(Integer, default=10)

    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="quests")
    reading_text = relationship("ReadingText", back_populates="quests")
    questions = relationship(
        "Question",
        back_populates="quest",
        cascade="all, delete-orphan",
        order_by="Question.order_number",
    )


class Question(Base):
    __tablename__ = "questions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    quest_id: Mapped[int] = mapped_column(ForeignKey("quests.id"))

    order_number: Mapped[int] = mapped_column(Integer, default=1)
    question_type: Mapped[str] = mapped_column(String(40), default="single_choice")

    text: Mapped[str] = mapped_column(Text)
    options: Mapped[list] = mapped_column(JSONB, default=list)
    correct_answer: Mapped[str] = mapped_column(Text)
    explanation: Mapped[str] = mapped_column(Text)

    quest = relationship("Quest", back_populates="questions")


class Attempt(Base):
    __tablename__ = "attempts"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)

    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    quest_id: Mapped[int] = mapped_column(ForeignKey("quests.id"))

    score: Mapped[int] = mapped_column(Integer, default=0)
    total_questions: Mapped[int] = mapped_column(Integer, default=0)

    earned_xp: Mapped[int] = mapped_column(Integer, default=0)
    earned_coins: Mapped[int] = mapped_column(Integer, default=0)

    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    answers = relationship("AttemptAnswer", cascade="all, delete-orphan")


class AttemptAnswer(Base):
    __tablename__ = "attempt_answers"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)

    attempt_id: Mapped[int] = mapped_column(ForeignKey("attempts.id"))
    question_id: Mapped[int] = mapped_column(ForeignKey("questions.id"))

    selected_answer: Mapped[str] = mapped_column(Text)
    is_correct: Mapped[bool] = mapped_column(Boolean, default=False)


class UserCosmetic(Base):
    """
    Збережені покращення піксельного персонажа користувача.

    Окрема таблиця обрана спеціально, щоб не змінювати існуючу таблицю users
    і не ламати вже створену базу даних. Нові записи створюються тільки тоді,
    коли користувач купує предмет у магазині нагород.
    """

    __tablename__ = "user_cosmetics"
    __table_args__ = (
        UniqueConstraint("user_id", "item_key", name="uq_user_cosmetic_item"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)

    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    item_key: Mapped[str] = mapped_column(String(80), index=True)
    category: Mapped[str] = mapped_column(String(40), default="accessory")
    is_equipped: Mapped[bool] = mapped_column(Boolean, default=True)

    unlocked_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="cosmetics")
