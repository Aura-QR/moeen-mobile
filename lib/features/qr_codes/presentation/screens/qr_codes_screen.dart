import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/primary/upgrade_prompt_bottom_sheet.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/qr_codes/data/services/qr_export_service.dart';
import 'package:moean/features/qr_codes/presentation/cubit/link_qr_cubit.dart';
import 'package:moean/features/qr_codes/presentation/cubit/link_qr_state.dart';
import 'package:moean/features/qr_codes/presentation/cubit/shared_file_upload_cubit.dart';
import 'package:moean/features/qr_codes/presentation/cubit/shared_file_upload_state.dart';
import 'package:moean/features/qr_codes/presentation/widgets/qr_actions_row.dart';
import 'package:moean/features/qr_codes/presentation/widgets/qr_link_form.dart';
import 'package:moean/features/qr_codes/presentation/widgets/qr_preview_card.dart';
import 'package:moean/features/qr_codes/presentation/widgets/qr_tab_selector.dart';
import 'package:moean/features/qr_codes/presentation/widgets/shared_file_guest_card.dart';
import 'package:moean/features/qr_codes/presentation/widgets/shared_file_upload_form.dart';

class QrCodesScreen extends StatefulWidget {
  final bool isLoggedIn;

  const QrCodesScreen({
    super.key,
    this.isLoggedIn = false,
  });

  @override
  State<QrCodesScreen> createState() => _QrCodesScreenState();
}

class _QrCodesScreenState extends State<QrCodesScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isLoggedIn) {
      SharedFileUploadCubit.get(context).loadMeta();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        title: Text(
          appTranslation().get('qr_title'),
          style: TextStylesManager.bold16.copyWith(
            color: ColorsManager.mainText,
          ),
        ),
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              QrTabSelector(
                selectedIndex: _selectedTab,
                onTabChanged: (index) => setState(() => _selectedTab = index),
              ),
              verticalSpace16,
              if (_selectedTab == 0) ...[
                const QrLinkForm(),
                verticalSpace16,
                const QrPreviewCard(),
                verticalSpace16,
                BlocBuilder<LinkQrCubit, LinkQrState>(
                  buildWhen: (previous, current) =>
                      previous.url != current.url ||
                      previous.caption != current.caption ||
                      previous.isValid != current.isValid ||
                      previous.logo != current.logo,
                  builder: (context, linkState) {
                    return QrActionsRow(
                      getPngBytes: () => QrExportService().pngBytes(
                        data: linkState.url,
                        logo: linkState.logo,
                      ),
                      link: linkState.url,
                      caption: linkState.caption,
                      enabled: linkState.isValid,
                    );
                  },
                ),
              ] else ...[
                if (!widget.isLoggedIn)
                  const SharedFileGuestCard()
                else
                  BlocConsumer<SharedFileUploadCubit, SharedFileUploadState>(
                    listenWhen: (previous, current) =>
                        (current.error != null && previous.error != current.error) ||
                        current.paymentRequired != null ||
                        current.status == SharedFileUploadStatus.done,
                    listener: (context, state) {
                      if (state.paymentRequired != null) {
                        UpgradePromptBottomSheet.show(
                          context,
                          message: appTranslation()
                              .get(state.paymentRequired!.message),
                          isQuotaExceeded: true,
                        );
                        SharedFileUploadCubit.get(context).clearError();
                        return;
                      }
                      if (state.error != null) {
                        showPrimarySnackBar(
                          context,
                          state.error!,
                          isError: true,
                        );
                        SharedFileUploadCubit.get(context).clearError();
                      }
                      if (state.status == SharedFileUploadStatus.done &&
                          state.result != null) {
                        Navigator.pushReplacementNamed(
                          context,
                          Routes.sharedFileResult,
                          arguments: state.result,
                        );
                      }
                    },
                    buildWhen: (previous, current) => false,
                    builder: (context, _) => const SharedFileUploadForm(),
                  ),
              ],
              verticalSpace24,
            ],
          ),
        ),
      ),
    );
  }
}
