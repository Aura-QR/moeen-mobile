import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_confirm_dialog.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/online_tests/data/models/online_test_models.dart';
import 'package:moean/features/online_tests/data/repositories/online_tests_repository.dart';
import 'package:moean/features/online_tests/presentation/cubit/online_test_cubit.dart';
import 'package:moean/features/online_tests/presentation/widgets/online_test_links_tab.dart';
import 'package:moean/features/online_tests/presentation/widgets/online_test_passage_box.dart';
import 'package:moean/features/online_tests/presentation/widgets/online_test_results_tab.dart';
import 'package:moean/features/online_tests/presentation/widgets/online_test_state_badge.dart';

/// One online test: «الروابط» (a link and QR per class) and «النتائج» (scores, review, AI marks, analysis).
class OnlineTestScreen extends StatelessWidget {
  const OnlineTestScreen({super.key});

  static Widget create(int id) => BlocProvider(
        create: (_) => OnlineTestCubit(testId: id, repository: OnlineTestsRepository(), documents: DocumentsRepository())..load(),
        child: const OnlineTestScreen(),
      );

  static Uint8List? qrBytes(String? dataUri) {
    if (dataUri == null || !dataUri.contains(',')) return null;
    try {
      return base64Decode(dataUri.split(',').last);
    } catch (_) {
      return null;
    }
  }

  Future<void> _listen(BuildContext context, OnlineTestScreenState state) async {
    final cubit = OnlineTestCubit.get(context);
    if (state.message != null) {
      showPrimarySnackBar(context, appTranslation().get(state.message!), isError: state.messageIsError);
      cubit.clearMessage();
    }
    if (state.deleted) {
      Navigator.pop(context);
      return;
    }
    final docId = state.analysisDocumentId;
    if (docId != null) {
      cubit.clearAnalysis();
      await Navigator.pushNamed(context, Routes.gradeAnalysis, arguments: docId);
    }
  }

  Future<void> _menu(BuildContext context, String action) async {
    final cubit = OnlineTestCubit.get(context);
    if (action == 'toggle') {
      await cubit.toggleOpen();
    } else if (action == 'delete') {
      final ok = await showPrimaryConfirmDialog(context, titleKey: 'online_tests_delete_title', messageKey: 'online_tests_delete_message');
      if (ok) await cubit.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = OnlineTestCubit.get(context);
    return BlocConsumer<OnlineTestCubit, OnlineTestScreenState>(
      listenWhen: (a, b) => a.message != b.message || a.deleted != b.deleted || a.analysisDocumentId != b.analysisDocumentId,
      listener: _listen,
      builder: (context, state) {
        final test = state.test;
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: ColorsManager.background,
            appBar: AppBar(
              backgroundColor: ColorsManager.background,
              elevation: 0,
              centerTitle: true,
              title: Text(test?.title ?? appTranslation().get('online_tests_title'),
                  style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText), overflow: TextOverflow.ellipsis),
              actions: [
                if (test != null)
                  PopupMenuButton<String>(
                    onSelected: (v) => _menu(context, v),
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'toggle', child: Text(appTranslation().get(test.isOpen ? 'online_tests_close' : 'online_tests_reopen'))),
                      PopupMenuItem(value: 'delete', child: Text(appTranslation().get('delete'), style: const TextStyle(color: ColorsManager.errorColor))),
                    ],
                  ),
              ],
              bottom: test == null
                  ? null
                  : TabBar(
                      labelColor: ColorsManager.primaryColor,
                      unselectedLabelColor: ColorsManager.secondaryText,
                      indicatorColor: ColorsManager.primaryColor,
                      tabs: [
                        Tab(text: appTranslation().get('online_tests_links')),
                        Tab(text: '${appTranslation().get('online_tests_results')} (${test.submissions})'),
                      ],
                    ),
            ),
            body: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : test == null
                    ? PrimaryErrorView(message: state.loadError ?? 'generic_error', onRetry: cubit.load)
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Row(
                              children: [
                                OnlineTestStateBadge(state: test.state),
                                horizontalSpace8,
                                Expanded(
                                  child: Text(
                                    '${test.questionsCount} ${appTranslation().get('online_tests_questions')} · ${formatPoints(test.totalPoints)} ${appTranslation().get('online_tests_points')}'
                                    '${test.timeLimitMinutes != null ? ' · ${test.timeLimitMinutes} ${appTranslation().get('online_tests_minutes')}' : ''}',
                                    style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (test.passageParagraphs.isNotEmpty)
                            OnlineTestPassageBox(paragraphs: test.passageParagraphs),
                          verticalSpace8,
                          const Expanded(child: TabBarView(children: [OnlineTestLinksTab(), OnlineTestResultsTab()])),
                        ],
                      ),
          ),
        );
      },
    );
  }
}
