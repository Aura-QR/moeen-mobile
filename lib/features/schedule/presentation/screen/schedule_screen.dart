import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:moean/core/utils/cubit/theme/theme_state.dart';
import 'package:moean/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:moean/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:moean/features/schedule/presentation/widgets/class_card.dart';
import 'package:moean/features/schedule/presentation/widgets/day_tabs_list.dart';
import 'package:moean/features/schedule/presentation/widgets/schedule_app_bar.dart';
import 'package:moean/features/schedule/presentation/widgets/status_strip.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/features/payment/presentation/widgets/trial_banner_widget.dart';
import 'package:moean/core/utils/constants/primary/upgrade_prompt_bottom_sheet.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScheduleCubit()..getSchedule(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocListener<ScheduleCubit, ScheduleState>(
            listener: (context, state) {
              if (state is SchedulePaymentRequired) {
                UpgradePromptBottomSheet.show(
                  context,
                  message: state.message,
                  isQuotaExceeded: state.code == 'quota_exceeded',
                );
              }
            },
            child: Scaffold(
            backgroundColor: ColorsManager.scheduleBackground,
            body: SafeArea(
              child: Column(
                children: [
                  const TrialBannerWidget(),
                  const ScheduleAppBar(),
                  verticalSpace16,
                  const StatusStrip(),
                  verticalSpace24,
                  Expanded(
                    child: BlocBuilder<ScheduleCubit, ScheduleState>(
                      buildWhen: (prev, curr) => curr != prev,
                      builder: (context, state) {
                        final loadedState =
                            state is ScheduleLoaded ? state : null;
                        final isEmpty = loadedState?.days.isEmpty ?? false;

                        return ConditionalBuilder(
                          loadingState: state is ScheduleLoading ||
                              state is ScheduleInitial,
                          errorState: state is ScheduleError,
                          emptyState: isEmpty,
                          errorBuilder: (_) => _ScheduleErrorView(
                            message: (state as ScheduleError).message,
                          ),
                          emptyBuilder: (_) => const _ScheduleEmptyView(),
                          successBuilder: (_) {
                            final loaded = loadedState!;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              child: Column(
                                children: [
                                  DayTabsList(
                                    days: loaded.days,
                                    selectedIndex: loaded.selectedDayIndex,
                                    onDaySelected: (index) =>
                                        ScheduleCubit.get(context)
                                            .selectDay(index),
                                  ),
                                  verticalSpace16,
                                  Row(
                                    children: [
                                      Text(
                                        appTranslation().get('class_count'),
                                        style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
                                      ),
                                      horizontalSpace8,
                                      Text(
                                        loaded.classes.where((c) => !c.id.startsWith('empty_')).isEmpty ?  '0': '${loaded.classes.where((c) => !c.id.startsWith('empty_')).length}',
                                        style: TextStylesManager.bold16.copyWith(color: ColorsManager.primaryColor),
                                      ),
                                      const Spacer(),
                                      PrimaryElevatedButton(
                                        text: appTranslation().get('refresh'),
                                        width: 120,
                                        height: 38,
                                        radius: 12,
                                        textStyle: TextStylesManager.bold12.copyWith(color: Colors.white),
                                        icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
                                        onPressed: () {
                                          ScheduleCubit.get(context).refreshSchedule();
                                        },
                                      ),
                                    ],
                                  ),
                                  verticalSpace16,
                                  Expanded(
                                    child: loaded.classes.isEmpty
                                        ?  _ScheduleEmptyView(message:  appTranslation().get('no_classes'))
                                        : ListView.builder(
                                            itemCount: loaded.classes.length,
                                            itemBuilder: (context, index) =>
                                                ClassCard(
                                              key: ValueKey(loaded.classes[index].id),
                                              classModel: loaded.classes[index],
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
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


class _ScheduleErrorView extends StatelessWidget {
  final String message;

  const _ScheduleErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: ColorsManager.secondaryText.withValues(alpha: 0.5),
            ),
            verticalSpace16,
            Text(
              appTranslation().get('schedule_error_title'),
              style: TextStylesManager.bold16
                  .copyWith(color: ColorsManager.mainText),
              textAlign: TextAlign.center,
            ),
            verticalSpace8,
            Text(
              message,
              style: TextStylesManager.regular12
                  .copyWith(color: ColorsManager.secondaryText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleEmptyView extends StatelessWidget {
  final String? message;
  const _ScheduleEmptyView({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: ColorsManager.primaryDark,
            ),
            verticalSpace16,
            Text(
              message ?? appTranslation().get('schedule_empty_title'),
              style: TextStylesManager.bold16
                  .copyWith(color: ColorsManager.mainText),
              textAlign: TextAlign.center,
            ),
            verticalSpace8,
          ],
        ),
      ),
    );
  }
}
