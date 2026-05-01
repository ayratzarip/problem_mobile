import 'package:flutter_test/flutter_test.dart';
import 'package:problem_mobile/features/entries/domain/entry_metadata.dart';

void main() {
  group('generateTitle', () {
    test('возвращает название по первой строке ситуации', () {
      expect(
        generateTitle('Сижу дома, хочу начать писать книгу\nДальше текст'),
        'Сижу дома, хочу начать писать книгу',
      );
    });

    test('обрезает длинное название до 50 символов с многоточием', () {
      expect(generateTitle('а' * 60), '${'а' * 47}...');
    });

    test('возвращает дефолтное название для пустой ситуации', () {
      expect(generateTitle(''), 'Новая запись');
    });
  });

  group('getEmoji', () {
    test('распознает тревогу', () {
      expect(getEmoji('Сильная тревога и беспокойство'), '😰');
    });

    test('возвращает нейтральный emoji по умолчанию', () {
      expect(getEmoji('Просто сижу дома'), '😌');
    });
  });

  group('extractTags', () {
    test('извлекает уникальные теги и ограничивает список тремя', () {
      expect(
        extractTags('Работа, начальник, семья, тревога, здоровье, друзья'),
        ['Работа', 'Семья', 'Тревога'],
      );
    });
  });
}
