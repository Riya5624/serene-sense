// lib/models/dass_21_model.dart

/// Enum for type-safety, representing the three scales of the DASS-21 test.
enum DassScale { depression, anxiety, stress }

/// Represents a single question in the test, mapping its text to a scale.
class DassQuestion {
  final String text;
  final DassScale scale;

  const DassQuestion({required this.text, required this.scale});
}


// ------------------- FINAL MODEL FOR SAVING DATA -------------------
/// Represents a single, completed DASS-21 test record that is saved in the user's history.
/// This includes a unique ID and a timestamp for tracking over time.
class DassTestRecord {
  final String id;
  final DateTime timestamp;
  final int depressionScore;
  final String depressionSeverity;
  final int anxietyScore;
  final String anxietySeverity;
  final int stressScore;
  final String stressSeverity;

  DassTestRecord({
    required this.id,
    required this.timestamp,
    required this.depressionScore,
    required this.depressionSeverity,
    required this.anxietyScore,
    required this.anxietySeverity,
    required this.stressScore,
    required this.stressSeverity,
  });

  /// **UPDATED:** A factory constructor to cleanly create a saved record
  /// from a temporary calculation result. This encapsulates the creation logic.
  factory DassTestRecord.fromResult(DassResult result) {
    return DassTestRecord(
      id: DateTime.now().toIso8601String(), // Generate ID at the moment of creation
      timestamp: DateTime.now(), // Generate timestamp at the moment of creation
      depressionScore: result.depressionScore,
      depressionSeverity: result.depressionSeverity,
      anxietyScore: result.anxietyScore,
      anxietySeverity: result.anxietySeverity,
      stressScore: result.stressScore,
      stressSeverity: result.stressSeverity,
    );
  }

  /// Creates a formatted summary string to be passed back to the ChatService.
  String toSummaryString() {
    return 'DASS-21 Results: Depression - $depressionSeverity ($depressionScore), Anxiety - $anxietySeverity ($anxietyScore), Stress - $stressSeverity ($stressScore).';
  }
}


// ------------------- TEMPORARY MODEL FOR CALCULATION -------------------
/// A temporary data holder used by the Dass21Screen to represent the immediate
/// results of a calculation before they are saved as a permanent [DassTestRecord].
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
}