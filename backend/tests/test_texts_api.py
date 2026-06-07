def test_create_text_success(client, long_text):
    response = client.post(
        "/api/texts",
        json={
            "title": "Тестовий текст",
            "author": "Автор",
            "content": long_text,
            "target_age": 10,
            "pages_read": 4,
        },
    )

    assert response.status_code == 200, response.text

    data = response.json()

    assert data["id"] > 0
    assert data["title"] == "Тестовий текст"
    assert data["author"] == "Автор"
    assert data["content"] == long_text
    assert data["target_age"] == 10
    assert data["pages_read"] == 4
    assert data["created_at"]


def test_create_text_rejects_short_content(client):
    response = client.post(
        "/api/texts",
        json={
            "title": "Короткий текст",
            "author": "Автор",
            "content": "Занадто коротко.",
            "target_age": 10,
            "pages_read": 4,
        },
    )

    assert response.status_code == 422


def test_get_texts_returns_created_text(client, long_text):
    create_response = client.post(
        "/api/texts",
        json={
            "title": "Текст у бібліотеці",
            "author": "Автор",
            "content": long_text,
            "target_age": 9,
            "pages_read": 3,
        },
    )

    assert create_response.status_code == 200, create_response.text

    response = client.get("/api/texts")

    assert response.status_code == 200

    data = response.json()

    assert len(data) == 1
    assert data[0]["title"] == "Текст у бібліотеці"
    assert data[0]["target_age"] == 9
    assert data[0]["pages_read"] == 3


def test_get_single_text_success(client, long_text):
    create_response = client.post(
        "/api/texts",
        json={
            "title": "Окремий текст",
            "author": "Автор",
            "content": long_text,
            "target_age": 11,
            "pages_read": 5,
        },
    )

    assert create_response.status_code == 200, create_response.text

    text_id = create_response.json()["id"]

    response = client.get(f"/api/texts/{text_id}")

    assert response.status_code == 200
    assert response.json()["id"] == text_id
    assert response.json()["title"] == "Окремий текст"


def test_get_unknown_text_returns_404(client):
    response = client.get("/api/texts/999999")

    assert response.status_code == 404


def test_delete_unused_text_success(client, long_text):
    create_response = client.post(
        "/api/texts",
        json={
            "title": "Текст для видалення",
            "author": "Автор",
            "content": long_text,
            "target_age": 10,
            "pages_read": 4,
        },
    )

    assert create_response.status_code == 200, create_response.text

    text_id = create_response.json()["id"]

    delete_response = client.delete(f"/api/texts/{text_id}")

    assert delete_response.status_code == 200
    assert delete_response.json()["message"] == "Text deleted"
    assert delete_response.json()["text_id"] == text_id

    get_response = client.get(f"/api/texts/{text_id}")
    assert get_response.status_code == 404


def test_delete_used_text_returns_conflict(client, long_text):
    create_response = client.post(
        "/api/texts",
        json={
            "title": "Використаний текст",
            "author": "Автор",
            "content": long_text,
            "target_age": 10,
            "pages_read": 4,
        },
    )

    assert create_response.status_code == 200, create_response.text

    text_id = create_response.json()["id"]

    generate_response = client.post(
        f"/api/quests/generate-from-text/{text_id}",
        json={
            "user_name": "Test Reader",
            "grade_level": 5,
            "difficulty": "medium",
            "question_count": 3,
            "generation_mode": "algorithm",
        },
    )

    assert generate_response.status_code == 200, generate_response.text

    delete_response = client.delete(f"/api/texts/{text_id}")

    assert delete_response.status_code == 409

    detail = delete_response.json()["detail"]

    assert "використано у квестах" in detail
    assert "не можна видалити" in detail
