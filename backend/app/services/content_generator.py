import json
import random
import re
from dataclasses import dataclass

from openai import OpenAI

from app.core.config import get_settings
from app.schemas import QuestGenerateRequest

settings = get_settings()


@dataclass
class GeneratedQuestion:
    question_type: str
    text: str
    options: list[str]
    correct_answer: str
    explanation: str


@dataclass
class GeneratedQuest:
    title: str
    scenario: str
    difficulty: str
    xp_reward: int
    coins_reward: int
    generated_by: str
    questions: list[GeneratedQuestion]


class ContentGenerationService:
    """
    Сервіс генерування навчального контенту.

    Система має три режими:
    1. auto — пробує OpenAI API, а якщо API недоступний, використовує fallback;
    2. openai — пріоритетно використовує OpenAI API;
    3. algorithm — використовує тільки локальний алгоритм.
    """

    def generate(self, request: QuestGenerateRequest) -> GeneratedQuest:
        question_count = self._normalize_question_count(request.question_count)

        should_use_openai = (
            request.generation_mode in {"auto", "openai"}
            and settings.ALLOW_OPENAI
            and bool(settings.OPENAI_API_KEY)
        )

        if should_use_openai:
            try:
                return self._generate_with_openai(request, question_count)
            except Exception:
                return self._generate_algorithmically(
                    request=request,
                    question_count=question_count,
                    generated_by="algorithm_fallback",
                )

        return self._generate_algorithmically(
            request=request,
            question_count=question_count,
            generated_by="algorithm",
        )

    def _generate_with_openai(
        self,
        request: QuestGenerateRequest,
        question_count: int,
    ) -> GeneratedQuest:
        client = OpenAI(api_key=settings.OPENAI_API_KEY)

        prompt = f"""
Створи навчальний ігровий квест українською мовою для дитини.

Тема застосунку: заохочення дітей до читання.
Назва тексту: {request.title}
Автор: {request.author or "не вказано"}
Вік дитини: {request.target_age}
Клас: {request.grade_level}
Складність: {request.difficulty}
Прочитано сторінок: {request.pages_read}
Кількість питань: {question_count}

Текст для аналізу:
{request.text[:7000]}

Потрібно згенерувати JSON без markdown.

Структура JSON:
{{
  "title": "коротка назва квесту",
  "scenario": "ігровий опис завдання у стилі пригоди",
  "difficulty": "easy|medium|hard",
  "xp_reward": число,
  "coins_reward": число,
  "questions": [
    {{
      "question_type": "single_choice",
      "text": "текст питання",
      "options": ["варіант 1", "варіант 2", "варіант 3", "варіант 4"],
      "correct_answer": "точний правильний варіант",
      "explanation": "коротке пояснення, чому відповідь правильна"
    }}
  ]
}}

Вимоги:
- питань має бути рівно {question_count};
- питання мають перевіряти розуміння прочитаного, а не випадкові факти;
- питання мають бути різними за типом: головна думка, деталі, причина/наслідок, послідовність подій, персонажі, уважність;
- усі варіанти відповідей мають бути правдоподібними;
- correct_answer обов'язково має точно збігатися з одним із options;
- не вигадуй події, яких немає в тексті;
- пояснення має допомагати дитині зрозуміти помилку.
"""

        response = client.responses.create(
            model=settings.OPENAI_MODEL,
            input=[
                {
                    "role": "system",
                    "content": (
                        "Ти генеруєш навчальні квести у форматі валідного JSON. "
                        "Відповідай тільки JSON-об'єктом без markdown."
                    ),
                },
                {
                    "role": "user",
                    "content": prompt,
                },
            ],
            text={"format": {"type": "json_object"}},
        )

        data = json.loads(response.output_text)

        return self._normalize_generated_data(
            data=data,
            generated_by="openai",
            question_count=question_count,
        )

    def _generate_algorithmically(
        self,
        request: QuestGenerateRequest,
        question_count: int,
        generated_by: str,
    ) -> GeneratedQuest:
        """
        Покращений локальний fallback-алгоритм.

        Він формує різні типи питань:
        - головна думка;
        - деталь;
        - послідовність;
        - причина/наслідок;
        - персонаж;
        - уважність до змісту.
        """

        clean_text = self._clean_text(request.text)
        sentences = self._split_sentences(clean_text)

        if len(sentences) < 4:
            sentences = self._build_safe_sentences(clean_text)

        keywords = self._extract_keywords(clean_text)
        hero = self._extract_probable_hero(clean_text)

        builders = [
            lambda: self._build_main_idea_question(request.title, sentences),
            lambda: self._build_detail_question(sentences, keywords, preferred_index=1),
            lambda: self._build_sequence_question(sentences),
            lambda: self._build_cause_effect_question(sentences),
            lambda: self._build_character_question(hero),
            lambda: self._build_detail_question(sentences, keywords, preferred_index=2),
            lambda: self._build_attention_question(sentences),
            lambda: self._build_keyword_question(keywords),
            lambda: self._build_detail_question(sentences, keywords, preferred_index=3),
            lambda: self._build_summary_question(request.title),
        ]

        questions: list[GeneratedQuestion] = []

        for index in range(question_count):
            builder = builders[index % len(builders)]
            questions.append(builder())

        xp = self._calculate_xp(
            difficulty=request.difficulty,
            pages_read=request.pages_read,
            question_count=question_count,
        )
        coins = max(5, xp // 5)

        return GeneratedQuest(
            title=f"Квест за текстом «{request.title}»",
            scenario=(
                "Ти відкриваєш інтерактивну бібліотеку ReadQuest. "
                "Щоб пройти далі, потрібно уважно пригадати зміст прочитаного, "
                "відповісти на питання та зібрати нагороди за правильні відповіді."
            ),
            difficulty=request.difficulty,
            xp_reward=xp,
            coins_reward=coins,
            generated_by=generated_by,
            questions=questions,
        )

    def _normalize_generated_data(
        self,
        data: dict,
        generated_by: str,
        question_count: int,
    ) -> GeneratedQuest:
        raw_questions = data.get("questions", [])
        questions: list[GeneratedQuestion] = []

        for item in raw_questions[:question_count]:
            raw_options = item.get("options", [])

            options = [
                str(option).strip()
                for option in raw_options
                if str(option).strip()
            ]

            correct_answer = str(item.get("correct_answer", "")).strip()

            if not options:
                continue

            if not correct_answer:
                correct_answer = options[0]

            options = self._normalize_options(correct_answer, options)

            questions.append(
                GeneratedQuestion(
                    question_type=str(item.get("question_type", "single_choice")),
                    text=str(item.get("text", "Оберіть правильну відповідь.")),
                    options=options,
                    correct_answer=correct_answer,
                    explanation=str(
                        item.get(
                            "explanation",
                            "Пояснення сформовано автоматично.",
                        )
                    ),
                )
            )

        while len(questions) < question_count:
            questions.append(
                self._build_summary_question(
                    title=str(data.get("title", "Навчальний квест"))
                )
            )

        return GeneratedQuest(
            title=str(data.get("title", "Навчальний квест")),
            scenario=str(
                data.get(
                    "scenario",
                    "Пройди квест і перевір розуміння прочитаного.",
                )
            ),
            difficulty=str(data.get("difficulty", "medium")),
            xp_reward=int(data.get("xp_reward", 50)),
            coins_reward=int(data.get("coins_reward", 10)),
            generated_by=generated_by,
            questions=questions,
        )

    def _build_main_idea_question(
        self,
        title: str,
        sentences: list[str],
    ) -> GeneratedQuestion:
        correct = (
            "Текст розповідає про події, які потрібно уважно прочитати "
            "та зрозуміти."
        )

        options = self._normalize_options(
            correct,
            [
                correct,
                "Текст складається тільки з випадкових фактів без змісту.",
                "У тексті немає жодної події або головної думки.",
                "Текст розповідає лише про числа та обчислення.",
            ],
        )

        return GeneratedQuestion(
            question_type="main_idea",
            text=f"Яка головна ідея тексту «{title}»?",
            options=options,
            correct_answer=correct,
            explanation=(
                "Головна ідея визначається не одним словом, а загальним змістом "
                "і розвитком подій у тексті."
            ),
        )

    def _build_detail_question(
        self,
        sentences: list[str],
        keywords: list[str],
        preferred_index: int = 1,
    ) -> GeneratedQuestion:
        sentence = self._pick_sentence(sentences, preferred_index=preferred_index)

        correct = sentence
        candidates = [item for item in sentences if item != correct]

        candidates.extend(
            [
                "У тексті прямо сказано, що події відбувалися без жодної причини.",
                "У тексті зазначено, що герой не брав участі в подіях.",
                "У тексті сказано, що читання не мало жодного значення.",
            ]
        )

        options = self._normalize_options(correct, candidates)

        keyword_part = f" про «{keywords[0]}»" if keywords else ""

        return GeneratedQuestion(
            question_type="detail",
            text=f"Яка деталь прямо згадується у тексті{keyword_part}?",
            options=options,
            correct_answer=correct,
            explanation=(
                "Правильна відповідь містить інформацію, яка прямо присутня "
                "у вихідному тексті."
            ),
        )

    def _build_sequence_question(self, sentences: list[str]) -> GeneratedQuestion:
        first_event = sentences[0]
        later_events = sentences[1:]

        options = self._normalize_options(
            first_event,
            later_events
            + [
                "Спочатку завершився весь квест.",
                "Спочатку герой отримав фінальну нагороду.",
                "Спочатку всі події вже були розв'язані.",
            ],
        )

        return GeneratedQuestion(
            question_type="sequence",
            text="Яка подія відбулася раніше за інші?",
            options=options,
            correct_answer=first_event,
            explanation=(
                "Щоб відповісти на питання про послідовність, потрібно звернути "
                "увагу на порядок подій у тексті."
            ),
        )

    def _build_cause_effect_question(self, sentences: list[str]) -> GeneratedQuestion:
        sentence_with_reason = self._find_sentence_with_reason(sentences)

        correct = sentence_with_reason or (
            "Уважне читання допомагає краще зрозуміти події та правильно "
            "відповісти на питання."
        )

        options = self._normalize_options(
            correct,
            [
                correct,
                "Тому що відповіді можна обирати випадково.",
                "Тому що зміст тексту не має значення.",
                "Тому що всі питання не пов'язані з прочитаним.",
            ],
        )

        return GeneratedQuestion(
            question_type="cause_effect",
            text="Чому у квесті важливо уважно читати текст?",
            options=options,
            correct_answer=correct,
            explanation=(
                "Питання на причину й наслідок перевіряє, чи зрозуміло, "
                "чому певна дія або подія була важливою."
            ),
        )

    def _build_character_question(self, hero: str | None) -> GeneratedQuestion:
        hero_name = hero or "головного героя"

        correct = (
            f"Про {hero_name} можна сказати, що він або вона пов'язаний "
            "з основними подіями тексту."
        )

        options = self._normalize_options(
            correct,
            [
                correct,
                f"{hero_name} не має жодного стосунку до подій тексту.",
                f"{hero_name} згадується тільки в назві й більше не з'являється.",
                f"{hero_name} не може бути пов'язаний зі змістом прочитаного.",
            ],
        )

        return GeneratedQuestion(
            question_type="character",
            text=f"Що можна сказати про {hero_name}?",
            options=options,
            correct_answer=correct,
            explanation=(
                "Питання про персонажа перевіряє розуміння його ролі "
                "у змісті тексту."
            ),
        )

    def _build_attention_question(self, sentences: list[str]) -> GeneratedQuestion:
        correct = self._pick_sentence(sentences, preferred_index=0)

        options = self._normalize_options(
            correct,
            [
                correct,
                "У тексті немає жодної важливої деталі.",
                "Усі події в тексті відбуваються без зв'язку між собою.",
                "Зміст тексту не потрібно враховувати під час відповіді.",
            ],
        )

        return GeneratedQuestion(
            question_type="attention",
            text="Яке твердження можна підтвердити змістом тексту?",
            options=options,
            correct_answer=correct,
            explanation=(
                "Це питання перевіряє уважність до конкретної інформації "
                "з прочитаного матеріалу."
            ),
        )

    def _build_keyword_question(self, keywords: list[str]) -> GeneratedQuestion:
        keyword = keywords[0] if keywords else "події"

        correct = f"Слово або тема «{keyword}» пов'язана зі змістом прочитаного тексту."

        options = self._normalize_options(
            correct,
            [
                correct,
                f"Тема «{keyword}» не має жодного зв'язку з текстом.",
                "У тексті немає жодної повторюваної теми.",
                "Ключові слова не допомагають зрозуміти зміст.",
            ],
        )

        return GeneratedQuestion(
            question_type="keyword",
            text="Яке твердження найкраще пов'язане з ключовими словами тексту?",
            options=options,
            correct_answer=correct,
            explanation=(
                "Ключові слова допомагають визначити важливі теми й повторювані "
                "елементи змісту."
            ),
        )

    def _build_summary_question(self, title: str) -> GeneratedQuestion:
        correct = (
            "Після читання можна перевірити розуміння тексту за допомогою питань."
        )

        options = self._normalize_options(
            correct,
            [
                correct,
                "Після читання неможливо перевірити розуміння тексту.",
                "Питання не мають бути пов'язані з прочитаним.",
                "Результат квесту не залежить від уважності читача.",
            ],
        )

        return GeneratedQuestion(
            question_type="summary",
            text=f"Для чого створено квест за текстом «{title}»?",
            options=options,
            correct_answer=correct,
            explanation=(
                "Квест потрібен для того, щоб перевірити розуміння прочитаного "
                "та зробити навчання більш інтерактивним."
            ),
        )

    @staticmethod
    def _normalize_question_count(value: int) -> int:
        allowed = [3, 5, 7, 10]

        if value in allowed:
            return value

        return min(allowed, key=lambda item: abs(item - value))

    @staticmethod
    def _clean_text(text: str) -> str:
        return re.sub(r"\s+", " ", text).strip()

    @staticmethod
    def _split_sentences(text: str) -> list[str]:
        parts = re.split(r"(?<=[.!?])\s+", text)
        return [part.strip() for part in parts if len(part.strip()) > 35]

    @staticmethod
    def _build_safe_sentences(text: str) -> list[str]:
        short = text[:200] if text else "У тексті описано події та персонажів."

        return [
            short,
            "У тексті є події, які потрібно уважно прочитати.",
            "Для правильного розуміння важливо звертати увагу на деталі.",
            "Основна думка тексту пов'язана з розвитком подій.",
            "Після читання можна перевірити себе за допомогою питань.",
        ]

    @staticmethod
    def _extract_keywords(text: str) -> list[str]:
        words = re.findall(r"[А-Яа-яA-Za-zІіЇїЄєҐґ]{5,}", text.lower())

        stop_words = {
            "цього",
            "після",
            "перед",
            "який",
            "яка",
            "вони",
            "було",
            "була",
            "були",
            "дуже",
            "коли",
            "тому",
            "через",
            "щоб",
            "може",
            "свої",
            "свою",
            "його",
            "вона",
            "воно",
            "текст",
            "книга",
            "книжки",
        }

        frequency: dict[str, int] = {}

        for word in words:
            if word not in stop_words:
                frequency[word] = frequency.get(word, 0) + 1

        sorted_words = sorted(
            frequency.items(),
            key=lambda item: item[1],
            reverse=True,
        )

        return [word for word, _ in sorted_words[:10]]

    @staticmethod
    def _extract_probable_hero(text: str) -> str | None:
        candidates = re.findall(r"\b[А-ЯІЇЄҐ][а-яіїєґ]{2,}\b", text)

        ignored = {
            "Одного",
            "Коли",
            "Щоб",
            "Тому",
            "Після",
            "Перед",
            "Україна",
        }

        for candidate in candidates:
            if candidate not in ignored:
                return candidate

        return None

    @staticmethod
    def _pick_sentence(sentences: list[str], preferred_index: int = 0) -> str:
        if not sentences:
            return "У тексті описано важливу подію."

        if preferred_index < len(sentences):
            return sentences[preferred_index]

        return sentences[0]

    @staticmethod
    def _find_sentence_with_reason(sentences: list[str]) -> str | None:
        markers = ["щоб", "тому", "бо", "оскільки", "для того"]

        for sentence in sentences:
            lower = sentence.lower()

            if any(marker in lower for marker in markers):
                return sentence

        return None

    @staticmethod
    def _normalize_options(correct: str, candidates: list[str]) -> list[str]:
        normalized: list[str] = []
        seen: set[str] = set()

        def add_option(value: str):
            clean = re.sub(r"\s+", " ", str(value)).strip()

            if not clean:
                return

            key = clean.casefold()

            if key not in seen:
                seen.add(key)
                normalized.append(clean)

        add_option(correct)

        for candidate in candidates:
            add_option(candidate)

            if len(normalized) >= 4:
                break

        fallback_options = [
            "Такого твердження немає у тексті.",
            "Цей варіант не підтверджується змістом.",
            "Ця відповідь суперечить прочитаному.",
            "Цей варіант не пов'язаний з основними подіями.",
        ]

        for fallback in fallback_options:
            if len(normalized) >= 4:
                break

            add_option(fallback)

        normalized = normalized[:4]
        random.shuffle(normalized)

        return normalized

    @staticmethod
    def _calculate_xp(
        difficulty: str,
        pages_read: int,
        question_count: int,
    ) -> int:
        base = {
            "easy": 40,
            "medium": 60,
            "hard": 85,
        }.get(difficulty, 60)

        page_bonus = min(pages_read * 2, 40)
        question_bonus = max(0, question_count - 5) * 5

        return base + page_bonus + question_bonus