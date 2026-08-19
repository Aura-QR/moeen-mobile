import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:moean/core/utils/cubit/theme/theme_state.dart';
import 'package:moean/features/admin/teachers/presentation/cubit/admin_teachers_cubit.dart';

class AdminTeachersSearchFilterWidget extends StatelessWidget {
  const AdminTeachersSearchFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = AdminTeachersCubit.get(context);

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              flex: 5,
              child: PrimaryTextField(
                controller: cubit.searchController,
                onChanged: cubit.onSearchChanged,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hint: appTranslation().get('admin_search_hint'),
              ),
            ),
            horizontalSpace8,
            Expanded(
              flex: 2,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: ColorsManager.surfacePrimary,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: ColorsManager.borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: ColorsManager.surfacePrimary,
                    value: cubit.statusFilter,
                    hint: Text(
                      appTranslation().get('admin_all_status'),
                      style: TextStylesManager.regular14.copyWith(
                        color: ColorsManager.textSecondary.withValues(alpha: 0.85),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: ColorsManager.textPrimary, size: 20),
                    style: TextStylesManager.regular14.copyWith(
                      color: ColorsManager.textPrimary,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(
                          appTranslation().get('admin_all_status'),
                          style: TextStylesManager.regular14.copyWith(
                            color: ColorsManager.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'active',
                        child: Text(
                          appTranslation().get('admin_active'),
                          style: TextStylesManager.regular14.copyWith(
                            color: ColorsManager.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'inactive',
                        child: Text(
                          appTranslation().get('admin_suspended'),
                          style: TextStylesManager.regular14.copyWith(
                            color: ColorsManager.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                    onChanged: cubit.onStatusFilterChanged,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
