import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/referral/presentation/cubit/referral_cubit.dart';
import 'package:moean/features/referral/presentation/cubit/referral_state.dart';
import 'package:moean/features/referral/presentation/widgets/referral_body_widget.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  @override
  void initState() {
    super.initState();
    ReferralCubit.get(context).loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: AppBar(
          backgroundColor: ColorsManager.background,
          elevation: 0,
          centerTitle: true,
          title: Text(
            appTranslation().get('referral_chip_label'),
            style: TextStylesManager.bold18
                .copyWith(color: ColorsManager.primaryColor),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,
                color: ColorsManager.mainText),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<ReferralCubit, ReferralState>(
            buildWhen: (_, s) =>
                s is ReferralLoading ||
                s is ReferralLoaded ||
                s is ReferralError,
            builder: (context, state) {
              return ConditionalBuilder(
                loadingState: state is ReferralLoading,
                errorState: state is ReferralError,
                emptyState: false,
                errorBuilder: (_) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off_outlined,
                          size: 48,
                          color: ColorsManager.textSecondary
                              .withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      Text(
                        appTranslation().get('referral_loading_error'),
                        style: TextStylesManager.regular14.copyWith(
                            color: ColorsManager.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () =>
                            ReferralCubit.get(context).loadDashboard(),
                        icon: const Icon(Icons.refresh_rounded),
                        label:
                            Text(appTranslation().get('referral_refresh')),
                      ),
                    ],
                  ),
                ),
                successBuilder: (_) {
                  final cubit = ReferralCubit.get(context);
                  if (cubit.dashboard == null) return const SizedBox.shrink();
                  return ReferralBodyWidget(dashboard: cubit.dashboard!);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
