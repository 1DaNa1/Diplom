# ReadQuest AI

**ReadQuest AI** — інтерактивна система ігрового навчання з алгоритмічним генеруванням контенту.  
Проєкт призначений для заохочення дітей до читання через автоматичну генерацію навчальних квестів, гейміфікацію та аналіз результатів.

---

## Tech Stack

| Частина | Технології |
|---|---|
| Frontend | Flutter, Dart |
| Backend | FastAPI, Python |
| Database | PostgreSQL |
| AI | OpenAI API |
| Infrastructure | Docker Compose |
| ORM | SQLAlchemy |
| Validation | Pydantic |

---

## Основний функціонал

- генерація навчальних квестів за текстом;
- підтримка OpenAI API;
- локальний fallback-алгоритм генерації;
- режим учня;
- режим вчителя;
- бібліотека навчальних текстів;
- генерація квестів із бібліотеки;
- налаштування кількості питань;
- вибір складності;
- вибір режиму генерації: `Auto`, `OpenAI`, `Algorithm`;
- гейміфікація: XP, монети, рівні;
- історія проходження квестів;
- навчальна аналітика;
- перегляд правильних відповідей;
- пояснення до кожного питання;
- експорт результату у JSON.

---

## Структура проєкту

```text
ReadQuestAI/
│
├── backend/
│   ├── app/
│   │   ├── core/
│   │   │   └── config.py
│   │   │
│   │   ├── routers/
│   │   │   ├── quests.py
│   │   │   ├── progress.py
│   │   │   └── texts.py
│   │   │
│   │   ├── services/
│   │   │   └── content_generator.py
│   │   │
│   │   ├── database.py
│   │   ├── main.py
│   │   ├── models.py
│   │   └── schemas.py
│   │
│   ├── docker-compose.yml
│   ├── requirements.txt
│   └── .env.example
│
├── frontend/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── api_service.dart
│   │   └── models.dart
│   │
│   └── pubspec.yaml
│
└── README.md
```

---

## Архітектура

```text
Flutter Frontend
      │
      ▼
FastAPI Backend
      │
      ├── OpenAI API
      │
      ├── Algorithmic Fallback
      │
      ▼
PostgreSQL Database
```

---

## Логіка роботи

1. Вчитель додає текст у бібліотеку або учень вводить власний текст.
2. Користувач обирає параметри генерації.
3. Backend отримує текст і налаштування.
4. Система генерує квест через OpenAI API або локальний алгоритм.
5. Питання зберігаються у PostgreSQL.
6. Учень проходить квест у Flutter-застосунку.
7. Backend перевіряє відповіді.
8. Система нараховує XP, монети та оновлює прогрес.
9. Користувач бачить результат, пояснення та правильні відповіді.
10. Результат можна експортувати у JSON.

---

## Режими генерації

### OpenAI

Використовується для генерації:

- назви квесту;
- ігрового сценарію;
- питань;
- варіантів відповідей;
- правильної відповіді;
- пояснення.

### Algorithm

Локальний алгоритм працює без зовнішнього API та формує питання на основі:

- поділу тексту на речення;
- пошуку ключових слів;
- визначення ймовірного персонажа;
- формування питань різного типу;
- генерації варіантів відповідей.

### Auto

Система спочатку пробує використати OpenAI API.  
Якщо API недоступний, автоматично переходить у локальний fallback-режим.

---

## Налаштування генерації

У застосунку можна налаштувати:

| Параметр | Варіанти |
|---|---|
| Кількість питань | 3, 5, 7, 10 |
| Тип генерації | Auto, OpenAI, Algorithm |
| Складність | Easy, Medium, Hard |
| Вік дитини | 6–16 |
| Клас | 1–11 |
| Кількість сторінок | 1, 2, 3, 4, 5, 10, 20, 30 |

---

## База даних

Основні таблиці:

| Таблиця | Призначення |
|---|---|
| `users` | користувачі, XP, монети, клас |
| `reading_texts` | бібліотека текстів |
| `quests` | згенеровані квести |
| `questions` | питання до квестів |
| `attempts` | спроби проходження |
| `attempt_answers` | відповіді користувача |

---

## API Endpoints

### Quests

| Method | Endpoint | Опис |
|---|---|---|
| POST | `/api/quests/generate` | генерація квесту за введеним текстом |
| POST | `/api/quests/generate-from-text/{text_id}` | генерація квесту з бібліотеки |
| GET | `/api/quests/{quest_id}` | отримання квесту |
| POST | `/api/quests/{quest_id}/submit` | перевірка відповідей |

### Texts

| Method | Endpoint | Опис |
|---|---|---|
| POST | `/api/texts` | додавання тексту |
| GET | `/api/texts` | список текстів |
| GET | `/api/texts/{text_id}` | отримання тексту |
| DELETE | `/api/texts/{text_id}` | видалення тексту, якщо він не використаний у квестах |

### Progress

