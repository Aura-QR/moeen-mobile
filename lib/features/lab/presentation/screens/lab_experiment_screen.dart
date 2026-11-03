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
    // Allow landscape on this screen only, for the interactive board
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Restore default portrait orientation
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
        return Scaffold(
          backgroundColor: ColorsManager.background,
          appBar: AppBar(
            backgroundColor: ColorsManager.background,
            elevation: 0,
            title: Text(
              widget.args.name,
              style: TextStylesManager.bold16.copyWith(
                color: ColorsManager.mainText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
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
          body: BlocListener<LabExperimentCubit, LabExperimentState>(
            listenWhen: (_, current) => current.feedback != null,
            listener: (context, state) => showPrimarySnackBar(
              context,
              appTranslation().get(state.feedback!.message),
              isError: state.feedback!.isError,
            ),
            child: BlocBuilder<LabExperimentCubit, LabExperimentState>(
              builder: (context, state) {
                return LabInAppWebViewWidget(
                  experimentKey: widget.args.key,
                  cubit: cubit,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
