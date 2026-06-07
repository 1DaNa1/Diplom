def test_shop_initial_state_for_user(
    client,
    quest_payload,
    create_completed_quest,
):
    created = create_completed_quest(quest_payload)
    user_id = created["quest"]["user_id"]

    response = client.get(f"/api/progress/{user_id}/shop")

    assert response.status_code == 200

    data = response.json()

    assert data["user_id"] == user_id
    assert data["coins"] >= 0
    assert isinstance(data["unlocked_items"], list)
    assert isinstance(data["equipped_items"], list)
    assert len(data["items"]) >= 6

    for item in data["items"]:
        assert item["key"]
        assert item["title"]
        assert item["category"]
        assert item["price"] >= 0
        assert "is_unlocked" in item
        assert "is_equipped" in item


def test_purchase_shop_item_success_and_reactivation(
    client,
    quest_payload,
    create_completed_quest,
):
    created = create_completed_quest(quest_payload)
    user_id = created["quest"]["user_id"]

    before = client.get(f"/api/progress/{user_id}/shop")
    assert before.status_code == 200
    coins_before = before.json()["coins"]

    response = client.post(
        f"/api/progress/{user_id}/shop/purchase",
        json={"item_key": "hat_star"},
    )

    assert response.status_code == 200, response.text

    data = response.json()

    assert data["user_id"] == user_id
    assert data["purchased_item"]["key"] == "hat_star"
    assert data["purchased_item"]["is_unlocked"] is True
    assert data["purchased_item"]["is_equipped"] is True
    assert data["coins"] == coins_before - data["purchased_item"]["price"]

    second_response = client.post(
        f"/api/progress/{user_id}/shop/purchase",
        json={"item_key": "hat_star"},
    )

    assert second_response.status_code == 200, second_response.text
    assert second_response.json()["coins"] == data["coins"]
    assert second_response.json()["purchased_item"]["is_equipped"] is True


def test_purchase_shop_item_with_insufficient_coins_returns_400(
    client,
    quest_payload,
    create_completed_quest,
):
    created = create_completed_quest(quest_payload, correct_count=0)
    user_id = created["quest"]["user_id"]

    shop_response = client.get(f"/api/progress/{user_id}/shop")
    assert shop_response.status_code == 200
    assert shop_response.json()["coins"] == 0

    response = client.post(
        f"/api/progress/{user_id}/shop/purchase",
        json={"item_key": "hat_star"},
    )

    assert response.status_code == 400
    assert "Недостатньо монет" in response.json()["detail"]


def test_purchase_unknown_shop_item_returns_404(
    client,
    quest_payload,
    create_completed_quest,
):
    created = create_completed_quest(quest_payload)
    user_id = created["quest"]["user_id"]

    response = client.post(
        f"/api/progress/{user_id}/shop/purchase",
        json={"item_key": "missing_item"},
    )

    assert response.status_code == 404
    assert response.json()["detail"] == "Shop item not found"


def test_leaderboard_orders_users_by_xp(
    client,
    make_quest_payload,
    create_completed_quest,
):
    strong = create_completed_quest(
        make_quest_payload(user_name="Strong Reader", question_count=5),
        correct_count=5,
    )
    weak = create_completed_quest(
        make_quest_payload(user_name="Weak Reader", question_count=5),
        correct_count=1,
    )

    response = client.get("/api/progress/leaderboard")

    assert response.status_code == 200

    data = response.json()

    assert len(data) >= 2
    assert data[0]["total_xp"] >= data[1]["total_xp"]

    user_ids = [item["user_id"] for item in data]
    assert strong["quest"]["user_id"] in user_ids
    assert weak["quest"]["user_id"] in user_ids

    for index, item in enumerate(data, start=1):
        assert item["rank"] == index
        assert item["username"]
        assert item["level"] >= 1
        assert "current_streak" in item
