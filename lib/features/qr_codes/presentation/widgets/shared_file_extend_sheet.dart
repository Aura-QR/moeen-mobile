import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/qr_codes/presentation/cubit/shared_files_list_cubit.dart';
import 'package:moean/features/qr_codes/presentation/widgets/shared_file_expiry_chips.dart';

class SharedFileExtendSheet extends StatefulWidget {
  final int fileId;
  final List<int> expiryDays;

  const SharedFileExtendSheet({
    super.key,
    required this.fileId,
    required this.expiryDays,
  });

  static Future<void> show(
    BuildContext context, {
    required int fileId,
    required List<int> expiryDays,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: ColorsManager.surfacePrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SharedFileExtendSheet(
        fileId: fileId,
        expiryDays: expiryDays,
      ),
    );
  }

  @override
  State<SharedFileExtendSheet> createState() => _SharedFileExtendSheetState();
}

class _SharedFileExtendSheetState extends State<SharedFileExtendSheet> {
  late int _selectedDays;

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.expiryDays.isNotEmpty ? widget.expiryDays.first : 30;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              appTranslation().get('qr_extend'),
              style: TextStylesManager.bold16.copyWith(
                color: ColorsManager.mainText,
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpace20,
            SharedFileExpiryChips(
              daysOptions: widget.expiryDays,
              selectedDays: _selectedDays,
              onSelected: (days) => setState(() => _selectedDays = days),
            ),
            verticalSpace24,
            PrimaryElevatedButton(
              text: appTranslation().get('qr_extend'),
              onPressed: () {
                Navigator.pop(context);
                SharedFilesListCubit.get(context).extend(widget.fileId, _selectedDays);
              },
            ),
          ],
        ),
      ),
    );
  }
}
