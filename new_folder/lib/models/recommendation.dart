// lib/models/recommendation.dart

import 'package:flutter/material.dart';

/// An enum to define the specific type of a recommended item.
/// This is crucial for the UI to decide which icon to show and what action to take.
enum ItemType { song, exercise, guidedImagery, task }

/// Represents a single, actionable, and multi-sensory item suggested to the user
/// after a deep session analysis.
class RecommendedItem {
  /// A unique identifier for the item, typically derived from its title.
  final String id;

  /// The title of the recommendation (e.g., "5-Minute Breathing Exercise").
  final String title;
  
  /// A detailed description explaining why this item is helpful for the user's specific situation.
  final String description;
  
  /// The category of the recommendation.
  final ItemType type;
  
  /// A list of step-by-step instructions for tasks, exercises, and guided imagery.
  /// This will be an empty list for songs.
  final List<String> steps;
  
  /// A URL for songs (e.g., Spotify, Apple Music) or related articles. Nullable.
  final String? contentUrl;
  
  /// A specific YouTube video ID for exercises or guided imagery meditations. Nullable.
  final String? youtubeVideoId;

  RecommendedItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.steps = const [],
    this.contentUrl,
    this.youtubeVideoId,
  });

  /// A helper getter that concatenates all readable text into a single string.
  /// This is used by the Text-to-Speech service to read the entire card's content.
  String get speakableText {
    final stepsText = steps.isEmpty ? '' : 'Steps. ${steps.join('. ')}';
    return '$title. $description. $stepsText';
  }

  /// A factory constructor to safely parse a recommendation from the AI's JSON response.
  factory RecommendedItem.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse the ItemType from a string.
    ItemType _parseType(String? typeString) {
      switch (typeString?.toLowerCase()) {
        case 'song':
          return ItemType.song;
        case 'exercise':
          return ItemType.exercise;
        case 'guidedimagery': // Matches the AI prompt
          return ItemType.guidedImagery;
        case 'task':
          return ItemType.task;
        default:
          return ItemType.task; // A safe default
      }
    }

    return RecommendedItem(
      // Use the title as a pseudo-ID. It's unique enough for UI state management.
      id: json['title'] ?? UniqueKey().toString(),
      title: json['title'] ?? 'Untitled Recommendation',
      description: json['description'] ?? 'No description available.',
      type: _parseType(json['type']),
      // Safely parse the list of steps, defaulting to an empty list.
      steps: List<String>.from(json['steps'] ?? []),
      contentUrl: json['content_url'], // Directly assign as it's nullable
      youtubeVideoId: json['youtube_video_id'], // Directly assign as it's nullable
    );
  }
}