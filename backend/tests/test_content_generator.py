from app.schemas import QuestGenerateRequest
from app.services.content_generator import ContentGenerationService


def test_algorithm_generator_creates_requested_number_of_questions(long_text):
    request = QuestGenerateRequest(
        user_name="Generator Test",
        grade_level=5,
        title="Чарівна бібліотека",
        author="Test Author",
        text=long_text,
        target_age=10,
        pages_read=4,
        difficulty="medium",
        question_count=7,
        generation_mode="algorithm",
    )

    service = ContentGenerationService()
    result = service.generate(request)

    assert result.generated_by == "algorithm"
    assert result.difficulty == "medium"
    assert len(result.questions) == 7
    assert result.xp_reward > 0
    assert result.coins_reward > 0


def test_algorithm_generator_questions_have_valid_options(long_text):
    request = QuestGenerateRequest(
        user_name="Generator Test",
        grade_level=5,
        title="Чарівна бібліотека",
        author="Test Author",
        text=long_text,
        target_age=10,
        pages_read=4,
        difficulty="easy",
        question_count=3,
        generation_mode="algorithm",
    )

    result = ContentGenerationService().generate(request)

    for question in result.questions:
        assert question.text
        assert len(question.options) == 4
        assert question.correct_answer in question.options
        assert question.explanation


def test_question_count_is_normalized_to_allowed_value(long_text):
    request = QuestGenerateRequest(
        user_name="Generator Test",
        grade_level=5,
        title="Чарівна бібліотека",
        author="Test Author",
        text=long_text,
        target_age=10,
        pages_read=4,
        difficulty="hard",
        question_count=6,
        generation_mode="algorithm",
    )

    result = ContentGenerationService().generate(request)

    # 6 має бути нормалізовано до найближчого дозволеного значення.
    # У поточній логіці це 5 або 7 залежно від closest value.
    assert len(result.questions) in {5, 7}