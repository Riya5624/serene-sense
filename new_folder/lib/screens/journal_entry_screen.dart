// lib/screens/journal_entry_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:serene_sense/data/journal_questions.dart';
import 'package:serene_sense/models/journal_entry.dart';
import 'package:serene_sense/services/chat_service.dart';
import 'package:serene_sense/services/journal_service.dart';

/// This screen presents a guided, questionnaire-based check-in to the user.
/// It has replaced the old free-text JournalEditScreen.
class JournalEntryScreen extends StatefulWidget {
  /// The type of journal determines which set of questions are displayed.
  final JournalType journalType;

  const JournalEntryScreen({super.key, required this.journalType});

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  late final List<String> _questions;
  final Map<String, int> _answers = {}; // Stores question -> answer index
  late Mood _selectedMood;

  @override
  void initState() {
    super.initState();
    // Initialize state based on the provided journal type
    _questions = journalQuestions[widget.journalType]!;
    _selectedMood = Mood.neutral;
  }

  /// Saves the completed questionnaire and notifies the ChatService if needed.
  void _saveEntry() {
    if (_answers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please answer all questions before saving.'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final journalService = context.read<JournalService>();
    final chatService = context.read<ChatService>();

    final newEntryId = journalService.addEntry(
      _answers,
      _selectedMood,
      widget.journalType,
    );

    // After adding, find the full entry object to pass back to the chat service.
    // This ensures the ChatService has all the data it needs for its analysis.
    final newEntry = journalService.entries.firstWhere((e) => e.id == newEntryId);
    
    // Trigger the asynchronous AI analysis for the new entry.
    journalService.analyzeAndScoreEntry(newEntryId);

    // Notify ChatService that journaling is complete so it can resume the conversation.
    chatService.userCompletedJournaling(entry: newEntry);

    // Go back to the previous screen (either the chat or the journal list).
    Navigator.of(context).pop();
  }

  /// Helper getter to create a dynamic title for the AppBar.
  String get _appBarTitle {
    switch (widget.journalType) {
      case JournalType.depression:
        return 'Depression Check-in';
      case JournalType.anxiety:
        return 'Anxiety Check-in';
      case JournalType.stress:
        return 'Stress Check-in';
      case JournalType.general:
        return 'Daily Check-in';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle, style: GoogleFonts.poppins()),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _saveEntry,
            tooltip: 'Save Check-in',
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          Text("How are you feeling overall today?",
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _buildMoodSelector(),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          // Dynamically build the list of question widgets from our state
          ..._questions.map((question) => _buildQuestionWidget(question)).toList(),
        ],
      ),
    );
  }

  /// Builds a single question widget with its interactive answer choices.
  Widget _buildQuestionWidget(String question) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: GoogleFonts.lato(fontSize: 17, height: 1.5, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          // Wrap allows the chips to flow to the next line on smaller screens
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: List.generate(answerOptions.length, (index) {
              final isSelected = _answers[question] == index;
              return ChoiceChip(
                label: Text(answerOptions[index]),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _answers[question] = index;
                    }
                  });
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
          )
        ],
      ),
    );
  }

  /// Builds the horizontal row of selectable, animated mood emojis.
  Widget _buildMoodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: Mood.values.map((mood) {
        final isSelected = _selectedMood == mood;
        return InkWell(
          onTap: () => setState(() => _selectedMood = mood),
          borderRadius: BorderRadius.circular(30),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? mood.color.withOpacity(0.25) : Colors.transparent,
            ),
            child: Transform.scale(
              scale: isSelected ? 1.15 : 1.0,
              child: Text(mood.emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
        );
      }).toList(),
    );
  }
}