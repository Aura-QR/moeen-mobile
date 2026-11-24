import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/activities_plan/presentation/cubit/activities_plan_cubit.dart';

/// Shows [child], then the gap before the next section, only for a plan saved
/// before the official layout (e.g. the domains choice, which a new plan lacks).
class ActivitiesLegacyOnly extends StatelessWidget {
  final Widget child;

  const ActivitiesLegacyOnly({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ActivitiesPlanCubit, ActivitiesPlanState, bool>(
      selector: (state) => state.isLegacy,
      builder: (context, isLegacy) => isLegacy ? Column(children: [child, verticalSpace14]) : const SizedBox.shrink(),
    );
  }
}
