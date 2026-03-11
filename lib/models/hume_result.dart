class EmotionScore {
  const EmotionScore({required this.name, required this.score});

  final String name;
  final double score;

  factory EmotionScore.fromJson(Map<String, dynamic> json) {
    return EmotionScore(
      name: json['name'] as String,
      score: (json['score'] as num).toDouble(),
    );
  }
}

class FacsScore {
  const FacsScore({required this.name, required this.score});

  final String name;
  final double score;

  factory FacsScore.fromJson(Map<String, dynamic> json) {
    return FacsScore(
      name: json['name'] as String,
      score: (json['score'] as num).toDouble(),
    );
  }
}

class DescriptionScore {
  const DescriptionScore({required this.name, required this.score});

  final String name;
  final double score;

  factory DescriptionScore.fromJson(Map<String, dynamic> json) {
    return DescriptionScore(
      name: json['name'] as String,
      score: (json['score'] as num).toDouble(),
    );
  }
}

class HumeResult {
  const HumeResult({
    required this.emotions,
    required this.facs,
    required this.descriptions,
  });

  final List<EmotionScore> emotions;
  final List<FacsScore> facs;
  final List<DescriptionScore> descriptions;

  List<EmotionScore> get topEmotions {
    final sorted = [...emotions]..sort((a, b) => b.score.compareTo(a.score));
    return sorted.take(5).toList();
  }

  List<FacsScore> get topFacs {
    final sorted = [...facs]..sort((a, b) => b.score.compareTo(a.score));
    return sorted.where((f) => f.score > 0.1).take(10).toList();
  }

  List<DescriptionScore> get topDescriptions {
    final sorted = [...descriptions]..sort((a, b) => b.score.compareTo(a.score));
    return sorted.where((d) => d.score > 0.1).take(8).toList();
  }

  String get dominantEmotionName =>
      emotions.isEmpty ? 'neutral' : topEmotions.first.name;
}
