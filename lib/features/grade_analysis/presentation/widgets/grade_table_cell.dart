import 'package:flutter/material.dart';

/// One cell of the comparison table.
class GradeTableCell extends StatelessWidget {
  final String text;
  final TextStyle style;

  const GradeTableCell(this.text, {super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(text, style: style),
    );
  }
}
