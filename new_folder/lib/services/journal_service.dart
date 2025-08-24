// lib/services/journal_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:serene_sense/config.dart'; // For the Gemini API key
import 'package:serene_sense/data/journal_questions.dart';
import 'package:serene_sense/models/journal_entry.dart';

/// A provider responsible for managing the user's journal entries.
/// It handles adding, deleting, and triggering AI analysis for entries.
class JournalService with ChangeNotifier {
  final List<JournalEntry> _entries = [];

  /// A public getter to access the list of journal entries,
  /// always sorted with the most recent entry first for display.
  List<JournalEntry> get entries => _entries..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  /// Adds a new questionnaire-based entry and returns its unique ID.
  String addEntry(Map<String, int> answers, Mood mood, JournalType type) {
    final newEntry = JournalEntry(
      id: DateTime.now().toIso8601String(),
      mood: mood,
      timestamp: DateTime.now(),
      type: type,
      questionAnswers: answers,
    );
    _entries.add(newEntry);
    notifyListeners();
    return newEntry.id;
  }

  /// Deletes an entry from the list by its ID.
  void deleteEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
    notifyListeners();
  }

  /// Sorts and returns the top N most significant journal entries.
  /// Sorting is done first by the total weight of answers (descending),
  /// and then by timestamp (descending) as a tie-breaker.
  List<JournalEntry> getHighestWeightedEntries({int count = 5}) {
    // Create a copy of the list to sort without modifying the original order.
    final sortedEntries = List<JournalEntry>.from(_entries);

    sortedEntries.sort((a, b) {
      // First, compare by total weight in descending order.
      final weightComparison = b.totalWeight.compareTo(a.totalWeight);
      if (weightComparison != 0) {
        // If weights are different, the sort order is determined.
        return weightComparison;
      } else {
        // If weights are the same (a tie), compare by timestamp (most recent first).
        return b.timestamp.compareTo(a.timestamp);
      }
    });

    // Return the first `count` items from the sorted list.
    return sortedEntries.take(count).toList();
  }

  /// Analyzes an entry's question/answer set using the Gemini API
  /// and updates its sentiment score.
  Future<void> analyzeAndScoreEntry(String entryId) async {
    final index = _entries.indexWhere((e) => e.id == entryId);
    if (index == -1) return; // Entry not found

    final entryToAnalyze = _entries[index];

    final qaString = entryToAnalyze.questionAnswers.entries.map((e) {
      final question = e.key;
      final answerIndex = e.value;
      final answerText = (answerIndex < answerOptions.length) ? answerOptions[answerIndex] : "N/A";
      return '- Q: "$question"\n  - A: "$answerText" (score: $answerIndex)';
    }).join('\n');
    
    final prompt = """
    You are a sentiment analysis tool. Analyze the following questions and answers from a user's mental health check-in. Provide a single sentiment score representing their overall state. The score must be a single decimal number between -1.0 (very negative/distressed) and 1.0 (very positive/well). Your entire response must be a valid JSON object with a single key "score".

    **Context:**
    - The check-in type is: ${entryToAnalyze.type.name.toUpperCase()}
    - The user's self-reported mood was: ${entryToAnalyze.mood.name.toUpperCase()}
    - The answers are based on a 0-4 scale from "Not at all" to "Extremely".

    **User's Check-in Data:**
    $qaString

    **Task:**
    Based on all the provided context, generate the sentiment score.
    """;
    
    try {
      final responseJsonString = await _callGeminiApi(prompt);
      
      String cleanedJson = responseJsonString;
      if (cleanedJson.startsWith("```json")) {
        cleanedJson = cleanedJson.substring(7, cleanedJson.length - 3).trim();
      } else if (cleanedJson.startsWith("`")) {
        cleanedJson = cleanedJson.substring(1, cleanedJson.length - 1).trim();
      }
      
      final jsonResponse = jsonDecode(cleanedJson);
      final score = (jsonResponse['score'] as num?)?.toDouble() ?? 0.0;
      
      final updatedEntry = entryToAnalyze.copyWith(sentimentScore: score);
      
      final finalIndex = _entries.indexWhere((e) => e.id == entryId);
      if (finalIndex != -1) {
        _entries[finalIndex] = updatedEntry;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error during sentiment analysis in JournalService: $e");
      }
    }
  }

  /// Calls the Gemini API using the standard request structure.
  Future<String> _callGeminiApi(String prompt) async {
    final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$geminiApiKey");

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "contents": [{"parts": [{"text": prompt}]}]
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if ((responseData['candidates'] as List).isEmpty) {
          throw Exception("Gemini API returned no candidates. Check for safety blocks.");
        }
        return responseData['candidates'][0]['content']['parts'][0]['text'].trim();
      } else {
        throw Exception('API Error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Could not connect to Gemini API. Check network and API key. Error: $e');
    }
  }
}