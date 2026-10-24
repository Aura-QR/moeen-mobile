import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/online_tests/data/models/online_test_models.dart';
import 'package:moean/features/online_tests/data/repositories/online_tests_repository.dart';
import 'package:moean/features/online_tests/presentation/cubit/online_tests_list_cubit.dart';
import 'package:moean/features/online_tests/presentation/widgets/online_test_state_badge.dart';

/// «اختباراتي الإلكترونية»: the tests shared as links. New ones start from an exam («شارك إلكترونيًا»).
class OnlineTestsScreen extends StatelessWidget {
  const OnlineTestsScreen({super.key});

  static Widget create() => BlocProvider(
        create: (_) => OnlineTestsListCubit(OnlineTestsRepository())..load(),
        child: const OnlineTestsScreen(),
      );

  @override
  Widget build(BuildContext context) {
    final cubit = OnlineTestsListCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(appTranslation().get('online_tests_title'), style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText)),
      ),
      body: BlocBuilder<OnlineTestsListCubit, OnlineTestsListState>(
        builder: (context, state) {
          if (state.isLoading && state.tests.isEmpty) return const Center(child: CircularProgressIndicator());
          if (state.error != null && state.tests.isEmpty) return PrimaryErrorView(message: state.error!, onRetry: cubit.load);
          return RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(appTranslation().get('online_tests_hint'), style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText)),
                verticalSpace12,
                PrimaryElevatedButton(
                  text: appTranslation().get('online_tests_new'),
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => Navigator.pushNamed(context, Routes.myExams),
                ),
                verticalSpace16,
                if (state.tests.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(child: Text(appTranslation().get('online_tests_empty'), style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText))),
                  ),
                for (final test in state.tests) ...[
                  _TestCard(test: test, onReturn: cubit.load),
                  verticalSpace8,
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TestCard extends StatelessWidget {
  final OnlineTest test;
  final VoidCallback onReturn;

  const _TestCard({required this.test, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorsManager.surfacePrimary,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.pushNamed(context, Routes.onlineTest, arguments: test.id);
          onReturn();
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(test.title, style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
                    verticalSpace4,
                    Text(
                      '${test.questionsCount} ${appTranslation().get('online_tests_questions')} · ${test.groups.length} ${appTranslation().get('online_tests_classes')} · ${test.submissions} ${appTranslation().get('online_tests_submissions')}',
                      style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                    ),
                  ],
                ),
              ),
              OnlineTestStateBadge(state: test.state),
            ],
          ),
        ),
      ),
    );
  }
}
