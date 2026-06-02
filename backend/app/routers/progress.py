from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Attempt, Quest, User, UserCosmetic
from app.schemas import (
    AchievementOut,
    AnalyticsHistoryPoint,
    ProgressOut,
    PurchaseItemRequest,
    PurchaseItemResult,
    QuestHistoryItem,
    ShopItemOut,
    ShopStateOut,
    StudentSummaryOut,
    TeacherAnalyticsOut,
    TeacherChartPointOut,
    TeacherDashboardOut,
    TeacherInsightOut,
    TeacherMetricOut,
)

router = APIRouter(prefix="/api/progress", tags=["progress"])


SHOP_ITEMS: list[dict] = [
    {
        "key": "hat_star",
        "title": "Зоряний капелюх",
        "description": "Яскравий капелюх для уважного читача.",
        "category": "hat",
        "price": 8,
        "icon": "star",
        "color": "yellow",
    },
    {
        "key": "hat_wizard",
        "title": "Капелюх мага",
        "description": "Підходить для чарівних квестів і складних історій.",
        "category": "hat",
        "price": 14,
        "icon": "auto_awesome",
        "color": "purple",
    },
    {
        "key": "pet_owl",
        "title": "Мудра сова",
        "description": "Маленький помічник для читання та підказок.",
        "category": "pet",
        "price": 18,
        "icon": "pets",
        "color": "blue",
    },
    {
        "key": "pet_fox",
        "title": "Лисеня читач",
        "description": "Дружній супутник для щоденних квестів.",
        "category": "pet",
        "price": 22,
        "icon": "cruelty_free",
        "color": "orange",
    },
    {
        "key": "frame_gold",
        "title": "Золота рамка",
        "description": "Святкова рамка для профілю з високими результатами.",
        "category": "frame",
        "price": 12,
        "icon": "workspace_premium",
        "color": "yellow",
    },
    {
        "key": "badge_trophy",
        "title": "Значок трофея",
        "description": "Нагорода для учня, який не здається після помилок.",
        "category": "badge",
        "price": 10,
        "icon": "emoji_events",
        "color": "green",
    },
]


