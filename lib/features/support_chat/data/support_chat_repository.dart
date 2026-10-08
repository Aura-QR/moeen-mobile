import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:moean/core/network/remote/dio_helper.dart';

/// One message in the support chat. Errors are shown in the conversation but
/// never sent back to the server as history.
class SupportChatMessage {
  const SupportChatMessage(this.role, this.content);

  /// 'user', 'assistant' or 'error'.
  final String role;
  final String content;

  bool get isTurn => role == 'user' || role == 'assistant';
}

/// Talks to the support chatbot («مساعد حضّر»), the same one as on the site.
///
/// The server stores no conversation, so the earlier turns go with each
/// question. They live here for the app session, the way the site keeps them
/// for the browser tab.
class SupportChatRepository {
  SupportChatRepository._();
  static final SupportChatRepository instance = SupportChatRepository._();

  /// The server reads the last 10 turns; sending more only costs bandwidth.
  static const int historyTurns = 10;
  static const int maxChars = 1000;
  static const int _maxKept = 30;

  final ValueNotifier<List<SupportChatMessage>> messages = ValueNotifier(const []);
  final ValueNotifier<bool> sending = ValueNotifier(false);

  Future<void> send(String text) async {
    final question = text.trim();
    if (question.isEmpty || sending.value) return;

    final history = messages.value
        .where((m) => m.isTurn)
        .toList()
        .reversed
        .take(historyTurns)
        .toList()
        .reversed
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();

    _set([...messages.value.where((m) => m.isTurn), SupportChatMessage('user', question)]);
    sending.value = true;
    try {
      final result = await DioHelper.postData(
        url: '/chatbot/message',
        // client=app makes the bot answer about the app, not the site.
        data: {'message': question, 'history': history, 'client': 'app'},
      );
      result.fold(
        (error) => _set([...messages.value, SupportChatMessage('error', _errorText(error))]),
        (response) {
          final data = response.data is String ? _decode(response.data as String) : response.data;
          final reply = data is Map ? data['reply']?.toString().trim() ?? '' : '';
          _set([
            ...messages.value,
            reply.isEmpty
                ? const SupportChatMessage('error', 'لم يصل رد من المساعد. حاول مرة أخرى.')
                : SupportChatMessage('assistant', reply),
          ]);
        },
      );
    } finally {
      sending.value = false;
    }
  }

  void reset() => _set(const []);

  void _set(List<SupportChatMessage> next) {
    messages.value = next.length > _maxKept ? next.sublist(next.length - _maxKept) : next;
  }

  /// DioHelper reduces errors to the server's message, prefixing a few codes.
  static String _errorText(String error) {
    if (error.startsWith('__')) {
      final parts = error.split(':');
      if (parts.length > 2) return parts.sublist(2).join(':');
    }
    if (error == 'No response from server' || error == 'something went wrong') {
      return 'تعذر الاتصال بالمساعد. تحقق من الإنترنت وحاول مرة أخرى.';
    }
    // The server's own messages point to the site's contact page.
    return error.replaceAll('من صفحة /contact', 'من شاشة التواصل');
  }

  static dynamic _decode(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }
}
