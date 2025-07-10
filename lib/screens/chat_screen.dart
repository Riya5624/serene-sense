import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  @override
  void initState() {
    super.initState();
    // Listen to the ChatService to scroll down when new messages are added
    final chatService = context.read<ChatService>();
    chatService.addListener(_scrollToBottom);
  }

  @override
  void dispose() {
    // Clean up controllers and listeners
    _controller.dispose();
    _scrollController.dispose();
    context.read<ChatService>().removeListener(_scrollToBottom);
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      context.read<ChatService>().sendMessage(_controller.text.trim());
      _controller.clear();
    }
  }

  // Scroll to the bottom of the list
  void _scrollToBottom() {
    // A small delay ensures the list has been updated before we scroll
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
    return Scaffold(
      // NO AppBar here - it's handled by MainNavScreen
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            // Use a Consumer to rebuild the list when messages change
            child: Consumer<ChatService>(
              builder: (context, chatService, child) {
                // Show a welcome message if the chat is empty
                if (chatService.messages.isEmpty) {
                  return _buildEmptyState();
                }
                // Build the list of messages
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  itemCount: chatService.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatService.messages[index];
                    // UPDATED: Pass the full message object
                    return ChatBubble(message: message)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.5, end: 0, curve: Curves.easeOutCubic);
                  },
                );
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  // The widget for the text input field
  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 5.0,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Type your thoughts here...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send_rounded),
              color: Theme.of(context).primaryColor,
              iconSize: 28,
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  // The widget for the empty chat screen
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Serene Sense',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Your compassionate AI companion is here to listen. Feel free to share what\'s on your mind.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms);
  }
}
