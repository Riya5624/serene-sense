import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:serene_sense/models/journal_entry.dart';
import 'package:http/http.dart' as http;

class JournalService with ChangeNotifier {
  final List<JournalEntry> _entries = []; // Start with an empty list

  List<JournalEntry> get entries => _entries..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  // --- OLLAMA CONFIG ---
  final String _ollamaHost = (!kIsWeb && Platform.isAndroid) ? '10.0.2.2' : 'localhost';
  final String _ollamaPort = '11434';
  final String _model = 'gemma:2b';

  /// Adds a new entry and returns its unique ID.
  String addEntry(String content, Mood mood) {
    final newEntry = JournalEntry(
      id: DateTime.now().toIso8601String(),
      content: content,
      mood: mood,
      timestamp: DateTime.now(),
    );
    _entries.add(newEntry);
    notifyListeners();
    return newEntry.id;
  }

  /// Updates an existing entry.
  void updateEntry(JournalEntry entry, String newContent, Mood newMood) {
    final updatedEntry = entry.copyWith(
      content: newContent,
      mood: newMood,
      sentimentScore: null, // Reset score as content has changed
    );
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = updatedEntry;
      notifyListeners();
    }
  }

  void deleteEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
    notifyListeners();
  }

  /// Analyzes an entry's content using Ollama and updates its sentiment score.
  Future<void> analyzeAndScoreEntry(String entryId) async {
    final index = _entries.indexWhere((e) => e.id == entryId);
    if (index == -1) return; // Entry not found or already deleted

    final entryToAnalyze = _entries[index];

    final prompt = """
      [INST] You are a sentiment analysis tool. Analyze the following text and provide a sentiment score. The score must be a single decimal number between -1.0 (very negative) and 1.0 (very positive). Your entire response must be a valid JSON object with a single key "score".
      
      Example 1:
      Text: "I had a wonderful day, everything went perfectly."
      Response: {"score": 0.9}
      
      Example 2:
      Text: "I feel terrible and nothing is going right."
      Response: {"score": -0.8}
      [/INST]
      [USER]
      Text: "${entryToAnalyze.content}"
      Response:
      [/USER]
    """;
    
    try {
      final response = await _callOllama(prompt);
      final jsonResponse = jsonDecode(response);
      final score = (jsonResponse['score'] as num).toDouble();
      
      final updatedEntry = entryToAnalyze.copyWith(sentimentScore: score);
      _entries[index] = updatedEntry;
      notifyListeners();
    } catch (e) {
      print("Error during sentiment analysis: $e");
    }
  }

  Future<String> _callOllama(String prompt) async {
    final response = await http.post(
      Uri.parse('http://$_ollamaHost:$_ollamaPort/api/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'model': _model, 'prompt': prompt, 'stream': false}),
    );
    if (response.statusCode == 200) {
      return (jsonDecode(response.body)['response'] as String).trim();
    } else {
      throw Exception('Failed to get response from Ollama: ${response.body}');
    }
  }
}