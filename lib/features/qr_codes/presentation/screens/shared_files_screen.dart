import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/no_data_widget.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/primary/upgrade_prompt_bottom_sheet.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/qr_codes/presentation/cubit/shared_files_list_cubit.dart';
import 'package:moean/features/qr_codes/presentation/cubit/shared_files_list_state.dart';
import 'package:moean/features/qr_codes/presentation/widgets/shared_file_tile.dart';
import 'package:moean/features/qr_codes/presentation/widgets/shared_files_quota_bar.dart';

class SharedFilesScreen extends StatefulWidget {
  const SharedFilesScreen({super.key});

  @override
  State<SharedFilesScreen> createState() => _SharedFilesScreenState();
}

class _SharedFilesScreenState extends State<SharedFilesScreen> {
  @override
  void initState() {
    super.initState();
    SharedFilesListCubit.get(context).load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        title: Text(
          appTranslation().get('qr_my_files'),
          style: TextStylesManager.bold16.copyWith(
            color: ColorsManager.mainText,
          ),
        ),
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocConsumer<SharedFilesListCubit, SharedFilesListState>(
          listenWhen: (previous, current) =>
              (current.error != null && previous.error != current.error) ||
              current.paymentRequired != null,
          listener: (context, state) {
            if (state.paymentRequired != null) {
              UpgradePromptBottomSheet.show(
                context,
                message:
                    appTranslation().get(state.paymentRequired!.message),
                isQuotaExceeded: true,
              );
              SharedFilesListCubit.get(context).clearError();
              return;
            }
            if (state.error != null && state.files.isNotEmpty) {
              showPrimarySnackBar(context, state.error!, isError: true);
              SharedFilesListCubit.get(context).clearError();
            }
          },
          buildWhen: (previous, current) =>
              previous.isLoading != current.isLoading ||
              previous.files != current.files ||
              previous.meta != current.meta ||
              previous.error != current.error,
          builder: (context, state) {
            final cubit = SharedFilesListCubit.get(context);

            return ConditionalBuilder(
              loadingState: state.isLoading,
              errorState: state.error != null && state.files.isEmpty,
              emptyState: state.isEmpty,
              errorBuilder: (_) => PrimaryErrorView(
                message: state.error!,
                onRetry: () => cubit.load(),
              ),
              emptyBuilder: (_) => NoDataWidget(
                title: appTranslation().get('qr_files_empty'),
                icon: Icons.folder_open_rounded,
              ),
              successBuilder: (_) => RefreshIndicator(
                onRefresh: () => cubit.refresh(),
                color: ColorsManager.primaryColor,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  children: [
                    SharedFilesQuotaBar(meta: state.meta),
                    verticalSpace16,
                    for (final file in state.files)
                      SharedFileTile(
                        key: ValueKey(file.id),
                        file: file,
                        expiryOptions: state.meta.expiryDays,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
