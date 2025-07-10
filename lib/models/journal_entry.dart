import 'package:flutter/material.dart';

// An enum for predefined moods, making it easy to manage and display
enum Mood {
  happy,
  calm,
  neutral,
  anxious,
  sad,
  angry;

  // Helper to get a display-friendly name
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

  // Helper to get a corresponding emoji
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

  // Helper for color coding in the UI
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

class JournalEntry {
  final String id;
  final String content;
  final DateTime timestamp;
  final Mood mood;
  final double? sentimentScore; // Nullable: analysis might not have run yet

  JournalEntry({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.mood,
    this.sentimentScore,
  });

  // copyWith is a best practice for immutability.
  JournalEntry copyWith({
    String? id,
    String? content,
    DateTime? timestamp,
    Mood? mood,
    double? sentimentScore,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      mood: mood ?? this.mood,
      sentimentScore: sentimentScore ?? this.sentimentScore,
    );
  }
}