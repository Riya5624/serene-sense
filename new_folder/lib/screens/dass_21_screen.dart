// lib/screens/dass_21_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:serene_sense/models/dass_21_model.dart';
import 'package:serene_sense/providers/dass_result_provider.dart';
import 'package:serene_sense/services/chat_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Dass21Screen extends StatefulWidget {
  const Dass21Screen({super.key});

  @override
  State<Dass21Screen> createState() => _Dass21ScreenState();
}

class _Dass21ScreenState extends State<Dass21Screen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Map<int, int> _answers = {};

  // Descriptive text for the answer choices.
  final List<String> _answerOptions = const [
    'Not at all',
    'Sometimes',
    'Often',
    'Almost Always',
  ];

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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentQuestionAnswered = _answers.containsKey(_currentPage);
    final allQuestionsAnswered = _answers.length == _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text("DASS-21 Self-Assessment", style: GoogleFonts.poppins()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildProgressIndicator(),
            const SizedBox(height: 24),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) {
                  return _buildQuestionCard(index, key: ValueKey(index));
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildNavigationControls(
          isCurrentQuestionAnswered, allQuestionsAnswered),
    );
  }

  Widget _buildHeader() {
    return Text(
      "Over the past week, how much did this statement apply to you?",
      textAlign: TextAlign.center,
      style: GoogleFonts.lato(fontSize: 16, color: Colors.black87),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Text(
          'Question ${_currentPage + 1} of ${_questions.length}',
          style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_currentPage + 1) / _questions.length,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
  
  Widget _buildQuestionCard(int index, {Key? key}) {
    final question = _questions[index];
    final selectedAnswer = _answers[index];

    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              question.text,
              style: GoogleFonts.lato(fontSize: 20, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.0,
              runSpacing: 8.0,
              children: List.generate(_answerOptions.length, (chipIndex) {
                final isSelected = selectedAnswer == chipIndex;
                return ChoiceChip(
                  label: Text(_answerOptions[chipIndex]),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _answers[index] = chipIndex);
                      if (_currentPage < _questions.length - 1) {
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (mounted) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        });
                      }
                    }
                  },
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Theme.of(context).primaryColorDark : Colors.black87,
                  ),
                  side: BorderSide(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    ).animate(key: ValueKey(_currentPage)).fadeIn(duration: 400.ms);
  }

  Widget _buildNavigationControls(bool isCurrentAnswered, bool allAnswered) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.arrow_back_ios),
            label: const Text("Prev"),
            onPressed: _currentPage == 0
                ? null
                : () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
          ),
          if (_currentPage < _questions.length - 1)
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward_ios),
              label: const Text("Next"),
              onPressed: !isCurrentAnswered
                  ? null
                  : () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
            )
          else
            ElevatedButton(
              onPressed: !allAnswered ? null : _calculateSaveAndShowResults,
              child: const Text("View Results"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }

  void _calculateSaveAndShowResults() {
    int depressionSum = 0; int anxietySum = 0; int stressSum = 0;
    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final answer = _answers[i]!;
      switch (question.scale) {
        case DassScale.depression: depressionSum += answer; break;
        case DassScale.anxiety: anxietySum += answer; break;
        case DassScale.stress: stressSum += answer; break;
      }
    }
    final result = DassResult(
      depressionScore: depressionSum * 2,
      depressionSeverity: _getSeverity(DassScale.depression, depressionSum * 2),
      anxietyScore: anxietySum * 2,
      anxietySeverity: _getSeverity(DassScale.anxiety, anxietySum * 2),
      stressScore: stressSum * 2,
      stressSeverity: _getSeverity(DassScale.stress, stressSum * 2),
    );
    final newRecord = DassTestRecord.fromResult(result);
    context.read<DassResultProvider>().addRecord(newRecord);
    _showResultDialog(newRecord);
  }

  String _getSeverity(DassScale scale, int score) {
    switch (scale) {
      case DassScale.depression:
        if (score <= 9) return 'Normal'; if (score <= 13) return 'Mild'; if (score <= 20) return 'Moderate'; if (score <= 27) return 'Severe'; return 'Extremely Severe';
      case DassScale.anxiety:
        if (score <= 7) return 'Normal'; if (score <= 9) return 'Mild'; if (score <= 14) return 'Moderate'; if (score <= 19) return 'Severe'; return 'Extremely Severe';
      case DassScale.stress:
        if (score <= 14) return 'Normal'; if (score <= 18) return 'Mild'; if (score <= 25) return 'Moderate'; if (score <= 33) return 'Severe'; return 'Extremely Severe';
    }
  }

  void _showResultDialog(DassTestRecord record) {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Your Results", style: GoogleFonts.poppins()),
          content: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ResultRow("Depression", record.depressionSeverity, record.depressionScore),
              _ResultRow("Anxiety", record.anxietySeverity, record.anxietyScore),
              _ResultRow("Stress", record.stressSeverity, record.stressScore),
              const SizedBox(height: 16),
              Text( "Note: This is a screening tool, not a diagnosis. Please consult a professional for a comprehensive evaluation.", style: GoogleFonts.lato(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<ChatService>().userCompletedWhoTest(record.toSummaryString());
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
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
  final String label; final String severity; final int score;
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