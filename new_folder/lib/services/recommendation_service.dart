// lib/services/recommendation_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:serene_sense/config.dart';
import 'package:serene_sense/models/recommendation.dart';

/// A provider responsible for generating a set of personalized, multi-sensory recommendations.
///
/// This service takes the complete data packet from a finished chat session,
/// sends it to the AI for a final deep analysis, and transforms the response

class RecommendationService with ChangeNotifier {
  List<RecommendedItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Public getters for the UI to listen to.
  List<RecommendedItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// The core method of this service. It generates and stores a list of recommendations.
  Future<void> generateRecommendations({
    required Map<String, String> sessionData,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _items = []; // Clear previous recommendations.
    notifyListeners();

    try {
      final prompt = _createDetailedAnalysisPrompt(sessionData);
      final responseJsonString = await _callGeminiApi(prompt);

      // Clean the response to ensure it's valid JSON, removing markdown wrappers.
      String cleanedJson = responseJsonString;
      if (cleanedJson.startsWith("```json")) {
        cleanedJson = cleanedJson.substring(7, cleanedJson.length - 3).trim();
      } else if (cleanedJson.startsWith("`")) {
        cleanedJson = cleanedJson.substring(1, cleanedJson.length - 1).trim();
      }

      final jsonResponse = jsonDecode(cleanedJson);
      final List<dynamic> recommendationsJson = jsonResponse['recommendations'] ?? [];
      
      _items = recommendationsJson
          .map((itemJson) => RecommendedItem.fromJson(itemJson as Map<String, dynamic>))
          .toList();

    } catch (e) {
      _errorMessage = "Failed to generate recommendations. Please try again. Error: $e";
      if (kDebugMode) {
        print(_errorMessage);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates the detailed prompt required to get the JSON structure that
  /// matches the RecommendedItem model.
  String _createDetailedAnalysisPrompt(Map<String, String> data) {
    return """
    You are a highly personalized mental wellness coach. A user has provided comprehensive data from a guided reflection, including a preliminary analysis of their emotional state. Your task is to provide a variety of actionable, multi-sensory recommendations tailored to their specific state, age, gender, and life context.

    **User's Comprehensive Data:**
    - **User's Name:** ${data['userName'] ?? 'User'}
    - **Personal Details:** Age: ${data['userAge']}, Gender: ${data['userGender']}, Marital Status: ${data['userMaritalStatus']}, Education: ${data['userEducation']}
    - **Preliminary AI Analysis:** "${data['analysis_summary']}"
    - **DASS-21 Result:** "${data['dass21_result']}"
    - **Journal Entry Summary:** "${data['journal_entry']}"
    - **CBT - Activating Event (A):** "${data['A']}"
    - **CBT - Beliefs (B):** "${data['B']}"
    - **CBT - Consequences (C):** "${data['C']}"

    **Your Task:**
    Use the 'Preliminary AI Analysis' as your primary guide. Generate a JSON object containing a list of 4-6 recommendations that directly address the identified emotion and severity.

    **Instructions for Recommendations:**
    1.  **Deep Personalization:** Recommendations MUST be highly appropriate for the user's specific emotional state (from the preliminary analysis) AND their personal context (age, gender, life stage implied by education/marital status). For example, a suggestion for a 20-year-old student experiencing 'Severe Anxiety' will be different from one for a 45-year-old married professional with 'Mild Stress'.
    2.  **Variety:** Provide a mix of types: 'song', 'exercise', 'guidedImagery', and 'task'.
    3.  **Detail:** For 'exercise', 'guidedImagery', and 'task', provide a 'steps' array with clear, step-by-step instructions. For 'song', the steps array should be empty.
    4.  **Links:** Provide a 'content_url' for songs and a 'youtube_video_id' for video-based exercises or imagery.

    **Output Format:**
    Respond ONLY with a single, valid JSON object with a root key "recommendations".

    **Example JSON Structure:**
    {
      "recommendations": [
        {
          "type": "song",
          "title": "Weightless by Marconi Union",
          "description": "This track is designed to reduce anxiety. Its calming rhythm can help ease the feeling of being overwhelmed you described.",
          "steps": [],
          "content_url": "https://open.spotify.com/track/6kGzBvjE1vUNee2sV12y0a",
          "youtube_video_id": null
        },
        {
          "type": "guidedImagery",
          "title": "Your Safe Place Visualization",
          "description": "A 10-minute guided exercise to build a mental sanctuary you can return to when you feel anxious.",
          "steps": [
            "Find a quiet, comfortable position.",
            "Close your eyes and take three deep, slow breaths.",
            "Imagine a place where you feel completely safe and at peace.",
            "Engage all your senses: What do you see, hear, smell, and feel?",
            "Spend a few minutes absorbing the feeling of calm.",
            "When ready, slowly bring your awareness back and open your eyes."
          ],
          "content_url": null,
          "youtube_video_id": "8C-w_j1d5cM"
        }
      ]
    }
    """;
  }
  
  /// Calls the Gemini API.
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