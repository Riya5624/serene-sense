// Enum for type-safety, representing the three scales.
enum DassScale { depression, anxiety, stress }

// Represents a single question in the test.
class DassQuestion {
  final String text;
  final DassScale scale;

  const DassQuestion({required this.text, required this.scale});
}

// Represents the final calculated result of the test.
class DassResult {
  final int depressionScore;
  final String depressionSeverity;
  final int anxietyScore;
  final String anxietySeverity;
  final int stressScore;
  final String stressSeverity;

  DassResult({
    required this.depressionScore,
    required this.depressionSeverity,
    required this.anxietyScore,
    required this.anxietySeverity,
    required this.stressScore,
    required this.stressSeverity,
  });

  /// Creates a formatted summary string to be passed back to the ChatService.
  String toSummaryString() {
    return "Depression: $depressionSeverity ($depressionScore), Anxiety: $anxietySeverity ($anxietyScore), Stress: $stressSeverity ($stressScore).";
  }
}