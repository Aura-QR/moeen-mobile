import 'package:flutter/material.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:moean/features/profile/presentation/cubit/profile_state.dart';
import 'package:moean/features/weekly_plan/data/weekly_plan_service.dart';

/// Lets the teacher pick which week to export as the ministry's weekly plan.
///
/// Only the weeks around this one are offered: they are the ones the
/// Madrasati screen saves as the teacher works, so they have data.
Future<void> showWeeklyPlanSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: ColorsManager.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const Directionality(
      textDirection: TextDirection.rtl,
      child: _WeeklyPlanSheet(),
    ),
  );
}

class _WeeklyPlanSheet extends StatefulWidget {
  const _WeeklyPlanSheet();

  @override
  State<_WeeklyPlanSheet> createState() => _WeeklyPlanSheetState();
}

class _WeeklyPlanSheetState extends State<_WeeklyPlanSheet> {
  static const _weeks = <({int offset, String label})>[
    (offset: -1, label: 'الأسبوع السابق'),
    (offset: 0, label: 'الأسبوع الحالي'),
    (offset: 1, label: 'الأسبوع القادم'),
  ];

  int? _busyOffset;

  Future<void> _export(int offset) async {
    if (_busyOffset != null) return;
    setState(() => _busyOffset = offset);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final profileState = sl<ProfileCubit>().state;
      await WeeklyPlanService.exportAndShare(
        WeeklyPlanService.sundayOf(offset),
        teacherName: profileState is ProfileLoadedState ? profileState.profile.user.name : null,
      );
      navigator.pop();
    } catch (error) {
      messenger.showSnackBar(SnackBar(
        content: Text(
          error is WeeklyPlanException ? error.message : 'تعذر إنشاء ملف الخطة. حاول مرة أخرى.',
          textDirection: TextDirection.rtl,
        ),
      ));
    } finally {
      if (mounted) setState(() => _busyOffset = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'خطة الأسبوع',
              textAlign: TextAlign.center,
              style: TextStylesManager.bold20.copyWith(color: ColorsManager.themeActiveAccent),
            ),
            const SizedBox(height: 6),
            Text(
              'ملف Word بنموذج الوزارة، مملوء بالحصص التي حضّرتها في الأسبوع.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: ColorsManager.themeDarkPrimary.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 16),
            for (final week in _weeks) ...[
              _WeekTile(
                label: week.label,
                period: WeeklyPlanService.hijriPeriod(WeeklyPlanService.sundayOf(week.offset)),
                busy: _busyOffset == week.offset,
                enabled: _busyOffset == null,
                onTap: () => _export(week.offset),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _WeekTile extends StatelessWidget {
  const _WeekTile({
    required this.label,
    required this.period,
    required this.busy,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String period;
  final bool busy;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorsManager.themeActiveAccent.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.description_outlined, color: ColorsManager.themeActiveAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      'الفترة $period',
                      style: TextStyle(fontSize: 12, color: ColorsManager.themeDarkPrimary.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              if (busy)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              else
                Icon(Icons.download_rounded, color: ColorsManager.themeActiveAccent),
            ],
          ),
        ),
      ),
    );
  }
}
