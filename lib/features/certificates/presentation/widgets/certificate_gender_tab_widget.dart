import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/certificates/presentation/cubit/certificate_cubit.dart';

class CertificateGenderTabWidget extends StatelessWidget {
  const CertificateGenderTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CertificateCubit, CertificateState>(
      buildWhen: (prev, curr) => curr is CertificateGenderChanged,
      builder: (context, state) {
        final cubit = CertificateCubit.get(context);
        final isMale = cubit.selectedGender == 'male';
        return Container(
          decoration: BoxDecoration(
            color: ColorsManager.surfacePrimary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorsManager.borderColor),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              _TabItem(
                label: appTranslation().get('cert_student_type_female'),
                isSelected: !isMale,
                onTap: () => cubit.selectGender('female'),
              ),
              horizontalSpace8,
              _TabItem(
                label: appTranslation().get('cert_student_type_male'),
                isSelected: isMale,
                onTap: () => cubit.selectGender('male'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? ColorsManager.primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStylesManager.bold14.copyWith(
              color: isSelected
                  ? ColorsManager.white
                  : ColorsManager.secondaryText,
            ),
          ),
        ),
      ),
    );
  }
}
