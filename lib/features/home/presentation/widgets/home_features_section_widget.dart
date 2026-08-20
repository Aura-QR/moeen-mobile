import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:moean/core/utils/cubit/theme/theme_state.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/features/home/presentation/cubit/home_cubit.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/home/presentation/widgets/home_action_chip_widget.dart';
import 'package:moean/features/home/presentation/widgets/home_feature_item_widget.dart';

class HomeFeaturesSectionWidget extends StatefulWidget {
  const HomeFeaturesSectionWidget({super.key});

  @override
  State<HomeFeaturesSectionWidget> createState() => _HomeFeaturesSectionWidgetState();
}

class _HomeFeaturesSectionWidgetState extends State<HomeFeaturesSectionWidget> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
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
                builder: (context, state) {
                  final isAdmin = context.read<HomeCubit>().isAdmin;
                  final isLoadingRole = context.read<HomeCubit>().isLoadingRole;
                  
                  return AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: ColorsManager.primaryColor.withValues(alpha: 0.2 + (_animation.value * 0.2)),
                              blurRadius: 10 + (_animation.value * 5),
                              spreadRadius: _animation.value * 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            if (token != null && token!.isNotEmpty) {
                              if (isAdmin) {
                                context.push(Routes.adminTeachers);
                              } else {
                                context.push(Routes.choseapp);
                              }
                            } else {
                              context.push(Routes.login);
                            }
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 22),
                            decoration: BoxDecoration(
                              color: ColorsManager.primaryColor,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: _animation.value * 0.3),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isLoadingRole)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: ColorsManager.white,
                                    ),
                                  )
                                else
                                  Text(
                                    isAdmin 
                                        ?  appTranslation().get('admin_dashboard')
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
            builder: (context, state) {
              final isAdmin = context.read<HomeCubit>().isAdmin;
              if (isAdmin) return const SizedBox.shrink();
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: PrimaryTextField(
                      controller: TextEditingController(),
                      hint: appTranslation().get('search_title'),
                      readOnly: true,
                      prefixIcon: Icon(Icons.search_rounded, color: ColorsManager.textSecondary),
                      onTap: () {
                        if (token != null && token!.isNotEmpty) {
                          context.push(Routes.search);
                        } else {
                          context.push(Routes.login);
                        }
                      },
                    ),
                  ),
                  verticalSpace24,
                ],
              );
            },
          ),
          // Action Chips Row
          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final isAdmin = context.read<HomeCubit>().isAdmin;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    // Search chip — visible for all users
                    // HomeActionChipWidget(
                    //   icon: Icons.search_rounded,
                    //   title: appTranslation().get('search_title'),
                    //   onTap: () => context.push(Routes.search),
                    // ),
                    //  horizontalSpace12,
                     
                     if (!isAdmin) ...[
                      HomeActionChipWidget(
                        icon: Icons.co_present_rounded,
                        title: appTranslation().get('presentations_title'),
                        onTap: () {
                          if (token != null && token!.isNotEmpty) {
                            context.push(Routes.presentations);
                          } else {
                            context.push(Routes.login);
                          }
                        },
                      ),
                      horizontalSpace12,
                    ],
                    if (!isAdmin) ...[
                      HomeActionChipWidget(
                        icon: Icons.monitor,
                        title: appTranslation().get('home_reports'),
                        onTap: () {
                          if (token != null && token!.isNotEmpty) {
                            context.push(Routes.reports);
                          } else {
                            context.push(Routes.login);
                          }
                        },
                      ),
                      horizontalSpace12,
                    ],
                    HomeActionChipWidget(
                      icon: isAdmin ? Icons.assignment_turned_in_outlined : Icons.verified_outlined,
                      title: isAdmin ? "مراجعة الأسئلة" : appTranslation().get('my_exam'),
                      onTap: () {
                        if (token != null && token!.isNotEmpty) {
                          if (isAdmin) {
                            context.push(Routes.adminExams);
                          } else {
                            context.push(Routes.examGenerationInfo);
                          }
                        } else {
                          context.push(Routes.login);
                        }
                      },
                    ),
                    if (isAdmin) ...[
                      horizontalSpace12,
                      HomeActionChipWidget(
                        icon: Icons.check_circle_outline,
                        title: "المدفوعات",
                        onTap: () {
                          if (token != null && token!.isNotEmpty) {
                            context.push(Routes.adminPayments);
                          } else {
                            context.push(Routes.login);
                          }
                        },
                      ),
                      horizontalSpace12,
                      HomeActionChipWidget(
                        icon: Icons.verified_user_outlined,
                        title: "تذاكر التواصل",
                        onTap: () {
                          if (token != null && token!.isNotEmpty) {
                            context.push(Routes.adminContact);
                          } else {
                            context.push(Routes.login);
                          }
                        },
                      ),
                      horizontalSpace12,
                      HomeActionChipWidget(
                        icon: Icons.discount_outlined,
                        title: "أكواد الخصم",
                        onTap: () {
                          if (token != null && token!.isNotEmpty) {
                            context.push(Routes.adminPromo);
                          } else {
                            context.push(Routes.login);
                          }
                        },
                      ),
                    ],
                    if (!isAdmin) ...[
                      horizontalSpace12,
                      HomeActionChipWidget(
                        icon: Icons.description_outlined,
                        title: "الاختبارات السابقه",
                        
                        //appTranslation().get('home_tests'),
                        onTap: () {
                          if (token != null && token!.isNotEmpty) {
                            context.push(Routes.myExams);
                          } else {
                            context.push(Routes.login);
                          }
                        },
                      ),
                     
                      horizontalSpace12,

                       HomeActionChipWidget(
                        icon: Icons.workspace_premium_rounded,
                        title: appTranslation().get('certificates'),
                        onTap: () {
                          if (token != null && token!.isNotEmpty) {
                            context.push(Routes.certificates);
                          } else {
                            context.push(Routes.login);
                          }
                        },
                      ),
                      horizontalSpace12,
                      HomeActionChipWidget(
                        icon: Icons.people_alt_outlined,
                        title: appTranslation().get('referral_chip_label'),
                        onTap: () {
                          if (token != null && token!.isNotEmpty) {
                            context.push(Routes.referral);
                          } else {
                            context.push(Routes.login);
                          }
                        },
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
                      onTap: () {
                        setState(() {
                          _selectedFeatureIndex = 0;
                        });
                      },
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
                      onTap: () {
                        setState(() {
                          _selectedFeatureIndex = 1;
                        });
                      },
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
                      onTap: () {
                        setState(() {
                          _selectedFeatureIndex = 2;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}
