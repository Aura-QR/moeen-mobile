import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/no_data_widget.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/role_suites/presentation/cubit/role_documents_cubit.dart';
import 'package:moean/features/role_suites/presentation/widgets/role_category_filter_bar.dart';
import 'package:moean/features/role_suites/presentation/widgets/role_category_section.dart';

/// Search bar, category tabs, and filtered document rows for a role suite.
class RoleDocumentsBody extends StatelessWidget {
  const RoleDocumentsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = RoleDocumentsCubit.get(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: PrimaryTextField(
            controller: cubit.searchController,
            hint: appTranslation().get('role_docs_search_hint'),
            textInputAction: TextInputAction.search,
            prefixIcon: Icon(Icons.search_rounded, color: ColorsManager.secondaryText),
            onChanged: cubit.onSearchChanged,
          ),
        ),
        const RoleCategoryFilterBar(),
        verticalSpace10,
        Expanded(
          child: BlocBuilder<RoleDocumentsCubit, RoleDocumentsState>(
            buildWhen: (previous, current) =>
                previous.categories != current.categories ||
                previous.selectedCategoryIndex != current.selectedCategoryIndex ||
                previous.searchQuery != current.searchQuery ||
                previous.openingDocKey != current.openingDocKey,
            builder: (context, state) {
              final visible = state.visibleCategories;
              if (visible.isEmpty) {
                return NoDataWidget(
                  icon: Icons.search_off_rounded,
                  title: appTranslation().get('role_docs_empty'),
                );
              }
              return RefreshIndicator(
                onRefresh: cubit.load,
                child: ListView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    for (final category in visible)
                      RoleCategorySection(
                        category: category,
                        openingDocKey: state.openingDocKey,
                        onOpen: cubit.openDocument,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
