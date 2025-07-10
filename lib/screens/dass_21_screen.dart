import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:serene_sense/models/dass_21_model.dart';
import 'package:serene_sense/services/chat_service.dart';

class Dass21Screen extends StatefulWidget {
  const Dass21Screen({super.key});

  @override
  State<Dass21Screen> createState() => _Dass21ScreenState();
}

class _Dass21ScreenState extends State<Dass21Screen> {
  // A map to store the user's answers: {questionIndex: answerValue}
  final Map<int, int> _answers = {};

  // All 21 questions, mapped to their correct scale.
  final List<DassQuestion> _questions = const [
    DassQuestion(text: "I found it hard to wind down", scale: DassScale.stress),
    DassQuestion(text: "I was aware of dryness of my mouth", scale: DassScale.anxiety),
    DassQuestion(text: "I couldn’t seem to experience any positive feeling at all", scale: DassScale.depression),
    DassQuestion(text: "I experienced breathing difficulty (e.g. excessively rapid breathing, breathlessness in the absence of physical exertion)", scale: DassScale.anxiety),
    DassQuestion(text: "I found it difficult to work up the initiative to do things", scale: DassScale.depression),
    DassQuestion(text: "I tended to over-react to situations", scale: DassScale.stress),
    DassQuestion(text: "I experienced trembling (e.g. in the hands)", scale: DassScale.anxiety),
    DassQuestion(text: "I felt that I was using a lot of nervous energy", scale: DassScale.stress),
    DassQuestion(text: "I was worried about situations in which I might panic and make a fool of myself", scale: DassScale.anxiety),
    DassQuestion(text: "I felt that I had nothing to look forward to", scale: DassScale.depression),
    DassQuestion(text: "I found myself getting agitated", scale: DassScale.stress),
    DassQuestion(text: "I found it difficult to relax", scale: DassScale.stress),
    DassQuestion(text: "I felt down-hearted and blue", scale: DassScale.depression),
    DassQuestion(text: "I was intolerant of anything that kept me from getting on with what I was doing", scale: DassScale.stress),
    DassQuestion(text: "I felt I was close to panic", scale: DassScale.anxiety),
    DassQuestion(text: "I was unable to become enthusiastic about anything", scale: DassScale.depression),
    DassQuestion(text: "I felt I wasn’t worth much as a person", scale: DassScale.depression),
    DassQuestion(text: "I felt that I was rather touchy", scale: DassScale.stress),
    DassQuestion(text: "I was aware of the action of my heart in the absence of physical exertion", scale: DassScale.anxiety),
    DassQuestion(text: "I felt scared without any good reason", scale: DassScale.anxiety),
    DassQuestion(text: "I felt that life was meaningless", scale: DassScale.depression),
  ];

  @override
  Widget build(BuildContext context) {
    bool allAnswered = _answers.length == _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text("DASS-21 Self-Assessment", style: GoogleFonts.poppins()),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _questions.length + 1, // +1 for the header
        itemBuilder: (context, index) {
          if (index == 0) return _buildHeader();
          final questionIndex = index - 1;
          return _buildQuestionCard(questionIndex);
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: allAnswered ? _calculateAndShowResults : null,
          child: const Text("View Results"),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Text(
        "Over the past week, how much did each statement apply to you?",
        style: GoogleFonts.lato(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    final question = _questions[index];
    final selectedAnswer = _answers[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${index + 1}. ${question.text}",
              style: GoogleFonts.lato(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (value) {
                return GestureDetector(
                  onTap: () => setState(() => _answers[index] = value),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selectedAnswer == value ? Theme.of(context).primaryColor : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        value.toString(),
                        style: TextStyle(
                          color: selectedAnswer == value ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _calculateAndShowResults() {
    int depressionSum = 0;
    int anxietySum = 0;
    int stressSum = 0;

    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final answer = _answers[i]!;
      switch (question.scale) {
        case DassScale.depression:
          depressionSum += answer;
          break;
        case DassScale.anxiety:
          anxietySum += answer;
          break;
        case DassScale.stress:
          stressSum += answer;
          break;
      }
    }

    // Multiply scores by 2 as per DASS-21 instructions
    final int finalDepression = depressionSum * 2;
    final int finalAnxiety = anxietySum * 2;
    final int finalStress = stressSum * 2;

    final result = DassResult(
      depressionScore: finalDepression,
      depressionSeverity: _getSeverity(DassScale.depression, finalDepression),
      anxietyScore: finalAnxiety,
      anxietySeverity: _getSeverity(DassScale.anxiety, finalAnxiety),
      stressScore: finalStress,
      stressSeverity: _getSeverity(DassScale.stress, finalStress),
    );

    _showResultDialog(result);
  }

  String _getSeverity(DassScale scale, int score) {
    switch (scale) {
      case DassScale.depression:
        if (score <= 9) return 'Normal';
        if (score <= 13) return 'Mild';
        if (score <= 20) return 'Moderate';
        if (score <= 27) return 'Severe';
        return 'Extremely Severe';
      case DassScale.anxiety:
        if (score <= 7) return 'Normal';
        if (score <= 9) return 'Mild';
        if (score <= 14) return 'Moderate';
        if (score <= 19) return 'Severe';
        return 'Extremely Severe';
      case DassScale.stress:
        if (score <= 14) return 'Normal';
        if (score <= 18) return 'Mild';
        if (score <= 25) return 'Moderate';
        if (score <= 33) return 'Severe';
        return 'Extremely Severe';
    }
  }

  void _showResultDialog(DassResult result) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap the button
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Your Results"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ResultRow("Depression", result.depressionSeverity, result.depressionScore),
              _ResultRow("Anxiety", result.anxietySeverity, result.anxietyScore),
              _ResultRow("Stress", result.stressSeverity, result.stressScore),
              const SizedBox(height: 16),
              Text(
                "Note: This is a screening tool, not a diagnosis. Please consult a professional for a comprehensive evaluation.",
                style: GoogleFonts.lato(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // CRITICAL: This is where we link back to the chat service
                context.read<ChatService>().userCompletedWhoTest(result.toSummaryString());
                Navigator.of(dialogContext).pop(); // Close the dialog
                Navigator.of(context).pop(); // Close the DASS-21 screen
              },
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String severity;
  final int score;
  const _ResultRow(this.label, this.severity, this.score);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.lato(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: "$severity (Score: $score)"),
          ],
        ),
      ),
    );
  }
}