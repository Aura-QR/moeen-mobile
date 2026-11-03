import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:moean/core/utils/cubit/theme/theme_state.dart';
import 'package:moean/features/lab/data/models/lab_experiment_model.dart';
import 'package:moean/features/lab/presentation/cubit/lab_experiment_cubit.dart';
import 'package:moean/features/lab/presentation/widgets/lab_inapp_webview_widget.dart';
import 'package:moean/features/lab/presentation/widgets/lab_linked_lessons_bar.dart';
import 'package:moean/features/lab/presentation/widgets/lab_linked_lessons_bottom_sheet.dart';
import 'package:moean/features/lab/presentation/widgets/lab_report_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

/// L8 «معمل حضر الافتراضي»: Live interactive experiment runner screen.
class LabExperimentScreen extends StatefulWidget {
  final LabExperimentArgs args;

  const LabExperimentScreen({super.key, required this.args});

  @override
  State<LabExperimentScreen> createState() => _LabExperimentScreenState();
}

class _LabExperimentScreenState extends State<LabExperimentScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _shareExperiment() {
    final shareUrl = 'https://haderedu.com/lab/${widget.args.key}';
    SharePlus.instance.share(ShareParams(text: shareUrl));
  }

  void _openReportSheet(BuildContext context, LabExperimentCubit cubit) {
    LabReportBottomSheet.show(context, cubit);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = LabExperimentCubit.get(context);

    return BlocBuilder<ThemeCubit, ThemeState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, _) {
        return BlocConsumer<LabExperimentCubit, LabExperimentState>(
          listenWhen: (prev, curr) =>
              prev.feedback != curr.feedback && curr.feedback != null,
          listener: (context, state) => showPrimarySnackBar(
            context,
            appTranslation().get(state.feedback!.message),
            isError: state.feedback!.isError,
          ),
          buildWhen: (prev, curr) =>
              prev.webViewStatus != curr.webViewStatus ||
              prev.experiment != curr.experiment,
          builder: (context, state) {
            final lessons = state.linkedLessons;

            return Scaffold(
              backgroundColor: ColorsManager.background,
              appBar: AppBar(
                backgroundColor: ColorsManager.background,
                elevation: 0,
                title: Text(
                  widget.args.name.isNotEmpty
                      ? widget.args.name
                      : (state.experiment?.name ?? ''),
                  style: TextStylesManager.bold16.copyWith(
                    color: ColorsManager.mainText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                actions: [
                  if (lessons.isNotEmpty)
                    IconButton(
                      tooltip: appTranslation().get('lab_linked_lessons'),
                      icon: const Icon(Icons.menu_book_rounded),
                      color: ColorsManager.primaryColor,
                      onPressed: () => LabLinkedLessonsBottomSheet.show(
                        context,
                        lessons: lessons,
                      ),
                    ),
                  IconButton(
                    tooltip: appTranslation().get('lab_share'),
                    icon: const Icon(Icons.share_outlined),
                    color: ColorsManager.mainText,
                    onPressed: _shareExperiment,
                  ),
                  IconButton(
                    tooltip: appTranslation().get('lab_report_mistake'),
                    icon: const Icon(Icons.report_problem_outlined),
                    color: ColorsManager.mainText,
                    onPressed: () => _openReportSheet(context, cubit),
                  ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: LabInAppWebViewWidget(
                      experimentKey: widget.args.key,
                      cubit: cubit,
                    ),
                  ),
                  LabLinkedLessonsBar(lessons: lessons),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
