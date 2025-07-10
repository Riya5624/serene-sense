import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:serene_sense/models/chat_message.dart';
import 'package:serene_sense/screens/dass_21_screen.dart';
import 'package:serene_sense/screens/journal_entry_screen.dart';
import 'package:serene_sense/screens/recommendations_screen.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    // The main build method acts as a router to the correct bubble type.
    if (message.isSystemMessage) {
      return _buildSystemMessageBubble(context, message.text);
    }

    switch (message.type) {
      case MessageType.whoTestLink:
        return _buildNavigationButton(
          context: context,
          text: message.text,
          icon: Icons.assignment_turned_in_outlined,
          onPressed: () {
            // Navigate to the DASS-21 test screen.
            // This screen is responsible for calling `userCompletedWhoTest`
            // on the ChatService when it's done.
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const Dass21Screen()),
            );
          },
        );
      case MessageType.journalLink:
        return _buildNavigationButton(
          context: context,
          text: message.text,
          icon: Icons.edit_note_rounded,
          onPressed: () {
            // Navigate to the Journal creation screen.
            // This screen is responsible for calling `userCompletedJournaling`
            // on the ChatService when an entry is saved.
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const JournalEntryScreen()),
            );
          },
        );
      case MessageType.recommendationLink:
        return _buildNavigationButton(
          context: context,
          text: message.text,
          icon: Icons.lightbulb_outline_rounded,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const RecommendationsScreen()),
          ),
        );
      case MessageType.standard:
      default:
        return _buildStandardBubble(context);
    }
  }

  /// A reusable, styled button for navigating to other parts of the app from the chat.
  Widget _buildNavigationButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 60),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(text, style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: const StadiumBorder(),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.5, curve: Curves.easeOut);
  }

  /// A subtle, centered bubble for informational system messages.
  Widget _buildSystemMessageBubble(BuildContext context, String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
          fontStyle: FontStyle.italic,
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  /// The primary bubble for user and standard bot text messages.
  Widget _buildStandardBubble(BuildContext context) {
    final bool isUser = message.isUser;
    final bool isThinking = !isUser && message.text == "...";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: isThinking
            ? _buildThinkingIndicator()
            : Text(
                message.text,
                style: GoogleFonts.lato(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                  height: 1.4, // Improved line spacing for readability
                ),
              ),
      ),
    );
  }

  /// A special animated "..." widget to show when the bot is processing.
  Widget _buildThinkingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(0.ms),
        _buildDot(200.ms),
        _buildDot(400.ms),
      ],
    );
  }

  Widget _buildDot(Duration delay) {
    return Text(
      '.',
      style: TextStyle(fontSize: 24, color: Colors.grey.shade500),
    )
    .animate(onPlay: (controller) => controller.repeat(reverse: true))
    .moveY(begin: 0, end: -4, duration: 600.ms, delay: delay, curve: Curves.easeInOut)
    .then()
    .moveY(begin: -4, end: 0, duration: 600.ms, curve: Curves.easeInOut);
  }
}