| Method | Endpoint | Опис |
|---|---|---|
| GET | `/api/progress/{user_id}` | прогрес користувача |
| GET | `/api/progress/history/{user_id}` | історія квестів |
| GET | `/api/progress/{user_id}/history` | альтернативний шлях історії |

---

## Запуск проєкту

Інструкція актуальна для Windows 11.

---

### 1. Відкрити проєкт

```powershell
cd C:\Users\v0303\PycharmProjects\ReadQuestAI
```

---

### 2. Створити virtual environment

```powershell
python -m venv .venv
```

Активувати середовище:

```powershell
.\.venv\Scripts\activate
```

---

### 3. Встановити backend-залежності

```powershell
cd backend
pip install -r requirements.txt
```

---

### 4. Створити `.env`

У папці `backend` створи файл `.env`:

```env
PROJECT_NAME=ReadQuest AI
DATABASE_URL=postgresql+psycopg://postgres:postgres@127.0.0.1:5433/readquest_db

OPENAI_API_KEY=your_openai_api_key_here
OPENAI_MODEL=gpt-4.1-mini
ALLOW_OPENAI=true

QUEST_QUESTION_COUNT=5
```

Якщо OpenAI API не використовується:

```env
ALLOW_OPENAI=false
```

---

### 5. Запустити PostgreSQL

Переконайся, що Docker Desktop запущений.

```powershell
cd C:\Users\v0303\PycharmProjects\ReadQuestAI\backend
docker compose up -d
```

Перевірити контейнер:

```powershell
docker ps
```

---

### 6. Запустити FastAPI backend

```powershell
uvicorn app.main:app --reload
```

Backend:

```text
http://127.0.0.1:8000
```

Swagger UI:

```text
http://127.0.0.1:8000/docs
```

---

### 7. Запустити Flutter frontend

Відкрити другий термінал:

```powershell
cd C:\Users\v0303\PycharmProjects\ReadQuestAI\frontend
flutter pub get
flutter run -d chrome --dart-define=API_URL=http://127.0.0.1:8000
```

---

## Перевірка OpenAI API

```powershell
cd C:\Users\v0303\PycharmProjects\ReadQuestAI\backend
python -c "from dotenv import load_dotenv; load_dotenv('.env'); from openai import OpenAI; c=OpenAI(); r=c.responses.create(model='gpt-4.1-mini', input='Return only OK'); print(r.output_text)"
```

Очікуваний результат:

```text
OK
```

---

## Експорт результату

Після проходження квесту користувач може експортувати результат у JSON.

JSON містить:

- ID спроби;
- ID користувача;
- ID квесту;
- кількість правильних відповідей;
- відсоток точності;
- отримані XP;
- отримані монети;
- рекомендацію;
- відповіді користувача;
- правильні відповіді;
- пояснення.

---

## Видалення текстів

Текст можна видалити тільки тоді, коли за ним ще не створено квестів.

Якщо текст уже використаний у квесті, система не видаляє його, щоб не пошкодити:

- історію проходження;
- питання;
- відповіді;
- навчальну аналітику.

---

## Типові проблеми

### Docker не знайдено

```powershell
docker --version
docker compose version
```

Якщо команди не працюють, потрібно встановити або перезапустити Docker Desktop.

---

### PostgreSQL не запускається

```powershell
cd backend
docker compose down -v
docker compose up -d
```

---

### Backend не відкривається

Перевірити:

```text
http://127.0.0.1:8000/docs
```

---

### Flutter не бачить backend

Запускати frontend потрібно з параметром:

```powershell
flutter run -d chrome --dart-define=API_URL=http://127.0.0.1:8000
```

---

### OpenAI не працює

Перевірити `.env`:

```env
OPENAI_API_KEY=sk-...
OPENAI_MODEL=gpt-4.1-mini
ALLOW_OPENAI=true
```

Також потрібно мати активні API credits на OpenAI Platform.

---

## `.gitignore`

Рекомендований `.gitignore`:

```gitignore
.venv/
__pycache__/
.env
*.pyc
.DS_Store
frontend/build/
backend/.pytest_cache/
```

---

## Статус реалізації

| Компонент | Статус |
|---|---|
| Flutter frontend | Реалізовано |
| FastAPI backend | Реалізовано |
| PostgreSQL | Реалізовано |
| Docker Compose | Реалізовано |
| OpenAI API | Реалізовано |
| Algorithm fallback | Реалізовано |
| Бібліотека текстів | Реалізовано |
| Режим учня | Реалізовано |
| Режим вчителя | Реалізовано |
| Гейміфікація | Реалізовано |
| Прогрес користувача | Реалізовано |
| Навчальна аналітика | Реалізовано |
| Експорт JSON | Реалізовано |

---

## Подальший розвиток

Можливі покращення:

- авторизація користувачів;
- окремі акаунти учнів і вчителів;
- завантаження PDF/DOCX;
- детальні графіки успішності;
- система нагород;
- мобільна Android-версія;
- рекомендаційна система для підбору текстів.

---

## Назва дипломної роботи

**Інтерактивна система ігрового навчання з алгоритмічним генеруванням контенту**