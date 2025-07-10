class SessionAnalysis {
  final MentalState anxiety;
  final MentalState depression;
  final MentalState stress;
  // This version uses Lists of Strings for detailed points
  final List<String> keyNegativeThoughts;
  final List<String> positiveReframes;
  final List<String> suggestedActions;

  SessionAnalysis({
    required this.anxiety,
    required this.depression,
    required this.stress,
    required this.keyNegativeThoughts,
    required this.positiveReframes,
    required this.suggestedActions,
  });

  // This factory constructor creates an instance from a JSON map
  factory SessionAnalysis.fromJson(Map<String, dynamic> json) {
    // A helper function to safely parse lists
    List<String> _parseList(dynamic list) {
      if (list is List) {
        return List<String>.from(list.map((item) => item.toString()));
      }
      return [];
    }
    
    return SessionAnalysis(
      anxiety: MentalState.fromJson(json['analysis']?['anxiety'] ?? {}),
      depression: MentalState.fromJson(json['analysis']?['depression'] ?? {}),
      stress: MentalState.fromJson(json['analysis']?['stress'] ?? {}),
      keyNegativeThoughts: _parseList(json['summary']?['key_negative_thoughts']),
      positiveReframes: _parseList(json['summary']?['positive_reframes']),
      suggestedActions: _parseList(json['summary']?['suggested_actions']),
    );
  }
}

class MentalState {
  final String severity;
  final String evidence;

  MentalState({required this.severity, required this.evidence});

  factory MentalState.fromJson(Map<String, dynamic> json) {
    return MentalState(
      severity: json['severity'] ?? 'Not assessed',
      evidence: json['evidence'] ?? 'No specific evidence found.',
    );
  }
}