import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reports/presentation/cubit/saved_reports_cubit.dart';
import 'package:moean/features/reports/presentation/cubit/saved_reports_state.dart';
import 'package:moean/features/reports/presentation/screen/saved_report_details_screen.dart';
import 'package:moean/features/reports/presentation/widgets/saved_report_card_widget.dart';
import 'package:moean/features/reports/presentation/widgets/saved_reports_filter_widget.dart';
import 'package:moean/features/reports/presentation/widgets/saved_reports_header_widget.dart';

class SavedReportsScreen extends StatelessWidget {
  final String teacherName;

  const SavedReportsScreen({
    super.key,
    required this.teacherName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SavedReportsCubit()..fetchReports(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: ColorsManager.background,
          body: SafeArea(
            child: BlocConsumer<SavedReportsCubit, SavedReportsState>(
              listener: (context, state) {
                if (state is SavedReportsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message, style: TextStylesManager.bold14),
                      backgroundColor: ColorsManager.errorColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final cubit = SavedReportsCubit.get(context);
                final reports = state is SavedReportsSuccess ? state.reports : [];

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SavedReportsHeaderWidget(
                        onRefresh: () => cubit.fetchReports(),
                      ),
                      verticalSpace24,
                      SavedReportsFilterWidget(
                        selectedFilter: cubit.currentFilter,
                        onFilterChanged: (filter) => cubit.fetchReports(filter: filter),
                      ),
                      verticalSpace20,
                      ConditionalBuilder(
                        loadingState: state is SavedReportsLoading,
                        errorState: state is SavedReportsError,
                        emptyState: state is SavedReportsSuccess && reports.isEmpty,
                        emptyBuilder: (context) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              appTranslation().get('no_saved_reports'),
                              style: TextStylesManager.regular16.copyWith(
                                color: ColorsManager.secondaryText,
                              ),
                            ),
                          ),
                        ),
                        errorBuilder: (context) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  (state as SavedReportsError).message,
                                  style: TextStylesManager.bold14.copyWith(
                                    color: ColorsManager.errorColor,
                                  ),
                                ),
                                verticalSpace12,
                                ElevatedButton(
                                  onPressed: () => cubit.fetchReports(),
                                  child: Text(appTranslation().get('retry')),
                                ),
                              ],
                            ),
                          ),
                        ),
                        successBuilder: (context) => LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 600;
                            if (isWide) {
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  mainAxisExtent: 260,
                                ),
                                itemCount: reports.length,
                                itemBuilder: (context, index) => SavedReportCardWidget(
                                  report: reports[index],
                                  onOpen: () => _openDetails(context, reports[index]),
                                ),
                              );
                            }
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: reports.length,
                              separatorBuilder: (context, index) => verticalSpace16,
                              itemBuilder: (context, index) => SavedReportCardWidget(
                                report: reports[index],
                                onOpen: () => _openDetails(context, reports[index]),
                              ),
                            );
                          },
                        ),
                      ),
                      verticalSpace32,
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _openDetails(BuildContext context, dynamic report) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SavedReportDetailsScreen(
          report: report,
          teacherName: teacherName,
        ),
      ),
    );
  }
}
