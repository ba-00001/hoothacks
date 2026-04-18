import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat_message.dart';
import '../models/user_profile.dart';
import '../services/ai_service.dart';
import '../services/app_session.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppSession>().user;
    final welcome = context.read<AiService>().buildWelcomeReply(user: user);
    _messages.add(
      ChatMessage(
        author: ChatAuthor.assistant,
        text: welcome.message,
        suggestions: welcome.suggestions,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? seededPrompt]) async {
    if (_isSending) {
      return;
    }

    final prompt = (seededPrompt ?? _controller.text).trim();
    if (prompt.isEmpty) {
      return;
    }

    setState(() {
      _messages.add(ChatMessage(author: ChatAuthor.user, text: prompt));
      _isSending = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final user = context.read<AppSession>().user;
      final reply = await context.read<AiService>().getChatReply(
        prompt: prompt,
        user: user,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _messages.add(
          ChatMessage(
            author: ChatAuthor.assistant,
            text: reply.message,
            suggestions: reply.suggestions,
          ),
        );
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _messages.add(
          ChatMessage(
            author: ChatAuthor.assistant,
            text:
                'I hit a problem while checking that request: ${error.toString().replaceFirst('Exception: ', '')}',
            suggestions: const [
              'Show my budget summary',
              'Find home recommendations',
            ],
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserProfile? user = context.watch<AppSession>().user;
    final lastAssistantMessage = _messages.lastWhere(
      (message) => message.author == ChatAuthor.assistant,
      orElse: () => _messages.first,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth > 960
            ? 960.0
            : constraints.maxWidth;

        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF4EFE7), Color(0xFFE8F2EF)],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: _ChatHero(user: user),
                  ),
                  Expanded(
                    child: Scrollbar(
                      controller: _scrollController,
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        itemCount: _messages.length + (_isSending ? 1 : 0),
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index >= _messages.length) {
                            return const _TypingBubble();
                          }
                          final message = _messages[index];
                          return _ChatBubble(message: message);
                        },
                      ),
                    ),
                  ),
                  if (lastAssistantMessage.suggestions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: lastAssistantMessage.suggestions
                              .map(
                                (suggestion) => ActionChip(
                                  label: Text(suggestion),
                                  onPressed: _isSending
                                      ? null
                                      : () => _sendMessage(suggestion),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: _Composer(
                      controller: _controller,
                      isSending: _isSending,
                      onSend: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChatHero extends StatelessWidget {
  const _ChatHero({required this.user});

  final UserProfile? user;

  @override
  Widget build(BuildContext context) {
    final location = user?.preferredLocation ?? 'your target market';
    final rentOrBuy = switch (user?.rentOrBuy) {
      'BUY' => 'buy',
      'RENT' => 'rent',
      _ => 'move',
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF18605D),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE59B32),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'AI Housing Chat',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ask HomePilot like a real assistant.',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'I can summarize your budget, explain grant options, compare listings, and estimate what you can $rentOrBuy around $location.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFFE4F2EF),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.author == ChatAuthor.user;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isUser ? const Color(0xFF18605D) : Colors.white;
    final textColor = isUser ? Colors.white : const Color(0xFF1F2A2C);

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Text(
              message.text,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: textColor, height: 1.45),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final Future<void> Function([String? prompt]) onSend;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: isSending ? null : (_) => onSend(),
                decoration: const InputDecoration(
                  hintText:
                      'Ask about budget, grants, listings, or mortgage...',
                  border: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: false,
                ),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: isSending ? null : () => onSend(),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF18605D),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
              ),
              child: Text(isSending ? '...' : 'Send'),
            ),
          ],
        ),
      ),
    );
  }
}
