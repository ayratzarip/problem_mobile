import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:problem_mobile/features/entries/data/shared_preferences_entries_repository.dart';
import 'package:problem_mobile/features/entries/domain/problem_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:problem_mobile/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Главный экран отображается после загрузки', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProblemApp());
    await tester.pumpAndSettle();

    expect(find.text('Мои Записи'), findsOneWidget);
    expect(find.textContaining('Пока записей нет'), findsOneWidget);
    expect(find.text('Скопировать для AI'), findsNothing);
  });

  testWidgets(
    'Маршруты создания и инструкций открываются и возвращаются назад',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ProblemApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Новая запись'));
      await tester.pumpAndSettle();
      expect(find.text('Шаг 1'), findsOneWidget);
      expect(find.text('Что происходит?'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Мои Записи'), findsOneWidget);

      await tester.tap(find.byTooltip('Инструкции'));
      await tester.pumpAndSettle();
      expect(find.text('Инструкции'), findsOneWidget);

      await tester.tap(find.text('Всё понятно'));
      await tester.pumpAndSettle();
      expect(find.text('Мои Записи'), findsOneWidget);
    },
  );

  testWidgets(
    'Инструкции: показывают группы, поиск и локальную конфиденциальность',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ProblemApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Инструкции'));
      await tester.pumpAndSettle();

      expect(find.text('Инструкции'), findsOneWidget);
      expect(find.text('ЧТО ПИСАТЬ В ОПИСАНИИ'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('БЕЗОПАСНОСТЬ'),
        320,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('БЕЗОПАСНОСТЬ'), findsOneWidget);
      expect(find.text('Как работать с AI'), findsOneWidget);

      await tester.tap(find.text('Конфиденциальность'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('только локально на вашем телефоне'),
        findsOneWidget,
      );
      expect(
        find.textContaining('не использует облачную синхронизацию'),
        findsOneWidget,
      );
      expect(find.textContaining('Telegram Cloud Storage'), findsNothing);

      await tester.tap(find.text('Всё понятно'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Инструкции'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText).first, 'AI');
      await tester.pumpAndSettle();
      expect(find.text('Как работать с AI'), findsOneWidget);
      expect(find.text('Как создать новую запись'), findsNothing);
    },
  );

  testWidgets('Инструкции: показывают пустое состояние поиска', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProblemApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Инструкции'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).first, 'не существует');
    await tester.pumpAndSettle();

    expect(find.textContaining('Ничего не найдено'), findsOneWidget);
  });

  testWidgets(
    'Главный экран показывает запись, поиск и подтверждение удаления',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        entriesStorageKey: jsonEncode([
          _entry(
            id: 'entry-1',
            situation: 'Собираюсь сесть за JS',
            tags: const ['Работа'],
          ).toJson(),
        ]),
      });

      await tester.pumpWidget(const ProblemApp());
      await tester.pumpAndSettle();

      expect(find.text('СЕГОДНЯ'), findsOneWidget);
      expect(find.text('Собираюсь сесть за JS'), findsOneWidget);
      expect(find.text('Работа'), findsNothing);
      expect(find.text('Скопировать для AI'), findsOneWidget);

      await tester.enterText(find.byType(EditableText).first, 'ничего');
      await tester.pumpAndSettle();
      expect(find.text('Ничего не найдено'), findsOneWidget);

      await tester.enterText(find.byType(EditableText).first, 'JS');
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Удалить'));
      await tester.pumpAndSettle();
      expect(find.text('Удалить запись?'), findsOneWidget);

      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();
      expect(find.text('Собираюсь сесть за JS'), findsOneWidget);
    },
  );

  testWidgets('Главный экран: копирование для AI показывает успех', (
    WidgetTester tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          switch (call.method) {
            case 'Clipboard.setData':
              return null;
            default:
              return null;
          }
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    SharedPreferences.setMockInitialValues({
      entriesStorageKey: jsonEncode([
        _entry(
          id: 'entry-1',
          situation: 'Тест ситуации',
          tags: const ['Тег'],
        ).toJson(),
      ]),
    });

    await tester.pumpWidget(const ProblemApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Скопировать для AI'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Запрос скопирован в буфер обмена'),
      findsOneWidget,
    );
  });

  testWidgets('Мастер создания: первый шаг обязателен и показывает подсказку', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProblemApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Новая запись'));
    await tester.pumpAndSettle();

    expect(find.text('Шаг 1'), findsOneWidget);
    expect(find.text('Что происходит?'), findsOneWidget);
    expect(
      find.textContaining('или вам стало плохо просто сидя дома за смартфоном'),
      findsOneWidget,
    );
    expect(find.textContaining('Начальник громко сказал'), findsOneWidget);

    final nextButton = find.widgetWithText(FilledButton, 'Далее');
    expect(tester.widget<FilledButton>(nextButton).onPressed, isNull);

    await tester.ensureVisible(find.text('Подсказка'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Подсказка'));
    await tester.pumpAndSettle();
    expect(find.text('Совет'), findsOneWidget);
    expect(find.textContaining('Сижу на диване'), findsOneWidget);

    await tester.tap(find.text('Понятно'));
    await tester.pumpAndSettle();
  });

  testWidgets(
    'Мастер создания: заполненный черновик требует подтверждения отмены',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ProblemApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Новая запись'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).first, 'Ситуация');
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Далее'))
            .onPressed,
        isNotNull,
      );

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Отменить создание записи?'), findsOneWidget);

      await tester.tap(find.text('Продолжить'));
      await tester.pumpAndSettle();
      expect(find.text('Шаг 1'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Отменить'));
      await tester.pumpAndSettle();
      expect(find.text('Мои Записи'), findsOneWidget);
    },
  );

  testWidgets('Редактирование: показывает секции и сохраняет изменения', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      entriesStorageKey: jsonEncode([
        _entry(
          id: 'entry-1',
          situation: 'Старая ситуация',
          thoughts: 'Старые мысли',
          bodyFeelings: 'Ком в горле',
          bodyZones: const ['Горло'],
          consequences: 'Потерял час',
          withoutProblem: 'Пошел бы гулять',
        ).toJson(),
      ]),
    });

    await tester.pumpWidget(const ProblemApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Старая ситуация').first);
    await tester.pumpAndSettle();

    expect(find.text('Редактирование'), findsOneWidget);
    expect(find.text('ДАТА И ВРЕМЯ'), findsOneWidget);
    expect(find.text('СИТУАЦИЯ'), findsOneWidget);
    expect(find.text('МЫСЛИ'), findsOneWidget);
    expect(find.text('ТЕЛЕСНЫЕ ОЩУЩЕНИЯ'), findsOneWidget);
    expect(find.text('ЧАСТИ ТЕЛА'), findsOneWidget);
    expect(find.text('ПОСЛЕДСТВИЯ'), findsOneWidget);
    expect(find.text('БЕЗ ПРОБЛЕМЫ'), findsOneWidget);

    await tester.enterText(
      find.byType(EditableText).first,
      'Работа вызывает тревогу',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сохранить изменения'));
    await tester.pumpAndSettle();

    expect(find.text('Мои Записи'), findsOneWidget);
    expect(find.text('Работа вызывает тревогу'), findsOneWidget);
    expect(find.text('Работа'), findsNothing);
    expect(find.text('Тревога'), findsNothing);
  });

  testWidgets(
    'Редактирование: подтверждает выход при несохраненных изменениях',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        entriesStorageKey: jsonEncode([
          _entry(id: 'entry-1', situation: 'Исходная ситуация').toJson(),
        ]),
      });

      await tester.pumpWidget(const ProblemApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Исходная ситуация').first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText).first, 'Новая ситуация');
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Выйти без сохранения изменений?'), findsOneWidget);

      await tester.tap(find.text('Остаться'));
      await tester.pumpAndSettle();
      expect(find.text('Редактирование'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Выйти'));
      await tester.pumpAndSettle();
      expect(find.text('Мои Записи'), findsOneWidget);
    },
  );
}

ProblemEntry _entry({
  required String id,
  required String situation,
  String thoughts = '',
  String bodyFeelings = '',
  List<String> bodyZones = const [],
  String consequences = '',
  String withoutProblem = '',
  List<String> tags = const [],
}) {
  final now = DateTime.now();
  return ProblemEntry(
    id: id,
    situation: situation,
    thoughts: thoughts,
    bodyFeelings: bodyFeelings,
    bodyZones: bodyZones,
    consequences: consequences,
    withoutProblem: withoutProblem,
    emoji: '😌',
    title: situation,
    tags: tags,
    createdAt: now,
    updatedAt: now,
  );
}
