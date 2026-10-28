import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class TahsiliSolutionTile extends StatefulWidget {
  final String solution;

  const TahsiliSolutionTile({
    super.key,
    required this.solution,
  });

  @override
  State<TahsiliSolutionTile> createState() => _TahsiliSolutionTileState();
}

class _TahsiliSolutionTileState extends State<TahsiliSolutionTile> {
  bool _isExpanded = false;

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.solution.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ColorsManager.borderLightGray,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 18,
                    color: ColorsManager.primaryColor,
                  ),
                  horizontalSpace6,
                  Expanded(
                    child: Text(
                      appTranslation().get('tahsili_solution_method'),
                      style: TextStylesManager.bold12.copyWith(
                        color: ColorsManager.primaryColor,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: ColorsManager.secondaryText,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            Divider(height: 1, color: ColorsManager.borderLightGray),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                widget.solution.trim(),
                style: TextStylesManager.regular12.copyWith(
                  color: ColorsManager.mainText,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
