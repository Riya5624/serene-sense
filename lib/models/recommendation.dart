// The type of recommendation helps the UI decide what icon to show.
enum ItemType { song, exercise, task }

class RecommendedItem {
  final String title;
  final String description;
  final String imageSearchQuery;
  final String contentUrl; // URL for songs (Spotify, etc.) or articles
  final String youtubeVideoId; // YouTube video ID for exercises/meditations
  bool isCompleted;
  String imageUrl; // This will be populated after fetching from Unsplash

  RecommendedItem({
    required this.title,
    required this.description,
    required this.imageSearchQuery,
    this.contentUrl = '',
    this.youtubeVideoId = '',
    this.isCompleted = false,
    this.imageUrl = '', // Start with an empty image URL
  });

  // Factory constructor to parse the initial data from Ollama's JSON
  factory RecommendedItem.fromJson(Map<String, dynamic> json) {
    return RecommendedItem(
      title: json['title'] ?? 'Untitled',
      description: json['description'] ?? 'No description available.',
      imageSearchQuery: json['image_search_query'] ?? 'calm nature',
      contentUrl: json['content_url'] ?? '',
      youtubeVideoId: json['youtube_video_id'] ?? '',
    );
  }
}

// This class holds the entire set of recommendations for a session.
class Recommendation {
  final String analysisSummary;
  final List<RecommendedItem> songs;
  final List<RecommendedItem> exercises;
  final List<RecommendedItem> tasks;

  Recommendation({
    required this.analysisSummary,
    required this.songs,
    required this.exercises,
    required this.tasks,
  });
}