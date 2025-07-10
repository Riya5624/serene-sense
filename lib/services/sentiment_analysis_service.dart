import 'dart:math';

/// A simulated service for analyzing the sentiment of a given text.
///
/// In a real-world application, the `analyze` method would be replaced with a
/// call to a cloud-based NLP API (like Google Cloud Natural Language, AWS Comprehend)
/// or an on-device TensorFlow Lite model.
class SentimentAnalysisService {

  /// Analyzes the input text and returns a sentiment score between -1.0 and 1.0.
  ///
  /// - **-1.0** represents a very negative sentiment.
  /// - **0.0** represents a neutral sentiment.
  /// - **1.0** represents a very positive sentiment.
  ///
  /// This method returns a `Future` to mimic the asynchronous nature of a
  /// real network call or a heavy computation.
  Future<double> analyze(String text) async {
    // Simulate a network delay for a more realistic user experience.
    await Future.delayed(const Duration(milliseconds: 500));

    // Define simple lists of positive and negative keywords.
    // A real model would be much more sophisticated.
    const List<String> positiveWords = [
      'happy', 'joyful', 'amazing', 'wonderful', 'great', 'good', 'love',
      'excellent', 'fantastic', 'beautiful', 'calm', 'proud', 'excited'
    ];
    const List<String> negativeWords = [
      'sad', 'angry', 'terrible', 'awful', 'bad', 'hate', 'hopeless',
      'stressed', 'anxious', 'worried', 'frustrated', 'disappointed'
    ];

    // Prepare the text for analysis: lowercase and split into words.
    // The RegExp removes punctuation and splits by spaces.
    final words = text.toLowerCase().split(RegExp(r"[ .,!?\n]+"));

    // If there's no text, return a neutral score.
    if (words.isEmpty) return 0.0;

    double score = 0;
    int significantWords = 0;

    // Iterate through the words and adjust the score.
    for (final word in words) {
      if (positiveWords.contains(word)) {
        score++;
        significantWords++;
      } else if (negativeWords.contains(word)) {
        score--;
        significantWords++;
      }
    }

    // Avoid division by zero if no significant words were found.
    if (significantWords == 0) return 0.0;

    // Normalize the score to be between -1.0 and 1.0 by dividing by the
    // number of significant words found.
    // The `clamp` function ensures the value stays within the [-1.0, 1.0] range,
    // protecting against any unexpected calculation results.
    return (score / significantWords).clamp(-1.0, 1.0);
  }
}