def test_teacher_dashboard_empty_database_returns_empty_state(client):
    response = client.get("/api/progress/teacher-dashboard")

    assert response.status_code == 200

    data = response.json()

    assert data["selected_user_id"] is None
    assert data["selected_username"] is None
    assert data["students"] == []
    assert data["attempt_count"] == 0
    assert data["completed_quests"] == 0
    assert data["average_percentage"] == 0
    assert data["metrics"] == []
    assert data["chart"] == []
    assert data["attention_points"]


def test_teacher_dashboard_for_selected_student(
    client,
    make_quest_payload,
    create_completed_quest,
):
    created = create_completed_quest(
        make_quest_payload(user_name="Dashboard Reader", question_count=5),
        correct_count=4,
    )
    user_id = created["quest"]["user_id"]

    response = client.get(f"/api/progress/teacher-dashboard/{user_id}")

    assert response.status_code == 200, response.text

    data = response.json()

    assert data["selected_user_id"] == user_id
    assert data["selected_username"] == "Dashboard Reader"
    assert len(data["students"]) == 1
    assert data["attempt_count"] == 1
    assert data["completed_quests"] == 1
    assert data["average_percentage"] == 80
    assert data["best_percentage"] == 80
    assert data["worst_percentage"] == 80
    assert data["algorithm_count"] == 1
    assert data["openai_count"] == 0
    assert data["total_correct_answers"] == 4
    assert data["total_questions"] == 5
    assert data["success_trend"]
    assert data["recommendation"]
    assert len(data["metrics"]) >= 8
    assert len(data["chart"]) == 1
    assert len(data["insights"]) >= 2
    assert data["strong_sides"]
    assert data["attention_points"]


def test_teacher_dashboard_limit_controls_chart_length(
    client,
    make_quest_payload,
    create_completed_quest,
):
    payload = make_quest_payload(user_name="Many Attempts", question_count=3)

    first = create_completed_quest(payload, correct_count=3)
    user_id = first["quest"]["user_id"]

    for _ in range(4):
        create_completed_quest(payload, correct_count=2)

    response = client.get(f"/api/progress/teacher-dashboard/{user_id}?limit=3")

    assert response.status_code == 200

    data = response.json()

    assert data["selected_user_id"] == user_id
    assert data["completed_quests"] == 5
    assert data["attempt_count"] == 3
    assert len(data["chart"]) == 3


def test_teacher_analytics_legacy_endpoint(
    client,
    make_quest_payload,
    create_completed_quest,
):
    created = create_completed_quest(
        make_quest_payload(user_name="Analytics Reader", question_count=5),
        correct_count=3,
    )
    user_id = created["quest"]["user_id"]

    response = client.get(f"/api/progress/{user_id}/analytics")

    assert response.status_code == 200

    data = response.json()

    assert data["user_id"] == user_id
    assert data["username"] == "Analytics Reader"
    assert data["attempt_count"] == 1
    assert data["completed_quests"] == 1
    assert data["average_percentage"] == 60
    assert data["best_percentage"] == 60
    assert data["algorithm_count"] == 1
    assert data["openai_count"] == 0
    assert data["recommendation"]
    assert len(data["history"]) == 1
