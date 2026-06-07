import 'dart:convert';
import 'dart:math' as math;

// Використовується тільки для Flutter Web, щоб реально завантажувати JSON-файл
// та імпортувати текст із .txt файлу.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'api_service.dart';
import 'models.dart';

void main() {
  runApp(const ReadQuestApp());
}

class ReadQuestApp extends StatelessWidget {
  const ReadQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return MaterialApp(
      title: 'ReadQuest AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.purple,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.studentBackground,
        textTheme: baseTextTheme.copyWith(
          displaySmall: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
          headlineSmall: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
          titleLarge: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
          titleMedium: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
          bodyLarge: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            color: AppColors.ink,
          ),
          bodyMedium: GoogleFonts.inter(
            color: AppColors.ink,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(
            color: AppColors.muted,
            fontWeight: FontWeight.w700,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: AppColors.cardBorder,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: AppColors.cardBorder,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: AppColors.purple,
              width: 2,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.purple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.ink,
            side: const BorderSide(
              color: AppColors.purple,
              width: 1.6,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class AppColors {
  static const Color studentBackground = Color(0xFFFFF7ED);
  static const Color teacherBackground = Color(0xFFEFF6FF);
  static const Color questBackground = Color(0xFFF5F3FF);
  static const Color progressBackground = Color(0xFFECFDF5);

  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleSoft = Color(0xFFEDE9FE);
  static const Color blue = Color(0xFF2563EB);
  static const Color blueSoft = Color(0xFFDBEAFE);
  static const Color green = Color(0xFF16A34A);
  static const Color greenSoft = Color(0xFFDCFCE7);
  static const Color yellow = Color(0xFFF59E0B);
  static const Color yellowSoft = Color(0xFFFEF3C7);
  static const Color pink = Color(0xFFDB2777);
  static const Color pinkSoft = Color(0xFFFCE7F3);
  static const Color red = Color(0xFFEF4444);
  static const Color redSoft = Color(0xFFFEE2E2);

  static const Color ink = Color(0xFF1F2937);
  static const Color muted = Color(0xFF64748B);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0);
}

const String sampleText = '''
Маленька дівчинка Марійка дуже любила читати книжки про далекі країни. 
Одного вечора вона знайшла у старій бібліотеці книгу з золотим ключиком на обкладинці. 
Коли Марійка відкрила першу сторінку, літери почали світитися, а перед нею з'явилася карта чарівного лісу. 
Щоб пройти стежкою, потрібно було уважно читати кожен розділ і відповідати на питання мудрої сови. 
Марійка зрозуміла, що читання може бути не лише корисним, а й захопливим. 
Вона пройшла перше випробування, отримала чарівну монету і пообіцяла повертатися до бібліотеки щодня.
''';

enum AppMode {
  student,
  teacher,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();

  final TextEditingController userController = TextEditingController(
    text: 'Demo Reader',
  );
  final TextEditingController titleController = TextEditingController(
    text: 'Чарівна бібліотека',
  );
  final TextEditingController authorController = TextEditingController(
    text: 'Народна історія',
  );
  final TextEditingController textController = TextEditingController(
    text: sampleText,
  );

  final TextEditingController teacherTitleController = TextEditingController(
    text: 'Казка про чарівний ліс',
  );
  final TextEditingController teacherAuthorController = TextEditingController(
    text: 'Вчитель',
  );
  final TextEditingController teacherTextController = TextEditingController(
    text: sampleText,
  );

  AppMode appMode = AppMode.student;

  String difficulty = 'medium';
  String generationMode = 'auto';
  int questionCount = 5;
  int targetAge = 10;
  int pagesRead = 4;
  int gradeLevel = 5;

  bool isLoading = false;
  bool isSavingText = false;

  List<LibraryText> libraryTexts = [];
  bool libraryLoading = false;

  @override
  void initState() {
    super.initState();
    loadLibraryTexts();
  }

  @override
  void dispose() {
    userController.dispose();
    titleController.dispose();
    authorController.dispose();
    textController.dispose();
    teacherTitleController.dispose();
    teacherAuthorController.dispose();
    teacherTextController.dispose();
    super.dispose();
  }

  Color get pageColor {
    return appMode == AppMode.student
        ? AppColors.studentBackground
        : AppColors.teacherBackground;
  }

  Future<void> loadLibraryTexts() async {
    setState(() {
      libraryLoading = true;
    });

    try {
      final texts = await apiService.getLibraryTexts();

      if (!mounted) return;

      setState(() {
        libraryTexts = texts;
      });
    } catch (error) {
      if (mounted) {
        showError(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          libraryLoading = false;
        });
      }
    }
  }

  Future<void> generateQuestFromManualText() async {
    if (textController.text.trim().length < 200) {
      showError('Текст має містити мінімум 200 символів.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final quest = await apiService.generateQuest(
        userName: userController.text.trim(),
        gradeLevel: gradeLevel,
        title: titleController.text.trim(),
        author: authorController.text.trim(),
        text: textController.text.trim(),
        targetAge: targetAge,
        pagesRead: pagesRead,
        difficulty: difficulty,
        questionCount: questionCount,
        generationMode: generationMode,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuestScreen(quest: quest),
        ),
      );
    } catch (error) {
      showError(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> generateQuestFromLibrary(LibraryText text) async {
    setState(() {
      isLoading = true;
    });

    try {
      final quest = await apiService.generateQuestFromLibraryText(
        textId: text.id,
        userName: userController.text.trim(),
        gradeLevel: gradeLevel,
        difficulty: difficulty,
        questionCount: questionCount,
        generationMode: generationMode,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuestScreen(quest: quest),
        ),
      );
    } catch (error) {
      showError(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> saveTeacherText() async {
    if (teacherTextController.text.trim().length < 200) {
      showError('Текст для бібліотеки має містити мінімум 200 символів.');
      return;
    }

    setState(() {
      isSavingText = true;
    });

    try {
      await apiService.createLibraryText(
        title: teacherTitleController.text.trim(),
        author: teacherAuthorController.text.trim(),
        content: teacherTextController.text.trim(),
        targetAge: targetAge,
        pagesRead: pagesRead,
      );

      if (!mounted) return;

      showInfo('Текст додано до бібліотеки.');
      await loadLibraryTexts();
    } catch (error) {
      showError(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          isSavingText = false;
        });
      }
    }
  }

  Future<void> deleteLibraryText(LibraryText text) async {
    try {
      await apiService.deleteLibraryText(textId: text.id);

      if (!mounted) return;

      showInfo('Текст видалено з бібліотеки.');
      await loadLibraryTexts();
    } catch (error) {
      showError(error.toString());
    }
  }

  Future<void> importTextFromTxtFile({
    required TextEditingController textTarget,
    TextEditingController? titleTarget,
  }) async {
    final input = html.FileUploadInputElement()
      ..accept = '.txt,text/plain'
      ..multiple = false;

    input.click();

    await input.onChange.first;

    final file = input.files?.isNotEmpty == true ? input.files!.first : null;

    if (file == null) {
      return;
    }

    final reader = html.FileReader();
    reader.readAsText(file);

    await reader.onLoadEnd.first;

    final content = reader.result?.toString() ?? '';

    if (content.trim().isEmpty) {
      showError('Файл порожній або не вдалося прочитати текст.');
      return;
    }

    setState(() {
      textTarget.text = content.trim();

      if (titleTarget != null && titleTarget.text.trim().isEmpty) {
        final fileName = file.name.replaceAll(RegExp(r'\.txt$', caseSensitive: false), '');
        titleTarget.text = fileName;
      }
    });

    showInfo('Текст із файлу завантажено.');
  }

  void openProgress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProgressScreen(userId: 1),
      ),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
      ),
    );
  }

  void showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      body: SafeArea(
        child: PageContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: Column(
                key: ValueKey(appMode),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PixelHeader(appMode: appMode),
                  const SizedBox(height: 18),
                  RoleSelectorCard(
                    appMode: appMode,
                    onChanged: (value) {
                      setState(() {
                        appMode = value;
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  GenerationSettingsCard(
                    difficulty: difficulty,
                    generationMode: generationMode,
                    questionCount: questionCount,
                    targetAge: targetAge,
                    pagesRead: pagesRead,
                    gradeLevel: gradeLevel,
                    onDifficultyChanged: (value) {
                      setState(() {
                        difficulty = value;
                      });
                    },
                    onGenerationModeChanged: (value) {
                      setState(() {
                        generationMode = value;
                      });
                    },
                    onQuestionCountChanged: (value) {
                      setState(() {
                        questionCount = value;
                      });
                    },
                    onTargetAgeChanged: (value) {
                      setState(() {
                        targetAge = value;
                      });
                    },
                    onPagesReadChanged: (value) {
                      setState(() {
                        pagesRead = value;
                      });
                    },
                    onGradeLevelChanged: (value) {
                      setState(() {
                        gradeLevel = value;
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  if (appMode == AppMode.student)
                    StudentModePanel(
                      userController: userController,
                      titleController: titleController,
                      authorController: authorController,
                      textController: textController,
                      libraryTexts: libraryTexts,
                      libraryLoading: libraryLoading,
                      isLoading: isLoading,
                      onGenerateManual: generateQuestFromManualText,
                      onGenerateFromLibrary: generateQuestFromLibrary,
                      onReloadLibrary: loadLibraryTexts,
                      onOpenProgress: openProgress,
                      onImportText: () => importTextFromTxtFile(
                        textTarget: textController,
                        titleTarget: titleController,
                      ),
                    )
                  else
                    TeacherModePanel(
                      titleController: teacherTitleController,
                      authorController: teacherAuthorController,
                      textController: teacherTextController,
                      libraryTexts: libraryTexts,
                      libraryLoading: libraryLoading,
                      isSavingText: isSavingText,
                      onSaveText: saveTeacherText,
                      onReloadLibrary: loadLibraryTexts,
                      onDeleteText: deleteLibraryText,
                      onGenerateFromLibrary: generateQuestFromLibrary,
                      onOpenProgress: openProgress,
                      onImportText: () => importTextFromTxtFile(
                        textTarget: teacherTextController,
                        titleTarget: teacherTitleController,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PixelHeader extends StatelessWidget {
  final AppMode appMode;

  const PixelHeader({
    super.key,
    required this.appMode,
  });

  @override
  Widget build(BuildContext context) {
    final isStudent = appMode == AppMode.student;

    return GameCard(
      backgroundColor: isStudent ? AppColors.purpleSoft : AppColors.blueSoft,
      borderColor: isStudent ? AppColors.purple : AppColors.blue,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const PixelBookIcon(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ReadQuest AI',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 28,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  isStudent
                      ? 'Читай, проходь квести, збирай монети та відкривай нові рівні'
                      : 'Додавайте тексти, керуйте бібліотекою та переглядайте навчальну аналітику',
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const PixelCompanion(
            size: 86,
            bodyColor: AppColors.yellow,
            accessoryColor: AppColors.pink,
          ),
        ],
      ),
    );
  }
}

class RoleSelectorCard extends StatelessWidget {
  final AppMode appMode;
  final ValueChanged<AppMode> onChanged;

  const RoleSelectorCard({
    super.key,
    required this.appMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isStudent = appMode == AppMode.student;

    return GameCard(
      backgroundColor: Colors.white,
      borderColor: isStudent ? AppColors.yellow : AppColors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            'Режим роботи',
            icon: Icons.switch_account,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              RoleButton(
                icon: Icons.school,
                label: 'Учень',
                subtitle: 'квести та нагороди',
                selected: appMode == AppMode.student,
                selectedColor: AppColors.purple,
                onTap: () => onChanged(AppMode.student),
              ),
              RoleButton(
                icon: Icons.manage_accounts,
                label: 'Вчитель',
                subtitle: 'бібліотека та аналітика',
                selected: appMode == AppMode.teacher,
                selectedColor: AppColors.blue,
                onTap: () => onChanged(AppMode.teacher),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RoleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const RoleButton({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background = selected ? selectedColor : Colors.white;
    final foreground = selected ? Colors.white : AppColors.ink;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 240,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? selectedColor : AppColors.cardBorder,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? selectedColor.withOpacity(0.22)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: foreground),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: foreground.withOpacity(0.82),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}

class GenerationSettingsCard extends StatelessWidget {
  final String difficulty;
  final String generationMode;
  final int questionCount;
  final int targetAge;
  final int pagesRead;
  final int gradeLevel;

  final ValueChanged<String> onDifficultyChanged;
  final ValueChanged<String> onGenerationModeChanged;
  final ValueChanged<int> onQuestionCountChanged;
  final ValueChanged<int> onTargetAgeChanged;
  final ValueChanged<int> onPagesReadChanged;
  final ValueChanged<int> onGradeLevelChanged;

  const GenerationSettingsCard({
    super.key,
    required this.difficulty,
    required this.generationMode,
    required this.questionCount,
    required this.targetAge,
    required this.pagesRead,
    required this.gradeLevel,
    required this.onDifficultyChanged,
    required this.onGenerationModeChanged,
    required this.onQuestionCountChanged,
    required this.onTargetAgeChanged,
    required this.onPagesReadChanged,
    required this.onGradeLevelChanged,
  });


  @override
  Widget build(BuildContext context) {
    return GameCard(
      backgroundColor: AppColors.greenSoft,
      borderColor: AppColors.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            'Налаштування генерації',
            icon: Icons.tune,
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool wide = constraints.maxWidth > 740;

              final children = [
                AppDropdown<String>(
                  label: 'Складність',
                  value: difficulty,
                  items: const {
                    'easy': 'Легка',
                    'medium': 'Середня',
                    'hard': 'Складна',
                  },
                  onChanged: onDifficultyChanged,
                ),
                AppDropdown<String>(
                  label: 'Тип генерації',
                  value: generationMode,
                  items: const {
                    'auto': 'Auto',
                    'openai': 'OpenAI',
                    'algorithm': 'Алгоритм',
                  },
                  onChanged: onGenerationModeChanged,
                ),
                AppDropdown<int>(
                  label: 'Кількість питань',
                  value: questionCount,
                  items: const {
                    3: '3 питання',
                    5: '5 питань',
                    7: '7 питань',
                    10: '10 питань',
                  },
                  onChanged: onQuestionCountChanged,
                ),
                AppDropdown<int>(
                  label: 'Клас',
                  value: gradeLevel,
                  items: const {
                    1: '1 клас',
                    2: '2 клас',
                    3: '3 клас',
                    4: '4 клас',
                    5: '5 клас',
                    6: '6 клас',
                    7: '7 клас',
                    8: '8 клас',
                    9: '9 клас',
                    10: '10 клас',
                    11: '11 клас',
                  },
                  onChanged: onGradeLevelChanged,
                ),
                AppDropdown<int>(
                  label: 'Вік дитини',
                  value: targetAge,
                  items: const {
                    6: '6 років',
                    7: '7 років',
                    8: '8 років',
                    9: '9 років',
                    10: '10 років',
                    11: '11 років',
                    12: '12 років',
                    13: '13 років',
                    14: '14 років',
                    15: '15 років',
                    16: '16 років',
                  },
                  onChanged: onTargetAgeChanged,
                ),
                AppDropdown<int>(
                  label: 'Прочитано сторінок',
                  value: pagesRead,
                  items: const {
                    1: '1 стор.',
                    2: '2 стор.',
                    3: '3 стор.',
                    4: '4 стор.',
                    5: '5 стор.',
                    10: '10 стор.',
                    20: '20 стор.',
                    30: '30 стор.',
                  },
                  onChanged: onPagesReadChanged,
                ),
              ];

              if (wide) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: children
                      .map(
                        (child) => SizedBox(
                          width: (constraints.maxWidth - 24) / 3,
                          child: child,
                        ),
                      )
                      .toList(),
                );
              }

              return Column(
                children: children
                    .map(
                      (child) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: child,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class StudentModePanel extends StatelessWidget {
  final TextEditingController userController;
  final TextEditingController titleController;
  final TextEditingController authorController;
  final TextEditingController textController;

  final List<LibraryText> libraryTexts;
  final bool libraryLoading;
  final bool isLoading;

  final VoidCallback onGenerateManual;
  final ValueChanged<LibraryText> onGenerateFromLibrary;
  final VoidCallback onReloadLibrary;
  final VoidCallback onOpenProgress;
  final VoidCallback onImportText;

  const StudentModePanel({
    super.key,
    required this.userController,
    required this.titleController,
    required this.authorController,
    required this.textController,
    required this.libraryTexts,
    required this.libraryLoading,
    required this.isLoading,
    required this.onGenerateManual,
    required this.onGenerateFromLibrary,
    required this.onReloadLibrary,
    required this.onOpenProgress,
    required this.onImportText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GameCard(
          backgroundColor: Colors.white,
          borderColor: AppColors.purple,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                'Учень створює навчальний квест',
                icon: Icons.auto_awesome,
              ),
              const SizedBox(height: 14),
              const StudentHeroStrip(),
              const SizedBox(height: 16),
              AppTextField(
                controller: userController,
                label: 'Імʼя читача',
                icon: Icons.face,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: titleController,
                label: 'Назва тексту',
                icon: Icons.title,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: authorController,
                label: 'Автор',
                icon: Icons.edit,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                minLines: 8,
                maxLines: 14,
                decoration: const InputDecoration(
                  labelText: 'Текст для генерації питань',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.menu_book),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ColorButton(
                    icon: Icons.upload_file,
                    label: 'Завантажити .txt',
                    color: AppColors.blue,
                    onPressed: onImportText,
                  ),
                  ColorButton(
                    icon: Icons.bar_chart,
                    label: 'Прогрес',
                    color: AppColors.yellow,
                    onPressed: onOpenProgress,
                    foreground: AppColors.ink,
                  ),
                  ColorButton(
                    icon: isLoading ? Icons.hourglass_top : Icons.auto_awesome,
                    label: isLoading ? 'Генерується...' : 'Згенерувати квест',
                    color: AppColors.purple,
                    onPressed: isLoading ? null : onGenerateManual,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        LibraryPanel(
          title: 'Бібліотека текстів для учня',
          subtitle:
              'Оберіть збережений текст і згенеруйте квест без повторного введення матеріалу.',
          texts: libraryTexts,
          loading: libraryLoading,
          showDelete: false,
          onReload: onReloadLibrary,
          onGenerate: onGenerateFromLibrary,
        ),
      ],
    );
  }
}

class TeacherModePanel extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController authorController;
  final TextEditingController textController;

  final List<LibraryText> libraryTexts;
  final bool libraryLoading;
  final bool isSavingText;

  final VoidCallback onSaveText;
  final VoidCallback onReloadLibrary;
  final ValueChanged<LibraryText> onDeleteText;
  final ValueChanged<LibraryText> onGenerateFromLibrary;
  final VoidCallback onOpenProgress;
  final VoidCallback onImportText;

  const TeacherModePanel({
    super.key,
    required this.titleController,
    required this.authorController,
    required this.textController,
    required this.libraryTexts,
    required this.libraryLoading,
    required this.isSavingText,
    required this.onSaveText,
    required this.onReloadLibrary,
    required this.onDeleteText,
    required this.onGenerateFromLibrary,
    required this.onOpenProgress,
    required this.onImportText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GameCard(
          backgroundColor: Colors.white,
          borderColor: AppColors.blue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                'Вчитель додає текст до бібліотеки',
                icon: Icons.library_add,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: titleController,
                label: 'Назва тексту',
                icon: Icons.title,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: authorController,
                label: 'Автор або джерело',
                icon: Icons.person,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                minLines: 8,
                maxLines: 14,
                decoration: const InputDecoration(
                  labelText: 'Навчальний текст',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ColorButton(
                    icon: Icons.upload_file,
                    label: 'Завантажити .txt',
                    color: AppColors.blue,
                    onPressed: onImportText,
                  ),
                  ColorButton(
                    icon: Icons.analytics,
                    label: 'Аналітика',
                    color: AppColors.yellow,
                    onPressed: onOpenProgress,
                    foreground: AppColors.ink,
                  ),
                  ColorButton(
                    icon: isSavingText ? Icons.hourglass_top : Icons.save,
                    label: isSavingText ? 'Збереження...' : 'Додати текст',
                    color: AppColors.green,
                    onPressed: isSavingText ? null : onSaveText,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        LibraryPanel(
          title: 'Бібліотека збережених текстів',
          subtitle:
              'Тут вчитель може переглядати матеріали, запускати генерацію квесту або видаляти зайві тексти.',
          texts: libraryTexts,
          loading: libraryLoading,
          showDelete: true,
          onReload: onReloadLibrary,
          onGenerate: onGenerateFromLibrary,
          onDelete: onDeleteText,
        ),
      ],
    );
  }
}

class StudentHeroStrip extends StatelessWidget {
  const StudentHeroStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.pinkSoft,
            AppColors.yellowSoft,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.yellow,
          width: 2,
        ),
      ),
      child: const Row(
        children: [
          PixelCompanion(
            size: 90,
            bodyColor: AppColors.purple,
            accessoryColor: AppColors.yellow,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Піксельний помічник готовий до пригоди',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Проходь квести, збирай монети й відкривай нові рівні читання.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          RewardIcon(
            icon: Icons.emoji_events,
            color: AppColors.yellow,
          ),
        ],
      ),
    );
  }
}


class LibraryPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<LibraryText> texts;
  final bool loading;
  final bool showDelete;

  final VoidCallback onReload;
  final ValueChanged<LibraryText> onGenerate;
  final ValueChanged<LibraryText>? onDelete;

  const LibraryPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.texts,
    required this.loading,
    required this.showDelete,
    required this.onReload,
    required this.onGenerate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GameCard(
      backgroundColor: Colors.white,
      borderColor: AppColors.pink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SectionTitle(
                  title,
                  icon: Icons.local_library,
                ),
              ),
              IconButton.filledTonal(
                onPressed: onReload,
                icon: const Icon(Icons.refresh),
                tooltip: 'Оновити бібліотеку',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (loading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (texts.isEmpty)
            const EmptyState(
              icon: Icons.menu_book,
              title: 'Бібліотека поки порожня',
              subtitle: 'Додайте перший текст у режимі вчителя.',
            )
          else
            Column(
              children: texts
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: LibraryTextCard(
                        item: item,
                        showDelete: showDelete,
                        onGenerate: () => onGenerate(item),
                        onDelete: showDelete && onDelete != null
                            ? () => onDelete!(item)
                            : null,
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class LibraryTextCard extends StatelessWidget {
  final LibraryText item;
  final bool showDelete;
  final VoidCallback onGenerate;
  final VoidCallback? onDelete;

  const LibraryTextCard({
    super.key,
    required this.item,
    required this.showDelete,
    required this.onGenerate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final preview = item.content.length > 180
        ? '${item.content.substring(0, 180)}...'
        : item.content;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.purpleSoft.withOpacity(0.42),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Автор: ${item.author?.isNotEmpty == true ? item.author : 'не вказано'}',
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PixelChip(
                label: 'Age ${item.targetAge}',
                color: AppColors.pink,
                icon: Icons.cake,
              ),
              PixelChip(
                label: '${item.pagesRead} стор.',
                color: AppColors.blue,
                icon: Icons.auto_stories,
              ),
              PixelChip(
                label: 'ID ${item.id}',
                color: AppColors.green,
                icon: Icons.tag,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            preview,
            style: const TextStyle(
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ColorButton(
                  icon: Icons.auto_awesome,
                  label: 'Створити квест',
                  color: AppColors.purple,
                  onPressed: onGenerate,
                ),
              ),
              if (showDelete) ...[
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete),
                  color: AppColors.red,
                  tooltip: 'Видалити текст',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class QuestScreen extends StatefulWidget {
  final Quest quest;

  const QuestScreen({
    super.key,
    required this.quest,
  });

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  final ApiService apiService = ApiService();
  final Map<int, String> selectedAnswers = {};

  bool isSubmitting = false;
  bool showSelectionEffect = false;

  double get completionRatio {
    if (widget.quest.questions.isEmpty) {
      return 0;
    }

    return selectedAnswers.length / widget.quest.questions.length;
  }

  Future<void> submit() async {
    if (selectedAnswers.length != widget.quest.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Дайте відповідь на всі питання.'),
          backgroundColor: AppColors.yellow,
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final result = await apiService.submitAnswers(
        questId: widget.quest.id,
        userId: widget.quest.userId,
        answers: selectedAnswers,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: result,
            quest: widget.quest,
          ),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  void selectAnswer({
    required int questionId,
    required String answer,
  }) {
    setState(() {
      selectedAnswers[questionId] = answer;
      showSelectionEffect = true;
    });

    HapticFeedback.selectionClick();

    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;

      setState(() {
        showSelectionEffect = false;
      });
    });
  }

  void openProgress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProgressScreen(userId: widget.quest.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quest = widget.quest;

    return Scaffold(
      backgroundColor: AppColors.questBackground,
      appBar: AppBar(
        title: const Text('ReadQuest'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: openProgress,
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Прогрес',
          ),
        ],
      ),
      body: SafeArea(
        child: PageContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GameCard(
                      backgroundColor: Colors.white,
                      borderColor: AppColors.purple,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const PixelCompanion(
                                size: 82,
                                bodyColor: AppColors.purple,
                                accessoryColor: AppColors.yellow,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      quest.title,
                                      style:
                                          Theme.of(context).textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      quest.scenario,
                                      style: const TextStyle(
                                        color: AppColors.muted,
                                        fontWeight: FontWeight.w700,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              PixelChip(
                                label: 'XP ${quest.xpReward}',
                                icon: Icons.bolt,
                                color: AppColors.purple,
                              ),
                              PixelChip(
                                label: 'Coins ${quest.coinsReward}',
                                icon: Icons.monetization_on,
                                color: AppColors.yellow,
                              ),
                              PixelChip(
                                label: 'Mode ${quest.generatedBy}',
                                icon: Icons.memory,
                                color: AppColors.blue,
                              ),
                              PixelChip(
                                label: 'Level ${quest.difficulty}',
                                icon: Icons.speed,
                                color: AppColors.green,
                              ),
                              PixelChip(
                                label:
                                    '${selectedAnswers.length}/${quest.questions.length}',
                                icon: Icons.checklist,
                                color: AppColors.pink,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          QuestProgressBar(
                            value: completionRatio,
                            label:
                                'Прогрес проходження: ${selectedAnswers.length}/${quest.questions.length}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    ...quest.questions.map(
                      (question) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: QuestionCard(
                          question: question,
                          selectedAnswer: selectedAnswers[question.id],
                          onSelected: (answer) => selectAnswer(
                            questionId: question.id,
                            answer: answer,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    GameCard(
                      backgroundColor: AppColors.yellowSoft,
                      borderColor: AppColors.yellow,
                      child: Row(
                        children: [
                          const RewardIcon(
                            icon: Icons.emoji_events,
                            color: AppColors.yellow,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedAnswers.length == quest.questions.length
                                  ? 'Усі відповіді обрано. Можна завершувати квест.'
                                  : 'Залишилось відповісти на ${quest.questions.length - selectedAnswers.length} пит.',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ColorButton(
                            icon: isSubmitting
                                ? Icons.hourglass_top
                                : Icons.done_all,
                            label: isSubmitting ? 'Перевірка...' : 'Завершити',
                            color: AppColors.green,
                            onPressed: isSubmitting ? null : submit,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (showSelectionEffect)
                  const Positioned(
                    top: 140,
                    right: 30,
                    child: FloatingStarEffect(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuestionCard extends StatelessWidget {
  final QuestQuestion question;
  final String? selectedAnswer;
  final ValueChanged<String> onSelected;

  const QuestionCard({
    super.key,
    required this.question,
    required this.selectedAnswer,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GameCard(
      backgroundColor: Colors.white,
      borderColor:
          selectedAnswer == null ? AppColors.cardBorder : AppColors.purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RewardIcon(
                icon: selectedAnswer == null ? Icons.quiz : Icons.check_circle,
                color: selectedAnswer == null ? AppColors.blue : AppColors.green,
                size: 42,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${question.orderNumber}. ${question.text}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...question.options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AnswerOptionTile(
                text: option,
                selected: selectedAnswer == option,
                onTap: () => onSelected(option),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnswerOptionTile extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const AnswerOptionTile({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: selected ? AppColors.purpleSoft : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? AppColors.purple : AppColors.cardBorder,
          width: selected ? 2.2 : 1.4,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selected ? AppColors.purple : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.purple : AppColors.muted,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                    color: AppColors.ink,
                    height: 1.35,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.star,
                  color: AppColors.yellow,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestProgressBar extends StatelessWidget {
  final double value;
  final String label;

  const QuestProgressBar({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = (value.clamp(0.0, 1.0) as num).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: safeValue,
            minHeight: 16,
            backgroundColor: AppColors.cardBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green),
          ),
        ),
      ],
    );
  }
}

class FloatingStarEffect extends StatelessWidget {
  const FloatingStarEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      builder: (context, value, child) {
        return Opacity(
          opacity: 1 - value,
          child: Transform.translate(
            offset: Offset(0, -30 * value),
            child: Transform.scale(
              scale: 0.8 + value,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: AppColors.yellow,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppColors.yellow.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.white),
            SizedBox(width: 6),
            Text(
              '+ вибір',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final AttemptResult result;
  final Quest quest;

  const ResultScreen({
    super.key,
    required this.result,
    required this.quest,
  });

  void goHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
      (route) => false,
    );
  }

  void openProgress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProgressScreen(userId: result.userId),
      ),
    );
  }

  void repeatQuest(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuestScreen(quest: quest),
      ),
    );
  }

  String buildRecommendation() {
    return result.recommendation;
  }

  void downloadJsonFile({
    required String fileName,
    required String content,
  }) {
    final bytes = utf8.encode(content);
    final blob = html.Blob(
      [bytes],
      'application/json;charset=utf-8',
    );

    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    html.Url.revokeObjectUrl(url);
  }

  Future<void> exportResult(BuildContext context) async {
    final report = {
      'app': 'ReadQuest AI',
      'exported_at': DateTime.now().toIso8601String(),
      'recommendation': buildRecommendation(),
      'result': result.toReportJson(),
    };

    final jsonText = const JsonEncoder.withIndent('  ').convert(report);
    final fileName = 'readquest_result_attempt_${result.attemptId}.json';

    downloadJsonFile(
      fileName: fileName,
      content: jsonText,
    );

    await Clipboard.setData(
      ClipboardData(text: jsonText),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('JSON-звіт завантажено у файл $fileName.'),
        backgroundColor: AppColors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStrong = result.percentage >= 80;
    final isMiddle = result.percentage >= 50 && result.percentage < 80;
    final resultColor =
        isStrong ? AppColors.green : isMiddle ? AppColors.yellow : AppColors.red;

    return Scaffold(
      backgroundColor: AppColors.progressBackground,
      appBar: AppBar(
        title: const Text('Результат квесту'),
        backgroundColor: resultColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => exportResult(context),
            icon: const Icon(Icons.download),
            tooltip: 'Експортувати JSON',
          ),
        ],
      ),
      body: SafeArea(
        child: PageContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result.percentage >= 70 || result.earnedXp >= 50) ...[
                  CelebrationFireworks(
                    isPerfect: result.percentage >= 99,
                  ),
                  const SizedBox(height: 18),
                ],
                GameCard(
                  backgroundColor: Colors.white,
                  borderColor: resultColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(
                        'Підсумок проходження',
                        icon: Icons.emoji_events,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            RewardIcon(
                              icon: isStrong
                                  ? Icons.workspace_premium
                                  : isMiddle
                                      ? Icons.star_half
                                      : Icons.refresh,
                              color: resultColor,
                              size: 78,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${result.score}/${result.totalQuestions}',
                              style: TextStyle(
                                color: resultColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 54,
                              ),
                            ),
                            Text(
                              'Точність: ${result.percentage.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              result.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          PixelChip(
                            label: 'XP +${result.earnedXp}',
                            icon: Icons.bolt,
                            color: AppColors.purple,
                          ),
                          PixelChip(
                            label: 'Coins +${result.earnedCoins}',
                            icon: Icons.monetization_on,
                            color: AppColors.yellow,
                          ),
                          PixelChip(
                            label: 'Attempt #${result.attemptId}',
                            icon: Icons.flag,
                            color: AppColors.blue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      InfoBanner(
                        color: AppColors.purpleSoft,
                        icon: Icons.tips_and_updates,
                        text: buildRecommendation(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                ResultRewardBanner(result: result),
                const SizedBox(height: 18),
                const SectionTitle(
                  'Розбір відповідей',
                  icon: Icons.fact_check,
                ),
                const SizedBox(height: 12),
                ...result.answers.map(
                  (answer) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: AnswerReviewCard(answer: answer),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ColorButton(
                        icon: Icons.bar_chart,
                        label: 'Прогрес',
                        color: AppColors.blue,
                        onPressed: () => openProgress(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ColorButton(
                        icon: Icons.refresh,
                        label: 'Пройти ще раз',
                        color: AppColors.yellow,
                        foreground: AppColors.ink,
                        onPressed: () => repeatQuest(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ColorButton(
                        icon: Icons.home,
                        label: 'На головну',
                        color: AppColors.purple,
                        onPressed: () => goHome(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ColorButton(
                    icon: Icons.download,
                    label: 'Експортувати результат у JSON',
                    color: AppColors.green,
                    onPressed: () => exportResult(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnswerReviewCard extends StatelessWidget {
  final AttemptAnswerReview answer;

  const AnswerReviewCard({
    super.key,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    final color = answer.isCorrect ? AppColors.green : AppColors.red;
    final softColor = answer.isCorrect ? AppColors.greenSoft : AppColors.redSoft;

    return GameCard(
      backgroundColor: softColor,
      borderColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RewardIcon(
                icon: answer.isCorrect ? Icons.check_circle : Icons.cancel,
                color: color,
                size: 42,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${answer.isCorrect ? 'Правильно' : 'Помилка'} • Питання ${answer.orderNumber}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            answer.questionText,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ResultLine(
            title: 'Ваша відповідь',
            value: answer.selectedAnswer,
            color: answer.isCorrect ? AppColors.green : AppColors.red,
          ),
          const SizedBox(height: 10),
          ResultLine(
            title: 'Правильна відповідь',
            value: answer.correctAnswer,
            color: AppColors.green,
          ),
          const SizedBox(height: 10),
          ResultLine(
            title: 'Пояснення',
            value: answer.explanation,
            color: AppColors.purple,
          ),
        ],
      ),
    );
  }
}

class ResultLine extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const ResultLine({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color,
          width: 1.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressScreen extends StatefulWidget {
  final int userId;

  const ProgressScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ApiService apiService = ApiService();

  late Future<ProgressBundle> future;
  late int selectedUserId;
  bool isPurchasing = false;

  @override
  void initState() {
    super.initState();
    selectedUserId = widget.userId;
    future = loadProgress();
  }

  Future<ProgressBundle> loadProgress() async {
    final progress = await apiService.getUserProgress(userId: selectedUserId);
    final history = await apiService.getQuestHistory(userId: selectedUserId);
    final shop = await apiService.getAvatarShop(userId: selectedUserId);
    final analytics = await apiService.getTeacherAnalytics(userId: selectedUserId);
    final achievements = await apiService.getAchievements(userId: selectedUserId);
    final streak = await apiService.getStreakStats(userId: selectedUserId);
    final leaderboard = await apiService.getLeaderboard(limit: 10);
    final teacherDashboard = await apiService.getTeacherDashboard(userId: selectedUserId);

    return ProgressBundle(
      progress: progress,
      history: history,
      shop: shop,
      analytics: analytics,
      achievements: achievements,
      streak: streak,
      leaderboard: leaderboard,
      teacherDashboard: teacherDashboard,
    );
  }

  void reload() {
    setState(() {
      future = loadProgress();
    });
  }

  void selectStudent(int userId) {
    if (userId == selectedUserId) {
      return;
    }

    setState(() {
      selectedUserId = userId;
      future = loadProgress();
    });
  }

  void downloadJsonFile({
    required String fileName,
    required String content,
  }) {
    final bytes = utf8.encode(content);
    final blob = html.Blob(
      [bytes],
      'application/json;charset=utf-8',
    );

    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    html.Url.revokeObjectUrl(url);
  }

  Future<void> exportTeacherDashboard(TeacherDashboard dashboard) async {
    final report = {
      'app': 'ReadQuest AI',
      'type': 'teacher_dashboard',
      'exported_at': DateTime.now().toIso8601String(),
      'dashboard': dashboard.toReportJson(),
    };

    final jsonText = const JsonEncoder.withIndent('  ').convert(report);
    final fileName = 'readquest_teacher_dashboard_${dashboard.selectedUserId ?? 'all'}.json';

    downloadJsonFile(
      fileName: fileName,
      content: jsonText,
    );

    await Clipboard.setData(ClipboardData(text: jsonText));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Аналітичний JSON-звіт завантажено у файл $fileName.'),
        backgroundColor: AppColors.green,
      ),
    );
  }

  Future<void> buyShopItem(ShopItem item) async {
    if (isPurchasing) {
      return;
    }

    setState(() {
      isPurchasing = true;
    });

    try {
      final result = await apiService.purchaseAvatarItem(
        userId: selectedUserId,
        itemKey: item.key,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.green,
        ),
      );

      setState(() {
        future = loadProgress();
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isPurchasing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.progressBackground,
      appBar: AppBar(
        title: const Text('Прогрес читача'),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<ProgressBundle>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GameCard(
                    backgroundColor: Colors.white,
                    borderColor: AppColors.red,
                    child: Text(
                      'Помилка завантаження прогресу: ${snapshot.error}',
                    ),
                  ),
                ),
              );
            }

            final bundle = snapshot.data!;

            return PageContainer(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProgressSummaryCard(progress: bundle.progress),
                    const SizedBox(height: 18),
                    StreakAndLeaderboardCard(
                      streak: bundle.streak,
                      leaderboard: bundle.leaderboard,
                      selectedUserId: selectedUserId,
                    ),
                    const SizedBox(height: 18),
                    AchievementsCard(achievements: bundle.achievements),
                    const SizedBox(height: 18),
                    AvatarUpgradeCard(
                      shop: bundle.shop,
                      isPurchasing: isPurchasing,
                      onBuy: buyShopItem,
                    ),
                    const SizedBox(height: 18),
                    TeacherDashboardCard(
                      dashboard: bundle.teacherDashboard,
                      selectedUserId: selectedUserId,
                      onStudentSelected: selectStudent,
                      onExport: exportTeacherDashboard,
                    ),
                    const SizedBox(height: 18),
                    const SectionTitle(
                      'Історія квестів',
                      icon: Icons.history,
                    ),
                    const SizedBox(height: 12),
                    if (bundle.history.isEmpty)
                      const EmptyState(
                        icon: Icons.flag,
                        title: 'Історії поки немає',
                        subtitle: 'Пройдіть перший квест, щоб побачити результат.',
                      )
                    else
                      ...bundle.history.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: HistoryCard(item: item),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProgressBundle {
  final UserProgress progress;
  final List<QuestHistoryItem> history;
  final AvatarShop shop;
  final TeacherAnalytics analytics;
  final List<Achievement> achievements;
  final StreakStats streak;
  final List<LeaderboardEntry> leaderboard;
  final TeacherDashboard teacherDashboard;

  ProgressBundle({
    required this.progress,
    required this.history,
    required this.shop,
    required this.analytics,
    required this.achievements,
    required this.streak,
    required this.leaderboard,
    required this.teacherDashboard,
  });
}

class ProgressSummaryCard extends StatelessWidget {
  final UserProgress progress;

  const ProgressSummaryCard({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final levelPercent = (progress.levelProgressPercent.clamp(0, 100) as num).toDouble() / 100.0;

    return GameCard(
      backgroundColor: Colors.white,
      borderColor: AppColors.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            'Профіль читача',
            icon: Icons.account_circle,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              PixelAvatarBadge(level: progress.level),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      progress.username,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      'Клас: ${progress.gradeLevel}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              PixelChip(
                label: 'Level ${progress.level}',
                icon: Icons.leaderboard,
                color: AppColors.purple,
              ),
              PixelChip(
                label: 'XP ${progress.totalXp}',
                icon: Icons.bolt,
                color: AppColors.blue,
              ),
              PixelChip(
                label: 'Coins ${progress.coins}',
                icon: Icons.monetization_on,
                color: AppColors.yellow,
              ),
              PixelChip(
                label: 'Quests ${progress.completedQuests}',
                icon: Icons.flag,
                color: AppColors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          QuestProgressBar(
            value: levelPercent,
            label:
                'Прогрес рівня: ${progress.currentLevelXp}/100 XP. До наступного рівня потрібно ${math.max(0, progress.nextLevelXp - progress.totalXp)} XP.',
          ),
        ],
      ),
    );
  }
}


class AchievementsCard extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementsCard({
    super.key,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    final unlockedCount = achievements.where((item) => item.isUnlocked).length;

    return GameCard(
      backgroundColor: AppColors.purpleSoft,
      borderColor: AppColors.purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            'Досягнення учня',
            icon: Icons.workspace_premium,
            trailing: PixelChip(
              label: '$unlockedCount/${achievements.length} відкрито',
              icon: Icons.emoji_events,
              color: AppColors.purple,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Досягнення відкриваються автоматично на основі проходжень, XP та якості відповідей.',
            style: TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth > 760
                  ? (constraints.maxWidth - 20) / 3
                  : constraints.maxWidth > 520
                      ? (constraints.maxWidth - 10) / 2
                      : constraints.maxWidth;

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: achievements
                    .map(
                      (achievement) => SizedBox(
                        width: itemWidth,
                        child: AchievementTile(achievement: achievement),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AchievementTile extends StatelessWidget {
  final Achievement achievement;

  const AchievementTile({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    final color = shopColor(achievement.color);
    final progressValue =
        (achievement.progressPercent.clamp(0, 100) as num).toDouble() / 100.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: achievement.isUnlocked ? color.withOpacity(0.14) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: achievement.isUnlocked ? color : AppColors.cardBorder,
          width: achievement.isUnlocked ? 2 : 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RewardIcon(
                icon: achievementIcon(achievement.icon),
                color: achievement.isUnlocked ? color : AppColors.muted,
                size: 42,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  achievement.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(
                achievement.isUnlocked ? Icons.lock_open : Icons.lock,
                color: achievement.isUnlocked ? color : AppColors.muted,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            achievement.description,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: progressValue,
              backgroundColor: AppColors.cardBorder,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          PixelChip(
            label: achievement.isUnlocked
                ? 'Відкрито'
                : '${achievement.currentValue}/${achievement.targetValue}',
            icon: achievement.isUnlocked ? Icons.check_circle : Icons.hourglass_bottom,
            color: achievement.isUnlocked ? color : AppColors.muted,
          ),
        ],
      ),
    );
  }
}

IconData achievementIcon(String icon) {
  switch (icon) {
    case 'flag':
      return Icons.flag;
    case 'visibility':
      return Icons.visibility;
    case 'checklist':
      return Icons.checklist;
    case 'bolt':
      return Icons.bolt;
    case 'workspace_premium':
      return Icons.workspace_premium;
    case 'emoji_events':
      return Icons.emoji_events;
    default:
      return Icons.star;
  }
}

class AvatarUpgradeCard extends StatelessWidget {
  final AvatarShop shop;
  final bool isPurchasing;
  final ValueChanged<ShopItem> onBuy;

  const AvatarUpgradeCard({
    super.key,
    required this.shop,
    required this.isPurchasing,
    required this.onBuy,
  });

  Color get avatarBodyColor {
    final pet = shop.equippedByCategory('pet');

    if (pet == null) {
      return AppColors.purple;
    }

    return shopColor(pet.color);
  }

  Color get accessoryColor {
    final hat = shop.equippedByCategory('hat');

    if (hat == null) {
      return AppColors.yellow;
    }

    return shopColor(hat.color);
  }

  bool get hasFrame {
    return shop.equippedByCategory('frame') != null;
  }

  bool get hasBadge {
    return shop.equippedByCategory('badge') != null;
  }

  @override
  Widget build(BuildContext context) {
    return GameCard(
      backgroundColor: AppColors.yellowSoft,
      borderColor: AppColors.yellow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            'Магазин нагород',
            icon: Icons.storefront,
          ),
          const SizedBox(height: 10),
          Text(
            'Доступно монет: ${shop.coins}. Куплені предмети зберігаються в базі даних і залишаються доступними після перезапуску застосунку.',
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool wide = constraints.maxWidth > 760;

              final avatar = _ShopAvatarPreview(
                bodyColor: avatarBodyColor,
                accessoryColor: accessoryColor,
                hasFrame: hasFrame,
                hasBadge: hasBadge,
              );

              final shopGrid = Wrap(
                spacing: 10,
                runSpacing: 10,
                children: shop.items
                    .map(
                      (item) => ShopItemCard(
                        item: item,
                        availableCoins: shop.coins,
                        disabled: isPurchasing,
                        onTap: () => onBuy(item),
                      ),
                    )
                    .toList(),
              );

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    avatar,
                    const SizedBox(width: 18),
                    Expanded(child: shopGrid),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  avatar,
                  const SizedBox(height: 16),
                  shopGrid,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ShopAvatarPreview extends StatelessWidget {
  final Color bodyColor;
  final Color accessoryColor;
  final bool hasFrame;
  final bool hasBadge;

  const _ShopAvatarPreview({
    required this.bodyColor,
    required this.accessoryColor,
    required this.hasFrame,
    required this.hasBadge,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = PixelCompanion(
      size: 118,
      bodyColor: bodyColor,
      accessoryColor: accessoryColor,
    );

    return Container(
      width: 190,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: hasFrame ? AppColors.yellow : AppColors.cardBorder,
          width: hasFrame ? 4 : 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              avatar,
              if (hasBadge)
                const Positioned(
                  right: 6,
                  bottom: 0,
                  child: RewardIcon(
                    icon: Icons.emoji_events,
                    color: AppColors.green,
                    size: 42,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const PixelChip(
            label: 'Стартовий персонаж',
            icon: Icons.face,
            color: AppColors.purple,
          ),
          const SizedBox(height: 8),
          Text(
            hasFrame || hasBadge
                ? 'Активні покращення вже застосовані до аватара.'
                : 'Базовий аватар доступний одразу, а покращення відкриваються за монети.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class ShopItemCard extends StatelessWidget {
  final ShopItem item;
  final int availableCoins;
  final bool disabled;
  final VoidCallback onTap;

  const ShopItemCard({
    super.key,
    required this.item,
    required this.availableCoins,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = shopColor(item.color);
    final unlocked = item.isUnlocked;
    final equipped = item.isEquipped;
    final notEnoughCoins = !unlocked && availableCoins < item.price;
    final isFreeStarter = item.price == 0;

    String statusLabel;
    IconData statusIcon;
    Color statusColor;

    if (equipped) {
      statusLabel = 'Активно';
      statusIcon = Icons.check_circle;
      statusColor = Colors.white;
    } else if (unlocked) {
      statusLabel = 'Куплено';
      statusIcon = Icons.inventory_2;
      statusColor = color;
    } else if (isFreeStarter) {
      statusLabel = 'Стартовий предмет';
      statusIcon = Icons.face;
      statusColor = color;
    } else if (notEnoughCoins) {
      statusLabel = 'Не вистачає монет';
      statusIcon = Icons.lock;
      statusColor = AppColors.red;
    } else {
      statusLabel = '${item.price} монет';
      statusIcon = Icons.monetization_on;
      statusColor = color;
    }

    return SizedBox(
      width: 238,
      child: InkWell(
        onTap: disabled || notEnoughCoins ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: equipped
                ? color
                : notEnoughCoins
                    ? AppColors.redSoft
                    : unlocked
                        ? color.withOpacity(0.14)
                        : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: notEnoughCoins ? AppColors.red : color,
              width: equipped ? 2.4 : 1.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    shopIcon(item.icon),
                    color: equipped ? Colors.white : color,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        color: equipped ? Colors.white : AppColors.ink,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.description,
                style: TextStyle(
                  color: equipped ? Colors.white.withOpacity(0.9) : AppColors.muted,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              PixelChip(
                label: statusLabel,
                icon: statusIcon,
                color: statusColor,
                foreground: equipped ? color : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData shopIcon(String icon) {
  switch (icon) {
    case 'star':
      return Icons.star;
    case 'auto_awesome':
      return Icons.auto_awesome;
    case 'pets':
      return Icons.pets;
    case 'cruelty_free':
      return Icons.cruelty_free;
    case 'workspace_premium':
      return Icons.workspace_premium;
    case 'emoji_events':
      return Icons.emoji_events;
    default:
      return Icons.card_giftcard;
  }
}

Color shopColor(String color) {
  switch (color) {
    case 'yellow':
      return AppColors.yellow;
    case 'purple':
      return AppColors.purple;
    case 'blue':
      return AppColors.blue;
    case 'green':
      return AppColors.green;
    case 'pink':
      return AppColors.pink;
    case 'orange':
      return AppColors.yellow;
    default:
      return AppColors.purple;
  }
}

class TeacherAnalyticsCard extends StatelessWidget {
  final TeacherAnalytics analytics;
  final List<QuestHistoryItem> history;

  const TeacherAnalyticsCard({
    super.key,
    required this.analytics,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return GameCard(
      backgroundColor: Colors.white,
      borderColor: AppColors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            'Панель аналітики вчителя',
            icon: Icons.insights,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              PixelChip(
                label:
                    'Середній результат ${analytics.averagePercentage.toStringAsFixed(0)}%',
                icon: Icons.percent,
                color: AppColors.purple,
              ),
              PixelChip(
                label: 'Кращий ${analytics.bestPercentage.toStringAsFixed(0)}%',
                icon: Icons.emoji_events,
                color: AppColors.yellow,
              ),
              PixelChip(
                label: 'Спроб ${analytics.attemptCount}',
                icon: Icons.checklist,
                color: AppColors.pink,
              ),
              PixelChip(
                label: 'OpenAI ${analytics.openAiCount}',
                icon: Icons.smart_toy,
                color: AppColors.blue,
              ),
              PixelChip(
                label: 'Algorithm ${analytics.algorithmCount}',
                icon: Icons.memory,
                color: AppColors.green,
              ),
              PixelChip(
                label: 'XP +${analytics.totalEarnedXp}',
                icon: Icons.bolt,
                color: AppColors.purple,
              ),
              PixelChip(
                label: 'Coins +${analytics.totalEarnedCoins}',
                icon: Icons.monetization_on,
                color: AppColors.yellow,
              ),
            ],
          ),
          const SizedBox(height: 16),
          MiniBarChart(history: history),
          const SizedBox(height: 14),
          InfoBanner(
            color: AppColors.blueSoft,
            icon: Icons.school,
            text: analytics.recommendation,
          ),
        ],
      ),
    );
  }
}

class MiniBarChart extends StatelessWidget {
  final List<QuestHistoryItem> history;

  const MiniBarChart({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final visible = history.take(6).toList();

    if (visible.isEmpty) {
      return const Text(
        'Дані для графіка зʼявляться після проходження квестів.',
        style: TextStyle(
          color: AppColors.muted,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return SizedBox(
      height: 130,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: visible.map(
          (item) {
            final value = ((item.percentage / 100).clamp(0.05, 1.0) as num).toDouble();

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${item.percentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      height: 90 * value,
                      decoration: BoxDecoration(
                        color: item.percentage >= 70
                            ? AppColors.green
                            : item.percentage >= 40
                                ? AppColors.yellow
                                : AppColors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final QuestHistoryItem item;

  const HistoryCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final strong = item.percentage >= 70;
    final color =
        strong ? AppColors.green : item.percentage >= 40 ? AppColors.yellow : AppColors.red;

    return GameCard(
      backgroundColor: Colors.white,
      borderColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 17,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PixelChip(
                label: '${item.score}/${item.totalQuestions}',
                icon: Icons.check_circle,
                color: color,
              ),
              PixelChip(
                label: '${item.percentage.toStringAsFixed(0)}%',
                icon: Icons.percent,
                color: AppColors.purple,
              ),
              PixelChip(
                label: 'XP +${item.earnedXp}',
                icon: Icons.bolt,
                color: AppColors.blue,
              ),
              PixelChip(
                label: 'Coins +${item.earnedCoins}',
                icon: Icons.monetization_on,
                color: AppColors.yellow,
              ),
              PixelChip(
                label: item.generatedBy,
                icon: Icons.memory,
                color: AppColors.green,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            strong ? 'Статус: добре' : 'Статус: потрібно повторити',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}



class StreakAndLeaderboardCard extends StatelessWidget {
  final StreakStats streak;
  final List<LeaderboardEntry> leaderboard;
  final int selectedUserId;

  const StreakAndLeaderboardCard({
    super.key,
    required this.streak,
    required this.leaderboard,
    required this.selectedUserId,
  });

  @override
  Widget build(BuildContext context) {
    return GameCard(
      backgroundColor: Colors.white,
      borderColor: AppColors.yellow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            'Страйки та таблиця лідерів',
            icon: Icons.local_fire_department,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StreakPanel(streak: streak),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _LeaderboardPanel(
                  entries: leaderboard,
                  selectedUserId: selectedUserId,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakPanel extends StatelessWidget {
  final StreakStats streak;

  const _StreakPanel({
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.yellowSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.yellow,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RewardIcon(
            icon: Icons.local_fire_department,
            color: AppColors.yellow,
            size: 54,
          ),
          const SizedBox(height: 12),
          Text(
            '${streak.currentStreak} дн. поспіль',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Найдовша серія: ${streak.longestStreak} дн.',
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          InfoBanner(
            color: Colors.white,
            icon: streak.activeToday ? Icons.check_circle : Icons.schedule,
            text: streak.message,
          ),
        ],
      ),
    );
  }
}

class _LeaderboardPanel extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final int selectedUserId;

  const _LeaderboardPanel({
    required this.entries,
    required this.selectedUserId,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const EmptyState(
        icon: Icons.leaderboard,
        title: 'Лідерборд порожній',
        subtitle: 'Після проходження квестів тут з’являться результати.',
      );
    }

    return Column(
      children: entries.take(5).map((entry) {
        final bool selected = entry.userId == selectedUserId;
        final Color color = entry.rank == 1
            ? AppColors.yellow
            : selected
                ? AppColors.purple
                : AppColors.blue;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.purpleSoft : AppColors.blueSoft,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color,
              width: selected ? 2.2 : 1.4,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                foregroundColor: Colors.white,
                child: Text(
                  '${entry.rank}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              PixelChip(
                label: '${entry.totalXp} XP',
                icon: Icons.bolt,
                color: AppColors.purple,
              ),
              const SizedBox(width: 8),
              PixelChip(
                label: '${entry.currentStreak}🔥',
                icon: Icons.local_fire_department,
                color: AppColors.yellow,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class CelebrationFireworks extends StatelessWidget {
  final bool isPerfect;

  const CelebrationFireworks({
    super.key,
    required this.isPerfect,
  });

  @override
  Widget build(BuildContext context) {
    final symbols = isPerfect
        ? ['🏆', '✨', '🎉', '⭐', '🔥', '📚']
        : ['✨', '🎉', '⭐', '📚'];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.85 + value * 0.15,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: GameCard(
        backgroundColor: isPerfect ? AppColors.yellowSoft : AppColors.purpleSoft,
        borderColor: isPerfect ? AppColors.yellow : AppColors.purple,
        child: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                18,
                (index) => Text(
                  symbols[index % symbols.length],
                  style: TextStyle(
                    fontSize: 24 + (index % 3) * 5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isPerfect
                  ? 'Ідеальне проходження. Відкрито святковий ефект перемоги!'
                  : 'Квест завершено. Прогрес, XP і нагороди вже зараховано!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultRewardBanner extends StatelessWidget {
  final AttemptResult result;

  const ResultRewardBanner({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final bool levelHint = result.earnedXp >= 50;
    final bool achievementHint = result.percentage >= 90;

    return GameCard(
      backgroundColor: AppColors.greenSoft,
      borderColor: AppColors.green,
      child: Row(
        children: [
          RewardIcon(
            icon: achievementHint
                ? Icons.workspace_premium
                : levelHint
                    ? Icons.trending_up
                    : Icons.card_giftcard,
            color: AppColors.green,
            size: 58,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              achievementHint
                  ? 'Високий результат може відкрити нові досягнення. Перейдіть у прогрес, щоб перевірити нагороди.'
                  : levelHint
                      ? 'Отримано достатньо XP для помітного прогресу рівня. Продовжуйте серію читання.'
                      : 'Навіть невеликий результат зберігається в історії та допомагає побачити навчальний прогрес.',
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w800,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class PixelBookIcon extends StatelessWidget {
  const PixelBookIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.purple,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withOpacity(0.26),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: const Icon(
        Icons.menu_book,
        size: 40,
        color: Colors.white,
      ),
    );
  }
}

class PixelCompanion extends StatefulWidget {
  final double size;
  final Color bodyColor;
  final Color accessoryColor;

  const PixelCompanion({
    super.key,
    required this.size,
    required this.bodyColor,
    required this.accessoryColor,
  });

  @override
  State<PixelCompanion> createState() => _PixelCompanionState();
}

class _PixelCompanionState extends State<PixelCompanion>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.size / 7;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final offset = math.sin(controller.value * math.pi) * 5;

        return Transform.translate(
          offset: Offset(0, -offset),
          child: Transform.rotate(
            angle: math.sin(controller.value * math.pi * 2) * 0.035,
            child: child,
          ),
        );
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: unit * 0.2,
              child: Container(
                width: unit * 3.6,
                height: unit * 1.1,
                decoration: BoxDecoration(
                  color: widget.accessoryColor,
                  borderRadius: BorderRadius.circular(unit * 0.2),
                ),
              ),
            ),
            Positioned(
              top: unit * 1.2,
              child: Container(
                width: unit * 4.4,
                height: unit * 4.2,
                decoration: BoxDecoration(
                  color: widget.bodyColor,
                  borderRadius: BorderRadius.circular(unit * 1.2),
                  border: Border.all(
                    color: AppColors.ink,
                    width: 2,
                  ),
                ),
              ),
            ),
            Positioned(
              top: unit * 2.4,
              left: unit * 2.0,
              child: _PixelEye(size: unit * 0.65),
            ),
            Positioned(
              top: unit * 2.4,
              right: unit * 2.0,
              child: _PixelEye(size: unit * 0.65),
            ),
            Positioned(
              top: unit * 3.6,
              child: Container(
                width: unit * 1.7,
                height: unit * 0.42,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Positioned(
              bottom: unit * 0.8,
              left: unit * 1.4,
              child: _PixelFoot(size: unit, color: widget.bodyColor),
            ),
            Positioned(
              bottom: unit * 0.8,
              right: unit * 1.4,
              child: _PixelFoot(size: unit, color: widget.bodyColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _PixelEye extends StatelessWidget {
  final double size;

  const _PixelEye({
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: AppColors.ink,
    );
  }
}

class _PixelFoot extends StatelessWidget {
  final double size;
  final Color color;

  const _PixelFoot({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 1.35,
      height: size * 0.75,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: AppColors.ink,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class PixelAvatarBadge extends StatelessWidget {
  final int level;

  const PixelAvatarBadge({
    super.key,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const PixelCompanion(
          size: 92,
          bodyColor: AppColors.green,
          accessoryColor: AppColors.yellow,
        ),
        Positioned(
          right: -4,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: AppColors.purple,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: Text(
              'Lv $level',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RewardIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const RewardIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: size * 0.52,
      ),
    );
  }
}

class PageContainer extends StatelessWidget {
  final Widget child;

  const PageContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1040),
        child: child,
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;

  const GameCard({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.card,
    this.borderColor = AppColors.cardBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Widget? trailing;

  const SectionTitle(
    this.text, {
    super.key,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return Text(
        text,
        style: Theme.of(context).textTheme.titleLarge,
      );
    }

    return Row(
      children: [
        RewardIcon(
          icon: icon!,
          color: AppColors.purple,
          size: 38,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          trailing!,
        ],
      ],
    );
  }
}

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
      ),
    );
  }
}

class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;

  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
      ),
      dropdownColor: Colors.white,
      items: items.entries
          .map(
            (entry) => DropdownMenuItem<T>(
              value: entry.key,
              child: Text(entry.value),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

class PixelChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final Color? foreground;

  const PixelChip({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.purple,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final contentColor = foreground ?? color;

    return Chip(
      avatar: icon == null
          ? null
          : Icon(
              icon,
              size: 18,
              color: contentColor,
            ),
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: contentColor,
        ),
      ),
      backgroundColor: color.withOpacity(0.12),
      side: BorderSide(
        color: color,
        width: 1.5,
      ),
    );
  }
}

class ColorButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color foreground;
  final VoidCallback? onPressed;

  const ColorButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.foreground = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: foreground,
        disabledBackgroundColor: color.withOpacity(0.45),
        disabledForegroundColor: foreground.withOpacity(0.7),
      ),
    );
  }
}

class InfoBanner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;

  const InfoBanner({
    super.key,
    required this.color,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.purple,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.purpleSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.purple,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          RewardIcon(
            icon: icon,
            color: AppColors.purple,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TeacherDashboardCard extends StatelessWidget {
  final TeacherDashboard dashboard;
  final int selectedUserId;
  final ValueChanged<int> onStudentSelected;
  final ValueChanged<TeacherDashboard> onExport;

  const TeacherDashboardCard({
    super.key,
    required this.dashboard,
    required this.selectedUserId,
    required this.onStudentSelected,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final studentIds = dashboard.students.map((student) => student.userId).toSet();
    final int? dropdownValue = studentIds.contains(selectedUserId)
        ? selectedUserId
        : dashboard.selectedUserId;

    return GameCard(
      backgroundColor: Colors.white,
      borderColor: AppColors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: SectionTitle(
                  'Кабінет вчителя 2.0',
                  icon: Icons.dashboard_customize,
                ),
              ),
              ColorButton(
                icon: Icons.download,
                label: 'Експорт JSON',
                color: AppColors.blue,
                onPressed: () => onExport(dashboard),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const InfoBanner(
            color: AppColors.blueSoft,
            icon: Icons.person_search,
            text:
                'Оберіть учня, щоб переглянути його результати, динаміку успішності та рекомендації.',
          ),
          const SizedBox(height: 16),
          if (dashboard.students.isEmpty)
            const EmptyState(
              icon: Icons.groups,
              title: 'Учнів поки немає',
              subtitle: 'Після створення першого квесту тут зʼявиться список учнів для аналізу.',
            )
          else ...[
            DropdownButtonFormField<int>(
              value: dropdownValue,
              decoration: const InputDecoration(
                labelText: 'Учень для аналізу',
                prefixIcon: Icon(Icons.person_search),
              ),
              items: dashboard.students
                  .map(
                    (student) => DropdownMenuItem<int>(
                      value: student.userId,
                      child: Text(
                        '${student.username} · ${student.gradeLevel} клас · ${student.completedQuests} квестів',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onStudentSelected(value);
                }
              },
            ),
            const SizedBox(height: 16),
            TeacherMetricGrid(metrics: dashboard.metrics),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 900;

                final chart = TeacherSuccessChart(
                  points: dashboard.chart,
                  averagePercentage: dashboard.averagePercentage,
                  successTrend: dashboard.successTrend,
                );

                final split = TeacherGenerationSplit(
                  openAiCount: dashboard.openAiCount,
                  algorithmCount: dashboard.algorithmCount,
                  totalQuestions: dashboard.totalQuestions,
                  totalCorrectAnswers: dashboard.totalCorrectAnswers,
                );

                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: chart),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: split),
                    ],
                  );
                }

                return Column(
                  children: [
                    chart,
                    const SizedBox(height: 16),
                    split,
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            TeacherInsightPanel(dashboard: dashboard),
            const SizedBox(height: 18),
            InfoBanner(
              color: AppColors.greenSoft,
              icon: Icons.psychology,
              text: dashboard.recommendation,
            ),
            const SizedBox(height: 18),
            TeacherRecentAttempts(points: dashboard.chart),
          ],
        ],
      ),
    );
  }
}

class TeacherMetricGrid extends StatelessWidget {
  final List<TeacherMetric> metrics;

  const TeacherMetricGrid({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) {
      return const EmptyState(
        icon: Icons.analytics,
        title: 'Метрик поки немає',
        subtitle: 'Після проходження квестів система сформує статистику.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 980
            ? 4
            : constraints.maxWidth > 680
                ? 3
                : 2;
        final spacing = 12.0;
        final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: width,
                  child: TeacherMetricCard(metric: metric),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class TeacherMetricCard extends StatelessWidget {
  final TeacherMetric metric;

  const TeacherMetricCard({
    super.key,
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    final color = teacherDashboardColor(metric.color);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color,
          width: 1.7,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  teacherDashboardIcon(metric.icon),
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  metric.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            metric.value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            metric.subtitle,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class TeacherSuccessChart extends StatelessWidget {
  final List<TeacherChartPoint> points;
  final double averagePercentage;
  final String successTrend;

  const TeacherSuccessChart({
    super.key,
    required this.points,
    required this.averagePercentage,
    required this.successTrend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.yellowSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.yellow,
          width: 1.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: SectionTitle(
                  'Динаміка успішності',
                  icon: Icons.show_chart,
                ),
              ),
              PixelChip(
                label: 'Тренд: $successTrend',
                icon: Icons.trending_up,
                color: AppColors.yellow,
                foreground: AppColors.ink,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (points.isEmpty)
            const EmptyState(
              icon: Icons.bar_chart,
              title: 'Дані для графіка відсутні',
              subtitle: 'Графік зʼявиться після першого проходження квесту.',
            )
          else
            Column(
              children: points
                  .map(
                    (point) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TeacherChartBar(point: point),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 10),
          Text(
            'Середній результат у вибірці становить ${averagePercentage.toStringAsFixed(0)}%.',
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class TeacherChartBar extends StatelessWidget {
  final TeacherChartPoint point;

  const TeacherChartBar({
    super.key,
    required this.point,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (point.percentage.clamp(0, 100) as num).toDouble();
    final color = percent >= 80
        ? AppColors.green
        : percent >= 50
            ? AppColors.yellow
            : AppColors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                point.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${percent.toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 14,
            color: color,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${point.score}/${point.totalQuestions} · ${point.generatedBy}',
          style: const TextStyle(
            color: AppColors.muted,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class TeacherGenerationSplit extends StatelessWidget {
  final int openAiCount;
  final int algorithmCount;
  final int totalQuestions;
  final int totalCorrectAnswers;

  const TeacherGenerationSplit({
    super.key,
    required this.openAiCount,
    required this.algorithmCount,
    required this.totalQuestions,
    required this.totalCorrectAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final totalGenerated = openAiCount + algorithmCount;
    final openAiShare = totalGenerated == 0 ? 0.0 : openAiCount / totalGenerated;
    final algorithmShare = totalGenerated == 0 ? 0.0 : algorithmCount / totalGenerated;
    final correctShare = totalQuestions == 0 ? 0.0 : totalCorrectAnswers / totalQuestions;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.purpleSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.purple,
          width: 1.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            'Порівняння режимів',
            icon: Icons.compare_arrows,
          ),
          const SizedBox(height: 14),
          TeacherRatioLine(
            label: 'OpenAI',
            value: openAiShare,
            count: openAiCount,
            color: AppColors.blue,
          ),
          const SizedBox(height: 12),
          TeacherRatioLine(
            label: 'Algorithm',
            value: algorithmShare,
            count: algorithmCount,
            color: AppColors.green,
          ),
          const SizedBox(height: 18),
          TeacherRatioLine(
            label: 'Правильні відповіді',
            value: correctShare,
            count: totalCorrectAnswers,
            total: totalQuestions,
            color: AppColors.purple,
          ),
        ],
      ),
    );
  }
}

class TeacherRatioLine extends StatelessWidget {
  final String label;
  final double value;
  final int count;
  final int? total;
  final Color color;

  const TeacherRatioLine({
    super.key,
    required this.label,
    required this.value,
    required this.count,
    required this.color,
    this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (value.clamp(0, 1) * 100).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              total == null
                  ? '$count · ${percent.toStringAsFixed(0)}%'
                  : '$count/$total · ${percent.toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1).toDouble(),
            minHeight: 12,
            color: color,
            backgroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class TeacherInsightPanel extends StatelessWidget {
  final TeacherDashboard dashboard;

  const TeacherInsightPanel({
    super.key,
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 800;
        final positive = TeacherListInsight(
          title: 'Сильні сторони',
          icon: Icons.thumb_up,
          color: AppColors.green,
          items: dashboard.strongSides,
        );
        final attention = TeacherListInsight(
          title: 'Потребує уваги',
          icon: Icons.priority_high,
          color: AppColors.red,
          items: dashboard.attentionPoints,
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: positive),
              const SizedBox(width: 16),
              Expanded(child: attention),
            ],
          );
        }

        return Column(
          children: [
            positive,
            const SizedBox(height: 14),
            attention,
          ],
        );
      },
    );
  }
}

class TeacherListInsight extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  const TeacherListInsight({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color,
          width: 1.7,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: color,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TeacherRecentAttempts extends StatelessWidget {
  final List<TeacherChartPoint> points;

  const TeacherRecentAttempts({
    super.key,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final latest = points.reversed.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            'Останні спроби учня',
            icon: Icons.history_edu,
          ),
          const SizedBox(height: 12),
          if (latest.isEmpty)
            const EmptyState(
              icon: Icons.history,
              title: 'Спроб поки немає',
              subtitle: 'Після проходження квестів тут буде список останніх результатів.',
            )
          else
            ...latest.map(
              (point) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: point.percentage >= 80
                          ? AppColors.greenSoft
                          : point.percentage >= 50
                              ? AppColors.yellowSoft
                              : AppColors.redSoft,
                      child: Icon(
                        point.percentage >= 80
                            ? Icons.check
                            : point.percentage >= 50
                                ? Icons.trending_up
                                : Icons.priority_high,
                        color: point.percentage >= 80
                            ? AppColors.green
                            : point.percentage >= 50
                                ? AppColors.yellow
                                : AppColors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            point.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${point.score}/${point.totalQuestions} · ${point.generatedBy}',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${point.percentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

IconData teacherDashboardIcon(String icon) {
  switch (icon) {
    case 'percent':
      return Icons.percent;
    case 'emoji_events':
      return Icons.emoji_events;
    case 'warning':
      return Icons.warning_amber;
    case 'checklist':
      return Icons.checklist;
    case 'smart_toy':
      return Icons.smart_toy;
    case 'memory':
      return Icons.memory;
    case 'bolt':
      return Icons.bolt;
    case 'monetization_on':
      return Icons.monetization_on;
    default:
      return Icons.insights;
  }
}

Color teacherDashboardColor(String color) {
  switch (color) {
    case 'yellow':
      return AppColors.yellow;
    case 'purple':
      return AppColors.purple;
    case 'blue':
      return AppColors.blue;
    case 'green':
      return AppColors.green;
    case 'pink':
      return AppColors.pink;
    case 'red':
      return AppColors.red;
    default:
      return AppColors.blue;
  }
}
