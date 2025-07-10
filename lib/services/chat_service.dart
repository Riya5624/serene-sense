import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:serene_sense/models/chat_message.dart';
import 'package:serene_sense/utils/quotes.dart'; // For the daily quote

/// The new, comprehensive state machine to manage the entire user journey.
enum ConversationFlowStep {
  idle,                 // Waiting for user to say 'start'
  promptingWhoTest,     // Bot has asked user to take the test and is waiting
  promptingJournal,     // Bot has asked user to write in journal and is waiting
  collectingA,          // Collecting Activating Event
  collectingB,          // Collecting Beliefs
  collectingC,          // Collecting Consequences
  performingAnalysis,   // AI is "thinking" after collecting all data
  sessionComplete,      // All steps done, recommendations offered
}

class ChatService with ChangeNotifier {
  // --- STATE MANAGEMENT ---
  ConversationFlowStep _currentStep = ConversationFlowStep.idle;
  final Map<String, String> _cbtSessionData = {};
  Map<String, String> _lastCompletedSessionData = {};
  bool _isLoading = false;

  // --- NEW DATA POINTS FOR ANALYSIS ---
  String? _whoTestResult; // Will hold the DASS-21 summary string
  String? _lastJournalEntry; // The full text of the last journal entry

  final List<ChatMessage> _messages = [];

  // --- GETTERS ---
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  Map<String, String> get lastCompletedSessionData => _lastCompletedSessionData;

  // --- OLLAMA CONFIG ---
  final String _ollamaHost = (!kIsWeb && Platform.isAndroid) ? '10.0.2.2' : 'localhost';
  final String _ollamaPort = '11434';
  final String _model = 'gemma:2b';

  ChatService() {
    _initializeChat();
  }

  /// Adds the initial greeting messages to the chat.
  void _initializeChat() {
    _addMessage("Hello! I'm Serene. Today's thought for you:", isUser: false);
    _addMessage('"${getDailyQuote()}"', isUser: false);
    _addMessage("When you're ready to begin, just say 'start'.", isUser: false);
  }

  // --- PUBLIC METHODS FOR OTHER SCREENS TO CALL ---

  /// CRITICAL: Call this from your DASS-21 screen when the user finishes.
  /// This method resumes the conversation.
  void userCompletedWhoTest(String result) {
    _whoTestResult = result;
    _addMessage("(DASS-21 self-assessment results have been noted.)", isUser: false, isSystemMessage: true);
    _currentStep = ConversationFlowStep.promptingJournal; // Set the next step
    _processNextStep();
  }

  /// CRITICAL: Call this from your Journal screen when the user saves an entry.
  /// This method resumes the conversation.
  void userCompletedJournaling(String journalText) {
    _lastJournalEntry = journalText;
    _addMessage("(Your journal entry has been saved and considered.)", isUser: false, isSystemMessage: true);
    _currentStep = ConversationFlowStep.collectingA; // Set the next step
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

    // If we are in the ABC collection phase, store the data and advance.
    if (_currentStep == ConversationFlowStep.collectingA ||
        _currentStep == ConversationFlowStep.collectingB ||
        _currentStep == ConversationFlowStep.collectingC) {
      _cbtSessionData[_currentStep.toString()] = text;
      _setLoading(true);
      
      // Manually advance to the next ABC step
      if (_currentStep == ConversationFlowStep.collectingA) _currentStep = ConversationFlowStep.collectingB;
      else if (_currentStep == ConversationFlowStep.collectingB) _currentStep = ConversationFlowStep.collectingC;
      else if (_currentStep == ConversationFlowStep.collectingC) _currentStep = ConversationFlowStep.performingAnalysis;

      await _processNextStep();
      _setLoading(false);
    }
  }

  void _startSession() {
    // Reset all session data
    _cbtSessionData.clear();
    _lastCompletedSessionData.clear();
    _whoTestResult = null;
    _lastJournalEntry = null;
    _messages.clear(); // Clear chat history for a new session
    _initializeChat(); // Re-add the greeting

    // Start the new flow
    _currentStep = ConversationFlowStep.promptingWhoTest;
    _processNextStep();
  }

  /// The "brain" of the conversation, directing the flow based on the current step.
  Future<void> _processNextStep() async {
    switch (_currentStep) {
      case ConversationFlowStep.promptingWhoTest:
        _addMessage("First, a quick self-assessment can provide a helpful baseline. This DASS-21 scale measures symptoms of depression, anxiety and stress.", isUser: false);
        _addMessage("Take the DASS-21 Test", isUser: false, type: MessageType.whoTestLink);
        // The flow now PAUSES, waiting for userCompletedWhoTest() to be called.
        break;

      case ConversationFlowStep.promptingJournal:
        _addMessage("Thank you. Now, taking a moment to write down your thoughts can be very clarifying.", isUser: false);
        _addMessage("Create a Journal Entry", isUser: false, type: MessageType.journalLink);
        // The flow now PAUSES, waiting for userCompletedJournaling() to be called.
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
        await Future.delayed(const Duration(seconds: 2)); // Simulate deep thought
        await _provideDEandRecommendations();
        break;

      default:
        // Handles idle, sessionComplete, and other states where no action is needed.
        break;
    }
  }

