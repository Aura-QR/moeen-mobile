import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';

/// The rounded, bordered expandable card used across the editor.
class PortfolioExpandableCardWidget extends StatelessWidget {
  final Widget title;
  final Widget? leading;
  final Widget? subtitle;
  final List<Widget> children;
  final bool initiallyExpanded;

  const PortfolioExpandableCardWidget({
    super.key,
    required this.title,
    required this.children,
    this.leading,
    this.subtitle,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));
    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: ExpansionTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        initiallyExpanded: initiallyExpanded,
        shape: shape,
        collapsedShape: shape,
        iconColor: ColorsManager.primaryColor,
        collapsedIconColor: ColorsManager.secondaryText,
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
