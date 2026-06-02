import 'package:flutter_test/flutter_test.dart';

import '../lib/models.dart';

void main() {
  group('QuestQuestion model', () {
    test('parses QuestQuestion from JSON', () {
      final json = {
        'id': 1,
        'order_number': 2,
        'question_type': 'single_choice',
        'text': 'Яка головна ідея тексту?',
        'options': [
          'Варіант 1',
          'Варіант 2',
          'Варіант 3',
          'Варіант 4',
        ],
      };

      final question = QuestQuestion.fromJson(json);

      expect(question.id, 1);
      expect(question.orderNumber, 2);
      expect(question.questionType, 'single_choice');
      expect(question.text, 'Яка головна ідея тексту?');
      expect(question.options.length, 4);
      expect(question.options.first, 'Варіант 1');
    });
  });

  group('Quest model', () {
    test('parses Quest with questions from JSON', () {
      final json = {
        'id': 10,
        'user_id': 5,
        'title': 'Квест за текстом',
        'scenario': 'Пройди квест і отримай нагороду.',
        'difficulty': 'medium',
        'generated_by': 'algorithm',
        'xp_reward': 60,
        'coins_reward': 12,
        'questions': [
          {
            'id': 1,
            'order_number': 1,
            'question_type': 'single_choice',
            'text': 'Питання 1',
            'options': ['A', 'B', 'C', 'D'],
          },
          {
            'id': 2,
            'order_number': 2,
            'question_type': 'single_choice',
            'text': 'Питання 2',
            'options': ['A1', 'B1', 'C1', 'D1'],
          },
        ],
      };

      final quest = Quest.fromJson(json);

      expect(quest.id, 10);
      expect(quest.userId, 5);
      expect(quest.title, 'Квест за текстом');
      expect(quest.scenario, 'Пройди квест і отримай нагороду.');
      expect(quest.difficulty, 'medium');
      expect(quest.generatedBy, 'algorithm');
      expect(quest.xpReward, 60);
      expect(quest.coinsReward, 12);
      expect(quest.questions.length, 2);
      expect(quest.questions[0].text, 'Питання 1');
      expect(quest.questions[1].orderNumber, 2);
    });
  });

  group('AttemptAnswerReview model', () {
    test('parses AttemptAnswerReview from JSON', () {
      final json = {
        'question_id': 3,
        'order_number': 1,
        'question_text': 'Що знайшла Марійка?',
        'selected_answer': 'Книгу',
        'correct_answer': 'Книгу',
        'is_correct': true,
        'explanation': 'Ця відповідь прямо згадується у тексті.',
      };

      final review = AttemptAnswerReview.fromJson(json);

      expect(review.questionId, 3);
      expect(review.orderNumber, 1);
      expect(review.questionText, 'Що знайшла Марійка?');
      expect(review.selectedAnswer, 'Книгу');
      expect(review.correctAnswer, 'Книгу');
      expect(review.isCorrect, true);
      expect(review.explanation, 'Ця відповідь прямо згадується у тексті.');
    });

    test('converts AttemptAnswerReview to JSON', () {
      final review = AttemptAnswerReview(
        questionId: 3,
        orderNumber: 1,
        questionText: 'Що знайшла Марійка?',
        selectedAnswer: 'Книгу',
        correctAnswer: 'Книгу',
        isCorrect: true,
        explanation: 'Ця відповідь прямо згадується у тексті.',
      );

      final json = review.toJson();

      expect(json['question_id'], 3);
      expect(json['order_number'], 1);
      expect(json['question_text'], 'Що знайшла Марійка?');
      expect(json['selected_answer'], 'Книгу');
      expect(json['correct_answer'], 'Книгу');
      expect(json['is_correct'], true);
      expect(json['explanation'], 'Ця відповідь прямо згадується у тексті.');
    });
  });

  group('AttemptResult model', () {
    test('parses AttemptResult from JSON', () {
      final json = {
        'attempt_id': 7,
        'user_id': 2,
        'quest_id': 10,
        'score': 2,
        'total_questions': 3,
        'earned_xp': 40,
        'earned_coins': 8,
        'percentage': 66.67,
        'message': 'Непогано, але деякі деталі варто перечитати.',
        'answers': [
          {
            'question_id': 1,
            'order_number': 1,
            'question_text': 'Питання 1',
            'selected_answer': 'A',
            'correct_answer': 'A',
            'is_correct': true,
            'explanation': 'Пояснення 1',
          },
          {
            'question_id': 2,
            'order_number': 2,
            'question_text': 'Питання 2',
            'selected_answer': 'B',
            'correct_answer': 'C',
            'is_correct': false,
            'explanation': 'Пояснення 2',
          },
        ],
      };

      final result = AttemptResult.fromJson(json);

      expect(result.attemptId, 7);
      expect(result.userId, 2);
      expect(result.questId, 10);
      expect(result.score, 2);
      expect(result.totalQuestions, 3);
      expect(result.earnedXp, 40);
      expect(result.earnedCoins, 8);
      expect(result.percentage, 66.67);
      expect(result.message, 'Непогано, але деякі деталі варто перечитати.');
      expect(result.answers.length, 2);
      expect(result.answers.first.isCorrect, true);
      expect(result.answers.last.isCorrect, false);
    });

    test('creates report JSON from AttemptResult', () {
      final result = AttemptResult(
        attemptId: 7,
        userId: 2,
        questId: 10,
        score: 2,
        totalQuestions: 3,
        earnedXp: 40,
        earnedCoins: 8,
        percentage: 66.67,
        message: 'Непогано.',
        answers: [
          AttemptAnswerReview(
            questionId: 1,
            orderNumber: 1,
            questionText: 'Питання 1',
            selectedAnswer: 'A',
            correctAnswer: 'A',
            isCorrect: true,
            explanation: 'Пояснення 1',
          ),
        ],
      );

      final report = result.toReportJson();

      expect(report['attempt_id'], 7);
      expect(report['user_id'], 2);
      expect(report['quest_id'], 10);
      expect(report['score'], 2);
      expect(report['total_questions'], 3);
      expect(report['percentage'], 66.67);
      expect(report['earned_xp'], 40);
      expect(report['earned_coins'], 8);
      expect(report['message'], 'Непогано.');
      expect(report['answers'], isA<List>());
      expect((report['answers'] as List).length, 1);
    });
  });

  group('UserProgress model', () {
    test('parses UserProgress from JSON', () {
      final json = {
        'user_id': 1,
        'username': 'Demo Reader',
        'grade_level': 5,
        'total_xp': 180,
        'coins': 36,
        'completed_quests': 9,
        'level': 2,
        'current_level_xp': 80,
        'next_level_xp': 200,
        'level_progress_percent': 80.0,
      };

      final progress = UserProgress.fromJson(json);

      expect(progress.userId, 1);
      expect(progress.username, 'Demo Reader');
      expect(progress.gradeLevel, 5);
      expect(progress.totalXp, 180);
      expect(progress.coins, 36);
      expect(progress.completedQuests, 9);
      expect(progress.level, 2);
      expect(progress.currentLevelXp, 80);
      expect(progress.nextLevelXp, 200);
      expect(progress.levelProgressPercent, 80.0);
    });
  });

  group('QuestHistoryItem model', () {
    test('parses QuestHistoryItem from JSON', () {
      final json = {
        'attempt_id': 1,
        'quest_id': 4,
        'title': 'Квест за текстом',
        'difficulty': 'medium',
        'generated_by': 'openai',
        'score': 2,
        'total_questions': 3,
        'percentage': 66.67,
        'earned_xp': 40,
        'earned_coins': 8,
        'created_at': '2026-05-29T12:30:00',
      };

      final item = QuestHistoryItem.fromJson(json);

      expect(item.attemptId, 1);
      expect(item.questId, 4);
      expect(item.title, 'Квест за текстом');
      expect(item.difficulty, 'medium');
      expect(item.generatedBy, 'openai');
      expect(item.score, 2);
      expect(item.totalQuestions, 3);
      expect(item.percentage, 66.67);
      expect(item.earnedXp, 40);
      expect(item.earnedCoins, 8);
      expect(item.createdAt.year, 2026);
      expect(item.createdAt.month, 5);
      expect(item.createdAt.day, 29);
    });
  });

  group('LibraryText model', () {
    test('parses LibraryText from JSON', () {
      final json = {
        'id': 15,
        'title': 'Чарівна бібліотека',
        'author': 'Народна історія',
        'content': 'Текст казки для перевірки моделі.',
        'target_age': 10,
        'pages_read': 4,
        'created_at': '2026-05-29T15:45:00',
      };

      final text = LibraryText.fromJson(json);

      expect(text.id, 15);
      expect(text.title, 'Чарівна бібліотека');
      expect(text.author, 'Народна історія');
      expect(text.content, 'Текст казки для перевірки моделі.');
      expect(text.targetAge, 10);
      expect(text.pagesRead, 4);
      expect(text.createdAt.year, 2026);
      expect(text.createdAt.hour, 15);
    });
  });
}