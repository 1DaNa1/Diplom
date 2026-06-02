from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Quest, ReadingText
from app.schemas import TextCreate, TextOut

router = APIRouter(prefix="/api/texts", tags=["texts"])


@router.post("", response_model=TextOut)
def create_text(
    payload: TextCreate,
    db: Session = Depends(get_db),
):
    """
    Додає текст у бібліотеку.

    Цей endpoint використовується у режимі вчителя:
    викладач може зберегти текст один раз, а потім учень
    може генерувати за ним квести без повторного введення матеріалу.
    """

    text = ReadingText(
        title=payload.title,
        author=payload.author,
        content=payload.content,
        target_age=payload.target_age,
        pages_read=payload.pages_read,
    )

    db.add(text)
    db.commit()
    db.refresh(text)

    return text


@router.get("", response_model=list[TextOut])
def get_texts(
    db: Session = Depends(get_db),
):
    """
    Повертає список усіх текстів бібліотеки.

    Тексти сортуються від найновіших до найстаріших,
    щоб останні додані матеріали відображалися першими.
    """

    return (
        db.query(ReadingText)
        .order_by(ReadingText.created_at.desc())
        .all()
    )


@router.get("/{text_id}", response_model=TextOut)
def get_text(
    text_id: int,
    db: Session = Depends(get_db),
):
    """
    Повертає один текст із бібліотеки за його id.
    """

    text = db.query(ReadingText).filter(ReadingText.id == text_id).first()

    if text is None:
        raise HTTPException(
            status_code=404,
            detail="Text not found",
        )

    return text


@router.delete("/{text_id}")
def delete_text(
    text_id: int,
    db: Session = Depends(get_db),
):
    """
    Видаляє текст із бібліотеки тільки тоді, коли за ним ще не створено квестів.

    Якщо текст уже використаний у квестах, фізично видаляти його не можна,
    тому що це може пошкодити:
    - історію проходження;
    - питання;
    - відповіді;
    - навчальну аналітику користувача.

    Для дипломного проєкту це правильніша поведінка, ніж примусове видалення,
    оскільки результати навчання мають залишатися цілісними.
    """

    text = db.query(ReadingText).filter(ReadingText.id == text_id).first()

    if text is None:
        raise HTTPException(
            status_code=404,
            detail="Text not found",
        )

    related_quests_count = (
        db.query(Quest)
        .filter(Quest.reading_text_id == text.id)
        .count()
    )

    if related_quests_count > 0:
        raise HTTPException(
            status_code=409,
            detail=(
                "Цей текст уже використано у квестах. "
                "Його не можна видалити, щоб не пошкодити історію результатів, "
                "питання та навчальну аналітику."
            ),
        )

    db.delete(text)
    db.commit()

    return {
        "message": "Text deleted",
        "text_id": text_id,
    }