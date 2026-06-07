from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class QuestGenerateRequest(BaseModel):
    user_name: str = Field(default="Demo Reader", min_length=2, max_length=80)
    grade_level: int = Field(default=5, ge=1, le=11)

    title: str = Field(..., min_length=2, max_length=200)
    author: str | None = Field(default=None, max_length=120)
    text: str = Field(..., min_length=200)

    target_age: int = Field(default=10, ge=6, le=16)
    pages_read: int = Field(default=1, ge=1, le=1000)

    difficulty: str = Field(default="medium", pattern="^(easy|medium|hard)$")

    # Нові адаптивні налаштування генерації
    question_count: int = Field(default=5, ge=3, le=10)
    generation_mode: str = Field(default="auto", pattern="^(auto|openai|algorithm)$")


class QuestGenerateFromLibraryRequest(BaseModel):
    user_name: str = Field(default="Demo Reader", min_length=2, max_length=80)
    grade_level: int = Field(default=5, ge=1, le=11)

    difficulty: str = Field(default="medium", pattern="^(easy|medium|hard)$")
    question_count: int = Field(default=5, ge=3, le=10)
    generation_mode: str = Field(default="auto", pattern="^(auto|openai|algorithm)$")


class QuestionOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    order_number: int
    question_type: str
    text: str
    options: list[str]
    explanation: str | None = None


class QuestOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    title: str
    scenario: str
    difficulty: str
    generated_by: str
    xp_reward: int
    coins_reward: int
    questions: list[QuestionOut]


class AnswerIn(BaseModel):
    question_id: int
    selected_answer: str


class SubmitAnswersRequest(BaseModel):
    user_id: int
    answers: list[AnswerIn]


class AnswerReviewOut(BaseModel):
    question_id: int
    order_number: int
    question_text: str
    selected_answer: str
    correct_answer: str
    is_correct: bool
    explanation: str


class AttemptResult(BaseModel):
    attempt_id: int
    user_id: int
    quest_id: int

    score: int
    total_questions: int
    earned_xp: int
    earned_coins: int
    percentage: float
    message: str
    recommendation: str

    answers: list[AnswerReviewOut]


class ProgressOut(BaseModel):
    user_id: int
    username: str
    grade_level: int

    total_xp: int
    coins: int
    completed_quests: int

    level: int
    current_level_xp: int
    next_level_xp: int
    level_progress_percent: float


class AchievementOut(BaseModel):
    key: str
    title: str
    description: str
    icon: str
    color: str
    is_unlocked: bool
    current_value: int
    target_value: int
    progress_percent: float


class QuestHistoryItem(BaseModel):
    attempt_id: int
    quest_id: int

    title: str
    difficulty: str
    generated_by: str

    score: int
    total_questions: int
    percentage: float

    earned_xp: int
    earned_coins: int
    created_at: datetime


class TextCreate(BaseModel):
    title: str = Field(..., min_length=2, max_length=200)
    author: str | None = Field(default=None, max_length=120)
    content: str = Field(..., min_length=200)

    target_age: int = Field(default=10, ge=6, le=16)
    pages_read: int = Field(default=1, ge=1, le=1000)


class TextOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str
    author: str | None
    content: str
    target_age: int
    pages_read: int
    created_at: datetime


class ShopItemOut(BaseModel):
    key: str
    title: str
    description: str
    category: str
    price: int
    icon: str
    color: str
    is_unlocked: bool
    is_equipped: bool


class ShopStateOut(BaseModel):
    user_id: int
    coins: int
    unlocked_items: list[str]
    equipped_items: list[str]
    items: list[ShopItemOut]


class PurchaseItemRequest(BaseModel):
    item_key: str = Field(..., min_length=2, max_length=80)


class PurchaseItemResult(BaseModel):
    message: str
    user_id: int
    coins: int
    purchased_item: ShopItemOut
    shop: ShopStateOut


class AnalyticsHistoryPoint(BaseModel):
    attempt_id: int
    quest_id: int
    title: str
    percentage: float
    score: int
    total_questions: int
    earned_xp: int
    earned_coins: int
    generated_by: str
    created_at: datetime


class TeacherAnalyticsOut(BaseModel):
    user_id: int
    username: str
    average_percentage: float
    best_percentage: float
    attempt_count: int
    completed_quests: int
    openai_count: int
    algorithm_count: int
    total_earned_xp: int
    total_earned_coins: int
    recommendation: str
    history: list[AnalyticsHistoryPoint]



class StudentSummaryOut(BaseModel):
    user_id: int
    username: str
    grade_level: int
    total_xp: int
    coins: int
    completed_quests: int
    average_percentage: float
    best_percentage: float
    last_activity: datetime | None = None


class TeacherMetricOut(BaseModel):
    key: str
    title: str
    value: str
    subtitle: str
    icon: str
    color: str


class TeacherChartPointOut(BaseModel):
    attempt_id: int
    quest_id: int
    title: str
    label: str
    percentage: float
    score: int
    total_questions: int
    generated_by: str
    created_at: datetime


class TeacherInsightOut(BaseModel):
    title: str
    description: str
    kind: str
    icon: str


class TeacherDashboardOut(BaseModel):
    selected_user_id: int | None
    selected_username: str | None
    students: list[StudentSummaryOut]

    average_percentage: float
    best_percentage: float
    worst_percentage: float
    attempt_count: int
    completed_quests: int

    openai_count: int
    algorithm_count: int

    total_earned_xp: int
    total_earned_coins: int
    total_correct_answers: int
    total_questions: int

    success_trend: str
    recommendation: str

    strong_sides: list[str]
    attention_points: list[str]

    metrics: list[TeacherMetricOut]
    chart: list[TeacherChartPointOut]
    insights: list[TeacherInsightOut]


class StreakOut(BaseModel):
    user_id: int
    current_streak: int
    longest_streak: int
    active_today: bool
    last_activity: datetime | None = None
    message: str


class LeaderboardEntryOut(BaseModel):
    rank: int
    user_id: int
    username: str
    grade_level: int
    total_xp: int
    coins: int
    level: int
    completed_quests: int
    average_percentage: float
    best_percentage: float
    current_streak: int


class LocalGenerationStepOut(BaseModel):
    title: str
    description: str
    example: str | None = None


class LocalGenerationPreviewOut(BaseModel):
    title: str
    sentence_count: int
    used_fallback_sentences: bool
    keywords: list[str]
    keyword_frequencies: dict[str, int]
    named_entities: list[str]
    selected_entity: str | None
    question_strategies: list[str]
    distractor_strategy: str
    steps: list[LocalGenerationStepOut]

