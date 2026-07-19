import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/search/presentation/cubit/search_cubit.dart';
import 'package:moean/features/search/presentation/cubit/search_state.dart';
import 'package:moean/features/search/presentation/widgets/search_empty_widget.dart';
import 'package:moean/features/search/presentation/widgets/search_result_item_widget.dart';

class SearchResultsBodyWidget extends StatelessWidget {
  const SearchResultsBodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        final isLoading = state is SearchLoading;
        final isError = state is SearchError;
        final isEmpty = state is SearchEmpty;
        final isLoaded = state is SearchLoaded;
        final isInitial = state is SearchInitial;

        if (isInitial) {
          return _SearchInitialHintWidget();
        }

        return ConditionalBuilder(
          loadingState: isLoading,
          errorState: isError,
          emptyState: isEmpty,
          errorBuilder: (ctx) => _SearchErrorWidget(
            message: (state as SearchError).message,
          ),
          emptyBuilder: (ctx) => SearchEmptyWidget(
            query: (state as SearchEmpty).query,
          ),
          successBuilder: (ctx) {
            if (!isLoaded) return const SizedBox.shrink();
            final loaded = state as SearchLoaded;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  verticalSpace12,
                  _SearchResultsCountWidget(
                    count: loaded.results.length,
                    query: loaded.query,
                  ),
                  verticalSpace16,
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: loaded.results.length,
                    itemBuilder: (context, index) => SearchResultItemWidget(
                      result: loaded.results[index],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SearchInitialHintWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 72),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.manage_search_rounded,
              size: 72,
              color: ColorsManager.primaryColor.withValues(alpha: 0.25),
            ),
            verticalSpace16,
            Text(
              appTranslation().get('search_hint_prompt'),
              style: TextStylesManager.regular14.copyWith(
                color: ColorsManager.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchErrorWidget extends StatelessWidget {
  final String message;

  const _SearchErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: ColorsManager.errorColor.withValues(alpha: 0.6),
            ),
            verticalSpace16,
            Text(
              appTranslation().get('search_error_title'),
              style: TextStylesManager.bold16.copyWith(
                color: ColorsManager.textPrimary,
              ),
            ),
            verticalSpace8,
            Text(
              message,
              style: TextStylesManager.regular13.copyWith(
                color: ColorsManager.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsCountWidget extends StatelessWidget {
  final int count;
  final String query;

  const _SearchResultsCountWidget({
    required this.count,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: ColorsManager.primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '($count)',
            style: TextStylesManager.bold13.copyWith(
              color: ColorsManager.white,
            ),
          ),
        ),
        horizontalSpace8,
        Expanded(
          child: Text(
            appTranslation().get('search_results_for'),
            style: TextStylesManager.regular13.copyWith(
              color: ColorsManager.secondaryText,
            ),
          ),
        ),
        Text(
          '"$query"',
          style: TextStylesManager.bold13.copyWith(
            color: ColorsManager.primaryColor,
          ),
        ),
      ],
    );
  }
}
