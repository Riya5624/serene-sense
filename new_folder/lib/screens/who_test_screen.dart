import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:serene_sense/services/chat_service.dart';

// Data class to hold question information
class DassQuestion {
  final String text;
  final String category; // 'D' for Depression, 'A' for Anxiety, 'S' for Stress

  DassQuestion({required this.text, required this.category});
}

class WhoTestScreen extends StatefulWidget {
  const WhoTestScreen({super.key});

  @override
  State<WhoTestScreen> createState() => _WhoTestScreenState();
}

class _WhoTestScreenState extends State<WhoTestScreen> {
  // List of all 21 DASS questions and their categories
  final List<DassQuestion> _questions = [
    DassQuestion(text: "I found it hard to wind down.", category: 'S'),
    DassQuestion(text: "I was aware of dryness of my mouth.", category: 'A'),
    DassQuestion(text: "I couldn’t seem to experience any positive feeling at all.", category: 'D'),
    DassQuestion(text: "I experienced breathing difficulty (e.g., excessively rapid breathing, breathlessness in the absence of physical exertion).", category: 'A'),
    DassQuestion(text: "I found it difficult to work up the initiative to do things.", category: 'D'),
    DassQuestion(text: "I tended to over-react to situations.", category: 'S'),
    DassQuestion(text: "I experienced trembling (e.g., in the hands).", category: 'A'),
    DassQuestion(text: "I felt that I was using a lot of nervous energy.", category: 'S'),
    DassQuestion(text: "I was worried about situations in which I might panic and make a fool of myself.", category: 'A'),
    DassQuestion(text: "I felt that I had nothing to look forward to.", category: 'D'),
    DassQuestion(text: "I found myself getting agitated.", category: 'S'),
    DassQuestion(text: "I found it difficult to relax.", category: 'S'),
    DassQuestion(text: "I felt down-hearted and blue.", category: 'D'),
    DassQuestion(text: "I was intolerant of anything that kept me from getting on with what I was doing.", category: 'S'),
    DassQuestion(text: "I felt I was close to panic.", category: 'A'),
    DassQuestion(text: "I was unable to become enthusiastic about anything.", category: 'D'),
    DassQuestion(text: "I felt I wasn’t worth much as a person.", category: 'D'),
    DassQuestion(text: "I felt that I was rather touchy.", category: 'S'),
    DassQuestion(text: "I was aware of the action of my heart in the absence of physical exertion (e.g., sense of heart rate increase, heart missing a beat).", category: 'A'),
    DassQuestion(text: "I felt scared without any good reason.", category: 'A'),
    DassQuestion(text: "I felt that life was meaningless.", category: 'D'),
  ];

  final List<String> _answerOptions = [
    "Did not apply to me at all",
    "Applied to me to some degree, or some of the time",
    "Applied to me to a considerable degree, or a good part of time",
    "Applied to me very much, or most of the time",
  ];

  // Map to store answers: key is question index, value is answer score (0-3)
  final Map<int, int> _answers = {};
  bool _areAllQuestionsAnswered = false;

  void _onAnswerChanged(int questionIndex, int? value) {
    setState(() {
      _answers[questionIndex] = value!;
      // Check if all questions have been answered to enable the submit button
      _areAllQuestionsAnswered = _answers.length == _questions.length;
    });
  }

  void _calculateAndSubmit() {
    int depressionScore = 0;
    int anxietyScore = 0;
    int stressScore = 0;

    for (int i = 0; i < _questions.length; i++) {
      final category = _questions[i].category;
      final score = _answers[i]!;

      if (category == 'D') depressionScore += score;
      if (category == 'A') anxietyScore += score;
      if (category == 'S') stressScore += score;
    }

    // IMPORTANT: DASS-21 scoring requires multiplying the final sums by 2
    depressionScore *= 2;
    anxietyScore *= 2;
    stressScore *= 2;

    // Interpret the scores
    final String resultString =
        "Depression: ${_getSeverityString(depressionScore, 'D')}, "
        "Anxiety: ${_getSeverityString(anxietyScore, 'A')}, "
        "Stress: ${_getSeverityString(stressScore, 'S')}.";

    // Notify the ChatService and go back
    context.read<ChatService>().userCompletedWhoTest(resultString);
    Navigator.of(context).pop();
  }

  String _getSeverityString(int score, String category) {
    if (category == 'D') {
      if (score <= 9) return 'Normal';
      if (score <= 13) return 'Mild';
      if (score <= 20) return 'Moderate';
      if (score <= 27) return 'Severe';
      return 'Extremely Severe';
    } else if (category == 'A') {
      if (score <= 7) return 'Normal';
      if (score <= 9) return 'Mild';
      if (score <= 14) return 'Moderate';
      if (score <= 19) return 'Severe';
      return 'Extremely Severe';
    } else { // Stress
      if (score <= 14) return 'Normal';
      if (score <= 18) return 'Mild';
      if (score <= 25) return 'Moderate';
      if (score <= 33) return 'Severe';
      return 'Extremely Severe';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Self-Assessment (DASS-21)", style: GoogleFonts.poppins()),
      ),
      body: Column(
        children: [
          // Instructions Header
          Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity,
            color: Colors.teal.withOpacity(0.1),
            child: Text(
              "Over the past week, how much did each statement apply to you?",
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(fontSize: 16, color: Colors.teal.shade800),
            ),
          ),
          // Questions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                return _QuestionCard(
                  question: _questions[index],
                  questionNumber: index + 1,
                  answerOptions: _answerOptions,
                  groupValue: _answers[index],
                  onChanged: (value) => _onAnswerChanged(index, value),
                );
              },
            ),
          ),
          // Submit Button Area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _areAllQuestionsAnswered ? _calculateAndSubmit : null, // Disabled if not all answered
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text("Submit & Continue"),
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}

// A dedicated widget for displaying a single question card for cleanliness
class _QuestionCard extends StatelessWidget {
  final DassQuestion question;
  final int questionNumber;
  final List<String> answerOptions;
  final int? groupValue;
  final ValueChanged<int?> onChanged;

  const _QuestionCard({
    required this.question,
    required this.questionNumber,
    required this.answerOptions,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: groupValue != null ? Colors.teal.shade200 : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$questionNumber. ${question.text}",
              style: GoogleFonts.lato(fontSize: 16.0, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12.0),
            // Generate the radio buttons for the answers
            ...List.generate(answerOptions.length, (index) {
              return RadioListTile<int>(
                title: Text(answerOptions[index]),
                value: index,
                groupValue: groupValue,
                onChanged: onChanged,
                contentPadding: EdgeInsets.zero,
                activeColor: Colors.teal,
              );
            }),
          ],
        ),
      ),
    );
  }
}