  /// Generates the final D & E steps and offers recommendations.
  Future<void> _provideDEandRecommendations() async {
    // Consolidate data for the prompt
    final abcData = {
      'A': _cbtSessionData[ConversationFlowStep.collectingA.toString()] ?? 'Not provided',
      'B': _cbtSessionData[ConversationFlowStep.collectingB.toString()] ?? 'Not provided',
      'C': _cbtSessionData[ConversationFlowStep.collectingC.toString()] ?? 'Not provided',
    };

    final prompt = """
      [INST] You are a highly empathetic and expert CBT guide named Serene. A user has provided comprehensive data about their mental state. Your task is to analyze all of it and provide the final D (Dispute) and E (Effective Belief) steps of the ABCDE model.

      **User's Comprehensive Data:**
      1.  **DASS-21 Self-Assessment Result:** "${_whoTestResult ?? 'Not provided'}"
      2.  **Journal Entry:** "${_lastJournalEntry ?? 'Not provided'}"
      3.  **CBT Reflection (ABC):**
          A (Event): ${abcData['A']}
          B (Belief): ${abcData['B']}
          C (Consequence): ${abcData['C']}

      **Your Instructions:**
      1.  **Synthesize:** In your "mind," synthesize all three data points to get a deep understanding of the user's core issue (e.g., anxiety from social evaluation, sadness from perceived failure).
      2.  **Generate Step D:** Create a gentle, compassionate, and insightful "Dispute" question (D) that directly challenges the user's core negative belief (B), taking the journal and DASS-21 context into account.
      3.  **Generate Step E:** Create a guiding prompt for the "Effective Belief" (E) that helps the user formulate a new, balanced perspective.
      4.  **Format:** Respond with a single, coherent message. Start with Step D, then on a new line, Step E. Frame it as a final, reflective exercise for the user to read. Do NOT ask them to reply.

      **Example Response:**
      "Thank you for your openness. Based on everything you've shared, let's reframe that perspective.

      (D) Dispute: Considering what you wrote in your journal about previous successes, what evidence suggests that the belief '${abcData['B']}' might not be 100% true in every situation?

      (E) A More Effective Belief: What could be a more compassionate and balanced thought to hold instead? Perhaps something like, 'This one event was difficult, but it doesn't define my overall capability.'"
      [/INST]
    """;

    final aiResponse = await _callOllamaGenerate(prompt);
    _addMessage(aiResponse, isUser: false);

    // Finalize the session data for the recommendation service
    _lastCompletedSessionData = {
      ...abcData,
      'dass21_result': _whoTestResult ?? 'Not provided',
      'journal_entry': _lastJournalEntry ?? 'Not provided',
    };
    notifyListeners();

    // Offer recommendations
    _addMessage("You have completed this reflection. This is a huge step.", isUser: false);
    _addMessage("View Personalized Recommendations", isUser: false, type: MessageType.recommendationLink);
    _currentStep = ConversationFlowStep.sessionComplete;
  }

  // --- OLLAMA CALLER & UTILITY METHODS ---

  Future<String> _callOllamaGenerate(String prompt) async {
    try {
      final requestBody = jsonEncode({'model': _model, 'prompt': prompt, 'stream': false});
      final response = await http.post(
        Uri.parse('http://$_ollamaHost:$_ollamaPort/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return (responseData['response'] as String).trim();
      } else {
        return "An error occurred while processing my thoughts. Please check the connection.";
      }
    } catch (e) {
      print("Ollama call error: $e");
      return "I'm having trouble connecting to my thoughts right now. Please ensure the local server is running.";
    }
  }

  void _addMessage(String text, {
    required bool isUser,
    MessageType type = MessageType.standard,
    bool isSystemMessage = false,
  }) {
    if (_isLoading && !isUser) {
      final lastMessage = _messages.last;
      if (!lastMessage.isUser && lastMessage.text == "...") {
        _messages.removeLast();
      }
    }
    _messages.add(ChatMessage(
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
      type: type,
      isSystemMessage: isSystemMessage,
    ));
    notifyListeners();
  }

  void _setLoading(bool loadingState) {
    if (_isLoading == loadingState) return;
    _isLoading = loadingState;
    if (_isLoading) {
      _addMessage("...", isUser: false);
    }
    notifyListeners();
  }
}