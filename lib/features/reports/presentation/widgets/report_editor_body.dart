import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';
import 'package:moean/features/reports/presentation/widgets/report_blocks_section.dart';
import 'package:moean/features/reports/presentation/widgets/report_element_section.dart';
import 'package:moean/features/reports/presentation/widgets/report_media_and_design_sections.dart';
import 'package:moean/features/reports/presentation/widgets/report_meta_section.dart';
import 'package:moean/features/reports/presentation/widgets/report_role_ai_card.dart';
import 'package:moean/features/reports/presentation/widgets/report_sensitive_banner.dart';
import 'package:moean/features/reports/presentation/widgets/report_signatures_section.dart';
import 'package:moean/features/reports/presentation/widgets/report_title_section.dart';

/// The whole report form. Keeps a key per block so a new block, or one the
/// server refused, is scrolled into view.
class ReportEditorBody extends StatefulWidget {
  const ReportEditorBody({super.key});

  @override
  State<ReportEditorBody> createState() => _ReportEditorBodyState();
}

class _ReportEditorBodyState extends State<ReportEditorBody> {
  final Map<int, GlobalKey> _keys = {};

  GlobalKey _keyOf(int blockId) => _keys.putIfAbsent(blockId, GlobalKey.new);

  void _scrollTo(int blockId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _keys[blockId]?.currentContext;
      if (target != null && target.mounted) {
        Scrollable.ensureVisible(target, duration: const Duration(milliseconds: 300), alignment: 0.1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportEditorCubit, ReportEditorState>(
      listenWhen: (_, current) => current.scrollToBlockId != null,
      listener: (_, state) => _scrollTo(state.scrollToBlockId!),
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const ReportSensitiveBanner(),
          const ReportTitleSection(),
          verticalSpace14,
          const ReportMetaSection(),
          verticalSpace14,
          const ReportRoleAiCard(),
          ReportBlocksSection(keyOf: _keyOf),
          verticalSpace14,
          const ReportSignaturesSection(),
          verticalSpace14,
          const ReportMediaAndDesignSections(),
          verticalSpace14,
          const ReportElementSection(),
        ],
      ),
    );
  }
}
