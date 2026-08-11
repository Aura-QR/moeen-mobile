import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/admin/promo/data/models/admin_promo_models.dart';
import 'package:moean/features/admin/promo/presentation/cubit/admin_promo_cubit.dart';
import 'package:moean/features/admin/promo/presentation/cubit/admin_promo_state.dart';
import 'package:moean/features/admin/promo/presentation/widgets/admin_promo_stat_card_widget.dart';
import 'package:moean/features/admin/promo/presentation/widgets/admin_promo_table_row_widget.dart';
import 'package:moean/features/admin/promo/presentation/widgets/admin_promo_create_dialog.dart';

class AdminPromoBodyWidget extends StatelessWidget {
  final AdminReferralStatsModel stats;
  final List<AdminPromoCodeModel> promoCodes;

  const AdminPromoBodyWidget({
    super.key,
    required this.stats,
    required this.promoCodes,
  });

  void _showDeleteConfirm(BuildContext context, int id) {
    showDialog<void>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: ColorsManager.surfacePrimary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            appTranslation().get('admin_promo_delete_confirm'),
            style:
                TextStylesManager.bold16.copyWith(color: ColorsManager.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                appTranslation().get('admin_promo_delete_no'),
                style: TextStylesManager.medium14
                    .copyWith(color: ColorsManager.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                AdminPromoCubit.get(context).deletePromoCode(id);
              },
              child: Text(
                appTranslation().get('admin_promo_delete_yes'),
                style: TextStylesManager.bold14
                    .copyWith(color: ColorsManager.errorColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Stats cards
          AdminPromoStatCardWidget(
            label: appTranslation().get('admin_promo_stat_registrations'),
            value: '${stats.totalRegistrations}',
            icon: Icons.people_alt_outlined,
            iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
            iconColor: ColorsManager.primaryColor,
          ),
          verticalSpace12,
          AdminPromoStatCardWidget(
            label: appTranslation().get('admin_promo_stat_qualified'),
            value: '${stats.qualifiedReferrals}',
            icon: Icons.workspace_premium_outlined,
            iconBgColor: const Color(0xFFEDE7F6),
            iconColor: const Color(0xFF7B1FA2),
          ),
          verticalSpace12,
          AdminPromoStatCardWidget(
            label: appTranslation().get('admin_promo_stat_rewards'),
            value: '${stats.rewardsUsed} / ${stats.rewardsGenerated}',
            icon: Icons.redeem_outlined,
            iconBgColor: const Color(0xFFFFF3E0),
            iconColor: const Color(0xFFFF8C00),
          ),
          verticalSpace12,
          AdminPromoStatCardWidget(
            label: appTranslation().get('admin_promo_stat_conversion'),
            value: '${stats.conversionRatePct.toStringAsFixed(1)}%',
            icon: Icons.trending_up_rounded,
            iconBgColor: const Color(0xFFE8F5E9),
            iconColor: const Color(0xFF2E7D32),
          ),
          verticalSpace24,
          // Promo codes table
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorsManager.surfacePrimary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorsManager.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  appTranslation().get('admin_promo_table_title'),
                  style: TextStylesManager.bold16
                      .copyWith(color: ColorsManager.textPrimary),
                ),
                verticalSpace16,
                if (promoCodes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        appTranslation().get('admin_promo_empty'),
                        style: TextStylesManager.regular14
                            .copyWith(color: ColorsManager.textSecondary),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: promoCodes.length,
                    separatorBuilder: (_, __) => verticalSpace10,
                    itemBuilder: (_, i) => AdminPromoTableRowWidget(
                      promo: promoCodes[i],
                      onDelete: () =>
                          _showDeleteConfirm(context, promoCodes[i].id),
                    ),
                  ),
              ],
            ),
          ),
          verticalSpace24,
        ],
      ),
    );
  }
}
