import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/admin/teachers/presentation/cubit/admin_teachers_cubit.dart';

class AdminTeachersSearchFilterWidget extends StatelessWidget {
  const AdminTeachersSearchFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = AdminTeachersCubit.get(context);

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Expanded(
            child: PrimaryTextField(controller: cubit.searchController,
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
             hint: appTranslation().get('admin_search_hint'))
          ),
        ),
        horizontalSpace16,
        Expanded(
          flex: 1,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: ColorsManager.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: cubit.statusFilter,
                hint: Text(appTranslation().get('admin_all_status')),
                isExpanded: true,
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(appTranslation().get('admin_all_status')),
                  ),
                  DropdownMenuItem(
                    value: 'active',
                    child: Text(appTranslation().get('admin_active')),
                  ),
                  DropdownMenuItem(
                    value: 'inactive',
                    child: Text(appTranslation().get('admin_suspended')),
                  ),
                ],
                onChanged: cubit.onStatusFilterChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
