import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:moean/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:moean/features/schedule/presentation/widgets/class_card.dart';
import 'package:moean/features/schedule/presentation/widgets/day_tabs_list.dart';
import 'package:moean/features/schedule/presentation/widgets/schedule_app_bar.dart';
import 'package:moean/features/schedule/presentation/widgets/status_strip.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScheduleCubit()..getSchedule(),
      child: Scaffold(
        backgroundColor: ColorsManager.scheduleBackground,
        body: SafeArea(
          child: Column(
            children: [
              const ScheduleAppBar(),
              verticalSpace16,
              const StatusStrip(),
              verticalSpace24,
              Expanded(
                child: BlocBuilder<ScheduleCubit, ScheduleState>(
                  builder: (context, state) {
                    return ConditionalBuilder(
                      loadingState: state is ScheduleLoading || state is ScheduleInitial,
                      successBuilder: (context) {
                        final loadedState = state as ScheduleLoaded;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              DayTabsList(
                                days: loadedState.days,
                                selectedIndex: loadedState.selectedDayIndex,
                                onDaySelected: (index) {
                                  ScheduleCubit.get(context).selectDay(index);
                                },
                              ),
                              verticalSpace24,
                              Expanded(
                                child: ListView.builder(
                                  itemCount: loadedState.classes.length,
                                  itemBuilder: (context, index) {
                                    return ClassCard(
                                      classModel: loadedState.classes[index],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
