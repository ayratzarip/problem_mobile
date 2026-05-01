const bodyZones = [
  'Голова',
  'Грудь',
  'Живот',
  'Плечи',
  'Руки',
  'Ноги',
  'Спина',
  'Горло',
];

String generateTitle(String situation) {
  if (situation.isEmpty) {
    return 'Новая запись';
  }

  final firstLine = situation.split('\n').first;
  if (firstLine.length <= 50) {
    return firstLine;
  }

  return '${firstLine.substring(0, 47)}...';
}

String getEmoji(String text) {
  final lowerText = text.toLowerCase();

  if (lowerText.contains('радост') ||
      lowerText.contains('счастл') ||
      lowerText.contains('удач')) {
    return '😊';
  }
  if (lowerText.contains('страх') ||
      lowerText.contains('боюсь') ||
      lowerText.contains('испуг')) {
    return '😨';
  }
  if (lowerText.contains('тревог') ||
      lowerText.contains('беспоко') ||
      lowerText.contains('волну')) {
    return '😰';
  }
  if (lowerText.contains('грус') ||
      lowerText.contains('печаль') ||
      lowerText.contains('плач')) {
    return '😢';
  }
  if (lowerText.contains('злость') ||
      lowerText.contains('раздраж') ||
      lowerText.contains('бесит')) {
    return '😤';
  }
  if (lowerText.contains('устал') ||
      lowerText.contains('скуч') ||
      lowerText.contains('апати')) {
    return '😔';
  }
  if (lowerText.contains('думаю') || lowerText.contains('размышл')) {
    return '🤔';
  }

  return '😌';
}

List<String> extractTags(String text) {
  final tags = <String>[];
  final lowerText = text.toLowerCase();
  const tagMap = <String, String>{
    'работ': 'Работа',
    'начальник': 'Работа',
    'коллег': 'Работа',
    'семь': 'Семья',
    'родител': 'Семья',
    'дети': 'Семья',
    'муж': 'Семья',
    'жен': 'Семья',
    'тревог': 'Тревога',
    'беспоко': 'Тревога',
    'страх': 'Страх',
    'боюсь': 'Страх',
    'грус': 'Грусть',
    'печаль': 'Грусть',
    'злость': 'Злость',
    'раздраж': 'Злость',
    'радост': 'Радость',
    'счастл': 'Радость',
    'успех': 'Успех',
    'удач': 'Успех',
    'здоров': 'Здоровье',
    'болезн': 'Здоровье',
    'друз': 'Друзья',
    'личн': 'Личное',
  };

  for (final entry in tagMap.entries) {
    if (lowerText.contains(entry.key) && !tags.contains(entry.value)) {
      tags.add(entry.value);
    }
  }

  return tags.take(3).toList();
}
