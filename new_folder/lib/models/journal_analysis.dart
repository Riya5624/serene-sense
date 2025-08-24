class JournalAnalysis {
  final String mentalStateSummary; // A single sentence summary of the mental state
  final String identifiedNegativeThought;
  final String cbtResponse; // The AI's full CBT-style response

  JournalAnalysis({
    required this.mentalStateSummary,
    required this.identifiedNegativeThought,
    required this.cbtResponse,
  });

  factory JournalAnalysis.fromJson(Map<String, dynamic> json) {
    return JournalAnalysis(
      mentalStateSummary: json['mental_state_summary'] ?? 'Analysis not available.',
      identifiedNegativeThought: json['identified_negative_thought'] ?? 'No specific negative thought identified.',
      cbtResponse: json['cbt_response'] ?? 'Keep reflecting on your thoughts!',
    );
  }
}