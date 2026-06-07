# МІНІСТЕРСТВО ОСВІТИ І НАУКИ УКРАЇНИ
<<<<<<< HEAD
## ЛЬВІВСЬКИЙ НАЦІОНАЛЬНИЙ УНІВЕРСИТЕТ ІМЕНІ ІВАНА ФРАНКА
### Факультет електроніки та комп'ютерних технологій
### Кафедра оптоелектроніки та інформаційних технологій
=======

# ЛЬВІВСЬКИЙ НАЦІОНАЛЬНИЙ УНІВЕРСИТЕТ ІМЕНІ ІВАНА ФРАНКА

## Факультет електроніки та комп'ютерних технологій

## Кафедра оптоелектроніки та інформаційних технологій
<<<<<<< HEAD
>>>>>>> a17aecf912ee533b12d0a14e3ce3d012053b0819
=======
>>>>>>> a17aecf912ee533b12d0a14e3ce3d012053b0819

---

# ReadQuest AI

> **Інтерактивна система ігрового навчання з алгоритмічним генеруванням контенту**

![Flutter](https://img.shields.io/badge/Frontend-Flutter_Web-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![OpenAI](https://img.shields.io/badge/AI-OpenAI_API-111827?style=for-the-badge&logo=openai&logoColor=white)
![Docker](https://img.shields.io/badge/Infrastructure-Docker_Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)

---

## Автор

<<<<<<< HEAD
| Поле | Значення |
|---|---|
| **ПІБ** | Бобкова Богдана Євгеніївна |
| **Група** | ФЕІ-43 |
| **Керівник** | Половинко Ігор Іванович, доктор фізико-математичних наук, професор |
| **Дата виконання** | 01.06.2026 |
| **Репозиторій** | https://github.com/1DaNa1/Diplom.git |
=======
- **ПІБ**: Бобкова Богдана Євгеніївна
- **Група**: ФЕІ-43
- **Керівник**: Половинко Ігор Іванович, доктор фізико-математичних наук, професор
- **Дата виконання**: 01.06.2026
- **Репозиторій**: https://github.com/1DaNa1/Diplom.git
>>>>>>> a17aecf912ee533b12d0a14e3ce3d012053b0819

---

## Загальна інформація

| Характеристика | Значення |
|---|---|
| **Назва проекту** | ReadQuest AI |
| **Тип проєкту** | Вебплатформа, Web Application |
| **Предметна область** | Цифрова освіта, ігрове навчання, підтримка читацької мотивації |
| **Мова програмування** | Python, Dart |
| **Backend** | FastAPI, SQLAlchemy, Pydantic |
| **Frontend** | Flutter Web |
| **База даних** | PostgreSQL із підтримкою JSONB |
| **Інтеграція** | OpenAI API (gpt-4o) |
| **Інфраструктура** | Docker Compose |
| **Тестування** | pytest, Flutter test |
| **Експорт результатів** | JSON |

---

## Призначення проекту

**ReadQuest AI** — це інтерактивна система ігрового навчання, яка перетворює навчальний текст на квест із питаннями, варіантами відповідей, поясненнями та ігровими винагородами.

Система призначена для підтримки читацької мотивації дітей 7–12 років, перевірки розуміння прочитаного тексту, накопичення навчального прогресу та надання вчителю інструментів для аналізу результатів.

Користувач вводить текст вручну або обирає матеріал із бібліотеки, налаштовує параметри генерації та отримує навчальний квест. Після проходження система перевіряє відповіді, показує результат, пояснення, рекомендацію, XP, монети та оновлює прогрес.

---

## Технологічний стек

| Рівень | Технології |
|---|---|
| **Frontend** | Flutter Web, Dart |
| **Backend** | Python, FastAPI |
| **Database** | PostgreSQL |
| **ORM** | SQLAlchemy |
| **Validation** | Pydantic |
| **AI Integration** | OpenAI API, gpt-4o |
| **Infrastructure** | Docker Compose |
| **Backend Testing** | pytest |
| **Frontend Testing** | Flutter test |
| **API Documentation** | Swagger UI, OpenAPI |

---

## Опис функціоналу

### Режим учня
<<<<<<< HEAD
<<<<<<< HEAD

- ручне введення або імпорт `.txt` файлу;
- генерація квесту за текстом або з бібліотеки;
- налаштування складності, кількості питань, класу, віку, режиму генерації;
- проходження квесту з progress bar;
- детальні пояснення та адаптивна рекомендація після результату;
- повторне проходження, накопичення XP, монет, рівнів;
- досягнення, страйки, таблиця лідерів, магазин нагород;
- кастомізація піксельного аватара;
- експорт результатів у JSON.

### Режим вчителя

- додавання текстів до бібліотеки, імпорт `.txt`;
- генерація квестів із бібліотечних текстів;
- захищене видалення текстів;
- перегляд аналітики учнів через кабінет вчителя 2.0;
- середній, найкращий і найнижчий результат, динаміка, сильні сторони, проблемні зони;
- автоматична рекомендація для вчителя;
- експорт аналітики у JSON.
=======
=======
>>>>>>> a17aecf912ee533b12d0a14e3ce3d012053b0819
- Налаштування кількості запитань, рівня складності та режиму генерації
- Проходження квесту з Progress Bar та перевіркою відповідей
- Детальні пояснення до кожного завдання
- Адаптивні навчальні рекомендації після кожної спроби
- Накопичення XP, монет та підвищення рівнів
- Система досягнень ("Перше проходження", "Уважний читач", "Без помилок" тощо)
- Магазин нагород — кастомізація аватара (капелюхи, рамки, значки)
- Експорт результатів у JSON

### Режим вчителя (Teacher Dashboard 2.0)
- Ручне введення тексту або імпорт `.txt` файлу
- Додавання текстів до бібліотеки із захищеним видаленням
- Генерація квестів із збережених текстів
- Перегляд профілю кожного учня
- Середній, найкращий і найгірший результати; кількість спроб
- Порівняння ефективності генерації OpenAI vs локальний алгоритм
- Графік динаміки результатів
- Автоматичні педагогічні висновки та рекомендації
- Експорт аналітики у JSON
>>>>>>> a17aecf912ee533b12d0a14e3ce3d012053b0819

---

## Режими генерації контенту

| Режим | Опис |
|---|---|
| **OpenAI Mode** | Генерація через зовнішню AI модель gpt-4o |
| **Algorithm Mode** | Локальна генерація без зовнішніх сервісів |
| **Auto Mode** | OpenAI з автоматичним fallback на локальний алгоритм |

---

## Гейміфікація та мотиваційна модель

| Елемент | Призначення |
|---|---|
| **XP** | Бали досвіду за проходження квестів |
| **Монети** | Ігрова валюта для магазину нагород |
| **Рівні** | Показник накопиченого прогресу |
| **Досягнення** | Нагороди за навчальні дії |
| **Страйки** | Кількість днів поспіль із навчальною активністю |
| **Таблиця лідерів** | Порівняння активності користувачів |
| **Магазин нагород** | Витрачання монет на кастомізацію аватара |
| **Адаптивні рекомендації** | Навчальна порада після завершення квесту |

### Досягнення

| Досягнення | Умова відкриття |
|---|---|
| Перше проходження | Завершено перший квест |
| Уважний читач | Стабільно високий середній результат |
| 5 квестів завершено | Виконано п'ять квестів |
| 100 XP отримано | Накопичено 100 XP |
| Без помилок | Квест пройдено без помилок |
| Майстер читання | Стабільно високий результат |

---

## Кабінет вчителя 2.0

Розширена аналітична панель для аналізу навчальної активності учнів. Включає список учнів, середній/найкращий/найнижчий результат, кількість спроб і квестів, порівняння OpenAI та локального алгоритму, динаміку результатів, сильні сторони, проблемні зони, автоматичну рекомендацію та експорт аналітики у JSON.

---

## Архітектура системи

```text
Користувач
    │
    ▼
Flutter Web Frontend
    │
    │ HTTP / JSON
    ▼
FastAPI Backend
    │
    ├── Quest API
    ├── Text Library API
    ├── Progress API
    ├── Reward Shop API
    ├── Streak API
    ├── Leaderboard API
    ├── Teacher Dashboard API
    │
    ├── ContentGenerationService
    │       ├── OpenAI API
    │       └── Local Algorithm Fallback
    │
    ▼
PostgreSQL Database
```

---

## Структура проекту

```text
ReadQuestAI/
├── backend/
│   ├── app/
│   │   ├── core/config.py
│   │   ├── routers/
│   │   │   ├── quests.py
│   │   │   ├── texts.py
│   │   │   └── progress.py
│   │   ├── services/content_generator.py
│   │   ├── database.py
│   │   ├── main.py
│   │   ├── models.py
│   │   └── schemas.py
│   ├── tests/
│   │   ├── conftest.py
│   │   ├── test_content_generator.py
│   │   ├── test_gamification_api.py
│   │   ├── test_progress_api.py
│   │   ├── test_quests_api.py
│   │   ├── test_teacher_dashboard_api.py
│   │   └── test_texts_api.py
│   ├── docker-compose.yml
│   └── requirements.txt
│
├── frontend/
│   ├── lib/
│   │   ├── api_service.dart
│   │   ├── main.dart
│   │   └── models.dart
│   ├── test/
│   │   └── models_test.dart
│   └── pubspec.yaml
│
├── screenshots/
└── README.md
```

---

## Опис основних файлів

| Файл або модуль | Призначення |
|---|---|
| `backend/app/main.py` | Точка входу FastAPI, підключення роутерів |
| `backend/app/models.py` | Реляційні моделі SQLAlchemy |
| `backend/app/schemas.py` | Схеми валідації Pydantic |
| `backend/app/database.py` | Підключення до PostgreSQL |
| `backend/app/core/config.py` | Налаштування через змінні середовища |
| `backend/app/routers/quests.py` | API генерації квестів і перевірки відповідей |
| `backend/app/routers/texts.py` | API бібліотеки навчальних текстів |
| `backend/app/routers/progress.py` | API прогресу, досягнень, магазину, страйків, лідерборду, аналітики |
| `backend/app/services/content_generator.py` | Логіка OpenAI та локальної генерації |
| `backend/tests/` | Автоматизовані тести backend |
| `frontend/lib/api_service.dart` | HTTP-клієнт для взаємодії з backend |
| `frontend/lib/main.dart` | Flutter Web інтерфейс і логіка екранів |
| `frontend/lib/models.dart` | Dart-моделі JSON-відповідей |
| `frontend/test/models_test.dart` | Unit-тести frontend-моделей |

---

## Модель даних

| Таблиця | Призначення |
|---|---|
| `users` | Користувачі, клас, XP, монети |
| `reading_texts` | Бібліотека навчальних текстів |
| `quests` | Згенеровані квести |
| `questions` | Питання, варіанти відповідей, пояснення |
| `attempts` | Спроби проходження квестів |
| `attempt_answers` | Відповіді користувача |
| `user_cosmetics` | Куплені та активні предмети персонажа |

---

## Як запустити проєкт з нуля (Windows 10/11)

### 1. Підготовка інструментів

- Python 3.12+
- Flutter SDK
- Docker Desktop
- Google Chrome
- Git

### 2. Клонування репозиторію

```powershell
git clone https://github.com/1DaNa1/Diplom.git ReadQuestAI
cd ReadQuestAI
```

### 3. Налаштування віртуального середовища

```powershell
python -m venv .venv
.\.venv\Scripts\activate
```

### 4. Встановлення backend-залежностей

```powershell
cd backend
pip install -r requirements.txt
```

### 5. Конфігурація змінних оточення

Створити файл `.env` у директорії `backend/`:

```env
PROJECT_NAME="ReadQuest AI"
DATABASE_URL=postgresql+psycopg://postgres:postgres@127.0.0.1:5433/readquest_db
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_MODEL=gpt-4o
ALLOW_OPENAI=true
QUEST_QUESTION_COUNT=5
```

Для запуску без OpenAI встановити `ALLOW_OPENAI=false`.

### 6. Запуск PostgreSQL через Docker Compose

```powershell
docker compose up -d
```

### 7. Запуск FastAPI backend

```powershell
uvicorn app.main:app --reload
```

Backend: `http://127.0.0.1:8000`  
Swagger UI: `http://127.0.0.1:8000/docs`

### 8. Запуск Flutter Web frontend

```powershell
cd ../frontend
flutter pub get
flutter run -d chrome --dart-define=API_URL=http://127.0.0.1:8000
```

---

## API основні ендпоінти

Повна документація: `http://127.0.0.1:8000/docs`

### Квести

| Метод | Ендпоінт | Опис |
|---|---|---|
| POST | `/api/quests/generate` | Генерація квесту з тексту |
| POST | `/api/quests/generate-from-text/{text_id}` | Генерація з бібліотечного тексту |
| GET | `/api/quests/{quest_id}` | Отримання квесту за ID |
| POST | `/api/quests/{quest_id}/submit` | Надсилання відповідей |

### Бібліотека текстів

| Метод | Ендпоінт | Опис |
|---|---|---|
| POST | `/api/texts` | Додати текст |
| GET | `/api/texts` | Отримати всі тексти |
| GET | `/api/texts/{text_id}` | Отримати текст за ID |
| DELETE | `/api/texts/{text_id}` | Видалити невикористаний текст |

### Прогрес та аналітика

| Метод | Ендпоінт | Опис |
|---|---|---|
| GET | `/api/progress/{user_id}` | Прогрес учня |
| GET | `/api/progress/history/{user_id}` | Історія проходжень |
| GET | `/api/progress/{user_id}/achievements` | Досягнення |
| GET | `/api/progress/{user_id}/shop` | Стан магазину |
| POST | `/api/progress/{user_id}/shop/purchase` | Купівля предмета |
| GET | `/api/progress/{user_id}/streak` | Страйки |
| GET | `/api/progress/leaderboard` | Таблиця лідерів |
| GET | `/api/progress/teacher-dashboard/{user_id}` | Аналітика вчителя |

---

## Приклади API-запитів

### Генерація квесту з бібліотечного тексту

```http
POST /api/quests/generate-from-text/{text_id}
```

Приклад відповіді:

```json
{
  "quest_id": 42,
  "title": "Подорож у країну знань",
  "difficulty": "medium",
  "generation_mode": "algorithm",
  "xp_reward": 40,
  "coin_reward": 20,
  "questions": [
    {
      "question_id": 101,
      "text": "Куди вирушили герої оповідання?",
      "options": ["До лісу", "До ботанічного саду", "До школи", "До бібліотеки"],
      "explanation": "У першому абзаці тексту вказано пункт призначення."
    }
  ]
}
```

### Відправка відповідей

```http
POST /api/quests/{quest_id}/submit
```

```json
{
  "answers": [
    { "question_id": 101, "selected_option": "До ботанічного саду" }
  ]
}
```

Відповідь:

```json
{
  "attempt_id": 567,
  "score": 100.0,
  "earned_xp": 20,
  "earned_coins": 15,
  "recommendation": "Блискучий результат. Можна переходити до складніших текстів."
}
```

---

## Скріншоти інтерфейсу

### Режим учня, створення квесту
![Створення квесту](screenshots/student_create.png)

### Бібліотека текстів
![Бібліотека текстів](screenshots/library.png)

### Проходження квесту
![Проходження квесту](screenshots/quest.png)

### Результат проходження
![Результат проходження](screenshots/result.png)

### Прогрес читача та досягнення
![Прогрес читача](screenshots/progress.png)

### Магазин нагород
![Магазин нагород](screenshots/shop.png)

### Страйки та таблиця лідерів
![Страйки та таблиця лідерів](screenshots/streak_leaderboard.png)

### Кабінет вчителя 2.0
![Кабінет вчителя](screenshots/teacher.png)

---

## Тестування

### Backend

```powershell
cd backend
pytest -v
```

38 автоматизованих тестів — усі пройдені успішно.

| Тестовий файл | Що перевіряється |
|---|---|
| `test_content_generator.py` | Локальний генератор, нормалізація, fallback, XP |
| `test_quests_api.py` | Генерація квестів, перевірка відповідей |
| `test_texts_api.py` | Бібліотека текстів, захист від видалення |
| `test_progress_api.py` | Прогрес, історія, досягнення, страйки |
| `test_gamification_api.py` | Магазин нагород, таблиця лідерів |
| `test_teacher_dashboard_api.py` | Кабінет вчителя 2.0, аналітика |

### Frontend

```powershell
cd frontend
flutter test test/models_test.dart
```

17 unit-тестів моделей — усі пройдені успішно.

### Підсумок

| Частина | Інструмент | Тестів | Результат |
|---|---:|---:|---|
| Backend | pytest | 38 | Passed |
| Frontend | Flutter test | 17 | Passed |
| **Разом** | | **55** | **Passed** |

---

## Проблеми і рішення

| Проблема | Рішення |
|---|---|
| `ConnectionTimeout` при запуску | Перевірити чи запущено PostgreSQL через Docker Compose |
| Backend не підключається до БД | Перевірити `DATABASE_URL` у `.env` |
| Frontend не бачить backend | Запустити з `--dart-define=API_URL=http://127.0.0.1:8000` |
| OpenAI не генерує | Перевірити `OPENAI_API_KEY`, модель, баланс, `ALLOW_OPENAI=true` |
| `relation "user_cosmetics" does not exist` | `docker compose down -v`, потім `docker compose up -d` |
| Swagger UI не відкривається | Перевірити чи запущено `uvicorn app.main:app --reload` |

---

## Рекомендований .gitignore

> ⚠️ Файл `.env` з реальними ключами не повинен потрапляти до репозиторію. Використовуйте `.env.example` для прикладу конфігурації.

```gitignore
# Python
.venv/
__pycache__/
*.pyc
.pytest_cache/

# Environment
.env

# Flutter
frontend/.dart_tool/
frontend/build/
frontend/.flutter-plugins
frontend/.flutter-plugins-dependencies

# IDE
.idea/
.vscode/

# OS
.DS_Store
Thumbs.db
```

---

## Подальший розвиток

- повноцінна авторизація та окремі акаунти учнів і вчителів;
- створення класів і груп;
- імпорт PDF та DOCX;
- адаптивна складність на основі історії користувача;
- мобільна Android-версія;
- рекомендаційна система добору текстів.

---

## Використані джерела

- FastAPI Documentation: https://fastapi.tiangolo.com
- Flutter Documentation: https://docs.flutter.dev
- SQLAlchemy Documentation: https://docs.sqlalchemy.org
- Pydantic Documentation: https://docs.pydantic.dev
- OpenAI API Documentation: https://platform.openai.com/docs
- PostgreSQL Documentation: https://www.postgresql.org/docs
- Docker Compose Documentation: https://docs.docker.com/compose
- pytest Documentation: https://docs.pytest.org
