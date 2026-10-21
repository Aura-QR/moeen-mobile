import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class PortfolioSignatureRowWidget extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController nameController;
  final VoidCallback onRemove;

  const PortfolioSignatureRowWidget({
    super.key,
    required this.titleController,
    required this.nameController,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: PrimaryTextField(
              controller: titleController,
              hint: appTranslation().get('portfolio_signature_title'),
            ),
          ),
          horizontalSpace8,
          Expanded(
            child: PrimaryTextField(
              controller: nameController,
              hint: appTranslation().get('portfolio_signature_name'),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.remove_circle_outline_rounded, color: ColorsManager.errorColor),
          ),
        ],
      ),
    );
  }
}
