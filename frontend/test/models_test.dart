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
        'options': ['Варіант 1', 'Варіант 2', 'Варіант 3', 'Варіант 4'],
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
    test('parses AttemptResult from JSON with recommendation', () {
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
        'recommendation': 'Рекомендовано пройти ще один квест.',
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
      expect(result.recommendation, 'Рекомендовано пройти ще один квест.');
      expect(result.answers.length, 2);
      expect(result.answers.first.isCorrect, true);
      expect(result.answers.last.isCorrect, false);
    });

    test('uses message as recommendation fallback', () {
      final json = {
        'attempt_id': 7,
        'user_id': 2,
        'quest_id': 10,
        'score': 1,
        'total_questions': 3,
        'earned_xp': 10,
        'earned_coins': 2,
        'percentage': 33.33,
        'message': 'Спробуй ще раз.',
        'answers': <Map<String, dynamic>>[],
      };

      final result = AttemptResult.fromJson(json);

      expect(result.recommendation, 'Спробуй ще раз.');
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
        recommendation: 'Варто повторити окремі фрагменти.',
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
      expect(report['recommendation'], 'Варто повторити окремі фрагменти.');
      expect(report['answers'], isA<List>());
      expect((report['answers'] as List).length, 1);
    });
  });

  group('Progress and history models', () {
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

  group('Gamification models', () {
    test('parses Achievement from JSON', () {
      final json = {
        'key': 'first_quest',
        'title': 'Перше проходження',
        'description': 'Учень завершив перший навчальний квест.',
        'icon': 'flag',
        'color': 'green',
        'is_unlocked': true,
        'current_value': 1,
        'target_value': 1,
        'progress_percent': 100.0,
      };

      final achievement = Achievement.fromJson(json);

      expect(achievement.key, 'first_quest');
      expect(achievement.isUnlocked, true);
      expect(achievement.progressPercent, 100.0);
    });

    test('parses AvatarShop and finds equipped item by category', () {
      final json = {
        'user_id': 1,
        'coins': 16,
        'unlocked_items': ['hat_star'],
        'equipped_items': ['hat_star'],
        'items': [
          {
            'key': 'hat_star',
            'title': 'Зоряний капелюх',
            'description': 'Яскравий капелюх.',
            'category': 'hat',
            'price': 8,
            'icon': 'star',
            'color': 'yellow',
            'is_unlocked': true,
            'is_equipped': true,
          },
          {
            'key': 'pet_owl',
            'title': 'Мудра сова',
            'description': 'Помічник для читання.',
            'category': 'pet',
            'price': 18,
            'icon': 'pets',
            'color': 'blue',
            'is_unlocked': false,
            'is_equipped': false,
          },
        ],
      };

      final shop = AvatarShop.fromJson(json);

      expect(shop.userId, 1);
      expect(shop.coins, 16);
      expect(shop.items.length, 2);
      expect(shop.equippedByCategory('hat')?.key, 'hat_star');
      expect(shop.equippedByCategory('pet'), isNull);
    });

    test('parses PurchaseResult from JSON', () {
      final json = {
        'message': 'Предмет успішно куплено та активовано.',
        'user_id': 1,
        'coins': 8,
        'purchased_item': {
          'key': 'hat_star',
          'title': 'Зоряний капелюх',
          'description': 'Яскравий капелюх.',
          'category': 'hat',
          'price': 8,
          'icon': 'star',
          'color': 'yellow',
          'is_unlocked': true,
          'is_equipped': true,
        },
        'shop': {
          'user_id': 1,
          'coins': 8,
          'unlocked_items': ['hat_star'],
          'equipped_items': ['hat_star'],
          'items': [
            {
              'key': 'hat_star',
              'title': 'Зоряний капелюх',
              'description': 'Яскравий капелюх.',
              'category': 'hat',
              'price': 8,
              'icon': 'star',
              'color': 'yellow',
              'is_unlocked': true,
              'is_equipped': true,
            },
          ],
        },
      };

      final result = PurchaseResult.fromJson(json);

      expect(result.userId, 1);
      expect(result.coins, 8);
      expect(result.purchasedItem.key, 'hat_star');
      expect(result.shop.equippedItems, ['hat_star']);
    });

    test('parses StreakStats and converts to JSON', () {
      final json = {
        'user_id': 1,
        'current_streak': 3,
        'longest_streak': 5,
        'active_today': true,
        'last_activity': '2026-06-01T00:00:00',
        'message': 'Серія вже формується.',
      };

      final streak = StreakStats.fromJson(json);
      final report = streak.toJson();

      expect(streak.userId, 1);
      expect(streak.currentStreak, 3);
      expect(streak.longestStreak, 5);
      expect(streak.activeToday, true);
      expect(streak.lastActivity?.year, 2026);
      expect(report['current_streak'], 3);
    });

    test('parses LeaderboardEntry from JSON', () {
      final json = {
        'rank': 1,
        'user_id': 1,
        'username': 'Demo Reader',
        'grade_level': 5,
        'total_xp': 240,
        'coins': 16,
        'level': 3,
        'completed_quests': 11,
        'average_percentage': 72.5,
        'best_percentage': 100.0,
        'current_streak': 2,
      };

      final entry = LeaderboardEntry.fromJson(json);

      expect(entry.rank, 1);
      expect(entry.username, 'Demo Reader');
      expect(entry.level, 3);
      expect(entry.averagePercentage, 72.5);
      expect(entry.currentStreak, 2);
    });
  });

  group('Teacher dashboard models', () {
    test('parses TeacherAnalytics legacy model', () {
      final json = {
        'user_id': 1,
        'username': 'Demo Reader',
        'average_percentage': 80.0,
        'best_percentage': 100.0,
        'attempt_count': 2,
        'completed_quests': 2,
        'openai_count': 1,
        'algorithm_count': 1,
        'total_earned_xp': 120,
        'total_earned_coins': 24,
        'recommendation': 'Результати добрі.',
        'history': [
          {
            'attempt_id': 1,
            'quest_id': 10,
            'title': 'Квест',
            'percentage': 80.0,
            'score': 4,
            'total_questions': 5,
            'earned_xp': 60,
            'earned_coins': 12,
            'generated_by': 'algorithm',
            'created_at': '2026-06-01T10:00:00',
          },
        ],
      };

      final analytics = TeacherAnalytics.fromJson(json);

      expect(analytics.userId, 1);
      expect(analytics.averagePercentage, 80.0);
      expect(analytics.openAiCount, 1);
      expect(analytics.algorithmCount, 1);
      expect(analytics.history.length, 1);
    });

    test('parses TeacherDashboard and creates export JSON', () {
      final json = {
        'selected_user_id': 1,
        'selected_username': 'Demo Reader',
        'students': [
          {
            'user_id': 1,
            'username': 'Demo Reader',
            'grade_level': 5,
            'total_xp': 180,
            'coins': 16,
            'completed_quests': 5,
            'average_percentage': 76.0,
            'best_percentage': 100.0,
            'last_activity': '2026-06-01T10:00:00',
          },
        ],
        'average_percentage': 76.0,
        'best_percentage': 100.0,
        'worst_percentage': 40.0,
        'attempt_count': 5,
        'completed_quests': 5,
        'openai_count': 2,
        'algorithm_count': 3,
        'total_earned_xp': 180,
        'total_earned_coins': 36,
        'total_correct_answers': 19,
        'total_questions': 25,
        'success_trend': 'стабільний',
        'recommendation': 'Можна поступово підвищувати складність.',
        'strong_sides': ['Є регулярна історія проходжень.'],
        'attention_points': ['Варто повторити складні тексти.'],
        'metrics': [
          {
            'key': 'average',
            'title': 'Середній результат',
            'value': '76%',
            'subtitle': 'за останніми проходженнями',
            'icon': 'percent',
            'color': 'purple',
          },
        ],
        'chart': [
          {
            'attempt_id': 1,
            'quest_id': 10,
            'title': 'Квест',
            'label': 'Квест 1',
            'percentage': 76.0,
            'score': 4,
            'total_questions': 5,
            'generated_by': 'algorithm',
            'created_at': '2026-06-01T10:00:00',
          },
        ],
        'insights': [
          {
            'title': 'Сильні сторони',
            'description': 'Є регулярна історія проходжень.',
            'kind': 'positive',
            'icon': 'thumb_up',
          },
        ],
      };

      final dashboard = TeacherDashboard.fromJson(json);
      final report = dashboard.toReportJson();

      expect(dashboard.selectedUserId, 1);
      expect(dashboard.selectedUsername, 'Demo Reader');
      expect(dashboard.students.length, 1);
      expect(dashboard.averagePercentage, 76.0);
      expect(dashboard.bestPercentage, 100.0);
      expect(dashboard.worstPercentage, 40.0);
      expect(dashboard.openAiCount, 2);
      expect(dashboard.algorithmCount, 3);
      expect(dashboard.metrics.length, 1);
      expect(dashboard.chart.length, 1);
      expect(dashboard.insights.length, 1);

      expect(report['selected_user_id'], 1);
      expect(report['selected_username'], 'Demo Reader');
      expect(report['chart'], isA<List>());
      expect((report['chart'] as List).length, 1);
    });
  });
}
