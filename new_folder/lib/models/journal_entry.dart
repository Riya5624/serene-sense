// lib/models/journal_entry.dart

import 'package:flutter/material.dart';
import 'package:serene_sense/data/journal_questions.dart'; // Required for JournalType and answerOptions

/// An enum for predefined moods, with helpers for UI display.
enum Mood {
  happy,
  calm,
  neutral,
  anxious,
  sad,
  angry;

  /// Helper to get a display-friendly name.
  String get displayName {
    switch (this) {
      case Mood.happy: return 'Happy';
      case Mood.calm: return 'Calm';
      case Mood.neutral: return 'Neutral';
      case Mood.anxious: return 'Anxious';
      case Mood.sad: return 'Sad';
      case Mood.angry: return 'Angry';
    }
  }

  /// Helper to get a corresponding emoji.
  String get emoji {
    switch (this) {
      case Mood.happy: return '😄';
      case Mood.calm: return '😌';
      case Mood.neutral: return '😐';
      case Mood.anxious: return '😟';
      case Mood.sad: return '😢';
      case Mood.angry: return '😠';
    }
  }

  /// Helper for color coding in the UI.
  Color get color {
    switch(this) {
      case Mood.happy: return Colors.green.shade400;
      case Mood.calm: return Colors.blue.shade400;
      case Mood.neutral: return Colors.grey.shade500;
      case Mood.anxious: return Colors.orange.shade400;
      case Mood.sad: return Colors.indigo.shade400;
      case Mood.angry: return Colors.red.shade400;
    }
  }
}

/// Represents a single, questionnaire-based journal entry.
/// This model is designed to store structured data from a check-in.
class JournalEntry {
  final String id;
  final DateTime timestamp;
  final Mood mood;
  final JournalType type;
  final Map<String, int> questionAnswers;
  double? sentimentScore;

  JournalEntry({
    required this.id,
    required this.timestamp,
    required this.mood,
    required this.type,
    required this.questionAnswers,
    this.sentimentScore,
  });

  /// Calculates the total weight of the entry by summing the answer values (0-4).
  /// A higher score indicates a more significant or negative entry, which is used
  /// for prioritizing which entries to show to the AI.
  int get totalWeight {
    if (questionAnswers.isEmpty) return 0;
    // .values returns all the integer answers (0, 1, 2, 3, 4)
    // .reduce sums them all up into a single value.
    return questionAnswers.values.reduce((sum, element) => sum + element);
  }

  /// A helper method to create a readable summary of the entry for display in lists.
  String get summary {
    if (questionAnswers.isEmpty) return "No details provided.";
    
    final firstQuestion = questionAnswers.keys.first;
    final firstAnswerIndex = questionAnswers.values.first;
    // Ensure the index is valid before accessing the answerOptions list to prevent errors.
    final firstAnswerText = (firstAnswerIndex < answerOptions.length) 
        ? answerOptions[firstAnswerIndex] 
        : "N/A";

    return '"$firstQuestion" - $firstAnswerText';
  }

  /// A method to create a new instance of JournalEntry with some updated values.
  /// This is a best practice for working with immutable objects.
  JournalEntry copyWith({
    String? id,
    DateTime? timestamp,
    Mood? mood,
    JournalType? type,
    Map<String, int>? questionAnswers,
    double? sentimentScore,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      mood: mood ?? this.mood,
      type: type ?? this.type,
      questionAnswers: questionAnswers ?? this.questionAnswers,
      sentimentScore: sentimentScore ?? this.sentimentScore,
    );
  }
}