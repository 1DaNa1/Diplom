from app.schemas import QuestGenerateRequest
from app.services.content_generator import ContentGenerationService


def make_request(
    long_text: str,
    *,
    difficulty: str = "medium",
    question_count: int = 5,
    generation_mode: str = "algorithm",
) -> QuestGenerateRequest:
    return QuestGenerateRequest(
        user_name="Generator Test",
        grade_level=5,
        title="Чарівна бібліотека",
        author="Test Author",
        text=long_text,
        target_age=10,
        pages_read=4,
        difficulty=difficulty,
        question_count=question_count,
        generation_mode=generation_mode,
    )


def test_algorithm_generator_creates_requested_number_of_questions(long_text):
    request = make_request(
        long_text,
        difficulty="medium",
        question_count=7,
    )

    result = ContentGenerationService().generate(request)

    assert result.generated_by == "algorithm"
    assert result.difficulty == "medium"
    assert len(result.questions) == 7
    assert result.xp_reward > 0
    assert result.coins_reward > 0


def test_algorithm_generator_questions_have_valid_options(long_text):
    request = make_request(
        long_text,
        difficulty="easy",
        question_count=3,
    )

    result = ContentGenerationService().generate(request)

    for question in result.questions:
        assert question.question_type
        assert question.text
        assert len(question.options) == 4
        assert len(set(question.options)) == 4
        assert question.correct_answer in question.options
        assert question.explanation


def test_question_count_is_normalized_to_nearest_allowed_value(long_text):
    request = make_request(
        long_text,
        difficulty="hard",
        question_count=6,
    )

    result = ContentGenerationService().generate(request)

    assert len(result.questions) in {5, 7}


def test_auto_mode_uses_algorithm_when_openai_is_disabled(long_text):
    request = make_request(
        long_text,
        difficulty="medium",
        question_count=5,
        generation_mode="auto",
    )

    result = ContentGenerationService().generate(request)

    assert result.generated_by == "algorithm"
    assert len(result.questions) == 5


def test_xp_reward_depends_on_difficulty(long_text):
    service = ContentGenerationService()

    easy_result = service.generate(
        make_request(long_text, difficulty="easy", question_count=5),
    )
    hard_result = service.generate(
        make_request(long_text, difficulty="hard", question_count=5),
    )

    assert hard_result.xp_reward > easy_result.xp_reward
    assert hard_result.coins_reward >= easy_result.coins_reward


def test_short_text_fallback_still_creates_valid_questions():
    text = "Короткий текст про читання. " * 12
    request = QuestGenerateRequest(
        user_name="Fallback Test",
        grade_level=5,
        title="Короткий текст",
        author="Test Author",
        text=text,
        target_age=10,
        pages_read=1,
        difficulty="medium",
        question_count=5,
        generation_mode="algorithm",
    )

    result = ContentGenerationService().generate(request)

    assert result.generated_by == "algorithm"
    assert len(result.questions) == 5
    assert all(question.correct_answer in question.options for question in result.questions)
