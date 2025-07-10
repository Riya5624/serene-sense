enum MessageType {
  standard,
  whoTestLink,
  journalLink,
  recommendationLink,
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;
  final bool isSystemMessage; // NEW: Added this flag

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.type = MessageType.standard,
    this.isSystemMessage = false, // Default to false
  });
}