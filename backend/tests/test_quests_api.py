from app.models import Question


def test_generate_quest_from_manual_text_success(client, quest_payload):
    response = client.post(
        "/api/quests/generate",
        json=quest_payload,
    )

    assert response.status_code == 200, response.text

    data = response.json()

    assert data["id"] > 0
    assert data["user_id"] > 0
    assert data["title"]
    assert data["scenario"]
    assert data["difficulty"] == "medium"
    assert data["generated_by"] == "algorithm"
    assert data["xp_reward"] > 0
    assert data["coins_reward"] > 0
    assert len(data["questions"]) == 5

    for question in data["questions"]:
        assert question["id"] > 0
        assert question["order_number"] > 0
        assert question["text"]
        assert len(question["options"]) == 4
        assert question["explanation"]


def test_generate_quest_rejects_too_short_text(client, quest_payload):
    payload = dict(quest_payload)
    payload["text"] = "Занадто короткий текст."

    response = client.post(
        "/api/quests/generate",
        json=payload,
    )

    assert response.status_code == 422


def test_generate_quest_from_library_text_success(client, long_text):
    text_response = client.post(
        "/api/texts",
        json={
            "title": "Бібліотечний текст",
            "author": "Автор",
            "content": long_text,
            "target_age": 10,
            "pages_read": 4,
        },
    )

    assert text_response.status_code == 200, text_response.text

    text_id = text_response.json()["id"]

    response = client.post(
        f"/api/quests/generate-from-text/{text_id}",
        json={
            "user_name": "Library Reader",
            "grade_level": 5,
            "difficulty": "easy",
            "question_count": 3,
            "generation_mode": "algorithm",
        },
    )

    assert response.status_code == 200, response.text

    data = response.json()

    assert data["generated_by"] == "algorithm"
    assert data["difficulty"] == "easy"
    assert len(data["questions"]) == 3


def test_generate_quest_from_unknown_library_text_returns_404(client):
    response = client.post(
        "/api/quests/generate-from-text/999999",
        json={
            "user_name": "Library Reader",
            "grade_level": 5,
            "difficulty": "easy",
            "question_count": 3,
            "generation_mode": "algorithm",
        },
    )

    assert response.status_code == 404
    assert response.json()["detail"] == "Text not found"


def test_get_quest_by_id_success(client, quest_payload):
    generated = client.post(
        "/api/quests/generate",
        json=quest_payload,
    )
    assert generated.status_code == 200, generated.text

    quest_id = generated.json()["id"]

    response = client.get(f"/api/quests/{quest_id}")

    assert response.status_code == 200
    assert response.json()["id"] == quest_id
    assert len(response.json()["questions"]) == 5


def test_get_unknown_quest_returns_404(client):
    response = client.get("/api/quests/999999")

    assert response.status_code == 404
    assert response.json()["detail"] == "Quest not found"


def test_submit_answers_returns_result_with_review(client, db_session, quest_payload):
    generate_response = client.post(
        "/api/quests/generate",
        json=quest_payload,
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

    answers = [
        {
            "question_id": question.id,
            "selected_answer": question.correct_answer,
        }
        for question in questions
    ]

    submit_response = client.post(
        f"/api/quests/{quest_id}/submit",
        json={
            "user_id": user_id,
            "answers": answers,
        },
    )

    assert submit_response.status_code == 200, submit_response.text

    result = submit_response.json()

    assert result["attempt_id"] > 0
    assert result["user_id"] == user_id
    assert result["quest_id"] == quest_id
    assert result["score"] == 5
    assert result["total_questions"] == 5
    assert result["percentage"] == 100
    assert result["earned_xp"] > 0
    assert result["earned_coins"] > 0
    assert result["message"]
    assert result["recommendation"]
    assert len(result["answers"]) == 5

    for answer_review in result["answers"]:
        assert answer_review["is_correct"] is True
        assert answer_review["selected_answer"] == answer_review["correct_answer"]
        assert answer_review["explanation"]


def test_submit_answers_with_wrong_answers_returns_zero_score(
    client,
    db_session,
    quest_payload,
):
    generate_response = client.post(
        "/api/quests/generate",
        json=quest_payload,
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

    answers = [
        {
            "question_id": question.id,
            "selected_answer": "Неправильна відповідь для тесту",
        }
        for question in questions
    ]

    submit_response = client.post(
        f"/api/quests/{quest_id}/submit",
        json={
            "user_id": user_id,
            "answers": answers,
        },
    )

    assert submit_response.status_code == 200, submit_response.text

    result = submit_response.json()

    assert result["score"] == 0
    assert result["total_questions"] == 5
    assert result["percentage"] == 0
    assert result["earned_xp"] == 0
    assert result["earned_coins"] == 0
    assert "перечитати" in result["recommendation"].lower()

    for answer_review in result["answers"]:
        assert answer_review["is_correct"] is False


def test_submit_answers_for_unknown_user_returns_404(client, quest_payload):
    generate_response = client.post(
        "/api/quests/generate",
        json=quest_payload,
    )
    assert generate_response.status_code == 200, generate_response.text

    quest_id = generate_response.json()["id"]

    response = client.post(
        f"/api/quests/{quest_id}/submit",
        json={
            "user_id": 999999,
            "answers": [],
        },
    )

    assert response.status_code == 404
    assert response.json()["detail"] == "User not found"
