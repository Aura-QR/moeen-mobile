import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/features/performance/presentation/cubit/performance_cubit.dart';
import 'package:moean/features/performance/presentation/widgets/performance_body.dart';

/// «الأداء الوظيفي» (T9): the portfolio by performance element.
class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = PerformanceCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get('performance_title'),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
      ),
      body: BlocConsumer<PerformanceCubit, PerformanceState>(
        listenWhen: (_, current) => current.feedback != null,
        listener: (context, state) =>
            showPrimarySnackBar(context, state.feedback!.message, isError: state.feedback!.isError),
        buildWhen: (previous, current) =>
            previous.status != current.status || previous.performance != current.performance,
        builder: (context, state) => ConditionalBuilder(
          loadingState: state.status == PerformanceStatus.loading,
          errorState: state.status == PerformanceStatus.failure,
          emptyState: false,
          errorBuilder: (_) => PrimaryErrorView(message: state.errorMessage ?? 'generic_error', onRetry: cubit.load),
          successBuilder: (_) => PerformanceBody(performance: state.performance!),
        ),
      ),
    );
  }
}
