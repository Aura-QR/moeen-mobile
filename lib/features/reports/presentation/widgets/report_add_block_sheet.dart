import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/reports/data/models/report_catalogue_model.dart';
import 'package:moean/features/reports/presentation/report_block_style.dart';

/// «إضافة»: the block kinds, in the server's order. Pops with the kind.
class ReportAddBlockSheet extends StatelessWidget {
  final List<String> kinds;
  final ReportCatalogueModel? catalogue;

  const ReportAddBlockSheet({super.key, required this.kinds, required this.catalogue});

  static Future<String?> show(BuildContext context, {required List<String> kinds, ReportCatalogueModel? catalogue}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => ReportAddBlockSheet(kinds: kinds, catalogue: catalogue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                appTranslation().get('report_add_block'),
                style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
              ),
            ),
            for (final kind in kinds)
              ListTile(
                onTap: () => Navigator.pop(context, kind),
                leading: Icon(reportBlockIcon(kind), color: ColorsManager.primaryColor),
                title: Text(
                  reportBlockLabel(kind, catalogue),
                  style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
