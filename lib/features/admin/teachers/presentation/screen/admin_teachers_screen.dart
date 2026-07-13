import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/admin/teachers/presentation/cubit/admin_teachers_cubit.dart';
import 'package:moean/features/admin/teachers/presentation/cubit/admin_teachers_state.dart';
import 'package:moean/features/admin/teachers/presentation/widgets/admin_stats_cards_widget.dart';
import 'package:moean/features/admin/teachers/presentation/widgets/admin_teacher_action_dialogs.dart';
import 'package:moean/features/admin/teachers/presentation/widgets/admin_teachers_search_filter_widget.dart';
import 'package:moean/features/admin/teachers/presentation/widgets/admin_teachers_table_widget.dart';

class AdminTeachersScreen extends StatelessWidget {
  const AdminTeachersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminTeachersCubit()..getTeachers(),
      child: BlocConsumer<AdminTeachersCubit, AdminTeachersState>(
        listener: (context, state) {
          if (state is AdminTeacherActionSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is AdminTeacherPasswordResetSuccessState) {
            showDialog(
              context: context,
              builder: (ctx) {
                final passwordController = TextEditingController(text: state.plainPassword);
                return AlertDialog(
                  title:  Text(appTranslation().get('new_password')),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(appTranslation().get('about_password')),
                      verticalSpace12,
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: passwordController,
                              decoration:  InputDecoration(
                                labelText: appTranslation().get('password'),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          horizontalSpace8,
                          IconButton(
                            onPressed: () {
                              const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%&*';
                              final random = Random();
                              final newPassword = String.fromCharCodes(Iterable.generate(
                                  8, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
                              passwordController.text = newPassword;
                            },
                            icon: const Icon(Icons.autorenew),
                            tooltip: appTranslation().get('regenerate_password'),
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: passwordController.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(appTranslation().get('copy_success')), backgroundColor: Colors.green),
                              );
                            },
                            icon: const Icon(Icons.copy),
                            tooltip: appTranslation().get('copy_password'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child:  Text(appTranslation().get('close')),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (passwordController.text != state.plainPassword) {
                          AdminTeachersCubit.get(context).updateTeacher(
                            id: state.teacherId,
                            password: passwordController.text,
                          );
                        }
                        Navigator.pop(ctx);
                      },
                      child:  Text(appTranslation().get('save_changes')),
                    ),
                  ],
                );
              },
            );
          } else if (state is AdminTeacherActionErrorState || state is GetTeachersErrorState) {
            final msg = state is AdminTeacherActionErrorState 
                ? state.message 
                : (state as GetTeachersErrorState).message;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final cubit = AdminTeachersCubit.get(context);
          final scrollController = ScrollController();

          // Infinite scrolling
          scrollController.addListener(() {
            if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
              if (state is! GetTeachersLoadingState) {
                cubit.getTeachers(loadMore: true);
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
                  const Icon(Icons.shield_outlined, color: Colors.white),
                  horizontalSpace8,
                  Text(
                    appTranslation().get('admin_teachers_title'),
                    style: TextStylesManager.bold18.copyWith(color: Colors.white),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => cubit.getTeachers(),
                ),
              //  PrimaryElevatedButton(
              //     text: appTranslation().get('return_home'),
              //     onPressed: () {
              //         context.push(Routes.home);
              //     },
              //   ),
              //   horizontalSpace8,

               Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:   Colors.white,
                      foregroundColor: ColorsManager.primaryColor,
                    ),
                    onPressed: () {
                       context.push(Routes.home);
                    },
                    icon: const Icon(Icons.home),
                    label: Text(appTranslation().get('home'),
                    style: TextStylesManager.medium16
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
                    const AdminStatsCardsWidget(),
                    verticalSpace24,
                    const AdminTeachersSearchFilterWidget(),
                    verticalSpace24,
                     Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                       children: [
                        //  ElevatedButton.icon(
                        //    style: ElevatedButton.styleFrom(
                        //      backgroundColor:  ColorsManager.secondaryColor,
                        //      foregroundColor: Colors.white,
                        //    ),
                        //    onPressed: () => context.push(Routes.adminPayments),
                        //    icon: const Icon(Icons.payments_outlined),
                        //    label: Text(appTranslation().get('admin_payments_title') ?? 'Payments'),
                        //  ),
                        //  horizontalSpace8,
                         ElevatedButton.icon(
                           style: ElevatedButton.styleFrom(
                             backgroundColor:  ColorsManager.primaryColor,
                             foregroundColor: Colors.white,
                           ),
                           onPressed: () => showAddTeacherDialog(context),
                           icon: const Icon(Icons.add),
                           label: Text(appTranslation().get('admin_add_teacher')),
                         ),
                       ],
                     ),
                     verticalSpace16,
                    Expanded(
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                      child: state is GetTeachersLoadingState && cubit.teachersList.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : AdminTeachersTableWidget(
                              teachers: cubit.teachersList,
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
