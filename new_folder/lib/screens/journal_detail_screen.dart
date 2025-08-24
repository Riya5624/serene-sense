// lib/screens/journal_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:serene_sense/data/journal_questions.dart';
import 'package:serene_sense/models/journal_entry.dart';

class JournalDetailScreen extends StatelessWidget {
  final JournalEntry entry;

  const JournalDetailScreen({super.key, required this.entry});

  // Helper to get a title based on the journal type
  String get _appBarTitle {
    switch (entry.type) {
      case JournalType.depression:
        return 'Depression Check-in Detail';
      case JournalType.anxiety:
        return 'Anxiety Check-in Detail';
      case JournalType.stress:
        return 'Stress Check-in Detail';
      default:
        return 'Daily Check-in Detail';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle, style: GoogleFonts.poppins()),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMoodCard(context),
          const SizedBox(height: 20),
          // UPDATED: Show the detailed questionnaire instead of the old content card.
          _buildQuestionnaireCard(context),
          const SizedBox(height: 20),
          if (entry.sentimentScore != null) _buildAnalysisCard(context),
        ],
      ),
    );
  }

  Widget _buildMoodCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'On ${DateFormat.yMMMd().format(entry.timestamp)}, you felt...',
              style: GoogleFonts.lato(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Text(
              entry.mood.emoji,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 8),
            Text(
              entry.mood.displayName,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: entry.mood.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// NEW: This widget dynamically builds the list of questions and answers.
  Widget _buildQuestionnaireCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Reflections',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 24),
            // Use ListView.separated for clean dividers between Q&A items.
            ListView.separated(
              shrinkWrap: true, // Important inside a scrolling parent
              physics: const NeverScrollableScrollPhysics(), // Also important
              itemCount: entry.questionAnswers.length,
              itemBuilder: (context, index) {
                final question = entry.questionAnswers.keys.elementAt(index);
                final answerIndex = entry.questionAnswers.values.elementAt(index);
                final answerText = (answerIndex < answerOptions.length)
                    ? answerOptions[answerIndex]
                    : "N/A";

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question,
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Chip(
                          label: Text(
                            answerText,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(height: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(BuildContext context) {
    final normalizedScore = (entry.sentimentScore! + 1) / 2;
    final scoreColor = Color.lerp(Colors.red.shade400, Colors.green.shade400, normalizedScore)!;
    String scoreLabel;
    if (normalizedScore > 0.65) {
      scoreLabel = 'Positive';
    } else if (normalizedScore < 0.35) {
      scoreLabel = 'Negative';
    } else {
      scoreLabel = 'Neutral';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Analysis',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sentiment:', style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  scoreLabel,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: scoreColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: normalizedScore,
                minHeight: 12,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('More Negative', style: GoogleFonts.lato(fontSize: 12, color: Colors.grey.shade600)),
                Text('More Positive', style: GoogleFonts.lato(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}