from app.models import Question


def create_completed_quest(client, db_session, quest_payload):
    generate_response = client.post(
        "/api/quests/generate",
        json=quest_payload,
    )

    assert generate_response.status_code == 200

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

    assert submit_response.status_code == 200

    return {
        "quest": quest,
        "result": submit_response.json(),
    }


def test_get_user_progress_after_completed_quest(client, db_session, quest_payload):
    created = create_completed_quest(
        client=client,
        db_session=db_session,
        quest_payload=quest_payload,
    )

    user_id = created["quest"]["user_id"]

    response = client.get(f"/api/progress/{user_id}")

    assert response.status_code == 200

    data = response.json()

    assert data["user_id"] == user_id
    assert data["username"] == "Test Reader"
    assert data["grade_level"] == 5
    assert data["total_xp"] > 0
    assert data["coins"] > 0
    assert data["completed_quests"] == 1
    assert data["level"] >= 1
    assert data["level_progress_percent"] >= 0


def test_get_user_history_after_completed_quest(client, db_session, quest_payload):
    created = create_completed_quest(
        client=client,
        db_session=db_session,
        quest_payload=quest_payload,
    )

    user_id = created["quest"]["user_id"]

    response = client.get(f"/api/progress/history/{user_id}")

    assert response.status_code == 200

    data = response.json()

    assert len(data) == 1
    assert data[0]["quest_id"] == created["quest"]["id"]
    assert data[0]["score"] == 5
    assert data[0]["total_questions"] == 5
    assert data[0]["percentage"] == 100
    assert data[0]["earned_xp"] > 0
    assert data[0]["earned_coins"] > 0


def test_legacy_history_endpoint_also_works(client, db_session, quest_payload):
    created = create_completed_quest(
        client=client,
        db_session=db_session,
        quest_payload=quest_payload,
    )

    user_id = created["quest"]["user_id"]

    response = client.get(f"/api/progress/{user_id}/history")

    assert response.status_code == 200

    data = response.json()

    assert len(data) == 1
    assert data[0]["quest_id"] == created["quest"]["id"]


def test_progress_for_unknown_user_returns_404(client):
    response = client.get("/api/progress/999999")

    assert response.status_code == 404
    assert response.json()["detail"] == "User not found"