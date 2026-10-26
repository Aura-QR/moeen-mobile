import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_choice_chips.dart';
import 'package:moean/features/role_suites/presentation/cubit/role_documents_cubit.dart';

/// Category tabs («الكل» + each category) above a role's document list.
class RoleCategoryFilterBar extends StatelessWidget {
  const RoleCategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = RoleDocumentsCubit.get(context);
    return BlocBuilder<RoleDocumentsCubit, RoleDocumentsState>(
      buildWhen: (previous, current) =>
          previous.categories != current.categories ||
          previous.selectedCategoryIndex != current.selectedCategoryIndex,
      builder: (context, state) {
        if (state.categories.length <= 1) return const Offstage();
        final options = <int?>[null, for (var i = 0; i < state.categories.length; i++) i];
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PrimaryChoiceChips<int?>(
            options: options,
            labelOf: (index) =>
                index == null ? appTranslation().get('all') : state.categories[index].label,
            isSelected: (index) => state.selectedCategoryIndex == index,
            onTap: cubit.selectCategory,
          ),
        );
      },
    );
  }
}
