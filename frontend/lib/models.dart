class QuestQuestion {
  final int id;
  final int orderNumber;
  final String questionType;
  final String text;
  final List<String> options;

  QuestQuestion({
    required this.id,
    required this.orderNumber,
    required this.questionType,
    required this.text,
    required this.options,
  });

  factory QuestQuestion.fromJson(Map<String, dynamic> json) {
    return QuestQuestion(
      id: json['id'],
      orderNumber: json['order_number'],
      questionType: json['question_type'],
      text: json['text'],
      options: List<String>.from(json['options']),
    );
  }
}

class Quest {
  final int id;
  final int userId;
  final String title;
  final String scenario;
  final String difficulty;
  final String generatedBy;
  final int xpReward;
  final int coinsReward;
  final List<QuestQuestion> questions;

  Quest({
    required this.id,
    required this.userId,
    required this.title,
    required this.scenario,
    required this.difficulty,
    required this.generatedBy,
    required this.xpReward,
    required this.coinsReward,
    required this.questions,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      scenario: json['scenario'],
      difficulty: json['difficulty'],
      generatedBy: json['generated_by'],
      xpReward: json['xp_reward'],
      coinsReward: json['coins_reward'],
      questions: (json['questions'] as List)
          .map((item) => QuestQuestion.fromJson(item))
          .toList(),
    );
  }
}

class AttemptAnswerReview {
  final int questionId;
  final int orderNumber;
  final String questionText;
  final String selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String explanation;

  AttemptAnswerReview({
    required this.questionId,
    required this.orderNumber,
    required this.questionText,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.explanation,
  });

  factory AttemptAnswerReview.fromJson(Map<String, dynamic> json) {
    return AttemptAnswerReview(
      questionId: json['question_id'],
      orderNumber: json['order_number'],
      questionText: json['question_text'],
      selectedAnswer: json['selected_answer'],
      correctAnswer: json['correct_answer'],
      isCorrect: json['is_correct'],
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'order_number': orderNumber,
      'question_text': questionText,
      'selected_answer': selectedAnswer,
      'correct_answer': correctAnswer,
      'is_correct': isCorrect,
      'explanation': explanation,
    };
  }
}

class AttemptResult {
  final int attemptId;
  final int userId;
  final int questId;

  final int score;
  final int totalQuestions;
  final int earnedXp;
  final int earnedCoins;
  final double percentage;
  final String message;
  final String recommendation;

  final List<AttemptAnswerReview> answers;

  AttemptResult({
    required this.attemptId,
    required this.userId,
    required this.questId,
    required this.score,
    required this.totalQuestions,
    required this.earnedXp,
    required this.earnedCoins,
    required this.percentage,
    required this.message,
    required this.recommendation,
    required this.answers,
  });

