import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/support_chat/data/support_chat_repository.dart';

/// «مساعد حضّر», the support chatbot the site has, as a full screen.
class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  static const _guestSuggestions = [
    'كيف أحضّر دروسي من التطبيق؟',
    'ما أسعار الاشتراك؟',
    'مدرستي تطلب تسجيل الدخول كل مرة',
  ];
  static const _teacherSuggestions = [
    'كم تبقى من اشتراكي؟',
    'كم تبقى من حدودي اليوم؟',
    'كيف أنزّل خطة الأسبوع؟',
  ];

  final _chat = SupportChatRepository.instance;
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _chat.messages.addListener(_scrollToEnd);
    _chat.sending.addListener(_scrollToEnd);
  }

  @override
  void dispose() {
    _chat.messages.removeListener(_scrollToEnd);
    _chat.sending.removeListener(_scrollToEnd);
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _send([String? text]) {
    final question = text ?? _input.text;
    if (question.trim().isEmpty) return;
    _input.clear();
    _chat.send(question);
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = token != null && token!.isNotEmpty;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.white,
        appBar: AppBar(
          backgroundColor: ColorsManager.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'مساعد حضّر',
            style: TextStylesManager.bold20.copyWith(color: ColorsManager.themeActiveAccent),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: ColorsManager.themeDarkPrimary,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.restart_alt_rounded),
              color: ColorsManager.themeDarkPrimary,
              tooltip: 'محادثة جديدة',
              onPressed: _chat.reset,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ValueListenableBuilder<List<SupportChatMessage>>(
                  valueListenable: _chat.messages,
                  builder: (context, messages, _) => ValueListenableBuilder<bool>(
                    valueListenable: _chat.sending,
                    builder: (context, sending, _) {
                      if (messages.isEmpty) {
                        return _Welcome(
                          suggestions: signedIn ? _teacherSuggestions : _guestSuggestions,
                          onTap: _send,
                        );
                      }
                      return ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length + (sending ? 1 : 0),
                        itemBuilder: (context, index) => index == messages.length
                            ? const _Typing()
                            : _Bubble(message: messages[index]),
                      );
                    },
                  ),
                ),
              ),
              _Composer(controller: _input, onSend: _send, sending: _chat.sending),
            ],
          ),
        ),
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.suggestions, required this.onTap});

  final List<String> suggestions;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        Icon(Icons.support_agent_rounded, size: 56, color: ColorsManager.themeActiveAccent),
        const SizedBox(height: 12),
        const Text(
          'أهلًا! أنا مساعد حضّر',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'أجيبك عن استخدام التطبيق، التحضير، الاشتراك والحدود.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: ColorsManager.themeDarkPrimary.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 24),
        for (final suggestion in suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                side: BorderSide(color: ColorsManager.themeActiveAccent.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => onTap(suggestion),
              child: Text(suggestion, style: TextStyle(color: ColorsManager.themeActiveAccent)),
            ),
          ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final SupportChatMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = message.role == 'user';
    final error = message.role == 'error';
    final background = mine
        ? ColorsManager.themeActiveAccent
        : error
            ? Colors.red.withValues(alpha: 0.08)
            : ColorsManager.themeActiveAccent.withValues(alpha: 0.07);
    final foreground = mine ? Colors.white : (error ? Colors.red.shade700 : ColorsManager.themeDarkPrimary);

    return Align(
      // RTL: the teacher's own messages sit on the right, the bot's on the left.
      alignment: mine ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(16)),
        child: SelectableText(
          message.content,
          style: TextStyle(color: foreground, fontSize: 14.5, height: 1.5),
        ),
      ),
    );
  }
}

class _Typing extends StatelessWidget {
  const _Typing();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: ColorsManager.themeActiveAccent.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 8),
            Text('يكتب…', style: TextStyle(color: ColorsManager.themeDarkPrimary.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend, required this.sending});

  final TextEditingController controller;
  final VoidCallback onSend;
  final ValueNotifier<bool> sending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: ColorsManager.white,
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLength: SupportChatRepository.maxChars,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'اكتب سؤالك…',
                counterText: '',
                filled: true,
                fillColor: ColorsManager.themeActiveAccent.withValues(alpha: 0.05),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<bool>(
            valueListenable: sending,
            builder: (context, busy, _) => IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: ColorsManager.themeActiveAccent),
              onPressed: busy ? null : onSend,
              // Arrow points left: the direction text flows in Arabic.
              icon: const Icon(Icons.send_rounded, textDirection: TextDirection.rtl),
            ),
          ),
        ],
      ),
    );
  }
}
