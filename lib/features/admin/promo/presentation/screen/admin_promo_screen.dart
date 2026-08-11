import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/admin/promo/presentation/cubit/admin_promo_cubit.dart';
import 'package:moean/features/admin/promo/presentation/cubit/admin_promo_state.dart';
import 'package:moean/features/admin/promo/presentation/widgets/admin_promo_body_widget.dart';
import 'package:moean/features/admin/promo/presentation/widgets/admin_promo_create_dialog.dart';

class AdminPromoScreen extends StatefulWidget {
  const AdminPromoScreen({super.key});

  @override
  State<AdminPromoScreen> createState() => _AdminPromoScreenState();
}

class _AdminPromoScreenState extends State<AdminPromoScreen> {
  @override
  void initState() {
    super.initState();
    AdminPromoCubit.get(context).loadAll();
  }

  void _showCreateDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: AdminPromoCubit.get(context),
        child: const AdminPromoCreateDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: AppBar(
          backgroundColor: ColorsManager.primaryColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            appTranslation().get('admin_promo_title'),
            style: TextStylesManager.bold18.copyWith(color: Colors.white),
          ),
          actions: [
            // Refresh
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: () => AdminPromoCubit.get(context).loadAll(),
            ),
            // Back home
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 4),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
                label: Text(appTranslation().get('return_home'),
                    style: TextStylesManager.medium12
                        .copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: ColorsManager.primaryColor,
          onPressed: () => _showCreateDialog(context),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            appTranslation().get('admin_promo_create_btn'),
            style:
                TextStylesManager.medium14.copyWith(color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<AdminPromoCubit, AdminPromoState>(
            listenWhen: (_, s) =>
                s is AdminPromoActionSuccess || s is AdminPromoActionError,
            listener: (context, state) {
              if (state is AdminPromoActionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message, textAlign: TextAlign.center),
                  backgroundColor: ColorsManager.primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ));
                Navigator.of(context, rootNavigator: true)
                    .popUntil((_) => true);
              } else if (state is AdminPromoActionError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error, textAlign: TextAlign.center),
                  backgroundColor: ColorsManager.errorColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ));
              }
            },
            buildWhen: (_, s) =>
                s is AdminPromoLoading ||
                s is AdminPromoLoaded ||
                s is AdminPromoError ||
                s is AdminPromoActionLoading,
            builder: (context, state) {
              final cubit = AdminPromoCubit.get(context);
              return ConditionalBuilder(
                loadingState: state is AdminPromoLoading || state is AdminPromoActionLoading,
                errorState: state is AdminPromoError,
                emptyState: false,
                errorBuilder: (_) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off_outlined,
                          size: 48,
                          color: ColorsManager.textSecondary
                              .withValues(alpha: 0.4)),
                      verticalSpace12,
                      Text((state as AdminPromoError).error,
                          style: TextStylesManager.regular14.copyWith(
                              color: ColorsManager.textSecondary),
                          textAlign: TextAlign.center),
                      verticalSpace16,
                      TextButton.icon(
                        onPressed: () => cubit.loadAll(),
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(appTranslation().get('admin_promo_refresh')),
                      ),
                    ],
                  ),
                ),
                successBuilder: (_) => AdminPromoBodyWidget(
                  stats: cubit.stats!,
                  promoCodes: cubit.promoCodes,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
