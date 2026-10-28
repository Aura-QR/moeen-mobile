import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/learning_styles/data/repositories/learning_styles_repository.dart';
import 'package:moean/features/learning_styles/presentation/cubit/learning_styles_list_cubit.dart';
import 'package:moean/features/learning_styles/presentation/widgets/learning_style_card.dart';

/// «أنماط التعلم»: the teacher's surveys. New ones start from «استبانة جديدة».
class LearningStylesScreen extends StatelessWidget {
  const LearningStylesScreen({super.key});

  static Widget create() => BlocProvider(
        create: (_) => LearningStylesListCubit(LearningStylesRepository())..load(),
        child: const LearningStylesScreen(),
      );

  @override
  Widget build(BuildContext context) {
    final cubit = LearningStylesListCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(appTranslation().get('learning_styles_title'),
            style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText)),
      ),
      body: BlocBuilder<LearningStylesListCubit, LearningStylesListState>(
        builder: (context, state) {
          if (state.isLoading && state.surveys.isEmpty) return const Center(child: CircularProgressIndicator());
          if (state.error != null && state.surveys.isEmpty) {
            return PrimaryErrorView(message: state.error!, onRetry: cubit.load);
          }
          return RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(appTranslation().get('learning_styles_hint'),
                    style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText)),
                verticalSpace12,
                PrimaryElevatedButton(
                  text: appTranslation().get('learning_styles_new'),
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () async {
                    await Navigator.pushNamed(context, Routes.learningStyleNew);
                    cubit.load();
                  },
                ),
                verticalSpace16,
                if (state.surveys.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(appTranslation().get('learning_styles_empty'),
                          style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText)),
                    ),
                  ),
                for (final survey in state.surveys) ...[
                  LearningStyleCard(survey: survey, onReturn: cubit.load),
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