def calculate_level(total_xp: int) -> tuple[int, int, int, float]:
    """
    Розрахунок рівня користувача.

    Логіка:
    - кожні 100 XP дають новий рівень;
    - current_level_xp показує прогрес у межах поточного рівня;
    - next_level_xp показує загальну кількість XP, потрібну для наступного рівня;
    - level_progress_percent використовується для progress bar у Flutter.
    """

    level = max(1, total_xp // 100 + 1)
    current_level_start = (level - 1) * 100
    next_level_xp = level * 100

    current_level_xp = total_xp - current_level_start
    level_progress_percent = round((current_level_xp / 100) * 100, 2)

    return level, current_level_xp, next_level_xp, level_progress_percent


def get_user_or_404(
    user_id: int,
    db: Session,
) -> User:
    user = db.query(User).filter(User.id == user_id).first()

    if user is None:
        raise HTTPException(status_code=404, detail="User not found")

    return user


def get_shop_item_definition(item_key: str) -> dict:
    for item in SHOP_ITEMS:
        if item["key"] == item_key:
            return item

    raise HTTPException(
        status_code=404,
        detail="Shop item not found",
    )


def build_shop_state(
    user: User,
    db: Session,
) -> ShopStateOut:
    cosmetics = (
        db.query(UserCosmetic)
        .filter(UserCosmetic.user_id == user.id)
        .all()
    )

    cosmetic_by_key = {
        cosmetic.item_key: cosmetic
        for cosmetic in cosmetics
    }

    unlocked_items = sorted(cosmetic_by_key.keys())
    equipped_items = sorted(
        cosmetic.item_key
        for cosmetic in cosmetics
        if cosmetic.is_equipped
    )

    items: list[ShopItemOut] = []

    for item in SHOP_ITEMS:
        cosmetic = cosmetic_by_key.get(item["key"])

        items.append(
            ShopItemOut(
                key=item["key"],
                title=item["title"],
                description=item["description"],
                category=item["category"],
                price=item["price"],
                icon=item["icon"],
                color=item["color"],
                is_unlocked=cosmetic is not None,
                is_equipped=bool(cosmetic and cosmetic.is_equipped),
            )
        )

    return ShopStateOut(
        user_id=user.id,
        coins=user.coins,
        unlocked_items=unlocked_items,
        equipped_items=equipped_items,
        items=items,
    )


def build_user_history(
    user_id: int,
    limit: int,
    db: Session,
) -> list[QuestHistoryItem]:
    """
    Допоміжна функція для формування історії квестів.
    Винесена окремо, щоб можна було підтримати два URL-маршрути:
    - /api/progress/history/{user_id}
    - /api/progress/{user_id}/history
    """

    get_user_or_404(user_id=user_id, db=db)

    rows = (
        db.query(Attempt, Quest)
        .join(Quest, Attempt.quest_id == Quest.id)
        .filter(Attempt.user_id == user_id)
        .order_by(Attempt.created_at.desc())
        .limit(limit)
        .all()
    )

    history: list[QuestHistoryItem] = []

    for attempt, quest in rows:
        if attempt.total_questions == 0:
            percentage = 0
        else:
            percentage = round((attempt.score / attempt.total_questions) * 100, 2)

        history.append(
            QuestHistoryItem(
                attempt_id=attempt.id,
                quest_id=quest.id,
                title=quest.title,
                difficulty=quest.difficulty,
                generated_by=quest.generated_by,
                score=attempt.score,
                total_questions=attempt.total_questions,
                percentage=percentage,
                earned_xp=attempt.earned_xp,
                earned_coins=attempt.earned_coins,
                created_at=attempt.created_at,
            )
        )

    return history


def get_analytics_recommendation(average_percentage: float) -> str:
    if average_percentage >= 85:
        return "Результати дуже високі. Можна пропонувати довші тексти й складніші квести."

    if average_percentage >= 70:
        return "Результати добрі. Варто поступово підвищувати складність завдань."

    if average_percentage >= 50:
        return "Результати середні. Доцільно повторити тексти з нижчими показниками."

    if average_percentage > 0:
        return "Потрібне повторне читання коротших текстів і проходження простіших квестів."

    return "Після перших проходжень система сформує навчальну рекомендацію."



def build_teacher_recommendation(
    average_percentage: float,
    worst_percentage: float,
    attempt_count: int,
) -> str:
    """
    Формує коротку педагогічну рекомендацію для кабінету вчителя.
    Вона базується не на одному проходженні, а на агрегованій історії.
    """

    if attempt_count == 0:
        return (
            "Поки немає проходжень. Варто запропонувати учню короткий текст "
            "і перший простий квест для стартової діагностики."
        )

    if average_percentage >= 90:
        return (
            "Учень демонструє дуже високий рівень розуміння тексту. "
            "Можна переходити до складніших текстів, довших історій і завдань на висновки."
        )

    if average_percentage >= 75:
        return (
            "Результати стабільно добрі. Доцільно поступово підвищувати складність "
            "і додавати питання на причинно-наслідкові зв’язки."
        )

    if average_percentage >= 55:
        return (
            "Результати середні. Варто повторити тексти, у яких були нижчі показники, "
            "і пропонувати коротші квести з поясненням помилок."
        )

    if worst_percentage < 40:
        return (
            "Потрібна додаткова підтримка. Рекомендовано коротші тексти, менша кількість питань "
            "і повторне проходження після перечитування."
        )

    return (
        "Учню варто продовжити тренування на простих і середніх текстах, "
        "звертаючи увагу на деталі та послідовність подій."
    )


def determine_success_trend(percentages_chronological: list[float]) -> str:
    if len(percentages_chronological) < 2:
        return "недостатньо даних"

    if len(percentages_chronological) < 6:
        delta = percentages_chronological[-1] - percentages_chronological[0]
    else:
        previous = percentages_chronological[-6:-3]
        recent = percentages_chronological[-3:]
        delta = (sum(recent) / len(recent)) - (sum(previous) / len(previous))

    if delta >= 8:
        return "покращується"

    if delta <= -8:
        return "знижується"

    return "стабільний"


def build_student_summary(
    user: User,
    db: Session,
) -> StudentSummaryOut:
    attempts = (
        db.query(Attempt)
        .filter(Attempt.user_id == user.id)
        .order_by(Attempt.created_at.desc())
        .all()
    )

    percentages = [calculate_attempt_percentage(attempt) for attempt in attempts]
    average_percentage = round(sum(percentages) / len(percentages), 2) if percentages else 0.0
    best_percentage = round(max(percentages), 2) if percentages else 0.0
    last_activity = attempts[0].created_at if attempts else None

    return StudentSummaryOut(
        user_id=user.id,
        username=user.username,
        grade_level=user.grade_level,
        total_xp=user.total_xp,
        coins=user.coins,
        completed_quests=len(attempts),
        average_percentage=average_percentage,
        best_percentage=best_percentage,
        last_activity=last_activity,
    )


def build_teacher_dashboard(
    db: Session,
    user_id: int | None = None,
    limit: int = 12,
) -> TeacherDashboardOut:
    users = db.query(User).order_by(User.created_at.desc()).all()
    students = [build_student_summary(user=user, db=db) for user in users]

    selected_user: User | None = None

    if user_id is not None:
        selected_user = get_user_or_404(user_id=user_id, db=db)
    elif users:
        users_with_attempts = [student for student in students if student.completed_quests > 0]
        selected_user_id = users_with_attempts[0].user_id if users_with_attempts else students[0].user_id
        selected_user = get_user_or_404(user_id=selected_user_id, db=db)

    if selected_user is None:
        return TeacherDashboardOut(
            selected_user_id=None,
            selected_username=None,
            students=students,
            average_percentage=0.0,
            best_percentage=0.0,
            worst_percentage=0.0,
            attempt_count=0,
            completed_quests=0,
            openai_count=0,
            algorithm_count=0,
            total_earned_xp=0,
            total_earned_coins=0,
            total_correct_answers=0,
            total_questions=0,
            success_trend="недостатньо даних",
            recommendation=build_teacher_recommendation(0.0, 0.0, 0),
            strong_sides=[],
            attention_points=["Потрібно пройти перший квест, щоб сформувати аналітику."],
            metrics=[],
            chart=[],
            insights=[],
        )

    rows = (
        db.query(Attempt, Quest)
        .join(Quest, Attempt.quest_id == Quest.id)
        .filter(Attempt.user_id == selected_user.id)
        .order_by(Attempt.created_at.desc())
        .limit(limit)
        .all()
    )

    rows_chronological = list(reversed(rows))
    percentages: list[float] = []
    chart: list[TeacherChartPointOut] = []
    openai_count = 0
    algorithm_count = 0
    total_earned_xp = 0
    total_earned_coins = 0
    total_correct_answers = 0
    total_questions = 0

    for index, (attempt, quest) in enumerate(rows_chronological, start=1):
        percentage = calculate_attempt_percentage(attempt)
        percentages.append(percentage)

        generated_by = quest.generated_by.lower()
        if "openai" in generated_by:
            openai_count += 1
        else:
            algorithm_count += 1

        total_earned_xp += attempt.earned_xp
        total_earned_coins += attempt.earned_coins
        total_correct_answers += attempt.score
        total_questions += attempt.total_questions

        chart.append(
            TeacherChartPointOut(
                attempt_id=attempt.id,
                quest_id=quest.id,
                title=quest.title,
                label=f"Квест {index}",
                percentage=percentage,
                score=attempt.score,
                total_questions=attempt.total_questions,
                generated_by=quest.generated_by,
                created_at=attempt.created_at,
            )
        )

    attempt_count = len(rows_chronological)
    average_percentage = round(sum(percentages) / attempt_count, 2) if attempt_count else 0.0
    best_percentage = round(max(percentages), 2) if percentages else 0.0
    worst_percentage = round(min(percentages), 2) if percentages else 0.0
    success_trend = determine_success_trend(percentages)
    completed_quests = db.query(Attempt).filter(Attempt.user_id == selected_user.id).count()

    strong_sides: list[str] = []
    attention_points: list[str] = []

    if best_percentage >= 90:
        strong_sides.append("Є високі результати, що показують здатність добре розуміти текст.")
    if average_percentage >= 70:
        strong_sides.append("Середній результат достатній для переходу до складніших завдань.")
    if completed_quests >= 5:
        strong_sides.append("Учень має регулярну історію проходжень і стабільну навчальну активність.")
    if total_earned_xp >= 100:
        strong_sides.append("Накопичено достатньо XP для підтримки мотивації через рівні та нагороди.")

    if not strong_sides:
        strong_sides.append("Після кількох додаткових проходжень система точніше визначить сильні сторони.")

    if average_percentage < 55 and attempt_count > 0:
        attention_points.append("Потрібно повторити базові тексти й зменшити складність квестів.")
    if worst_percentage < 40 and attempt_count > 0:
        attention_points.append("Є проходження з низьким результатом, яке варто розібрати окремо.")
    if completed_quests < 3:
        attention_points.append("Для надійної аналітики бажано пройти ще кілька квестів.")
    if algorithm_count == 0 and openai_count > 0:
        attention_points.append("Усі квести створені через OpenAI. Для порівняння можна спробувати локальний алгоритм.")
    if openai_count == 0 and algorithm_count > 0:
        attention_points.append("Усі квести створені локальним алгоритмом. Для різноманітності можна перевірити OpenAI режим.")

    if not attention_points:
        attention_points.append("Критичних проблем не виявлено. Можна поступово підвищувати складність.")

    metrics = [
        TeacherMetricOut(
            key="average",
            title="Середній результат",
            value=f"{average_percentage:.0f}%",
            subtitle="за останніми проходженнями",
            icon="percent",
            color="purple",
        ),
        TeacherMetricOut(
            key="best",
            title="Кращий результат",
            value=f"{best_percentage:.0f}%",
            subtitle="найуспішніший квест",
            icon="emoji_events",
            color="yellow",
        ),
        TeacherMetricOut(
            key="worst",
            title="Найнижчий результат",
            value=f"{worst_percentage:.0f}%",
            subtitle="потребує уваги",
            icon="warning",
            color="red" if worst_percentage < 50 and attempt_count > 0 else "blue",
        ),
        TeacherMetricOut(
            key="attempts",
            title="Спроби",
            value=str(attempt_count),
            subtitle="у вибірці аналітики",
            icon="checklist",
            color="pink",
        ),
        TeacherMetricOut(
            key="openai",
            title="OpenAI",
            value=str(openai_count),
            subtitle="квести через AI сервіс",
            icon="smart_toy",
            color="blue",
        ),
        TeacherMetricOut(
            key="algorithm",
            title="Algorithm",
            value=str(algorithm_count),
            subtitle="квести локальним алгоритмом",
            icon="memory",
            color="green",
        ),
        TeacherMetricOut(
            key="xp",
            title="XP",
            value=f"+{total_earned_xp}",
            subtitle="отримано за квести",
            icon="bolt",
            color="purple",
        ),
        TeacherMetricOut(
            key="coins",
            title="Монети",
            value=f"+{total_earned_coins}",
            subtitle="нараховано учню",
            icon="monetization_on",
            color="yellow",
        ),
    ]

    insights = [
        TeacherInsightOut(
            title="Сильні сторони",
            description=" ".join(strong_sides),
            kind="positive",
            icon="thumb_up",
        ),
        TeacherInsightOut(
            title="Потребує уваги",
            description=" ".join(attention_points),
            kind="warning",
            icon="priority_high",
        ),
    ]

    return TeacherDashboardOut(
        selected_user_id=selected_user.id,
        selected_username=selected_user.username,
        students=students,
        average_percentage=average_percentage,
        best_percentage=best_percentage,
        worst_percentage=worst_percentage,
        attempt_count=attempt_count,
        completed_quests=completed_quests,
        openai_count=openai_count,
        algorithm_count=algorithm_count,
        total_earned_xp=total_earned_xp,
        total_earned_coins=total_earned_coins,
        total_correct_answers=total_correct_answers,
        total_questions=total_questions,
        success_trend=success_trend,
        recommendation=build_teacher_recommendation(
            average_percentage=average_percentage,
            worst_percentage=worst_percentage,
            attempt_count=attempt_count,
        ),
        strong_sides=strong_sides,
        attention_points=attention_points,
        metrics=metrics,
        chart=chart,
        insights=insights,
    )


def calculate_attempt_percentage(attempt: Attempt) -> float:
    if attempt.total_questions == 0:
        return 0.0

    return round((attempt.score / attempt.total_questions) * 100, 2)


def build_user_achievements(
    user: User,
    db: Session,
) -> list[AchievementOut]:
    """
    Формує список досягнень учня без окремої таблиці.

    Досягнення обчислюються на основі вже наявних даних:
    - кількості спроб проходження;
    - XP користувача;
    - середнього результату;
    - наявності проходження без помилок.
    Такий підхід не ламає існуючу структуру бази даних і добре підходить
    для демонстраційної освітньої системи.
    """

    attempts = (
        db.query(Attempt)
        .filter(Attempt.user_id == user.id)
        .order_by(Attempt.created_at.desc())
        .all()
    )

    completed_quests = len(attempts)
    percentages = [calculate_attempt_percentage(attempt) for attempt in attempts]
    average_percentage = (
        round(sum(percentages) / len(percentages), 2)
        if percentages
        else 0.0
    )

    perfect_attempts = [
        attempt
        for attempt in attempts
        if attempt.total_questions > 0 and attempt.score == attempt.total_questions
    ]

    best_percentage = max(percentages) if percentages else 0.0

    achievement_definitions = [
        {
            "key": "first_quest",
            "title": "Перше проходження",
            "description": "Учень завершив перший навчальний квест.",
            "icon": "flag",
            "color": "green",
            "current_value": completed_quests,
            "target_value": 1,
        },
        {
            "key": "careful_reader",
            "title": "Уважний читач",
            "description": "Середній результат читача досяг 70% або більше.",
            "icon": "visibility",
            "color": "blue",
            "current_value": int(round(average_percentage)),
            "target_value": 70,
        },
        {
            "key": "five_quests",
            "title": "5 квестів завершено",
            "description": "Учень пройшов п’ять навчальних квестів.",
            "icon": "checklist",
            "color": "purple",
            "current_value": completed_quests,
            "target_value": 5,
        },
        {
            "key": "xp_100",
            "title": "100 XP отримано",
            "description": "Учень накопичив перші 100 XP.",
            "icon": "bolt",
            "color": "yellow",
            "current_value": user.total_xp,
            "target_value": 100,
        },
        {
            "key": "perfect_score",
            "title": "Без помилок",
            "description": "Учень хоча б один раз пройшов квест без помилок.",
            "icon": "workspace_premium",
            "color": "green",
            "current_value": len(perfect_attempts),
            "target_value": 1,
        },
        {
            "key": "reading_master",
            "title": "Майстер читання",
            "description": "Учень має високий результат і стабільний прогрес.",
            "icon": "emoji_events",
            "color": "orange",
            "current_value": int(round(best_percentage)),
            "target_value": 90,
        },
    ]

    achievements: list[AchievementOut] = []

    for item in achievement_definitions:
        current_value = max(0, int(item["current_value"]))
        target_value = max(1, int(item["target_value"]))
        progress_percent = min(100.0, round((current_value / target_value) * 100, 2))
        is_unlocked = current_value >= target_value

        achievements.append(
            AchievementOut(
                key=item["key"],
                title=item["title"],
                description=item["description"],
                icon=item["icon"],
                color=item["color"],
                is_unlocked=is_unlocked,
                current_value=current_value,
                target_value=target_value,
                progress_percent=progress_percent,
            )
        )

    return achievements



@router.get("/users", response_model=list[StudentSummaryOut])
def get_students_for_teacher(
    db: Session = Depends(get_db),
):
    """
    Повертає список учнів для кабінету вчителя.
    Окремої авторизації в демонстраційній версії немає, тому список
    формується за всіма користувачами, які вже створювали або проходили квести.
    """

    users = db.query(User).order_by(User.created_at.desc()).all()
    return [build_student_summary(user=user, db=db) for user in users]


@router.get("/teacher-dashboard", response_model=TeacherDashboardOut)
def get_teacher_dashboard(
    limit: int = Query(default=12, ge=1, le=50),
    db: Session = Depends(get_db),
):
    """
    Повертає повний аналітичний кабінет учителя.
    Якщо конкретного учня не вибрано, система автоматично бере першого учня
    з історією проходжень або першого створеного користувача.
    """

    return build_teacher_dashboard(
        db=db,
        user_id=None,
        limit=limit,
    )


@router.get("/teacher-dashboard/{user_id}", response_model=TeacherDashboardOut)
def get_teacher_dashboard_for_user(
    user_id: int,
    limit: int = Query(default=12, ge=1, le=50),
    db: Session = Depends(get_db),
):
    """
    Повертає аналітичний кабінет учителя для конкретного учня.
    """

    return build_teacher_dashboard(
        db=db,
        user_id=user_id,
        limit=limit,
    )


@router.get("/history/{user_id}", response_model=list[QuestHistoryItem])
def get_user_history_new_path(
    user_id: int,
    limit: int = Query(default=20, ge=1, le=100),
    db: Session = Depends(get_db),
):
    """
    Основний endpoint історії.

    URL:
    /api/progress/history/{user_id}

    Саме цей шлях використовує оновлений Flutter frontend.
    """

    return build_user_history(
        user_id=user_id,
        limit=limit,
        db=db,
    )


@router.get("/{user_id}/history", response_model=list[QuestHistoryItem])
def get_user_history_legacy_path(
    user_id: int,
    limit: int = Query(default=20, ge=1, le=100),
    db: Session = Depends(get_db),
):
    """
    Додатковий endpoint для сумісності зі старим frontend.

    URL:
    /api/progress/{user_id}/history

    Його можна залишити, щоб не отримувати Not Found,
    якщо десь випадково залишився старий шлях.
    """

    return build_user_history(
        user_id=user_id,
        limit=limit,
        db=db,
    )


@router.get("/{user_id}/shop", response_model=ShopStateOut)
def get_user_shop(
    user_id: int,
    db: Session = Depends(get_db),
):
    """
    Повертає стан магазину нагород для учня:
    - поточну кількість монет;
    - список доступних предметів;
    - куплені предмети;
    - активні предмети для піксельного персонажа.
    """

    user = get_user_or_404(user_id=user_id, db=db)

    return build_shop_state(
        user=user,
        db=db,
    )


@router.post("/{user_id}/shop/purchase", response_model=PurchaseItemResult)
def purchase_shop_item(
    user_id: int,
    payload: PurchaseItemRequest,
    db: Session = Depends(get_db),
):
    """
    Купує або активує предмет магазину.

    Якщо предмет уже куплено, монети повторно не списуються.
    Якщо предмет новий, система перевіряє баланс користувача,
    списує монети та зберігає покупку в таблиці user_cosmetics.
    """

    user = get_user_or_404(user_id=user_id, db=db)
    item_definition = get_shop_item_definition(payload.item_key)

    existing = (
        db.query(UserCosmetic)
        .filter(
            UserCosmetic.user_id == user.id,
            UserCosmetic.item_key == item_definition["key"],
        )
        .first()
    )

    same_category_items = (
        db.query(UserCosmetic)
        .filter(
            UserCosmetic.user_id == user.id,
            UserCosmetic.category == item_definition["category"],
        )
        .all()
    )

    for cosmetic in same_category_items:
        cosmetic.is_equipped = False

    if existing is not None:
        existing.is_equipped = True
        message = "Предмет уже був куплений. Його активовано для персонажа."
    else:
        price = item_definition["price"]

        if user.coins < price:
            raise HTTPException(
                status_code=400,
                detail="Недостатньо монет для покупки цього предмета.",
            )

        user.coins -= price

        existing = UserCosmetic(
            user_id=user.id,
            item_key=item_definition["key"],
            category=item_definition["category"],
            is_equipped=True,
        )

        db.add(existing)
        message = "Предмет успішно куплено та активовано."

    db.commit()
    db.refresh(user)
    db.refresh(existing)

    shop = build_shop_state(user=user, db=db)
    purchased_item = next(
        item
        for item in shop.items
        if item.key == item_definition["key"]
    )

    return PurchaseItemResult(
        message=message,
        user_id=user.id,
        coins=user.coins,
        purchased_item=purchased_item,
        shop=shop,
    )


@router.get("/{user_id}/analytics", response_model=TeacherAnalyticsOut)
def get_teacher_analytics(
    user_id: int,
    limit: int = Query(default=10, ge=1, le=50),
    db: Session = Depends(get_db),
):
    """
    Повертає агреговану навчальну аналітику для панелі вчителя.

    Цей endpoint не замінює історію проходжень, а доповнює її
    готовими показниками для швидкого відображення у Flutter.
    """

    user = get_user_or_404(user_id=user_id, db=db)

    rows = (
        db.query(Attempt, Quest)
        .join(Quest, Attempt.quest_id == Quest.id)
        .filter(Attempt.user_id == user_id)
        .order_by(Attempt.created_at.desc())
        .limit(limit)
        .all()
    )

    points: list[AnalyticsHistoryPoint] = []

    total_percentage = 0.0
    best_percentage = 0.0
    openai_count = 0
    algorithm_count = 0
    total_earned_xp = 0
    total_earned_coins = 0

    for attempt, quest in rows:
        if attempt.total_questions == 0:
            percentage = 0.0
        else:
            percentage = round((attempt.score / attempt.total_questions) * 100, 2)

        total_percentage += percentage
        best_percentage = max(best_percentage, percentage)
        total_earned_xp += attempt.earned_xp
        total_earned_coins += attempt.earned_coins

        generated_by = quest.generated_by.lower()

        if "openai" in generated_by:
            openai_count += 1
        else:
            algorithm_count += 1

        points.append(
            AnalyticsHistoryPoint(
                attempt_id=attempt.id,
                quest_id=quest.id,
                title=quest.title,
                percentage=percentage,
                score=attempt.score,
                total_questions=attempt.total_questions,
                earned_xp=attempt.earned_xp,
                earned_coins=attempt.earned_coins,
                generated_by=quest.generated_by,
                created_at=attempt.created_at,
            )
        )

    attempt_count = len(points)
    average_percentage = (
        round(total_percentage / attempt_count, 2)
        if attempt_count > 0
        else 0.0
    )

    return TeacherAnalyticsOut(
        user_id=user.id,
        username=user.username,
        average_percentage=average_percentage,
        best_percentage=round(best_percentage, 2),
        attempt_count=attempt_count,
        completed_quests=db.query(Attempt).filter(Attempt.user_id == user.id).count(),
        openai_count=openai_count,
        algorithm_count=algorithm_count,
        total_earned_xp=total_earned_xp,
        total_earned_coins=total_earned_coins,
        recommendation=get_analytics_recommendation(average_percentage),
        history=points,
    )


@router.get("/{user_id}/achievements", response_model=list[AchievementOut])
def get_user_achievements(
    user_id: int,
    db: Session = Depends(get_db),
):
    """
    Повертає досягнення учня.

    Досягнення не зберігаються окремо, а розраховуються за поточним
    прогресом користувача та історією його проходжень.
    """

    user = get_user_or_404(user_id=user_id, db=db)

    return build_user_achievements(
        user=user,
        db=db,
    )


@router.get("/{user_id}", response_model=ProgressOut)
def get_user_progress(
    user_id: int,
    db: Session = Depends(get_db),
):
    """
    Повертає загальний прогрес користувача:
    - XP;
    - монети;
    - рівень;
    - кількість пройдених квестів;
    - прогрес до наступного рівня.
    """

    user = get_user_or_404(user_id=user_id, db=db)

    completed_quests = db.query(Attempt).filter(Attempt.user_id == user.id).count()

    level, current_level_xp, next_level_xp, level_progress_percent = calculate_level(
        user.total_xp
    )

    return ProgressOut(
        user_id=user.id,
        username=user.username,
        grade_level=user.grade_level,
        total_xp=user.total_xp,
        coins=user.coins,
        completed_quests=completed_quests,
        level=level,
        current_level_xp=current_level_xp,
        next_level_xp=next_level_xp,
        level_progress_percent=level_progress_percent,
    )
