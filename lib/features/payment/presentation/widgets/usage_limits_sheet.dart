import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/features/payment/data/models/subscription_current_model.dart';

/// What is left of each tool's daily and monthly limit
/// (`usage.limits` from /subscription/current), as a bottom sheet.
class UsageLimitsSheet extends StatefulWidget {
  final List<UsageLimitModel> limits;

  const UsageLimitsSheet({super.key, required this.limits});

  static Future<void> show(BuildContext context, List<UsageLimitModel> limits) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UsageLimitsSheet(limits: limits),
    );
  }

  @override
  State<UsageLimitsSheet> createState() => _UsageLimitsSheetState();
}

class _UsageLimitsSheetState extends State<UsageLimitsSheet> {
  bool _showOthers = false;

  @override
  Widget build(BuildContext context) {
    // A tool with no limit in either period (a team account) is left out.
    final tools = widget.limits.where((t) => t.daily.limit != null || t.monthly.limit != null).toList();
    // Tools the teacher used this month come first; the rest wait behind a toggle.
    final used = tools.where((t) => t.daily.used > 0 || t.monthly.used > 0).toList();
    final others = tools.where((t) => t.daily.used == 0 && t.monthly.used == 0).toList();
    final secondary = ColorsManager.isDark ? ColorsManager.textPrimaryDark : const Color(0xFF475569);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          color: ColorsManager.isDark ? const Color(0xFF0C2923) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorsManager.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.speed_outlined, color: Color(0xFF0E7A5E), size: 20),
                  const SizedBox(width: 8),
                  Text('حدود الاستخدام', style: TextStylesManager.bold16.copyWith(color: ColorsManager.textPrimary)),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: tools.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'لا توجد حدود على حسابك.',
                          textAlign: TextAlign.center,
                          style: TextStylesManager.bold13.copyWith(color: const Color(0xFF0E7A5E)),
                        ),
                      )
                    : ListView(
                        shrinkWrap: true,
                        children: [
                          if (used.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'لم تستخدم أي أداة بعد.\nستظهر هنا حدود كل أداة عند استخدامها.',
                                textAlign: TextAlign.center,
                                style: TextStylesManager.bold12.copyWith(color: secondary),
                              ),
                            ),
                          for (final tool in used) ...[
                            _ToolCard(tool: tool, secondary: secondary),
                            const SizedBox(height: 10),
                          ],
                          if (others.isNotEmpty)
                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => setState(() => _showOthers = !_showOthers),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: ColorsManager.borderColor),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${used.isEmpty ? 'عرض كل الحدود' : 'أدوات أخرى'} (${others.length})',
                                        style: TextStylesManager.bold13.copyWith(color: const Color(0xFF0E7A5E)),
                                      ),
                                    ),
                                    Icon(
                                      _showOthers ? Icons.expand_less : Icons.expand_more,
                                      color: const Color(0xFF0E7A5E),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (_showOthers)
                            for (final tool in others) ...[
                              const SizedBox(height: 10),
                              _ToolCard(tool: tool, secondary: secondary),
                            ],
                        ],
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                'تتجدد الحدود اليومية الساعة 3 فجرًا بتوقيت السعودية، والشهرية أول كل شهر. المحاولة التي تفشل لا تُحسب عليك.',
                style: TextStylesManager.regular12.copyWith(color: secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final UsageLimitModel tool;
  final Color secondary;

  const _ToolCard({required this.tool, required this.secondary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsManager.isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF6FBF9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(tool.label, style: TextStylesManager.bold13.copyWith(color: ColorsManager.textPrimary)),
          const SizedBox(height: 8),
          _PeriodRow(title: 'اليوم', period: tool.daily, secondary: secondary),
          const SizedBox(height: 8),
          _PeriodRow(title: 'هذا الشهر', period: tool.monthly, secondary: secondary),
        ],
      ),
    );
  }
}

class _PeriodRow extends StatelessWidget {
  final String title;
  final UsageLimitPeriod period;
  final Color secondary;

  const _PeriodRow({required this.title, required this.period, required this.secondary});

  @override
  Widget build(BuildContext context) {
    final limit = period.limit;
    final style = TextStylesManager.bold12.copyWith(color: secondary);
    if (limit == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(title, style: style), Text('غير محدود', style: style)],
      );
    }

    final share = limit > 0 ? (period.used / limit).clamp(0.0, 1.0) : 1.0;
    final color = share >= 1
        ? const Color(0xFFDC2626)
        : share >= 0.8
            ? const Color(0xFFD97706)
            : const Color(0xFF0E7A5E);
    final remaining = period.remaining ?? (limit - period.used).clamp(0, limit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: style),
            Text('متبقٍ $remaining من $limit', style: style.copyWith(color: ColorsManager.textPrimary)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: share.toDouble(),
            minHeight: 6,
            color: color,
            backgroundColor: ColorsManager.isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE3F1EC),
          ),
        ),
      ],
    );
  }
}
