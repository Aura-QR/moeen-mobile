import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/features/documents/presentation/widgets/document_header_section.dart';
import 'package:moean/features/grade_analysis/presentation/cubit/grade_analysis_cubit.dart';

/// «الترويسة» of the report: read-only defaults, with «تعديل لهذا المستند فقط».
class GradeAnalysisHeaderSection extends StatelessWidget {
  const GradeAnalysisHeaderSection({super.key});

  Future<void> _editDefaults(BuildContext context) async {
    final cubit = GradeAnalysisCubit.get(context);
    final saved = await Navigator.pushNamed(context, Routes.documentDefaults);
    if (saved == true) cubit.reloadDefaults();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = GradeAnalysisCubit.get(context);
    return BlocBuilder<GradeAnalysisCubit, GradeAnalysisState>(
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
