enum ChatAuthor { assistant, user }

class ChatMessage {
  ChatMessage({
    required this.author,
    required this.text,
    this.suggestions = const [],
    DateTime? sentAt,
  }) : sentAt = sentAt ?? DateTime.now();

  final ChatAuthor author;
  final String text;
  final List<String> suggestions;
  final DateTime sentAt;
}
