# МІНІСТЕРСТВО ОСВІТИ І НАУКИ УКРАЇНИ

# ЛЬВІВСЬКИЙ НАЦІОНАЛЬНИЙ УНІВЕРСИТЕТ ІМЕНІ ІВАНА ФРАНКА

## Факультет електроніки та комп'ютерних технологій

## Кафедра фізичної та біомедичної електроніки

---

# ReadQuest AI

> Інтерактивна система ігрового навчання з алгоритмічним генеруванням контенту

---

## Автор

- **ПІБ**: Бобкова Богдана Євгеніївна
- **Група**: ФЕІ-43
- **Керівник**: Половинко Ігор Іванович, кандидат фізико-математичних наук, доцент
- **Дата виконання**: 01.06.2026
- **Репозиторій**: https://github.com/1DaNa1/Diplom.git

---

## Загальна інформація

- **Тип проєкту**: Вебплатформа (Web Application)
- **Мова програмування**: Python (Backend), Dart (Frontend)
- **Фреймворки / Бібліотеки**: FastAPI, SQLAlchemy, Pydantic (Backend); Flutter Web (Frontend)
- **База даних**: PostgreSQL (із підтримкою JSONB)
- **Інтеграція**: OpenAI API (модель gpt-4o)
- **Інфраструктура**: Docker Compose
- **Тестування**: pytest (Backend), Flutter test (Frontend)

---

## Опис функціоналу

### Режим учня

- Ручне введення тексту або імпорт `.txt` файлу
- Налаштування кількості запитань, рівня складності та режиму генерації
- Проходження квесту з Progress Bar та перевіркою відповідей
- Детальні пояснення до кожного завдання
- Адаптивні навчальні рекомендації після кожної спроби
- Накопичення XP, монет та підвищення рівнів
- Система досягнень ("Перше проходження", "Уважний читач", "Без помилок" тощо)
- Магазин нагород — кастомізація аватара (капелюхи, рамки, значки)
- Експорт результатів у JSON

### Режим вчителя (Teacher Dashboard 2.0)

- Додавання текстів до бібліотеки із захищеним видаленням
- Генерація квестів із збережених текстів
- Перегляд профілю кожного учня
- Середній, найкращий і найгірший результати; кількість спроб
- Порівняння ефективності генерації OpenAI vs локальний алгоритм
- Графік динаміки результатів
- Автоматичні педагогічні висновки та рекомендації
- Експорт аналітики у JSON

---

## Режими генерації контенту

1. **OpenAI Mode** — бекенд надсилає текст до ШІ, отримуючи структурований квест із контекстними запитаннями та поясненнями.
2. **Algorithm Mode** — локальний автономний режим без зовнішніх сервісів: нормалізує текст, визначає ключові сутності, створює дистрактори та прораховує баланс нагород.
3. **Auto Mode** — пріоритетно використовує OpenAI; при недоступності автоматично перемикається на локальний алгоритм.

---

## Структура проєкту

```text
ReadQuestAI/
├── backend/
│   ├── app/
│   │   ├── core/             # Конфігурація та налаштування
│   │   ├── routers/          # Маршрути REST API (quests, progress, texts)
│   │   ├── services/         # Бізнес-логіка (content_generator)
│   │   ├── database.py       # Підключення до PostgreSQL
│   │   ├── main.py           # Точка входу FastAPI
│   │   ├── models.py         # Моделі SQLAlchemy
│   │   └── schemas.py        # Схеми валідації Pydantic
│   ├── tests/                # Тести pytest
│   ├── docker-compose.yml
│   └── requirements.txt
└── frontend/
    ├── lib/
    │   ├── api_service.dart  # HTTP-клієнт для взаємодії з API
    │   ├── main.dart         # Головний екран Flutter Web
    │   └── models.dart       # Dart-моделі JSON-відповідей
    └── test/                 # Тести Flutter
```

---

## Опис основних файлів

| Файл / Модуль                               | Призначення                                      |
| ------------------------------------------- | ------------------------------------------------ |
| `backend/app/main.py`                       | Точка входу FastAPI, Lifespan, створення таблиць |
| `backend/app/models.py`                     | Реляційні моделі SQLAlchemy                      |
| `backend/app/schemas.py`                    | Валідація даних через Pydantic                   |
| `backend/app/database.py`                   | Підключення до PostgreSQL                        |
| `backend/app/core/config.py`                | Налаштування через змінні середовища             |
| `backend/app/routers/quests.py`             | API для квестів                                  |
| `backend/app/routers/texts.py`              | API для бібліотеки текстів                       |
| `backend/app/routers/progress.py`           | API для прогресу, магазину, аналітики            |
| `backend/app/services/content_generator.py` | Логіка генерації квестів                         |
| `frontend/lib/main.dart`                    | Flutter Web UI та логіка                         |
| `frontend/lib/models.dart`                  | Моделі відповідей API                            |
| `frontend/lib/api_service.dart`             | HTTP-клієнт                                      |

---

## Як запустити проєкт "з нуля" (Windows 10/11)

### 1. Підготовка інструментів

Встановити: Python 3.12+, Flutter SDK, Docker Desktop, Google Chrome, Git.

### 2. Клонування репозиторію

```powershell
git clone https://github.com/1DaNa1/Diplom.git
cd ReadQuestAI
```

### 3. Налаштування віртуального середовища

```powershell
python -m venv .venv
.\.venv\Scripts\activate
cd backend
pip install -r requirements.txt
```

