import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/thank_you_certificates/presentation/cubit/certificates_cubit.dart';
import 'package:moean/features/thank_you_certificates/presentation/widgets/certificate_name_tile.dart';
import 'package:moean/features/thank_you_certificates/presentation/widgets/certificate_preview_sheet.dart';
import 'package:moean/features/documents/presentation/widgets/student_picker_sheet.dart';

/// «الأسماء»: from «فصولي», pasted, or imported from Excel. One certificate each.
class CertificatesNamesSection extends StatelessWidget {
  const CertificatesNamesSection({super.key});

  Future<void> _pick(BuildContext context) async {
    final cubit = CertificatesCubit.get(context);
    final result = await StudentPickerSheet.show(
      context,
      initialClassId: cubit.state.classId,
      initialStudents: cubit.state.names,
    );
    if (result != null) cubit.setNames(result);
  }

  void _preview(BuildContext context, String name) {
    final input = CertificatesCubit.get(context).previewInput(name: name, fallbackName: name);
    if (input != null) CertificatePreviewSheet.show(context, name: name, input: input);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = CertificatesCubit.get(context);
    return BlocBuilder<CertificatesCubit, CertificatesState>(
      buildWhen: (previous, current) => previous.names != current.names || previous.isImporting != current.isImporting,
      builder: (context, state) => PrimarySectionCard(
        icon: Icons.groups_2_outlined,
        title: appTranslation().get('certificates_section_names'),
        trailing: Text(
          '${state.names.length}/${state.catalogue.limits.names}',
          style: TextStylesManager.medium12.copyWith(color: ColorsManager.secondaryText),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.names.isEmpty)
              Text(
                appTranslation().get('certificates_names_empty'),
                style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
              ),
            for (var i = 0; i < state.names.length; i++)
              CertificateNameTile(
                key: ValueKey('$i-${state.names[i]}'),
                number: i + 1,
                name: state.names[i],
                onPreview: () => _preview(context, state.names[i]),
                onRemove: () => cubit.removeName(i),
              ),
            verticalSpace8,
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: () => _pick(context),
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 20),
                  label: Text(appTranslation().get('certificates_names_pick')),
                ),
                TextButton.icon(
                  onPressed: state.isImporting || state.isFull ? null : cubit.importFromFile,
                  icon: state.isImporting
                      ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.upload_file_rounded, size: 20),
                  label: Text(appTranslation().get('class_import_excel')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
