// lib/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serene_sense/services/chat_service.dart';
import 'package:serene_sense/widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // --- THIS IS THE FIX (Part 1) ---
  // Create a local, late final variable to hold the ChatService instance.
  late final ChatService _chatService;
  // --- END OF FIX ---

  // Defines the steps during which the user should not be able to type.
  static const Set<ConversationFlowStep> _disabledInputStates = {
    ConversationFlowStep.promptingWhoTest,
    ConversationFlowStep.promptingJournal,
    ConversationFlowStep.performingAnalysis,
    ConversationFlowStep.sessionComplete,
  };

  @override
  void initState() {
    super.initState();
    // --- THIS IS THE FIX (Part 2) ---
    // Get the service instance once in initState where context is safe to use
    // and store it in our local variable.
    _chatService = context.read<ChatService>();
    // Add the listener using the stored variable.
    _chatService.addListener(_scrollToBottom);
    // --- END OF FIX ---
  }

  @override
  void dispose() {
    // --- THIS IS THE FIX (Part 3) ---
    // Use the stored _chatService variable to remove the listener.
    // This is the safe way to interact with a provider in dispose().
    _chatService.removeListener(_scrollToBottom);
    // --- END OF FIX ---
    
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Sends the user's message to the ChatService.
  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      // It's okay to use context.read() here as it's a user-triggered event
      // during the widget's active lifecycle.
      context.read<ChatService>().sendMessage(_controller.text.trim());
      _controller.clear();
      FocusScope.of(context).unfocus(); // Hide the keyboard
    }
  }

  /// Smoothly scrolls the chat list to the bottom when a new message is added.
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Consumer widget rebuilds the UI whenever the ChatService notifies listeners.
    return Consumer<ChatService>(
      builder: (context, chatService, child) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: Column(
            children: [
              Expanded(
                child: chatService.messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        itemCount: chatService.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatService.messages[index];
                          // The ChatBubble widget intelligently renders the correct UI
                          // based on the message type.
                          return ChatBubble(message: message)
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: 0.5, end: 0, curve: Curves.easeOutCubic);
                        },
                      ),
              ),
              _buildMessageComposer(chatService),
            ],
          ),
        );
      },
    );
  }

  /// Builds the text input area at the bottom of the screen.
  Widget _buildMessageComposer(ChatService chatService) {
    final bool isInputDisabled = chatService.isLoading || _disabledInputStates.contains(chatService.currentStep);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [BoxShadow(offset: const Offset(0, -2), blurRadius: 5.0, color: Colors.black.withOpacity(0.05))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                decoration: BoxDecoration(
                  color: isInputDisabled ? Colors.grey.shade200 : Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(color: Colors.grey.shade300)
                ),
                child: TextField(
                  controller: _controller,
                  enabled: !isInputDisabled,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: isInputDisabled ? 'Complete the step above...' : 'Type your thoughts here...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: isInputDisabled ? null : (value) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send_rounded),
              color: isInputDisabled ? Colors.grey : Theme.of(context).primaryColor,
              iconSize: 28,
              onPressed: isInputDisabled ? null : _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the placeholder UI shown when the chat is empty.
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 20),
            Text(
              'Welcome to Serene Sense',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              'Your compassionate AI companion is here to listen. Say "start" to begin a guided reflection.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms, duration: 500.ms));
  }
}