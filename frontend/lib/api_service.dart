import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  Map<String, dynamic> _decodeMap(http.Response response) {
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  List<dynamic> _decodeList(http.Response response) {
    return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
  }

  Future<Quest> generateQuest({
    required String userName,
    required int gradeLevel,
    required String title,
    required String author,
    required String text,
    required int targetAge,
    required int pagesRead,
    required String difficulty,
    required int questionCount,
    required String generationMode,
  }) async {
    final uri = Uri.parse('$baseUrl/api/quests/generate');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        'user_name': userName,
        'grade_level': gradeLevel,
        'title': title,
        'author': author,
        'text': text,
        'target_age': targetAge,
        'pages_read': pagesRead,
        'difficulty': difficulty,
        'question_count': questionCount,
        'generation_mode': generationMode,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Помилка генерації квесту: ${response.body}');
    }

    return Quest.fromJson(_decodeMap(response));
  }

  Future<Quest> generateQuestFromLibraryText({
    required int textId,
    required String userName,
    required int gradeLevel,
    required String difficulty,
    required int questionCount,
    required String generationMode,
  }) async {
    final uri = Uri.parse('$baseUrl/api/quests/generate-from-text/$textId');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        'user_name': userName,
        'grade_level': gradeLevel,
        'difficulty': difficulty,
        'question_count': questionCount,
        'generation_mode': generationMode,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Помилка генерації квесту з бібліотеки: ${response.body}');
    }

    return Quest.fromJson(_decodeMap(response));
  }

  Future<AttemptResult> submitAnswers({
    required int questId,
    required int userId,
    required Map<int, String> answers,
  }) async {
    final uri = Uri.parse('$baseUrl/api/quests/$questId/submit');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        'user_id': userId,
        'answers': answers.entries
            .map(
              (entry) => {
                'question_id': entry.key,
                'selected_answer': entry.value,
              },
            )
            .toList(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Помилка перевірки відповідей: ${response.body}');
    }

    return AttemptResult.fromJson(_decodeMap(response));
  }

  Future<UserProgress> getUserProgress({
    required int userId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/progress/$userId');

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    );

    if (response.statusCode != 200) {
      throw Exception('Помилка завантаження прогресу: ${response.body}');
    }

    return UserProgress.fromJson(_decodeMap(response));
  }

  Future<List<QuestHistoryItem>> getQuestHistory({
    required int userId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/progress/history/$userId');

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    );

    if (response.statusCode != 200) {
      throw Exception('Помилка завантаження історії: ${response.body}');
    }

    return _decodeList(response)
        .map((item) => QuestHistoryItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Achievement>> getAchievements({
    required int userId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/progress/$userId/achievements');

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    );

    if (response.statusCode != 200) {
      throw Exception('Помилка завантаження досягнень: ${response.body}');
    }

    return _decodeList(response)
        .map((item) => Achievement.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<LibraryText>> getLibraryTexts() async {
    final uri = Uri.parse('$baseUrl/api/texts');

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    );

    if (response.statusCode != 200) {
      throw Exception('Помилка завантаження бібліотеки: ${response.body}');
    }

    return _decodeList(response)
        .map((item) => LibraryText.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<LibraryText> createLibraryText({
    required String title,
    required String author,
    required String content,
    required int targetAge,
    required int pagesRead,
  }) async {
    final uri = Uri.parse('$baseUrl/api/texts');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        'title': title,
        'author': author,
        'content': content,
        'target_age': targetAge,
        'pages_read': pagesRead,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Помилка додавання тексту: ${response.body}');
    }

    return LibraryText.fromJson(_decodeMap(response));
  }

  Future<void> deleteLibraryText({
    required int textId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/texts/$textId');

    final response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    );

    if (response.statusCode == 409) {
      final data = _decodeMap(response);
      throw Exception(data['detail']);
    }

    if (response.statusCode == 404) {
      throw Exception('Текст не знайдено або він уже був видалений.');
    }

    if (response.statusCode != 200) {
      throw Exception('Помилка видалення тексту: ${response.body}');
    }
  }


  Future<AvatarShop> getAvatarShop({
    required int userId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/progress/$userId/shop');

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    );

    if (response.statusCode != 200) {
      throw Exception('Помилка завантаження магазину нагород: ${response.body}');
    }

    return AvatarShop.fromJson(_decodeMap(response));
  }

  Future<PurchaseResult> purchaseAvatarItem({
    required int userId,
    required String itemKey,
  }) async {
    final uri = Uri.parse('$baseUrl/api/progress/$userId/shop/purchase');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        'item_key': itemKey,
      }),
    );

    if (response.statusCode == 400) {
      final data = _decodeMap(response);
      throw Exception(data['detail']);
    }

    if (response.statusCode == 404) {
      final data = _decodeMap(response);
      throw Exception(data['detail']);
    }

    if (response.statusCode != 200) {
      throw Exception('Помилка покупки предмета: ${response.body}');
    }

    return PurchaseResult.fromJson(_decodeMap(response));
  }

  Future<TeacherAnalytics> getTeacherAnalytics({
    required int userId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/progress/$userId/analytics');

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    );

    if (response.statusCode != 200) {
      throw Exception('Помилка завантаження аналітики: ${response.body}');
    }

    return TeacherAnalytics.fromJson(_decodeMap(response));
  }

  Future<List<StudentSummary>> getStudents() async {
    final uri = Uri.parse('$baseUrl/api/progress/users');

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    );

    if (response.statusCode != 200) {
      throw Exception('Помилка завантаження списку учнів: ${response.body}');
    }

    return _decodeList(response)
        .map((item) => StudentSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<TeacherDashboard> getTeacherDashboard({
    int? userId,
  }) async {
    final path = userId == null
        ? '$baseUrl/api/progress/teacher-dashboard'
        : '$baseUrl/api/progress/teacher-dashboard/$userId';

    final uri = Uri.parse(path);

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    );

    if (response.statusCode != 200) {
      throw Exception('Помилка завантаження кабінету вчителя: ${response.body}');
    }

    return TeacherDashboard.fromJson(_decodeMap(response));
  }

}
