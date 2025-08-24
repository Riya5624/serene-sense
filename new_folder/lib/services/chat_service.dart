// lib/services/chat_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:serene_sense/config.dart';
import 'package:serene_sense/data/journal_questions.dart';
import 'package:serene_sense/models/chat_message.dart';
import 'package:serene_sense/models/journal_entry.dart';
import 'package:serene_sense/providers/user_data_provider.dart';
import 'package:serene_sense/services/journal_service.dart';
import 'package:serene_sense/utils/quotes.dart';

/// The state machine to manage the entire user journey.
enum ConversationFlowStep {
  idle,
  promptingWhoTest,
  promptingJournal,
  collectingA,
  collectingB,
  collectingC,
  performingAnalysis,
  sessionComplete,
}

class ChatService with ChangeNotifier {
  // --- STATE MANAGEMENT ---
  // These dependencies can be updated by the ChangeNotifierProxyProvider2
  // This is the key to preventing the chat from restarting.
  UserDataProvider _userDataProvider;
  JournalService _journalService;

  ConversationFlowStep _currentStep = ConversationFlowStep.idle;
  final Map<String, String> _cbtSessionData = {};
  Map<String, String> _lastCompletedSessionData = {};
  bool _isLoading = false;

  // --- DATA POINTS FOR ANALYSIS ---
  String? _whoTestResult;
  JournalEntry? _lastJournalEntry;

  final List<ChatMessage> _messages = [];

  // --- GETTERS ---
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  Map<String, String> get lastCompletedSessionData => _lastCompletedSessionData;
  ConversationFlowStep get currentStep => _currentStep;

  /// Constructor requires both UserDataProvider and JournalService.
  ChatService(this._userDataProvider, this._journalService) {
    _initializeChat();
  }

  /// Allows the ChangeNotifierProxyProvider2 to update dependencies without
  /// creating a new ChatService instance, thus preserving state.
  void updateDependencies(UserDataProvider userData, JournalService journalService) {
    _userDataProvider = userData;
    _journalService = journalService;
  }

  void _initializeChat() {
    _addMessage("Hello! I'm Serene. Today's thought for you:", isUser: false);
    _addMessage('"${getDailyQuote()}"', isUser: false);
    _addMessage("When you're ready to begin, just say 'start'.", isUser: false);
  }

  // --- PUBLIC METHODS FOR OTHER SCREENS TO CALL ---

  void userCompletedWhoTest(String result) {
    _whoTestResult = result;
    _addMessage("(Self-assessment results noted.)", isUser: false, isSystemMessage: true);
    _currentStep = ConversationFlowStep.promptingJournal;
    _processNextStep();
  }

  void userCompletedJournaling({JournalEntry? entry}) {
    _lastJournalEntry = entry;
    _addMessage("(Journal entry saved and considered.)", isUser: false, isSystemMessage: true);
    _currentStep = ConversationFlowStep.collectingA;
    _processNextStep();
  }

  // --- CORE CONVERSATION LOGIC ---

  Future<void> sendMessage(String text) async {
    _addMessage(text, isUser: true);

    if (_currentStep == ConversationFlowStep.idle) {
      if (text.toLowerCase().trim() == 'start') {
        _startSession();
      } else {
        _addMessage("Ready when you are. Just say 'start'.", isUser: false);
      }
      return;
    }
    
    if ([ConversationFlowStep.collectingA, ConversationFlowStep.collectingB, ConversationFlowStep.collectingC].contains(_currentStep)) {
      _cbtSessionData[_currentStep.toString()] = text;
      _setLoading(true);

      if (_currentStep == ConversationFlowStep.collectingA) _currentStep = ConversationFlowStep.collectingB;
      else if (_currentStep == ConversationFlowStep.collectingB) _currentStep = ConversationFlowStep.collectingC;
      else if (_currentStep == ConversationFlowStep.collectingC) _currentStep = ConversationFlowStep.performingAnalysis;

      await _processNextStep();
      _setLoading(false);
    }
  }

  void _startSession() {
    _cbtSessionData.clear();
    _lastCompletedSessionData.clear();
    _whoTestResult = null;
    _lastJournalEntry = null;
    _messages.clear();
    _initializeChat();
    _currentStep = ConversationFlowStep.promptingWhoTest;
    _processNextStep();
  }

