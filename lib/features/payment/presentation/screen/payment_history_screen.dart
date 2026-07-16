import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:moean/features/payment/presentation/cubit/payment_state.dart';
import 'package:moean/features/payment/presentation/widgets/payment_history_item_widget.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    PaymentCubit.get(context).loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.surfacePrimary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get('pay_history_title'),
          style: TextStylesManager.bold16.copyWith(
            color: ColorsManager.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: ColorsManager.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: ColorsManager.borderColor),
        ),
      ),
      body: BlocBuilder<PaymentCubit, PaymentState>(
        buildWhen: (_, s) =>
            s is HistoryLoading || s is HistoryLoaded || s is HistoryError,
        builder: (context, state) {
          final cubit = PaymentCubit.get(context);
          return ConditionalBuilder(
            loadingState: state is HistoryLoading,
            errorState: state is HistoryError,
            emptyState:
                state is HistoryLoaded && cubit.paymentHistory.isEmpty,
            errorBuilder: (_) => Center(
              child: Text(
                (state as HistoryError).error,
                style: TextStylesManager.regular14
                    .copyWith(color: ColorsManager.errorColor),
                textAlign: TextAlign.center,
              ),
            ),
            emptyBuilder: (_) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 60, color: ColorsManager.secondaryText),
                  verticalSpace16,
                  Text(
                    appTranslation().get('pay_no_history'),
                    style: TextStylesManager.regular14.copyWith(
                      color: ColorsManager.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            successBuilder: (_) => RefreshIndicator(
              color: ColorsManager.primaryColor,
              onRefresh: () => cubit.loadHistory(),
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: cubit.paymentHistory.length,
                separatorBuilder: (_, __) => verticalSpace12,
                itemBuilder: (_, i) => PaymentHistoryItemWidget(
                  payment: cubit.paymentHistory[i],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
