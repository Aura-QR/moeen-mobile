import 'package:flutter/material.dart';

/// Distinct icon per school role key in «حقائب الأدوار».
IconData roleSuiteIcon(String key) => switch (key) {
      'activity_leader' => Icons.emoji_events_outlined,
      'health_guide' => Icons.health_and_safety_outlined,
      'student_counsellor' || 'student_counselor' => Icons.psychology_outlined,
      'vice_principal' || 'deputy' => Icons.manage_accounts_outlined,
      'principal' => Icons.account_balance_outlined,
      _ => Icons.work_outline_rounded,
    };
