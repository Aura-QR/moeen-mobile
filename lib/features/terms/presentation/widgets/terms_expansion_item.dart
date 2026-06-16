import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class TermsExpansionItem extends StatefulWidget {
  final String title;
  final String content;
  final IconData icon;
  final bool isExpandedInitially;

  const TermsExpansionItem({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    this.isExpandedInitially = false,
  });

  @override
  State<TermsExpansionItem> createState() => _TermsExpansionItemState();
}

class _TermsExpansionItemState extends State<TermsExpansionItem> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpandedInitially;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded
              ? ColorsManager.primaryColor
              : ColorsManager.borderColor.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _isExpanded
                          ? ColorsManager.primaryColor.withValues(alpha: 0.1)
                          : ColorsManager.textSecondary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      color: _isExpanded
                          ? ColorsManager.primaryColor
                          : ColorsManager.textSecondary,
                      size: 20,
                    ),
                  ),
                  horizontalSpace12,
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStylesManager.bold16.copyWith(
                        color: _isExpanded
                            ? ColorsManager.primaryColor
                            : ColorsManager.textPrimary,
                      ),
                    ),
                  ),
               
                ],
              ),
            ),
          ),
          ClipRect(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.center,
              heightFactor: _isExpanded ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Column(
                  children: [
                    Divider(
                      color: ColorsManager.borderColor.withValues(alpha: 0.1),
                    ),
                    verticalSpace8,
                    Text(
                      widget.content,
                      style: TextStylesManager.regular14.copyWith(
                        color: ColorsManager.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
