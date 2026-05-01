class EntryDraft {
  const EntryDraft({
    this.situation = '',
    this.thoughts = '',
    this.bodyFeelings = '',
    this.bodyZones = const [],
    this.consequences = '',
    this.withoutProblem = '',
  });

  final String situation;
  final String thoughts;
  final String bodyFeelings;
  final List<String> bodyZones;
  final String consequences;
  final String withoutProblem;

  bool get isEmpty =>
      situation.trim().isEmpty &&
      thoughts.trim().isEmpty &&
      bodyFeelings.trim().isEmpty &&
      bodyZones.isEmpty &&
      consequences.trim().isEmpty &&
      withoutProblem.trim().isEmpty;

  EntryDraft copyWith({
    String? situation,
    String? thoughts,
    String? bodyFeelings,
    List<String>? bodyZones,
    String? consequences,
    String? withoutProblem,
  }) {
    return EntryDraft(
      situation: situation ?? this.situation,
      thoughts: thoughts ?? this.thoughts,
      bodyFeelings: bodyFeelings ?? this.bodyFeelings,
      bodyZones: bodyZones ?? this.bodyZones,
      consequences: consequences ?? this.consequences,
      withoutProblem: withoutProblem ?? this.withoutProblem,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'situation': situation,
      'thoughts': thoughts,
      'bodyFeelings': bodyFeelings,
      'bodyZones': bodyZones,
      'consequences': consequences,
      'withoutProblem': withoutProblem,
    };
  }

  factory EntryDraft.fromJson(Map<String, Object?> json) {
    return EntryDraft(
      situation: json['situation'] as String? ?? '',
      thoughts: json['thoughts'] as String? ?? '',
      bodyFeelings: json['bodyFeelings'] as String? ?? '',
      bodyZones: (json['bodyZones'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      consequences: json['consequences'] as String? ?? '',
      withoutProblem: json['withoutProblem'] as String? ?? '',
    );
  }
}
