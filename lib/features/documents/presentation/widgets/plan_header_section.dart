import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/features/documents/presentation/cubit/plan_form_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_header_section.dart';

/// «الترويسة» of a plan: read-only defaults, with «تعديل لهذا المستند فقط».
class PlanHeaderSection extends StatelessWidget {
  const PlanHeaderSection({super.key});

  /// Defaults change the header of every document, so reload them on return.
  Future<void> _editDefaults(BuildContext context) async {
    final cubit = PlanFormCubit.get(context);
    final saved = await Navigator.pushNamed(context, Routes.documentDefaults);
    if (saved == true) cubit.reloadDefaults();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = PlanFormCubit.get(context);
    return BlocBuilder<PlanFormCubit, PlanFormState>(
      buildWhen: (previous, current) =>
          previous.defaults != current.defaults || previous.isOverridingHeader != current.isOverridingHeader,
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
