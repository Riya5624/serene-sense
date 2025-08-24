// lib/screens/journal_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:serene_sense/data/journal_questions.dart';
import 'package:serene_sense/models/journal_entry.dart';
import 'package:serene_sense/screens/journal_detail_screen.dart';
import 'package:serene_sense/screens/journal_entry_screen.dart';
import 'package:serene_sense/services/journal_service.dart';

/// A screen that displays a list of all the user's past journal check-ins.
class JournalListScreen extends StatelessWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch for changes in the journal service to rebuild the list
    final journalService = context.watch<JournalService>();
    final entries = journalService.entries;

    return Scaffold(
      body: entries.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                return _JournalCard(entry: entries[index])
                    .animate()
                    .fadeIn(delay: (100 * index).ms, duration: 500.ms)
                    .slideX(begin: 0.2, curve: Curves.easeOut);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // The FAB starts a 'General' questionnaire for a new check-in.
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const JournalEntryScreen(
                journalType: JournalType.general,
              ),
            ),
          );
        },
        tooltip: 'New Check-in',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// A widget to display when the user has no journal entries yet.
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_note_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            'No Check-ins Yet',
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            'Tap the + button to add your first check-in.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }
}

/// A tappable card widget that displays a summary of a single journal entry.
class _JournalCard extends StatelessWidget {
  final JournalEntry entry;
  const _JournalCard({required this.entry});

  String get _cardTitle {
    switch (entry.type) {
      case JournalType.depression:
        return 'Depression Check-in';
      case JournalType.anxiety:
        return 'Anxiety Check-in';
      case JournalType.stress:
        return 'Stress Check-in';
      case JournalType.general:
        return 'Daily Check-in';
      default:
        return 'Journal Entry';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to the detail screen when the card is tapped.
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => JournalDetailScreen(entry: entry),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Use Expanded to prevent overflow if the title is long.
                  Expanded(
                    child: Row(
                      children: [
                        Text(entry.mood.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        // Use Flexible to prevent the title/date column from overflowing.
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _cardTitle,
                                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                DateFormat('MMMM d, yyyy').format(entry.timestamp),
                                style: GoogleFonts.lato(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (entry.sentimentScore != null)
                    _SentimentIndicator(score: entry.sentimentScore!)
                  else
                    const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ),
              const Divider(height: 24),
              Text(
                entry.summary,
                style: GoogleFonts.lato(fontSize: 15, height: 1.5, color: Colors.black87),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A chip that displays the sentiment (Positive, Neutral, Negative) with a corresponding color.
class _SentimentIndicator extends StatelessWidget {
  final double score;
  const _SentimentIndicator({required this.score});

  String get _label {
    if (score > 0.3) return "Positive";
    if (score < -0.3) return "Negative";
    return "Neutral";
  }

  Color get _color {
    if (score > 0.3) return Colors.green.shade400;
    if (score < -0.3) return Colors.red.shade400;
    return Colors.grey.shade500;
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(_label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      backgroundColor: _color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}