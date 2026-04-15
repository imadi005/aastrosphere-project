class DailyPrediction {
  final String quote;
  final String rating;
  final String insight;
  final List<String> whatToDo;
  final List<String> whatToAvoid;
  final List<YogaModel> activeYogas;

  DailyPrediction({
    required this.quote,
    required this.rating,
    required this.insight,
    required this.whatToDo,
    required this.whatToAvoid,
    required this.activeYogas,
  });

  factory DailyPrediction.fromJson(Map<String, dynamic> json) {
    return DailyPrediction(
      quote: json['quote'] ?? '',
      rating: json['rating'] ?? 'neutral',
      insight: json['insight'] ?? '',
      whatToDo: List<String>.from(json['what_to_do'] ?? []),
      whatToAvoid: List<String>.from(json['what_to_avoid'] ?? []),
      activeYogas: (json['active_yogas'] as List? ?? [])
          .map((y) => YogaModel.fromJson(y))
          .toList(),
    );
  }
}

class YogaModel {
  final String name;
  final bool positive;

  YogaModel({required this.name, required this.positive});

  factory YogaModel.fromJson(Map<String, dynamic> json) {
    return YogaModel(
      name: json['name'] ?? '',
      positive: json['positive'] ?? true,
    );
  }
}