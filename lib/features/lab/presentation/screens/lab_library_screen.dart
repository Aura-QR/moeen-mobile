import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/no_data_widget.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:moean/core/utils/cubit/theme/theme_state.dart';
import 'package:moean/features/lab/presentation/cubit/lab_library_cubit.dart';
import 'package:moean/features/lab/presentation/widgets/lab_experiments_list_view.dart';
import 'package:moean/features/lab/presentation/widgets/lab_lesson_filter_banner.dart';
import 'package:moean/features/lab/presentation/widgets/lab_library_filters_bar.dart';
import 'package:moean/features/lab/presentation/widgets/lab_sort_selector.dart';

/// L8 «معمل حضر الافتراضي»: Virtual Lab experiments showcase.
class LabLibraryScreen extends StatelessWidget {
  const LabLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = LabLibraryCubit.get(context);

    return BlocBuilder<ThemeCubit, ThemeState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: ColorsManager.background,
          appBar: AppBar(
            backgroundColor: ColorsManager.background,
            elevation: 0,
            centerTitle: true,
            title: Text(
              appTranslation().get('lab_library_title'),
              style: TextStylesManager.bold16.copyWith(
                color: ColorsManager.mainText,
              ),
            ),
          ),
          body: BlocListener<LabLibraryCubit, LabLibraryState>(
            listenWhen: (_, current) => current.feedback != null,
            listener: (context, state) => showPrimarySnackBar(
              context,
              state.feedback!.message,
              isError: state.feedback!.isError,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: PrimaryTextField(
                    controller: cubit.searchController,
                    hint: appTranslation().get('lab_search_hint'),
                    textInputAction: TextInputAction.search,
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: ColorsManager.secondaryText,
                    ),
                    onChanged: cubit.onSearchChanged,
                  ),
                ),
                BlocBuilder<LabLibraryCubit, LabLibraryState>(
                  buildWhen: (previous, current) =>
                      previous.lessonId != current.lessonId ||
                      previous.filters != current.filters ||
                      previous.selectedStageId != current.selectedStageId ||
                      previous.selectedGradeId != current.selectedGradeId ||
                      previous.selectedSubjectId != current.selectedSubjectId ||
                      previous.selectedSubjectGroup != current.selectedSubjectGroup ||
                      previous.sort != current.sort,
                  builder: (context, state) {
                    return Column(
                      children: [
                        if (state.lessonId != null)
                          LabLessonFilterBanner(lessonTitle: state.lessonTitle),
                        LabLibraryFiltersBar(state: state),
                        verticalSpace8,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              LabSortSelector(
                                currentSort: state.sort,
                                onSortChanged: cubit.setSort,
                              ),
                            ],
                          ),
                        ),
                        verticalSpace4,
                      ],
                    );
                  },
                ),
                Expanded(
                  child: BlocBuilder<LabLibraryCubit, LabLibraryState>(
                    buildWhen: (previous, current) =>
                        previous.status != current.status ||
                        previous.experiments.length != current.experiments.length ||
                        previous.isLoadingMore != current.isLoadingMore,
                    builder: (context, state) {
                      return ConditionalBuilder(
                        loadingState: state.status == LabLibraryStatus.loading,
                        errorState: state.status == LabLibraryStatus.failure,
                        emptyState: state.experiments.isEmpty,
                        errorBuilder: (_) => PrimaryErrorView(
                          message: state.errorMessage ?? 'generic_error',
                          onRetry: cubit.load,
                        ),
                        emptyBuilder: (_) => NoDataWidget(
                          title: appTranslation().get('lab_no_experiments'),
                          icon: Icons.science_outlined,
                        ),
                        successBuilder: (_) => RefreshIndicator(
                          onRefresh: cubit.load,
                          color: ColorsManager.primaryColor,
                          child: LabExperimentsListView(
                            experiments: state.experiments,
                            isLoadingMore: state.isLoadingMore,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