### 4. Конфігурація змінних оточення

Створіть файл `.env` у директорії `backend/`:

```env
PROJECT_NAME="ReadQuest AI"
DATABASE_URL=postgresql+psycopg://postgres:postgres@127.0.0.1:5433/readquest_db
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_MODEL=gpt-4o
ALLOW_OPENAI=true
QUEST_QUESTION_COUNT=5
```

Для запуску без OpenAI:

```env
ALLOW_OPENAI=false
```

### 5. Запуск бази даних (PostgreSQL через Docker)

```powershell
docker compose up -d
```

### 6. Запуск FastAPI бекенду

```powershell
uvicorn app.main:app --reload
```

- Backend: `http://127.0.0.1:8000`
- Swagger UI: `http://127.0.0.1:8000/docs`

### 7. Запуск Flutter Web фронтенду

```powershell
cd ../frontend
flutter pub get
flutter run -d chrome --dart-define=API_URL=http://127.0.0.1:8000
```

---

## API — основні ендпоінти

### Квести

| Метод | Ендпоінт                                   | Опис                      |
| ----- | ------------------------------------------ | ------------------------- |
| POST  | `/api/quests/generate`                     | Генерація квесту з тексту |
| POST  | `/api/quests/generate-from-text/{text_id}` | Генерація з бібліотеки    |
| GET   | `/api/quests/{quest_id}`                   | Отримати квест за ID      |
| POST  | `/api/quests/{quest_id}/submit`            | Надіслати відповіді       |

### Бібліотека текстів

| Метод  | Ендпоінт               | Опис                                      |
| ------ | ---------------------- | ----------------------------------------- |
| POST   | `/api/texts`           | Додати текст                              |
| GET    | `/api/texts`           | Отримати всі тексти                       |
| DELETE | `/api/texts/{text_id}` | Видалити текст (якщо не використовується) |

### Прогрес та аналітика

| Метод | Ендпоінт                                    | Опис              |
| ----- | ------------------------------------------- | ----------------- |
| GET   | `/api/progress/{user_id}`                   | Прогрес учня      |
| GET   | `/api/progress/{user_id}/achievements`      | Досягнення        |
| GET   | `/api/progress/{user_id}/shop`              | Стан магазину     |
| POST  | `/api/progress/{user_id}/shop/purchase`     | Купити предмет    |
| GET   | `/api/progress/teacher-dashboard/{user_id}` | Аналітика вчителя |

Повна документація: `http://127.0.0.1:8000/docs`

---

## Приклади API запитів

### Генерація квесту з бібліотечного тексту

**POST** `/api/quests/generate-from-text/{text_id}`

Відповідь:

```json
{
  "quest_id": 42,
  "title": "Подорож у країну знань",
  "questions": [
    {
      "question_id": 101,
      "text": "Куди вирушили герої оповідання?",
      "options": ["До лісу", "До ботанічного саду", "До школи"],
      "explanation": "У першому абзаці тексту вказано пункт призначення — ботанічний сад."
    }
  ]
}
```

### Відправка відповідей

**POST** `/api/quests/{quest_id}/submit`

```json
{
  "answers": [{ "question_id": 101, "selected_option": "До ботанічного саду" }]
}
```

Відповідь:

```json
{
  "attempt_id": 567,
  "score": 100.0,
  "earned_xp": 20,
  "earned_coins": 15,
  "recommendation": "Блискучий результат! Твоя уважність допомогла пройти квест без жодної помилки."
}
```

---

## Скріншоти

### Режим учня — створення квесту

![Створення квесту](screenshots/student_create.png)

### Бібліотека текстів

![Бібліотека](screenshots/library.png)

### Проходження квесту

![Квест](screenshots/quest.png)

### Результат проходження

![Результат](screenshots/result.png)

### Прогрес читача та досягнення

![Прогрес](screenshots/progress.png)

### Магазин нагород

![Магазин](screenshots/shop.png)

### Кабінет вчителя 2.0

![Кабінет вчителя](screenshots/teacher.png)

---

## Проблеми і рішення

| Проблема                                   | Рішення                                                                                           |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------- |
| `ConnectionTimeout` при старті бекенду     | Перевірте, чи не запущений локальний PostgreSQL на порту 5432, що конфліктує з Docker-портом 5433 |
| `relation "user_cosmetics" does not exist` | Виконайте `docker compose down -v` та `docker compose up -d`                                      |
| Backend недоступний                        | Перевірте термінал на помилки підключення до БД                                                   |
| Frontend не може дістатися backend         | Запустіть з `--dart-define=API_URL=http://127.0.0.1:8000`                                         |
| OpenAI не генерує                          | Перевірте `OPENAI_API_KEY` та баланс на платформі OpenAI                                          |

---

## Тестування

### Backend

```powershell
cd backend
pytest -v
```

### Frontend

```powershell
cd frontend
flutter test test/models_test.dart
```

## Використані джерела

- FastAPI офіційна документація — https://fastapi.tiangolo.com
- Flutter офіційна документація — https://flutter.dev/docs
- SQLAlchemy документація — https://docs.sqlalchemy.org
- Pydantic документація — https://docs.pydantic.dev
- OpenAI API Reference — https://platform.openai.com/docs
- PostgreSQL документація — https://www.postgresql.org/docs
- Docker Compose документація — https://docs.docker.com/compose
- pytest документація — https://docs.pytest.org
