from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import (
    Attempt,
    AttemptAnswer,
    Question,
    Quest,
    ReadingText,
    User,
)
from app.schemas import (
    AnswerReviewOut,
    AttemptResult,
    QuestGenerateFromLibraryRequest,
    QuestGenerateRequest,
    QuestOut,
    SubmitAnswersRequest,
)
from app.services.content_generator import ContentGenerationService

router = APIRouter(prefix="/api/quests", tags=["quests"])


def get_or_create_user(
    db: Session,
    username: str,
    grade_level: int,
) -> User:
    user = db.query(User).filter(User.username == username).first()

    if user is None:
        user = User(
            username=username,
            grade_level=grade_level,
        )
        db.add(user)
        db.flush()
    else:
        user.grade_level = grade_level

    return user


def create_quest_from_text(
    db: Session,
    user: User,
    reading_text: ReadingText,
    payload: QuestGenerateRequest,
) -> Quest:
    generator = ContentGenerationService()
    generated = generator.generate(payload)

    quest = Quest(
        user_id=user.id,
        reading_text_id=reading_text.id,
        title=generated.title,
        scenario=generated.scenario,
        difficulty=generated.difficulty,
        generated_by=generated.generated_by,
        xp_reward=generated.xp_reward,
        coins_reward=generated.coins_reward,
    )

    db.add(quest)
    db.flush()

    for index, generated_question in enumerate(generated.questions, start=1):
        question = Question(
            quest_id=quest.id,
            order_number=index,
            question_type=generated_question.question_type,
            text=generated_question.text,
            options=generated_question.options,
            correct_answer=generated_question.correct_answer,
            explanation=generated_question.explanation,
        )
        db.add(question)

    db.commit()
    db.refresh(quest)

    return quest


@router.post("/generate", response_model=QuestOut)
def generate_quest(
    payload: QuestGenerateRequest,
    db: Session = Depends(get_db),
):
    """
    Генерує навчальний квест за введеним текстом.

    Нові можливості:
    - користувач сам вибирає кількість питань;
    - можна вибрати режим генерації: auto, openai або algorithm;
    - складність, вік дитини та кількість сторінок впливають на генерацію.
    """

    user = get_or_create_user(
        db=db,
        username=payload.user_name,
        grade_level=payload.grade_level,
    )

    reading_text = ReadingText(
        title=payload.title,
        author=payload.author,
        content=payload.text,
        target_age=payload.target_age,
        pages_read=payload.pages_read,
    )

    db.add(reading_text)
    db.flush()

    return create_quest_from_text(
        db=db,
        user=user,
        reading_text=reading_text,
        payload=payload,
    )


@router.post("/generate-from-text/{text_id}", response_model=QuestOut)
def generate_quest_from_library_text(
    text_id: int,
    payload: QuestGenerateFromLibraryRequest,
    db: Session = Depends(get_db),
):
    """
    Генерує квест за текстом із бібліотеки.

    Це потрібно для повноцінного сценарію:
    1. Вчитель додає текст у бібліотеку.
    2. Учень вибирає текст.
    3. Система генерує квест за збереженим матеріалом.
    """

    reading_text = db.query(ReadingText).filter(ReadingText.id == text_id).first()

    if reading_text is None:
        raise HTTPException(status_code=404, detail="Text not found")

    user = get_or_create_user(
        db=db,
        username=payload.user_name,
        grade_level=payload.grade_level,
    )

    generation_payload = QuestGenerateRequest(
        user_name=payload.user_name,
        grade_level=payload.grade_level,
        title=reading_text.title,
        author=reading_text.author,
        text=reading_text.content,
        target_age=reading_text.target_age,
        pages_read=reading_text.pages_read,
        difficulty=payload.difficulty,
        question_count=payload.question_count,
        generation_mode=payload.generation_mode,
    )

    return create_quest_from_text(
        db=db,
        user=user,
        reading_text=reading_text,
        payload=generation_payload,
    )


def build_attempt_message(percentage: float) -> str:
    if percentage >= 91:
        return "Відмінно! Ти майже бездоганно зрозумів текст."

    if percentage >= 71:
        return "Добрий результат! Можна поступово переходити до складніших текстів."

    if percentage >= 41:
        return "Непогано, але варто пройти ще один квест середньої складності."

    return "Спробуй перечитати текст і пройти квест ще раз."