  Future<void> _processNextStep() async {
    switch (_currentStep) {
      case ConversationFlowStep.promptingWhoTest:
        _addMessage("First, a quick self-assessment can provide a helpful baseline. This DASS-21 scale measures symptoms of depression, anxiety and stress.", isUser: false);
        _addMessage("Take the DASS-21 Test", isUser: false, type: MessageType.whoTestLink);
        break;
      case ConversationFlowStep.promptingJournal:
        _addMessage("Thank you. Now, taking a moment to check-in with your thoughts can be very clarifying.", isUser: false);
        _addMessage("Start Your Check-in", isUser: false, type: MessageType.journalLink);
        break;
      case ConversationFlowStep.collectingA:
        _addMessage("Great. Now let's walk through the situation using the ABC method.", isUser: false);
        _addMessage("Describe the situation or activating event that's on your mind.\n(A - Activating Event)", isUser: false);
        break;
      case ConversationFlowStep.collectingB:
        _addMessage("Thank you. What beliefs or thoughts went through your mind about this event?\n(B - Beliefs)", isUser: false);
        break;
      case ConversationFlowStep.collectingC:
        _addMessage("I see. And what were the emotional consequences of these beliefs? How did you feel?\n(C - Consequences)", isUser: false);
        break;
      case ConversationFlowStep.performingAnalysis:
        _addMessage("Thank you for sharing. I'm now analyzing your reflections from the assessment, your journal, and our conversation to offer the most helpful perspective.", isUser: false);
        await _performFinalAnalysisAndRespond();
        break;
      default:
        break;
    }
  }
  
  /// Performs the two-stage AI analysis and generates the final conversational response.
  Future<void> _performFinalAnalysisAndRespond() async {
    final abcData = {
      'A': _cbtSessionData[ConversationFlowStep.collectingA.toString()] ?? 'Not provided',
      'B': _cbtSessionData[ConversationFlowStep.collectingB.toString()] ?? 'Not provided',
      'C': _cbtSessionData[ConversationFlowStep.collectingC.toString()] ?? 'Not provided',
    };
    
    // Fetch the top 5 most significant journal entries.
    final topJournalEntries = _journalService.getHighestWeightedEntries(count: 5);

    try {
      final analysisPrompt = _createAnalysisPrompt(abcData);
      final analysisResponseJson = await _callGeminiApi(analysisPrompt);

      String cleanedJson = analysisResponseJson.replaceAll("```json", "").replaceAll("```", "").trim();
      final analysisData = jsonDecode(cleanedJson);

      _addMessage(analysisData['summary'], isUser: false);
      await Future.delayed(const Duration(milliseconds: 1200)); 

      final dePrompt = _createDEPrompt(abcData, analysisData, topJournalEntries);
      final deResponse = await _callGeminiApi(dePrompt);
      _addMessage(deResponse, isUser: false); 

      // Prepare the final data packet for the RecommendationService
      _lastCompletedSessionData = {
        'userName': _userDataProvider.user?.name ?? 'User',
        'userAge': _userDataProvider.user?.age.toString() ?? 'Not provided',
        'userGender': _userDataProvider.user?.gender ?? 'Not provided',
        'userMaritalStatus': _userDataProvider.user?.maritalStatus ?? 'Not provided',
        'userEducation': _userDataProvider.user?.education ?? 'Not provided',
        'A': abcData['A']!,
        'B': abcData['B']!,
        'C': abcData['C']!,
        'dass21_result': _whoTestResult ?? 'Not provided',
        'journal_entry': _formatSingleJournalForPrompt(_lastJournalEntry),
        'analysis_summary': analysisData['summary'] ?? 'Analysis complete.',
      };
      notifyListeners();

      _addMessage("You have completed this reflection. This is a huge step.", isUser: false);
      _addMessage("View Personalized Recommendations", isUser: false, type: MessageType.recommendationLink);
      _currentStep = ConversationFlowStep.sessionComplete;

    } catch (e) {
      if (kDebugMode) { print("Error during final analysis: $e"); }
      _addMessage("I'm having a little trouble processing everything right now. Let's try that last part again later.", isUser: false);
      _currentStep = ConversationFlowStep.idle;
    }
  }

  // --- HELPER AND PROMPT ENGINEERING METHODS ---

  String _formatSingleJournalForPrompt(JournalEntry? entry) {
    if (entry == null) return "Not provided";
    final qaString = entry.questionAnswers.entries.map((e) {
      final answerText = (e.value < answerOptions.length) ? answerOptions[e.value] : "N/A";
      return '- Q: "${e.key}"\n  - A: "$answerText"';
    }).join('\n');
    return "Type: ${entry.type.name} Check-in\nOverall Mood: ${entry.mood.name}\nQuestions and Answers:\n$qaString";
  }

