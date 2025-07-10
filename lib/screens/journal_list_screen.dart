import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // <-- THE FIX: ADD THIS IMPORT
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/models/journal_entry.dart';
import '/screens/journal_entry_screen.dart';
import 'package:serene_sense/services/journal_service.dart';

class JournalListScreen extends StatelessWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final journalService = context.watch<JournalService>();
    final entries = journalService.entries;

    return Scaffold(
      body: entries.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                // This line will now work correctly
                return _JournalCard(entry: entries[index])
                    .animate()
                    .fadeIn(delay: (100 * index).ms, duration: 500.ms)
                    .slideX(begin: 0.2, curve: Curves.easeOut);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const JournalEntryScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_note_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            'Your Journal is Empty',
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            'Tap the + button to add your first entry.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms), // And this line will also work
    );
  }
}

// The _JournalCard and _SentimentIndicator widgets below remain unchanged
class _JournalCard extends StatelessWidget {
  final JournalEntry entry;
  const _JournalCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => JournalEntryScreen(entry: entry),
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
                  Row(
                    children: [
                      Text(entry.mood.emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.mood.displayName, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(DateFormat('MMMM d, yyyy').format(entry.timestamp), style: GoogleFonts.lato(color: Colors.grey.shade600, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  if (entry.sentimentScore != null)
                    _SentimentIndicator(score: entry.sentimentScore!)
                  else
                    const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ),
              const Divider(height: 24),
              Text(
                entry.content,
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