def build_adaptive_recommendation(
    percentage: float,
    earned_coins: int,
) -> str:
    """
    Формує адаптивну навчальну рекомендацію після проходження квесту.

    Межі підібрані так, щоб результат не був лише оцінкою,
    а перетворювався на коротку підказку для наступного навчального кроку.
    """

    if percentage >= 91:
        bonus_text = (
            "Також можна перевірити блок досягнень і магазин нагород."
            if earned_coins > 0
            else "Спробуй ще один складний квест, щоб отримати більше монет."
        )
        return (
            "Результат дуже високий. Можна переходити до складніших текстів "
            f"і відкривати нові досягнення. {bonus_text}"
        )

    if percentage >= 71:
        return (
            "Результат добрий. Можна поступово переходити до складніших текстів "
            "або збільшити кількість питань у наступному квесті."
        )

    if percentage >= 41:
        return (
            "Результат середній. Рекомендовано пройти ще один квест середньої "
            "складності та уважніше перечитати фрагменти, де були помилки."
        )

    return (
        "Рекомендовано перечитати текст повністю, звернути увагу на основні події "
        "та пройти квест ще раз."
    )


@router.get("/{quest_id}", response_model=QuestOut)
def get_quest(
    quest_id: int,
    db: Session = Depends(get_db),
):
    quest = db.query(Quest).filter(Quest.id == quest_id).first()

    if quest is None:
        raise HTTPException(status_code=404, detail="Quest not found")

    return quest


@router.post("/{quest_id}/submit", response_model=AttemptResult)
def submit_quest_answers(
    quest_id: int,
    payload: SubmitAnswersRequest,
    db: Session = Depends(get_db),
):
    """
    Перевіряє відповіді користувача та повертає детальний розбір.
    """

    quest = db.query(Quest).filter(Quest.id == quest_id).first()

    if quest is None:
        raise HTTPException(status_code=404, detail="Quest not found")

    user = db.query(User).filter(User.id == payload.user_id).first()

    if user is None:
        raise HTTPException(status_code=404, detail="User not found")

    questions = (
        db.query(Question)
        .filter(Question.quest_id == quest_id)
        .order_by(Question.order_number)
        .all()
    )

    if not questions:
        raise HTTPException(status_code=400, detail="Quest has no questions")

    selected_answers = {
        answer.question_id: answer.selected_answer
        for answer in payload.answers
    }

    score = 0
    review_items: list[AnswerReviewOut] = []
    answer_rows: list[AttemptAnswer] = []

    for question in questions:
        selected = selected_answers.get(question.id, "").strip()
        correct = question.correct_answer.strip()

        is_correct = selected.casefold() == correct.casefold()

        if is_correct:
            score += 1

        answer_rows.append(
            AttemptAnswer(
                question_id=question.id,
                selected_answer=selected,
                is_correct=is_correct,
            )
        )

        review_items.append(
            AnswerReviewOut(
                question_id=question.id,
                order_number=question.order_number,
                question_text=question.text,
                selected_answer=selected if selected else "Відповідь не вибрано",
                correct_answer=question.correct_answer,
                is_correct=is_correct,
                explanation=question.explanation,
            )
        )

    total_questions = len(questions)
    percentage = round((score / total_questions) * 100, 2)

    earned_xp = round(quest.xp_reward * (score / total_questions))
    earned_coins = round(quest.coins_reward * (score / total_questions))

    user.total_xp += earned_xp
    user.coins += earned_coins
    quest.status = "completed"

    attempt = Attempt(
        user_id=user.id,
        quest_id=quest.id,
        score=score,
        total_questions=total_questions,
        earned_xp=earned_xp,
        earned_coins=earned_coins,
    )

    db.add(attempt)
    db.flush()

    for row in answer_rows:
        row.attempt_id = attempt.id
        db.add(row)

    db.commit()
    db.refresh(attempt)

    message = build_attempt_message(percentage)
    recommendation = build_adaptive_recommendation(
        percentage=percentage,
        earned_coins=earned_coins,
    )

    return AttemptResult(
        attempt_id=attempt.id,
        user_id=user.id,
        quest_id=quest.id,
        score=score,
        total_questions=total_questions,
        earned_xp=earned_xp,
        earned_coins=earned_coins,
        percentage=percentage,
        message=message,
        recommendation=recommendation,
        answers=review_items,
    )