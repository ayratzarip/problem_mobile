import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:problem_mobile/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Главный экран отображается после загрузки', (WidgetTester tester) async {
    await tester.pumpWidget(const ProblemApp());
    await tester.pumpAndSettle();

    expect(find.text('Problem?'), findsOneWidget);
    expect(find.text('Мои записи'), findsOneWidget);
    expect(
      find.textContaining('Пока записей нет'),
      findsOneWidget,
    );
  });

  testWidgets('Маршруты создания и инструкций открываются и возвращаются назад', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProblemApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Новая запись'));
    await tester.pumpAndSettle();
    expect(find.text('Шаг 1'), findsOneWidget);
    expect(find.text('Что происходит?'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Мои записи'), findsOneWidget);

    await tester.tap(find.byTooltip('Инструкции'));
    await tester.pumpAndSettle();
    expect(find.text('Инструкции'), findsOneWidget);

    await tester.tap(find.text('Всё понятно'));
    await tester.pumpAndSettle();
    expect(find.text('Мои записи'), findsOneWidget);
  });
}
