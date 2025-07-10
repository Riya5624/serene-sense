import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:serene_sense/models/journal_entry.dart';
import 'package:serene_sense/services/chat_service.dart';
import 'package:serene_sense/services/journal_service.dart';

class JournalEntryScreen extends StatefulWidget {
  final JournalEntry? entry;
  const JournalEntryScreen({super.key, this.entry});

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  late final TextEditingController _contentController;
  late Mood _selectedMood;
  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.entry?.content ?? '');
    _selectedMood = widget.entry?.mood ?? Mood.neutral;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please write something before saving.')));
      return;
    }

    final journalService = context.read<JournalService>();
    final chatService = context.read<ChatService>();

    if (_isEditing) {
      journalService.updateEntry(widget.entry!, content, _selectedMood);
      journalService.analyzeAndScoreEntry(widget.entry!.id);
    } else {
      final newEntryId = journalService.addEntry(content, _selectedMood);
      journalService.analyzeAndScoreEntry(newEntryId);

      // CRITICAL: Inform ChatService to resume the guided flow.
      chatService.userCompletedJournaling(content);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Entry' : 'New Entry', style: GoogleFonts.poppins()),
        actions: [IconButton(icon: const Icon(Icons.check_rounded), onPressed: _saveEntry, tooltip: 'Save')],
      ),
      body: ListView( // Use ListView for better small-screen adaptability
        padding: const EdgeInsets.all(20.0),
        children: [
          Text("How are you feeling today?", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _buildMoodSelector(),
          const SizedBox(height: 32),
          Text("What's on your mind?", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)]
            ),
            child: TextField(
              controller: _contentController,
              decoration: const InputDecoration.collapsed(hintText: 'Describe your thoughts and feelings...'),
              style: GoogleFonts.lato(fontSize: 16, height: 1.6),
              maxLines: null,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
        ],
      ),
    );
  }

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
              border: Border.all(
                color: isSelected ? mood.color : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Transform.scale(
              scale: isSelected ? 1.2 : 1.0,
              child: Text(mood.emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
        );
      }).toList(),
    );
  }
}