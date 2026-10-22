import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/primary/upgrade_prompt_bottom_sheet.dart';
import 'package:moean/features/documents/presentation/cubit/ai_suggestions_cubit.dart';

/// Hands finished AI suggestions to [onResult], and opens the upgrade sheet
/// when the account has no trial or subscription (402). Needs an
/// [AiSuggestionsCubit] above it.
class DocumentAiListener extends StatelessWidget {
  final ValueChanged<Map<String, List<String>>> onResult;
  final Widget child;

  const DocumentAiListener({super.key, required this.onResult, required this.child});

  void _onEvent(BuildContext context, AiSuggestionsState state) {
    final payment = state.paymentRequired;
    if (payment != null) {
      UpgradePromptBottomSheet.show(
        context,
        message: payment.message,
        isQuotaExceeded: payment.code == 'quota_exceeded',
      );
      return;
    }
    onResult(state.result);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AiSuggestionsCubit, AiSuggestionsState>(
      listenWhen: (previous, current) =>
          (current.status == AiSuggestionsStatus.done && previous.status != AiSuggestionsStatus.done) ||
          (current.paymentRequired != null && previous.paymentRequired != current.paymentRequired),
      listener: _onEvent,
      child: child,
    );
  }
}
