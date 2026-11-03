import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:moean/core/utils/cubit/theme/theme_state.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/features/admin/lab/presentation/cubit/admin_lab_cubit.dart';
import 'package:moean/features/admin/lab/presentation/widgets/admin_lab_experiments_tab.dart';
import 'package:moean/features/admin/lab/presentation/widgets/admin_lab_reports_tab.dart';
import 'package:moean/features/admin/lab/presentation/widgets/admin_lab_requests_tab.dart';
import 'package:moean/features/admin/lab/presentation/widgets/admin_lab_tab_bar.dart';

class AdminLabScreen extends StatelessWidget {
  const AdminLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, _) {
        return BlocListener<AdminLabCubit, AdminLabState>(
          listenWhen: (prev, curr) =>
              curr.feedback != null && curr.feedback != prev.feedback,
          listener: (context, state) {
            showPrimarySnackBar(
              context,
              state.feedback!.message,
              isError: state.feedback!.isError,
            );
          },
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: ColorsManager.background,
              appBar: AppBar(
                backgroundColor: ColorsManager.surfacePrimary,
                elevation: 0,
                title: Text(
                  appTranslation().get('admin_lab_title'),
                  style: TextStylesManager.bold18.copyWith(
                    color: ColorsManager.mainText,
                  ),
                ),
                centerTitle: true,
                iconTheme: IconThemeData(color: ColorsManager.mainText),
              ),
              body: BlocBuilder<AdminLabCubit, AdminLabState>(
                buildWhen: (prev, curr) =>
                    prev.currentTab != curr.currentTab ||
                    prev.experiments.length != curr.experiments.length ||
                    prev.reports.length != curr.reports.length ||
                    prev.requests.length != curr.requests.length,
                builder: (context, state) {
                  final cubit = AdminLabCubit.get(context);
                  return Column(
                    children: [
                      AdminLabTabBar(
                        selectedIndex: state.currentTab,
                        onTabSelected: cubit.setTab,
                        experimentsCount: state.experiments.length,
                        reportsCount:
                            state.reports.where((r) => r.isOpen).length,
                        requestsCount:
                            state.requests.where((r) => r.isOpen).length,
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: state.currentTab,
                          children: const [
                            AdminLabExperimentsTab(),
                            AdminLabReportsTab(),
                            AdminLabRequestsTab(),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
