def test_get_user_progress_after_completed_quest(
    client,
    quest_payload,
    create_completed_quest,
):
    created = create_completed_quest(quest_payload)
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
    assert 0 <= data["level_progress_percent"] <= 100


def test_get_user_history_after_completed_quest(
    client,
    quest_payload,
    create_completed_quest,
):
    created = create_completed_quest(quest_payload)
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


def test_legacy_history_endpoint_also_works(
    client,
    quest_payload,
    create_completed_quest,
):
    created = create_completed_quest(quest_payload)
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


def test_achievements_after_perfect_attempt(
    client,
    quest_payload,
    create_completed_quest,
):
    created = create_completed_quest(quest_payload)
    user_id = created["quest"]["user_id"]

    response = client.get(f"/api/progress/{user_id}/achievements")

    assert response.status_code == 200

    achievements = response.json()
    by_key = {item["key"]: item for item in achievements}

    assert len(achievements) >= 6
    assert by_key["first_quest"]["is_unlocked"] is True
    assert by_key["perfect_score"]["is_unlocked"] is True
    assert by_key["first_quest"]["progress_percent"] == 100


def test_streak_after_completed_quest(
    client,
    quest_payload,
    create_completed_quest,
):
    created = create_completed_quest(quest_payload)
    user_id = created["quest"]["user_id"]

    response = client.get(f"/api/progress/{user_id}/streak")

    assert response.status_code == 200

    data = response.json()

    assert data["user_id"] == user_id
    assert data["current_streak"] >= 1
    assert data["longest_streak"] >= 1
    assert data["active_today"] is True
    assert data["message"]


def test_users_endpoint_returns_student_summaries(
    client,
    make_quest_payload,
    create_completed_quest,
):
    first = create_completed_quest(
        make_quest_payload(user_name="Анна", question_count=5),
    )
    second = create_completed_quest(
        make_quest_payload(user_name="Богдан", question_count=3),
    )

    response = client.get("/api/progress/users")

    assert response.status_code == 200

    data = response.json()
    user_ids = {item["user_id"] for item in data}

    assert first["quest"]["user_id"] in user_ids
    assert second["quest"]["user_id"] in user_ids

    for item in data:
        assert "username" in item
        assert "average_percentage" in item
        assert "best_percentage" in item
        assert "completed_quests" in item
