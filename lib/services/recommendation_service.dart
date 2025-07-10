import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:serene_sense/config.dart'; // Your API key
import 'package:serene_sense/models/recommendation.dart';

class RecommendationService with ChangeNotifier {
  Recommendation? _recommendation;
  Recommendation? get recommendation => _recommendation;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  final String _ollamaHost = (!kIsWeb && Platform.isAndroid) ? '10.0.2.2' : 'localhost';
  final String _ollamaPort = '11434';
  final String _model = 'gemma:2b';

  Future<void> generateRecommendations({required Map<String, String> cbtSessionData}) async {
    if (cbtSessionData.isEmpty) { /* ... error handling ... */ return; }

    _setLoading(true);
    _errorMessage = '';
    _recommendation = null;

    try {
      final ollamaPrompt = _createOllamaPrompt(cbtSessionData);
      final ollamaResponse = await _callOllamaGenerate(ollamaPrompt);
      final parsedJson = jsonDecode(ollamaResponse);
      final String analysisSummary = parsedJson['analysis_summary'];

      // Build items by parsing JSON, then fetching images.
      final List<RecommendedItem> songs = await _createItemsFromJson(parsedJson['songs'] ?? []);
      final List<RecommendedItem> exercises = await _createItemsFromJson(parsedJson['exercises'] ?? []);
      final List<RecommendedItem> tasks = await _createItemsFromJson(parsedJson['tasks'] ?? []);

      _recommendation = Recommendation(
        analysisSummary: analysisSummary,
        songs: songs,
        exercises: exercises,
        tasks: tasks,
      );

    } catch (e) {
      print("Error generating recommendations: $e");
      _errorMessage = "Sorry, I couldn't generate recommendations at this time.";
    } finally {
      _setLoading(false);
    }
  }

  // Helper to process a list of items from the JSON response
  Future<List<RecommendedItem>> _createItemsFromJson(List<dynamic> itemsJson) async {
    List<Future<RecommendedItem>> futureItems = [];
    for (var itemJson in itemsJson) {
      // Parse the item from JSON and then fetch its image
      futureItems.add(_buildCompleteRecommendedItem(itemJson));
    }
    return await Future.wait(futureItems); // Wait for all items to be fully built
  }

  // Builds a single, complete RecommendedItem instance.
  Future<RecommendedItem> _buildCompleteRecommendedItem(Map<String, dynamic> itemData) async {
    // 1. Parse the initial data from Ollama's JSON
    final item = RecommendedItem.fromJson(itemData);

    // 2. Use the image_search_query to fetch a real image URL
    final imageUrl = await _fetchUnsplashImage(item.imageSearchQuery);
    item.imageUrl = imageUrl; // 3. Populate the imageUrl field

    return item;
  }

  // THE NEW, UPDATED PROMPT FOR OLLAMA
  String _createOllamaPrompt(Map<String, String> data) {
    final context = data.entries.map((e) => "${e.key.split('.').last}: ${e.value}").join('\n');

    return """
    [INST] You are a compassionate mental health assistant. A user has completed a CBT reflection. Your task is to analyze it and provide personalized recommendations.

    **User's Reflection:**
    $context

    **Your Instructions:**
    1.  **Analyze:** Briefly analyze the user's primary emotion and its intensity.
    2.  **Generate Recommendations:** Create THREE items for EACH category: `songs`, `exercises`, and `tasks`.
    3.  **Format:** Your entire response MUST be a single, valid JSON object. Do not include any text outside the JSON block.
    4.  **Content Rules:**
        *   For each item, provide a `title`, `description`, and `image_search_query`.
        *   For `songs`, provide a `content_url` (e.g., a Spotify or YouTube Music link) and leave `youtube_video_id` empty.
        *   For `exercises`, provide a `youtube_video_id` (just the ID, not the full URL) and leave `content_url` empty.
        *   For `tasks`, leave both `content_url` and `youtube_video_id` empty.

    **Example JSON Structure:**
    ```json
    {
      "analysis_summary": "It sounds like you're grappling with feelings of anxiety. These suggestions are designed to help you find a moment of calm and regain a sense of control.",
      "songs": [
        {
          "title": "Clair de Lune by Claude Debussy",
          "description": "A classic, soothing piano piece that can help calm a busy mind.",
          "image_search_query": "moonlit piano",
          "content_url": "https://open.spotify.com/track/4u7EnebtmKWzUH433cf5Qv",
          "youtube_video_id": ""
        }
      ],
      "exercises": [
        {
          "title": "5-4-3-2-1 Grounding Technique",
          "description": "Engage all your senses to ground yourself in the present moment when feeling anxious.",
          "image_search_query": "calm forest path",
          "content_url": "",
          "youtube_video_id": "30VMIEmA114"
        }
      ],
      "tasks": [
        {
          "title": "Write Down Three Things You're Grateful For",
          "description": "Shifting focus to gratitude can counteract negative thought patterns.",
          "image_search_query": "journal with pen",
          "content_url": "",
          "youtube_video_id": ""
        }
      ]
    }
    ```
    [/INST]
    """;
  }

  Future<String> _callOllamaGenerate(String prompt) async {
    final response = await http.post(
      Uri.parse('http://$_ollamaHost:$_ollamaPort/api/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'model': _model, 'prompt': prompt, 'stream': false}),
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      // Clean up the response which might be wrapped in ```json ... ```
      String responseText = (responseData['response'] as String).trim();
      if (responseText.startsWith("```json")) {
          responseText = responseText.substring(7, responseText.length - 3).trim();
      }
      return responseText;
    } else {
      throw Exception('Failed to get response from Ollama: ${response.body}');
    }
  }

  Future<String> _fetchUnsplashImage(String query) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.unsplash.com/photos/random?query=$query&orientation=landscape'),
        headers: {'Authorization': 'Client-ID $unsplashApiKey'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['urls']['regular'];
      }
    } catch (e) {
      print("Unsplash API error: $e");
    }
    // Return a default placeholder image on failure
    return 'https://images.unsplash.com/photo-1508669232494-e384593f6378';
  }

  void _setLoading(bool state) {
    _isLoading = state;
    notifyListeners();
  }

  // Add this method if you keep the task completion feature
  void toggleTaskCompletion(RecommendedItem item) {
    item.isCompleted = !item.isCompleted;
    notifyListeners();
  }
}