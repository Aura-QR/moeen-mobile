import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/qr_codes/presentation/cubit/shared_file_upload_cubit.dart';
import 'package:moean/features/qr_codes/presentation/cubit/shared_file_upload_state.dart';
import 'package:moean/features/qr_codes/presentation/widgets/shared_file_expiry_chips.dart';
import 'package:moean/features/qr_codes/presentation/widgets/shared_file_picked_card.dart';

class SharedFileUploadForm extends StatefulWidget {
  const SharedFileUploadForm({super.key});

  @override
  State<SharedFileUploadForm> createState() => _SharedFileUploadFormState();
}

class _SharedFileUploadFormState extends State<SharedFileUploadForm> {
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _showSourceSheet(BuildContext context) {
    final cubit = SharedFileUploadCubit.get(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ColorsManager.surfacePrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.insert_drive_file_outlined,
                  color: ColorsManager.primaryColor,
                ),
                title: Text(
                  appTranslation().get('qr_from_files'),
                  style: TextStylesManager.bold14.copyWith(
                    color: ColorsManager.mainText,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  cubit.pickFileFromDevice();
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.photo_library_outlined,
                  color: ColorsManager.primaryColor,
                ),
                title: Text(
                  appTranslation().get('qr_from_gallery'),
                  style: TextStylesManager.bold14.copyWith(
                    color: ColorsManager.mainText,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  cubit.pickMediaFromGallery();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SharedFileUploadCubit, SharedFileUploadState>(
      buildWhen: (previous, current) =>
          previous.file != current.file ||
          previous.status != current.status ||
          previous.progress != current.progress ||
          previous.expiryDays != current.expiryDays,
      builder: (context, state) {
        final cubit = SharedFileUploadCubit.get(context);
        final isUploading =
            state.status == SharedFileUploadStatus.uploading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, Routes.sharedFiles),
                icon: Icon(
                  Icons.folder_shared_outlined,
                  size: 18,
                  color: ColorsManager.primaryColor,
                ),
                label: Text(
                  appTranslation().get('qr_my_files'),
                  style: TextStylesManager.bold13.copyWith(
                    color: ColorsManager.primaryColor,
                  ),
                ),
              ),
            ),
            verticalSpace8,
            if (state.file == null)
              OutlinedButton.icon(
                onPressed: isUploading ? null : () => _showSourceSheet(context),
                icon: Icon(
                  Icons.cloud_upload_outlined,
                  color: ColorsManager.primaryColor,
                ),
                label: Text(
                  appTranslation().get('qr_pick_file'),
                  style: TextStylesManager.bold14.copyWith(
                    color: ColorsManager.primaryColor,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  side: BorderSide(
                    color: ColorsManager.primaryColor,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              )
            else ...[
              SharedFilePickedCard(
                file: state.file!,
                onChange: isUploading ? () {} : () => _showSourceSheet(context),
              ),
              verticalSpace16,
              PrimaryTextField(
                controller: _titleController,
                label: appTranslation().get('qr_file_title_label'),
                hint: appTranslation().get('qr_file_title_label'),
                maxLength: 120,
                enabled: !isUploading,
                onChanged: (text) => cubit.setTitle(text),
              ),
              verticalSpace16,
              SharedFileExpiryChips(
                daysOptions: state.meta.expiryDays,
                selectedDays: state.expiryDays,
                onSelected: isUploading ? (_) {} : (d) => cubit.setExpiryDays(d),
              ),
              verticalSpace20,
              if (isUploading) ...[
                LinearProgressIndicator(
                  value: state.progress > 0 ? state.progress : null,
                  backgroundColor: ColorsManager.borderLightGray,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ColorsManager.primaryColor,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  minHeight: 8,
                ),
                verticalSpace8,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appTranslation().get('qr_uploading'),
                      style: TextStylesManager.medium12.copyWith(
                        color: ColorsManager.secondaryText,
                      ),
                    ),
                    Text(
                      '${(state.progress * 100).toInt()}%',
                      style: TextStylesManager.bold12.copyWith(
                        color: ColorsManager.primaryColor,
                      ),
                    ),
                  ],
                ),
                verticalSpace12,
                OutlinedButton(
                  onPressed: () => cubit.cancel(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorsManager.errorColor,
                    side: BorderSide(color: ColorsManager.errorColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(appTranslation().get('qr_cancel')),
                ),
              ] else
                PrimaryElevatedButton(
                  text: appTranslation().get('qr_upload_share'),
                  onPressed: state.canUpload ? () => cubit.upload() : null,
                ),
            ],
          ],
        );
      },
    );
  }
}
