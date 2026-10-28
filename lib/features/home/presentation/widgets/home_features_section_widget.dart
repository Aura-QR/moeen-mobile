import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/router/app_router.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:moean/core/utils/cubit/theme/theme_state.dart';
import 'package:moean/features/home/presentation/cubit/home_cubit.dart';
import 'package:moean/features/home/presentation/widgets/home_action_chip_widget.dart';
import 'package:moean/features/home/presentation/widgets/home_feature_item_widget.dart';

class HomeFeaturesSectionWidget extends StatefulWidget {
  const HomeFeaturesSectionWidget({super.key});

  @override
  State<HomeFeaturesSectionWidget> createState() => _HomeFeaturesSectionWidgetState();
}

class _HomeFeaturesSectionWidgetState extends State<HomeFeaturesSectionWidget>
    with SingleTickerProviderStateMixin {
  int _selectedFeatureIndex = 1;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openAuthed(BuildContext context, String route, {Object? arguments}) {
    final target = token != null && token!.isNotEmpty ? route : Routes.login;
    AppRouter.push(
      target,
      arguments: target == route ? arguments : null,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, themeState) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Start Prep Button with Pulse Effect
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: BlocBuilder<HomeCubit, HomeState>(
                    buildWhen: (previous, current) => previous != current,
                    builder: (context, state) {
                      final homeCubit = HomeCubit.get(context);
                      final isAdmin = homeCubit.isAdmin;
                      final isLoadingRole = homeCubit.isLoadingRole;

                      return AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: ColorsManager.primaryColor.withValues(
                                    alpha: 0.2 + (_animation.value * 0.2),
                                  ),
                                  blurRadius: 10 + (_animation.value * 5),
                                  spreadRadius: _animation.value * 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () => _openAuthed(
                                context,
                                isAdmin ? Routes.adminTeachers : Routes.haderWebView,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 22),
                                decoration: BoxDecoration(
                                  color: ColorsManager.primaryColor,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: ColorsManager.white.withValues(alpha: _animation.value * 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isLoadingRole)
                                      ConstrainedBox(
                                        constraints: const BoxConstraints.tightFor(width: 16, height: 16),
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: ColorsManager.white,
                                        ),
                                      )
                                    else
                                      Text(
                                        isAdmin
                                            ? appTranslation().get('admin_dashboard')
                                            : appTranslation().get('home_start_prep'),
                                        style: TextStylesManager.bold16.copyWith(
                                          color: ColorsManager.white,
                                        ),
                                      ),
                                    horizontalSpace8,
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: ColorsManager.white,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              verticalSpace40,
              BlocBuilder<HomeCubit, HomeState>(
                buildWhen: (previous, current) => previous != current,
                builder: (context, state) {
                  final homeCubit = HomeCubit.get(context);
                  if (homeCubit.isAdmin) return const Offstage();
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: PrimaryTextField(
                          controller: homeCubit.searchController,
                          hint: appTranslation().get('search_title'),
                          readOnly: true,
                          prefixIcon: Icon(Icons.search_rounded, color: ColorsManager.textSecondary),
                          onTap: () => _openAuthed(context, Routes.search),
                        ),
                      ),
                      verticalSpace24,
                    ],
                  );
                },
              ),
              // Action Chips Row
              BlocBuilder<HomeCubit, HomeState>(
                buildWhen: (previous, current) => previous != current,
                builder: (context, state) {
                  final isAdmin = HomeCubit.get(context).isAdmin;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        if (!isAdmin) ...[
                          HomeActionChipWidget(
                            icon: Icons.co_present_rounded,
                            title: appTranslation().get('presentations_title'),
                            onTap: () => _openAuthed(context, Routes.presentations),
                          ),
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.monitor,
                            title: appTranslation().get('home_reports'),
                            onTap: () => _openAuthed(context, Routes.reports),
                          ),
                          horizontalSpace12,
                        ],
                        HomeActionChipWidget(
                          icon: isAdmin ? Icons.assignment_turned_in_outlined : Icons.verified_outlined,
                          title: isAdmin
                              ? appTranslation().get('home_admin_review_questions')
                              : appTranslation().get('my_exam'),
                          onTap: () => _openAuthed(
                            context,
                            isAdmin ? Routes.adminExams : Routes.examGenerationInfo,
                          ),
                        ),
                        if (!isAdmin) ...[
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.folder_copy_outlined,
                            title: appTranslation().get('my_documents_title'),
                            onTap: () => _openAuthed(context, Routes.myDocuments),
                          ),
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.tips_and_updates_outlined,
                            title: appTranslation().get('document_type_strategy_documentation'),
                            onTap: () => _openAuthed(context, Routes.strategyDocumentation),
                          ),
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.healing_outlined,
                            title: appTranslation().get('document_type_remedial_plan'),
                            onTap: () => _openAuthed(context, Routes.remedialPlan),
                          ),
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.rocket_launch_outlined,
                            title: appTranslation().get('document_type_enrichment_plan'),
                            onTap: () => _openAuthed(context, Routes.enrichmentPlan),
                          ),
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.local_activity_outlined,
                            title: appTranslation().get('document_type_activities_plan'),
                            onTap: () => _openAuthed(context, Routes.activitiesPlan),
                          ),
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.insights_rounded,
                            title: appTranslation().get('document_type_grade_analysis'),
                            onTap: () => _openAuthed(context, Routes.gradeAnalysis),
                          ),
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.workspace_premium_outlined,
                            title: appTranslation().get('document_type_certificates'),
                            onTap: () => _openAuthed(context, Routes.thankYouCertificates),
                          ),
                          horizontalSpace12,
                          HomeActionChipWidget(
                          icon: Icons.table_chart_outlined,
                          title: appTranslation().get('document_type_class_sheet'),
                          onTap: () => _openAuthed(context, Routes.classSheets),
                        ),
                        horizontalSpace12,
                        // Concept Maps feature chip
                        HomeActionChipWidget(
                          icon: Icons.map_outlined,
                          title: appTranslation().get('concept_maps_title'),
                          onTap: () => _openAuthed(context, Routes.conceptMaps),
                        ),
                        horizontalSpace12,
                        // Learning-outcomes map feature chip (L9)
                        HomeActionChipWidget(
                          icon: Icons.checklist_rtl_outlined,
                          title: appTranslation().get('outcomes_map_title'),
                          onTap: () => _openAuthed(context, Routes.outcomesMap),
                        ),
                          horizontalSpace12,
                          // Nafs practice tests feature chip (L11)
                          HomeActionChipWidget(
                            icon: Icons.track_changes_outlined,
                            title: appTranslation().get('nafs_title'),
                            onTap: () => _openAuthed(context, Routes.nafsTest),
                          ),
                          horizontalSpace12,
                          // Reading comprehension feature chip (L12)
                          HomeActionChipWidget(
                            icon: Icons.chrome_reader_mode_outlined,
                            title: appTranslation().get('reading_title'),
                            onTap: () => _openAuthed(context, Routes.readingComprehension),
                          ),
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.summarize_outlined,
                            title: appTranslation().get('document_type_report'),
                            onTap: () => _openAuthed(context, Routes.reportTools),
                          ),
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.work_outline_rounded,
                            title: appTranslation().get('role_suites_title'),
                            onTap: () => _openAuthed(context, Routes.roleSuites),
                          ),
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.groups_2_outlined,
                            title: appTranslation().get('classes_title'),
                            onTap: () => _openAuthed(context, Routes.classes),
                          ),
                        ],
                        if (isAdmin) ...[
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.check_circle_outline,
                            title: appTranslation().get('home_admin_payments'),
                            onTap: () => _openAuthed(context, Routes.adminPayments),
                          ),
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.verified_user_outlined,
                            title: appTranslation().get('home_admin_tickets'),
                            onTap: () => _openAuthed(context, Routes.adminContact),
                          ),
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.discount_outlined,
                            title: appTranslation().get('home_admin_promos'),
                            onTap: () => _openAuthed(context, Routes.adminPromo),
                          ),
                        ],
                        if (!isAdmin) ...[
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.print_outlined,
                            title: appTranslation().get('prep_history_title'),
                            onTap: () => _openAuthed(context, Routes.preparationHistory),
                          ),
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.qr_code_scanner_rounded,
                            title: appTranslation().get('qr_title'),
                            onTap: () => AppRouter.push(
                              Routes.qrCodes,
                              arguments: token != null && token!.isNotEmpty,
                              context: context,
                            ),
                          ),
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.qr_code_2_outlined,
                            title: appTranslation().get('online_tests_title'),
                            onTap: () => _openAuthed(context, Routes.onlineTests),
                          ),
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.description_outlined,
                            title: appTranslation().get('home_previous_exams'),
                            onTap: () => _openAuthed(context, Routes.myExams),
                          ),
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.people_alt_outlined,
                            title: appTranslation().get('referral_chip_label'),
                            onTap: () => _openAuthed(context, Routes.referral),
                          ),
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.calendar_month_outlined,
                            title: appTranslation().get('home_curriculum_dist_title'),
                            onTap: () => _openAuthed(context, Routes.curriculumDistribution),
                          ),
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.menu_book_rounded,
                            title: appTranslation().get('home_curriculum_books_title'),
                            onTap: () => _openAuthed(context, Routes.curriculumBooks),
                          ),
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.workspace_premium_outlined,
                            title: appTranslation().get('portfolio_title'),
                            onTap: () => _openAuthed(context, Routes.portfolio),
                          ),
                          horizontalSpace12,
                          HomeActionChipWidget(
                            icon: Icons.bar_chart_rounded,
                            title: appTranslation().get('achievement_report_title'),
                            onTap: () => _openAuthed(context, Routes.achievementReport),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              verticalSpace24,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: HomeFeatureItemWidget(
                          icon: Icons.menu_book_rounded,
                          iconColor: ColorsManager.primaryColor,
                          iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                          title: appTranslation().get('feature_curriculum_title'),
                          subtitle: appTranslation().get('feature_curriculum_subtitle'),
                          isHighlighted: _selectedFeatureIndex == 0,
                          onTap: () => setState(() => _selectedFeatureIndex = 0),
                        ),
                      ),
                      horizontalSpace8,
                      Expanded(
                        child: HomeFeatureItemWidget(
                          icon: Icons.access_time_filled,
                          iconColor: ColorsManager.primaryColor,
                          iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                          title: appTranslation().get('feature_time_title'),
                          subtitle: appTranslation().get('feature_time_subtitle'),
                          isHighlighted: _selectedFeatureIndex == 1,
                          onTap: () => setState(() => _selectedFeatureIndex = 1),
                        ),
                      ),
                      horizontalSpace8,
                      Expanded(
                        child: HomeFeatureItemWidget(
                          icon: Icons.shield_outlined,
                          iconColor: ColorsManager.primaryColor,
                          iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                          title: appTranslation().get('feature_security_title'),
                          subtitle: appTranslation().get('feature_security_subtitle'),
                          isHighlighted: _selectedFeatureIndex == 2,
                          onTap: () => setState(() => _selectedFeatureIndex = 2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Teacher-only tools grid
              BlocBuilder<HomeCubit, HomeState>(
                buildWhen: (previous, current) => previous != current,
                builder: (context, state) {
                  if (HomeCubit.get(context).isAdmin) return const Offstage();
                  return Column(
                    children: [
                      verticalSpace10,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: HomeFeatureItemWidget(
                                  icon: Icons.calendar_month_outlined,
                                  iconColor: ColorsManager.primaryColor,
                                  iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                                  title: appTranslation().get('home_curriculum_dist_title'),
                                  subtitle: appTranslation().get('home_curriculum_dist_subtitle'),
                                  isHighlighted: false,
                                  onTap: () => _openAuthed(context, Routes.curriculumDistribution),
                                ),
                              ),
                              horizontalSpace8,
                              Expanded(
                                child: HomeFeatureItemWidget(
                                  icon: Icons.menu_book_rounded,
                                  iconColor: ColorsManager.primaryColor,
                                  iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                                  title: appTranslation().get('home_curriculum_books_title'),
                                  subtitle: appTranslation().get('home_curriculum_books_subtitle'),
                                  isHighlighted: false,
                                  onTap: () => _openAuthed(context, Routes.curriculumBooks),
                                ),
                              ),
                              horizontalSpace8,
                              Expanded(
                                child: HomeFeatureItemWidget(
                                  icon: Icons.workspace_premium_outlined,
                                  iconColor: ColorsManager.primaryColor,
                                  iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                                  title: appTranslation().get('portfolio_title'),
                                  subtitle: appTranslation().get('portfolio_subtitle'),
                                  isHighlighted: false,
                                  onTap: () => _openAuthed(context, Routes.portfolio),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      verticalSpace10,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: HomeFeatureItemWidget(
                                  icon: Icons.tips_and_updates_outlined,
                                  iconColor: ColorsManager.primaryColor,
                                  iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                                  title: appTranslation().get('document_type_strategy_documentation'),
                                  subtitle: appTranslation().get('document_type_strategy_documentation_subtitle'),
                                  isHighlighted: false,
                                  onTap: () => _openAuthed(context, Routes.strategyDocumentation),
                                ),
                              ),
                              horizontalSpace8,
                              Expanded(
                                child: HomeFeatureItemWidget(
                                  icon: Icons.folder_copy_outlined,
                                  iconColor: ColorsManager.primaryColor,
                                  iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                                  title: appTranslation().get('my_documents_title'),
                                  subtitle: appTranslation().get('my_documents_subtitle'),
                                  isHighlighted: false,
                                  onTap: () => _openAuthed(context, Routes.myDocuments),
                                ),
                              ),
                              horizontalSpace8,
                              Expanded(
                                child: HomeFeatureItemWidget(
                                  icon: Icons.local_activity_outlined,
                                  iconColor: ColorsManager.primaryColor,
                                  iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                                  title: appTranslation().get('document_type_activities_plan'),
                                  subtitle: appTranslation().get('document_type_activities_plan_subtitle'),
                                  isHighlighted: false,
                                  onTap: () => _openAuthed(context, Routes.activitiesPlan),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      verticalSpace10,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: HomeFeatureItemWidget(
                                  icon: Icons.healing_outlined,
                                  iconColor: ColorsManager.primaryColor,
                                  iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                                  title: appTranslation().get('document_type_remedial_plan'),
                                  subtitle: appTranslation().get('document_type_remedial_plan_subtitle'),
                                  isHighlighted: false,
                                  onTap: () => _openAuthed(context, Routes.remedialPlan),
                                ),
                              ),
                              horizontalSpace8,
                              Expanded(
                                child: HomeFeatureItemWidget(
                                  icon: Icons.rocket_launch_outlined,
                                  iconColor: ColorsManager.primaryColor,
                                  iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                                  title: appTranslation().get('document_type_enrichment_plan'),
                                  subtitle: appTranslation().get('document_type_enrichment_plan_subtitle'),
                                  isHighlighted: false,
                                  onTap: () => _openAuthed(context, Routes.enrichmentPlan),
                                ),
                              ),
                              horizontalSpace8,
                              Expanded(
                                child: HomeFeatureItemWidget(
                                  icon: Icons.groups_2_outlined,
                                  iconColor: ColorsManager.primaryColor,
                                  iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                                  title: appTranslation().get('classes_title'),
                                  subtitle: appTranslation().get('classes_subtitle'),
                                  isHighlighted: false,
                                  onTap: () => _openAuthed(context, Routes.classes),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      verticalSpace10,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: HomeFeatureItemWidget(
                                  icon: Icons.insights_rounded,
                                  iconColor: ColorsManager.primaryColor,
                                  iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                                  title: appTranslation().get('document_type_grade_analysis'),
                                  subtitle: appTranslation().get('document_type_grade_analysis_subtitle'),
                                  isHighlighted: false,
                                  onTap: () => _openAuthed(context, Routes.gradeAnalysis),
                                ),
                              ),
                              horizontalSpace8,
                              Expanded(
                                child: HomeFeatureItemWidget(
                                  icon: Icons.workspace_premium_outlined,
                                  iconColor: ColorsManager.primaryColor,
                                  iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                                  title: appTranslation().get('document_type_certificates'),
                                  subtitle: appTranslation().get('document_type_certificates_subtitle'),
                                  isHighlighted: false,
                                  onTap: () => _openAuthed(context, Routes.thankYouCertificates),
                                ),
                              ),
                              horizontalSpace8,
                              Expanded(
                                child: HomeFeatureItemWidget(
                                  icon: Icons.table_chart_outlined,
                                  iconColor: ColorsManager.primaryColor,
                                  iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                                  title: appTranslation().get('document_type_class_sheet'),
                                  subtitle: appTranslation().get('document_type_class_sheet_subtitle'),
                                  isHighlighted: false,
                                  onTap: () => _openAuthed(context, Routes.classSheets),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      verticalSpace10,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: HomeFeatureItemWidget(
                                  icon: Icons.work_outline_rounded,
                                  iconColor: ColorsManager.primaryColor,
                                  iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                                  title: appTranslation().get('role_suites_title'),
                                  subtitle: appTranslation().get('document_type_role_suites_subtitle'),
                                  isHighlighted: false,
                                  onTap: () => _openAuthed(context, Routes.roleSuites),
                                ),
                              ),
                              horizontalSpace8,
                              Expanded(
                                child: HomeFeatureItemWidget(
                                  icon: Icons.summarize_outlined,
                                  iconColor: ColorsManager.primaryColor,
                                  iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                                  title: appTranslation().get('document_type_report'),
                                  subtitle: appTranslation().get('document_type_report_subtitle'),
                                  isHighlighted: false,
                                  onTap: () => _openAuthed(context, Routes.reportTools),
                                ),
                              ),
                              horizontalSpace8,
                              Expanded(
                                child: HomeFeatureItemWidget(
                                  icon: Icons.print_outlined,
                                  iconColor: ColorsManager.primaryColor,
                                  iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                                  title: appTranslation().get('prep_history_title'),
                                  subtitle: appTranslation().get('document_type_lesson_preparation_subtitle'),
                                  isHighlighted: false,
                                  onTap: () => _openAuthed(context, Routes.preparationHistory),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
