import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/features/activities_plan/presentation/cubit/activities_plan_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_header_section.dart';

/// «الترويسة» of the plan: read-only defaults, with «تعديل لهذا المستند فقط».
class ActivitiesPlanHeaderSection extends StatelessWidget {
  const ActivitiesPlanHeaderSection({super.key});

  Future<void> _editDefaults(BuildContext context) async {
    final cubit = ActivitiesPlanCubit.get(context);
    final saved = await Navigator.pushNamed(context, Routes.documentDefaults);
    if (saved == true) cubit.reloadDefaults();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ActivitiesPlanCubit.get(context);
    return BlocBuilder<ActivitiesPlanCubit, ActivitiesPlanState>(
      buildWhen: (previous, current) =>
          previous.defaults != current.defaults ||
          previous.isOverridingHeader != current.isOverridingHeader,
      builder: (context, state) => DocumentHeaderSection(
        defaults: state.defaults,
        isOverriding: state.isOverridingHeader,
        overrideControllers: cubit.header.controllers,
        onOverrideChanged: cubit.setHeaderOverride,
        onEditDefaults: () => _editDefaults(context),
      ),
    );
  }
}
