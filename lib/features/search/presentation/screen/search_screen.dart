import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:moean/core/utils/cubit/theme/theme_state.dart';
import 'package:moean/features/search/presentation/cubit/search_cubit.dart';
import 'package:moean/features/search/presentation/widgets/search_filter_chips_widget.dart';
import 'package:moean/features/search/presentation/widgets/search_input_widget.dart';
import 'package:moean/features/search/presentation/widgets/search_results_body_widget.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: ColorsManager.background,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SearchHeaderWidget(),
                  verticalSpace16,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SearchInputWidget(
                      onSearch: (query) =>
                          context.read<SearchCubit>().search(query),
                      onClear: () => context.read<SearchCubit>().reset(),
                    ),
                  ),
                  verticalSpace16,
                  const SearchFilterChipsWidget(),
                  verticalSpace8,
                  const Divider(height: 1),
                  verticalSpace8,
                  const Expanded(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: SearchResultsBodyWidget(),
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

class _SearchHeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: ColorsManager.textPrimary,
              size: 20,
            ),
          ),
          Expanded(
            child: Text(
              appTranslation().get('search_title'),
              style: TextStylesManager.bold20.copyWith(
                color: ColorsManager.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}
