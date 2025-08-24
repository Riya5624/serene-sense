// lib/models/chat_message.dart

/// An enum to define the specific type of a chat message.
/// This determines how the message is rendered in the UI (e.g., as a standard text bubble or a button).
enum MessageType {
  /// A standard text message from either the user or the bot.
  standard,

  /// A special message that renders as a button to navigate to the Recommendations screen.
  recommendationLink,

  /// A special message that renders as a button to navigate to the DASS-21 test screen.
  whoTestLink,

  /// A special message that renders as a button to navigate to the Journal Entry screen.
  journalLink
}

/// Represents a single message within the chat conversation.
///
/// This class is immutable, meaning its properties cannot be changed after creation,
/// which is ideal for state management.
class ChatMessage {
  /// The textual content of the message.
  final String text;

  /// A boolean indicating if the message was sent by the user (`true`) or the bot (`false`).
  final bool isUser;

  /// The exact time the message was created.
  final DateTime timestamp;

  /// The [MessageType] which dictates how the UI should render this message.
  /// Defaults to [MessageType.standard].
  final MessageType type;

  /// A flag for special, non-conversational messages from the system,
  /// such as "(Journal entry saved.)". These are styled differently.
  final bool isSystemMessage;

  /// Creates an instance of a chat message.
  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.type = MessageType.standard,
    this.isSystemMessage = false, // Defaults to false for standard conversation flow.
  });
}