  factory AttemptResult.fromJson(Map<String, dynamic> json) {
    return AttemptResult(
      attemptId: json['attempt_id'],
      userId: json['user_id'],
      questId: json['quest_id'],
      score: json['score'],
      totalQuestions: json['total_questions'],
      earnedXp: json['earned_xp'],
      earnedCoins: json['earned_coins'],
      percentage: (json['percentage'] as num).toDouble(),
      message: json['message'],
      recommendation: json['recommendation'] ?? json['message'],
      answers: (json['answers'] as List)
          .map((item) => AttemptAnswerReview.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toReportJson() {
    return {
      'attempt_id': attemptId,
      'user_id': userId,
      'quest_id': questId,
      'score': score,
      'total_questions': totalQuestions,
      'percentage': percentage,
      'earned_xp': earnedXp,
      'earned_coins': earnedCoins,
      'message': message,
      'recommendation': recommendation,
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }
}

class UserProgress {
  final int userId;
  final String username;
  final int gradeLevel;

  final int totalXp;
  final int coins;
  final int completedQuests;

  final int level;
  final int currentLevelXp;
  final int nextLevelXp;
  final double levelProgressPercent;

  UserProgress({
    required this.userId,
    required this.username,
    required this.gradeLevel,
    required this.totalXp,
    required this.coins,
    required this.completedQuests,
    required this.level,
    required this.currentLevelXp,
    required this.nextLevelXp,
    required this.levelProgressPercent,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['user_id'],
      username: json['username'],
      gradeLevel: json['grade_level'],
      totalXp: json['total_xp'],
      coins: json['coins'],
      completedQuests: json['completed_quests'],
      level: json['level'],
      currentLevelXp: json['current_level_xp'],
      nextLevelXp: json['next_level_xp'],
      levelProgressPercent: (json['level_progress_percent'] as num).toDouble(),
    );
  }
}

class QuestHistoryItem {
  final int attemptId;
  final int questId;

  final String title;
  final String difficulty;
  final String generatedBy;

  final int score;
  final int totalQuestions;
  final double percentage;

  final int earnedXp;
  final int earnedCoins;
  final DateTime createdAt;

  QuestHistoryItem({
    required this.attemptId,
    required this.questId,
    required this.title,
    required this.difficulty,
    required this.generatedBy,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.earnedXp,
    required this.earnedCoins,
    required this.createdAt,
  });

  factory QuestHistoryItem.fromJson(Map<String, dynamic> json) {
    return QuestHistoryItem(
      attemptId: json['attempt_id'],
      questId: json['quest_id'],
      title: json['title'],
      difficulty: json['difficulty'],
      generatedBy: json['generated_by'],
      score: json['score'],
      totalQuestions: json['total_questions'],
      percentage: (json['percentage'] as num).toDouble(),
      earnedXp: json['earned_xp'],
      earnedCoins: json['earned_coins'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class LibraryText {
  final int id;
  final String title;
  final String? author;
  final String content;
  final int targetAge;
  final int pagesRead;
  final DateTime createdAt;

  LibraryText({
    required this.id,
    required this.title,
    required this.author,
    required this.content,
    required this.targetAge,
    required this.pagesRead,
    required this.createdAt,
  });

  factory LibraryText.fromJson(Map<String, dynamic> json) {
    return LibraryText(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      content: json['content'],
      targetAge: json['target_age'],
      pagesRead: json['pages_read'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}



class Achievement {
  final String key;
  final String title;
  final String description;
  final String icon;
  final String color;
  final bool isUnlocked;
  final int currentValue;
  final int targetValue;
  final double progressPercent;

  Achievement({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isUnlocked,
    required this.currentValue,
    required this.targetValue,
    required this.progressPercent,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      key: json['key'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      color: json['color'],
      isUnlocked: json['is_unlocked'],
      currentValue: json['current_value'],
      targetValue: json['target_value'],
      progressPercent: (json['progress_percent'] as num).toDouble(),
    );
  }
}

class ShopItem {
  final String key;
  final String title;
  final String description;
  final String category;
  final int price;
  final String icon;
  final String color;
  final bool isUnlocked;
  final bool isEquipped;

  ShopItem({
    required this.key,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.icon,
    required this.color,
    required this.isUnlocked,
    required this.isEquipped,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      key: json['key'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      price: json['price'],
      icon: json['icon'],
      color: json['color'],
      isUnlocked: json['is_unlocked'],
      isEquipped: json['is_equipped'],
    );
  }
}

class AvatarShop {
  final int userId;
  final int coins;
  final List<String> unlockedItems;
  final List<String> equippedItems;
  final List<ShopItem> items;

  AvatarShop({
    required this.userId,
    required this.coins,
    required this.unlockedItems,
    required this.equippedItems,
    required this.items,
  });

  factory AvatarShop.fromJson(Map<String, dynamic> json) {
    return AvatarShop(
      userId: json['user_id'],
      coins: json['coins'],
      unlockedItems: List<String>.from(json['unlocked_items']),
      equippedItems: List<String>.from(json['equipped_items']),
      items: (json['items'] as List)
          .map((item) => ShopItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  ShopItem? equippedByCategory(String category) {
    for (final item in items) {
      if (item.category == category && item.isEquipped) {
        return item;
      }
    }

    return null;
  }
}

class PurchaseResult {
  final String message;
  final int userId;
  final int coins;
  final ShopItem purchasedItem;
  final AvatarShop shop;

  PurchaseResult({
    required this.message,
    required this.userId,
    required this.coins,
    required this.purchasedItem,
    required this.shop,
  });

  factory PurchaseResult.fromJson(Map<String, dynamic> json) {
    return PurchaseResult(
      message: json['message'],
      userId: json['user_id'],
      coins: json['coins'],
      purchasedItem: ShopItem.fromJson(
        json['purchased_item'] as Map<String, dynamic>,
      ),
      shop: AvatarShop.fromJson(
        json['shop'] as Map<String, dynamic>,
      ),
    );
  }
}

class AnalyticsHistoryPoint {
  final int attemptId;
  final int questId;
  final String title;
  final double percentage;
  final int score;
  final int totalQuestions;
  final int earnedXp;
  final int earnedCoins;
  final String generatedBy;
  final DateTime createdAt;

  AnalyticsHistoryPoint({
    required this.attemptId,
    required this.questId,
    required this.title,
    required this.percentage,
    required this.score,
    required this.totalQuestions,
    required this.earnedXp,
    required this.earnedCoins,
    required this.generatedBy,
    required this.createdAt,
  });

  factory AnalyticsHistoryPoint.fromJson(Map<String, dynamic> json) {
    return AnalyticsHistoryPoint(
      attemptId: json['attempt_id'],
      questId: json['quest_id'],
      title: json['title'],
      percentage: (json['percentage'] as num).toDouble(),
      score: json['score'],
      totalQuestions: json['total_questions'],
      earnedXp: json['earned_xp'],
      earnedCoins: json['earned_coins'],
      generatedBy: json['generated_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class TeacherAnalytics {
  final int userId;
  final String username;
  final double averagePercentage;
  final double bestPercentage;
  final int attemptCount;
  final int completedQuests;
  final int openAiCount;
  final int algorithmCount;
  final int totalEarnedXp;
  final int totalEarnedCoins;
  final String recommendation;
  final List<AnalyticsHistoryPoint> history;

  TeacherAnalytics({
    required this.userId,
    required this.username,
    required this.averagePercentage,
    required this.bestPercentage,
    required this.attemptCount,
    required this.completedQuests,
    required this.openAiCount,
    required this.algorithmCount,
    required this.totalEarnedXp,
    required this.totalEarnedCoins,
    required this.recommendation,
    required this.history,
  });

  factory TeacherAnalytics.fromJson(Map<String, dynamic> json) {
    return TeacherAnalytics(
      userId: json['user_id'],
      username: json['username'],
      averagePercentage: (json['average_percentage'] as num).toDouble(),
      bestPercentage: (json['best_percentage'] as num).toDouble(),
      attemptCount: json['attempt_count'],
      completedQuests: json['completed_quests'],
      openAiCount: json['openai_count'],
      algorithmCount: json['algorithm_count'],
      totalEarnedXp: json['total_earned_xp'],
      totalEarnedCoins: json['total_earned_coins'],
      recommendation: json['recommendation'],
      history: (json['history'] as List)
          .map((item) => AnalyticsHistoryPoint.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}


class StudentSummary {
  final int userId;
  final String username;
  final int gradeLevel;
  final int totalXp;
  final int coins;
  final int completedQuests;
  final double averagePercentage;
  final double bestPercentage;
  final DateTime? lastActivity;

  StudentSummary({
    required this.userId,
    required this.username,
    required this.gradeLevel,
    required this.totalXp,
    required this.coins,
    required this.completedQuests,
    required this.averagePercentage,
    required this.bestPercentage,
    required this.lastActivity,
  });

  factory StudentSummary.fromJson(Map<String, dynamic> json) {
    final rawLastActivity = json['last_activity'];

    return StudentSummary(
      userId: json['user_id'],
      username: json['username'],
      gradeLevel: json['grade_level'],
      totalXp: json['total_xp'],
      coins: json['coins'],
      completedQuests: json['completed_quests'],
      averagePercentage: (json['average_percentage'] as num).toDouble(),
      bestPercentage: (json['best_percentage'] as num).toDouble(),
      lastActivity: rawLastActivity == null
          ? null
          : DateTime.parse(rawLastActivity.toString()),
    );
  }
}

class TeacherMetric {
  final String key;
  final String title;
  final String value;
  final String subtitle;
  final String icon;
  final String color;

  TeacherMetric({
    required this.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  factory TeacherMetric.fromJson(Map<String, dynamic> json) {
    return TeacherMetric(
      key: json['key'],
      title: json['title'],
      value: json['value'],
      subtitle: json['subtitle'],
      icon: json['icon'],
      color: json['color'],
    );
  }
}

class TeacherChartPoint {
  final int attemptId;
  final int questId;
  final String title;
  final String label;
  final double percentage;
  final int score;
  final int totalQuestions;
  final String generatedBy;
  final DateTime createdAt;

  TeacherChartPoint({
    required this.attemptId,
    required this.questId,
    required this.title,
    required this.label,
    required this.percentage,
    required this.score,
    required this.totalQuestions,
    required this.generatedBy,
    required this.createdAt,
  });

  factory TeacherChartPoint.fromJson(Map<String, dynamic> json) {
    return TeacherChartPoint(
      attemptId: json['attempt_id'],
      questId: json['quest_id'],
      title: json['title'],
      label: json['label'],
      percentage: (json['percentage'] as num).toDouble(),
      score: json['score'],
      totalQuestions: json['total_questions'],
      generatedBy: json['generated_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attempt_id': attemptId,
      'quest_id': questId,
      'title': title,
      'label': label,
      'percentage': percentage,
      'score': score,
      'total_questions': totalQuestions,
      'generated_by': generatedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class TeacherInsight {
  final String title;
  final String description;
  final String kind;
  final String icon;

  TeacherInsight({
    required this.title,
    required this.description,
    required this.kind,
    required this.icon,
  });

  factory TeacherInsight.fromJson(Map<String, dynamic> json) {
    return TeacherInsight(
      title: json['title'],
      description: json['description'],
      kind: json['kind'],
      icon: json['icon'],
    );
  }
}

class TeacherDashboard {
  final int? selectedUserId;
  final String? selectedUsername;
  final List<StudentSummary> students;

  final double averagePercentage;
  final double bestPercentage;
  final double worstPercentage;
  final int attemptCount;
  final int completedQuests;

  final int openAiCount;
  final int algorithmCount;

  final int totalEarnedXp;
  final int totalEarnedCoins;
  final int totalCorrectAnswers;
  final int totalQuestions;

  final String successTrend;
  final String recommendation;

  final List<String> strongSides;
  final List<String> attentionPoints;

  final List<TeacherMetric> metrics;
  final List<TeacherChartPoint> chart;
  final List<TeacherInsight> insights;

  TeacherDashboard({
    required this.selectedUserId,
    required this.selectedUsername,
    required this.students,
    required this.averagePercentage,
    required this.bestPercentage,
    required this.worstPercentage,
    required this.attemptCount,
    required this.completedQuests,
    required this.openAiCount,
    required this.algorithmCount,
    required this.totalEarnedXp,
    required this.totalEarnedCoins,
    required this.totalCorrectAnswers,
    required this.totalQuestions,
    required this.successTrend,
    required this.recommendation,
    required this.strongSides,
    required this.attentionPoints,
    required this.metrics,
    required this.chart,
    required this.insights,
  });

  factory TeacherDashboard.fromJson(Map<String, dynamic> json) {
    return TeacherDashboard(
      selectedUserId: json['selected_user_id'],
      selectedUsername: json['selected_username'],
      students: (json['students'] as List)
          .map((item) => StudentSummary.fromJson(item as Map<String, dynamic>))
          .toList(),
      averagePercentage: (json['average_percentage'] as num).toDouble(),
      bestPercentage: (json['best_percentage'] as num).toDouble(),
      worstPercentage: (json['worst_percentage'] as num).toDouble(),
      attemptCount: json['attempt_count'],
      completedQuests: json['completed_quests'],
      openAiCount: json['openai_count'],
      algorithmCount: json['algorithm_count'],
      totalEarnedXp: json['total_earned_xp'],
      totalEarnedCoins: json['total_earned_coins'],
      totalCorrectAnswers: json['total_correct_answers'],
      totalQuestions: json['total_questions'],
      successTrend: json['success_trend'],
      recommendation: json['recommendation'],
      strongSides: List<String>.from(json['strong_sides']),
      attentionPoints: List<String>.from(json['attention_points']),
      metrics: (json['metrics'] as List)
          .map((item) => TeacherMetric.fromJson(item as Map<String, dynamic>))
          .toList(),
      chart: (json['chart'] as List)
          .map((item) => TeacherChartPoint.fromJson(item as Map<String, dynamic>))
          .toList(),
      insights: (json['insights'] as List)
          .map((item) => TeacherInsight.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toReportJson() {
    return {
      'selected_user_id': selectedUserId,
      'selected_username': selectedUsername,
      'average_percentage': averagePercentage,
      'best_percentage': bestPercentage,
      'worst_percentage': worstPercentage,
      'attempt_count': attemptCount,
      'completed_quests': completedQuests,
      'openai_count': openAiCount,
      'algorithm_count': algorithmCount,
      'total_earned_xp': totalEarnedXp,
      'total_earned_coins': totalEarnedCoins,
      'total_correct_answers': totalCorrectAnswers,
      'total_questions': totalQuestions,
      'success_trend': successTrend,
      'recommendation': recommendation,
      'strong_sides': strongSides,
      'attention_points': attentionPoints,
      'chart': chart.map((item) => item.toJson()).toList(),
    };
  }
}
