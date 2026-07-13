import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/admin/payments/data/repositories/admin_payments_repository.dart';
import 'package:moean/features/admin/payments/presentation/cubit/admin_payments_cubit.dart';
import 'package:moean/features/admin/payments/presentation/cubit/admin_payments_state.dart';
import 'package:moean/features/admin/payments/presentation/widgets/admin_payments_search_filter_widget.dart';
import 'package:moean/features/admin/payments/presentation/widgets/admin_payments_table_widget.dart';

class AdminPaymentsScreen extends StatelessWidget {
  const AdminPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminPaymentsCubit(AdminPaymentsRepository())..getPayments(),
      child: BlocConsumer<AdminPaymentsCubit, AdminPaymentsState>(
        listener: (context, state) {
          if (state is AdminPaymentActionSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is AdminPaymentActionErrorState || state is GetAdminPaymentsErrorState) {
            final msg = state is AdminPaymentActionErrorState 
                ? state.message 
                : (state as GetAdminPaymentsErrorState).message;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final cubit = AdminPaymentsCubit.get(context);
          final scrollController = ScrollController();

          // Infinite scrolling
          scrollController.addListener(() {
            if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
              if (state is! GetAdminPaymentsLoadingState) {
                cubit.getPayments(loadMore: true);
              }
            }
          });

          return Scaffold(
            backgroundColor: ColorsManager.background,
            appBar: AppBar(
              backgroundColor: ColorsManager.primaryColor,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  const Icon(Icons.payment, color: Colors.white),
                  horizontalSpace8,
                  Text(
                    appTranslation().get('admin_payments_title'),
                    style: TextStylesManager.bold18.copyWith(color: Colors.white),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => cubit.getPayments(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: ColorsManager.primaryColor,
                    ),
                    onPressed: () {
                      context.push(Routes.home);
                    },
                    icon: const Icon(Icons.home),
                    label: Text(
                      appTranslation().get('home'),
                      style: TextStylesManager.medium16,
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const AdminPaymentsSearchFilterWidget(),
                    verticalSpace24,
                    Expanded(
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                        child: state is GetAdminPaymentsLoadingState && cubit.paymentsList.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : AdminPaymentsTableWidget(
                                payments: cubit.paymentsList,
                                scrollController: scrollController,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
