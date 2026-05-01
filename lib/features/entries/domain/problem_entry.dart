import 'entry_draft.dart';

class ProblemEntry {
  const ProblemEntry({
    required this.id,
    required this.situation,
    required this.thoughts,
    required this.bodyFeelings,
    required this.bodyZones,
    required this.consequences,
    required this.withoutProblem,
    required this.emoji,
    required this.title,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String situation;
  final String thoughts;
  final String bodyFeelings;
  final List<String> bodyZones;
  final String consequences;
  final String withoutProblem;
  final String emoji;
  final String title;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  EntryDraft toDraft() {
    return EntryDraft(
      situation: situation,
      thoughts: thoughts,
      bodyFeelings: bodyFeelings,
      bodyZones: bodyZones,
      consequences: consequences,
      withoutProblem: withoutProblem,
    );
  }

  ProblemEntry copyWith({
    String? id,
    String? situation,
    String? thoughts,
    String? bodyFeelings,
    List<String>? bodyZones,
    String? consequences,
    String? withoutProblem,
    String? emoji,
    String? title,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProblemEntry(
      id: id ?? this.id,
      situation: situation ?? this.situation,
      thoughts: thoughts ?? this.thoughts,
      bodyFeelings: bodyFeelings ?? this.bodyFeelings,
      bodyZones: bodyZones ?? this.bodyZones,
      consequences: consequences ?? this.consequences,
      withoutProblem: withoutProblem ?? this.withoutProblem,
      emoji: emoji ?? this.emoji,
      title: title ?? this.title,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'situation': situation,
      'thoughts': thoughts,
      'bodyFeelings': bodyFeelings,
      'bodyZones': bodyZones,
      'consequences': consequences,
      'withoutProblem': withoutProblem,
      'emoji': emoji,
      'title': title,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProblemEntry.fromJson(Map<String, Object?> json) {
    return ProblemEntry(
      id: json['id'] as String? ?? '',
      situation: json['situation'] as String? ?? '',
      thoughts: json['thoughts'] as String? ?? '',
      bodyFeelings: json['bodyFeelings'] as String? ?? '',
      bodyZones: (json['bodyZones'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      consequences: json['consequences'] as String? ?? '',
      withoutProblem: json['withoutProblem'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '😌',
      title: json['title'] as String? ?? 'Новая запись',
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
