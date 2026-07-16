import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class BankInfoWidget extends StatelessWidget {
  final Map<String, dynamic> bankInfo;

  const BankInfoWidget({super.key, required this.bankInfo});

  @override
  Widget build(BuildContext context) {
    final bankName = bankInfo['bank_name'] as String? ?? '';
    final iban = bankInfo['iban'] as String? ?? '';
    final holder = bankInfo['account_holder'] as String? ?? '';
    final instructions = bankInfo['instructions'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                appTranslation().get('pay_bank_details'),
                style: TextStylesManager.bold16.copyWith(
                  color: ColorsManager.textPrimary,
                ),
              ),
              horizontalSpace8,
              Icon(
                Icons.account_balance_outlined,
                color: ColorsManager.secondaryColor,
                size: 20,
              ),
            ],
          ),
          verticalSpace4,
          Text(
            appTranslation().get('pay_upload_after_transfer'),
            style: TextStylesManager.regular12.copyWith(
              color: ColorsManager.secondaryText,
            ),
          ),
          verticalSpace16,
          _BankInfoRow(
            label: appTranslation().get('pay_bank_name'),
            value: bankName,
          ),
          verticalSpace10,
          _BankInfoRow(
            label: appTranslation().get('pay_account_holder'),
            value: holder,
          ),
          verticalSpace10,
          _IbanRow(iban: iban),
          if (instructions.isNotEmpty) ...[
            verticalSpace12,
            Text(
              instructions,
              style: TextStylesManager.regular13.copyWith(
                color: ColorsManager.secondaryText,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ],
      ),
    );
  }
}

class _BankInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _BankInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: TextStylesManager.bold14.copyWith(
            color: ColorsManager.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStylesManager.regular13.copyWith(
            color: ColorsManager.secondaryText,
          ),
        ),
      ],
    );
  }
}

class _IbanRow extends StatelessWidget {
  final String iban;

  const _IbanRow({required this.iban});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: iban));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  appTranslation().get('pay_iban_copied'),
                  textAlign: TextAlign.center,
                ),
                duration: const Duration(seconds: 2),
                backgroundColor: ColorsManager.primaryColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          child: Row(
            children: [
              Icon(
                Icons.copy_rounded,
                size: 16,
                color: ColorsManager.primaryColor,
              ),
              horizontalSpace4,
              Text(
                iban,
                style: TextStylesManager.bold13.copyWith(
                  color: ColorsManager.primaryColor,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        Text(
          'IBAN',
          style: TextStylesManager.regular13.copyWith(
            color: ColorsManager.secondaryText,
          ),
        ),
      ],
    );
  }
}