  String _formatTopJournalEntriesForPrompt(List<JournalEntry> entries) {
    if (entries.isEmpty) return "No recent journal entries to consider.";
    return entries.asMap().entries.map((entryMap) {
      int index = entryMap.key + 1;
      JournalEntry entry = entryMap.value;
      return "Entry $index (Weight: ${entry.totalWeight}, Mood: ${entry.mood.name}):\n${_formatSingleJournalForPrompt(entry)}";
    }).join('\n\n');
  }

  String _createAnalysisPrompt(Map<String, String> abcData) {
    final userName = _userDataProvider.user?.name ?? 'the user';
    final formattedJournal = _formatSingleJournalForPrompt(_lastJournalEntry);
    return """
    Analyze the user data to determine their primary emotional state. The user's name is $userName.
    **User Data:**
    1. DASS-21 Result: "${_whoTestResult ?? 'Not provided'}"
    2. Journal Entry: $formattedJournal
    3. CBT-ABC: A: ${abcData['A']}, B: ${abcData['B']}, C: ${abcData['C']}
    **Task:**
    Respond ONLY with a valid JSON object: { "primary_emotion": "...", "severity": "...", "summary": "A brief, gentle summary for the user. Address them by name, $userName." }
    """;
  }

  String _createDEPrompt(Map<String, String> abcData, Map<String, dynamic> analysisData, List<JournalEntry> topJournalEntries) {
    final user = _userDataProvider.user;
    final formattedTopJournals = _formatTopJournalEntriesForPrompt(topJournalEntries);
    return """
    You are a deeply empathetic CBT therapist named Serene. Your goal is to make the user feel seen, validated, and empowered by connecting their current situation to their recent history and personal context.

    **Full User Context:**
    - **User's Name:** ${user?.name ?? 'the user'}
    - **Personal Details:** Age: ${user?.age}, Gender: ${user?.gender}, Marital Status: ${user?.maritalStatus}, Education: ${user?.education}
    - **Your Initial Analysis:** The user is experiencing ${analysisData['severity']} ${analysisData['primary_emotion']}.
    - **Current Situation (CBT-ABC):**
        A (Event): ${abcData['A']}
        B (Belief): ${abcData['B']}
        C (Consequence): ${abcData['C']}
    - **Recent High-Impact Journal Entries (Top 5 Ranked by Significance):**
        $formattedTopJournals

    **Your Task:**
    Synthesize ALL the provided context. Create a therapeutic and healing response that contains the final (D) and (E) steps of the ABCDE model. Your response MUST be appropriate and sensitive to the user's personal details and feel deeply connected to both their current problem and their recent journaled history.

    **Instructions for Your Response:**
    1.  **Acknowledge & Validate:** Start with a warm, validating statement. If you see a pattern, gently point it out.
    2.  **Create Step D (Dispute):** Based on all context, formulate a gentle, insightful question that helps the user dispute their core belief (B).
    3.  **Create Step E (Effective Belief):** Guide them towards a new, more helpful belief.
    4.  **Format:** Combine into a single, natural-sounding message. Do NOT ask them to reply.
    """;
  }

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
          if (kDebugMode) { print("Gemini API Warning: No candidates returned. Check for safety blocks."); }
          return "I'm unable to respond to that specific topic right now. Could we try exploring it differently?";
        }
        return responseData['candidates'][0]['content']['parts'][0]['text'].trim();
      } else {
        if (kDebugMode) {
          print("Gemini API Error: Status Code ${response.statusCode}");
          print("Gemini API Error Body: ${response.body}");
        }
        throw Exception('Failed to get response from Gemini API.');
      }
    } catch (e) {
      if (kDebugMode) { print("Error calling Gemini API: $e"); }
      throw Exception('Could not connect to Gemini API. Please check your network connection and API key.');
    }
  }

  void _addMessage(String text, {required bool isUser, MessageType type = MessageType.standard, bool isSystemMessage = false}) {
    if (_isLoading && !isUser) {
      final lastMessage = _messages.last;
      if (!lastMessage.isUser && lastMessage.text == "...") _messages.removeLast();
    }
    _messages.add(ChatMessage(text: text, isUser: isUser, timestamp: DateTime.now(), type: type, isSystemMessage: isSystemMessage));
    notifyListeners();
  }

  void _setLoading(bool loadingState) {
    if (_isLoading == loadingState) return;
    _isLoading = loadingState;
    if (_isLoading) _addMessage("...", isUser: false);
    notifyListeners();
  }
}