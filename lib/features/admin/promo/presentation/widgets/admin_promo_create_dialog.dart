import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/admin/promo/presentation/cubit/admin_promo_cubit.dart';
import 'package:moean/features/admin/promo/presentation/cubit/admin_promo_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminPromoCreateDialog extends StatefulWidget {
  const AdminPromoCreateDialog({super.key});

  @override
  State<AdminPromoCreateDialog> createState() => _AdminPromoCreateDialogState();
}

class _AdminPromoCreateDialogState extends State<AdminPromoCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _valueCtrl;
  late final TextEditingController _maxUseCtrl;
  String _discountType = 'percentage';
  String _userTarget = 'all';

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController();
    _nameCtrl = TextEditingController();
    _valueCtrl = TextEditingController();
    _maxUseCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _valueCtrl.dispose();
    _maxUseCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    AdminPromoCubit.get(context).createPromoCode({
      'code': _codeCtrl.text.trim().toUpperCase(),
      'name': _nameCtrl.text.trim(),
      'discount_type': _discountType,
      'discount_value': double.tryParse(_valueCtrl.text) ?? 0,
      'max_redemptions': int.tryParse(_maxUseCtrl.text) ?? 100,
      'max_redemptions_per_user': 1,
      'is_active': true,
      'user_target': _userTarget,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: ColorsManager.surfacePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  appTranslation().get('admin_promo_create_title'),
                  style: TextStylesManager.bold18
                      .copyWith(color: ColorsManager.primaryColor),
                ),
                verticalSpace20,
                PrimaryTextField(
                  controller: _codeCtrl,
                  hint: appTranslation().get('admin_promo_form_code_hint'),
                  label: appTranslation().get('admin_promo_form_code'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'مطلوب' : null,
                ),
                verticalSpace12,
                PrimaryTextField(
                  controller: _nameCtrl,
                  hint: appTranslation().get('admin_promo_form_name_hint'),
                  label: appTranslation().get('admin_promo_form_name'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'مطلوب' : null,
                ),
                verticalSpace12,
                // Discount type selector
                Row(
                  children: [
                    Expanded(
                      child: _TypeButton(
                        label: appTranslation().get('admin_promo_type_percentage'),
                        isSelected: _discountType == 'percentage',
                        onTap: () => setState(() => _discountType = 'percentage'),
                      ),
                    ),
                    horizontalSpace8,
                    Expanded(
                      child: _TypeButton(
                        label: appTranslation().get('admin_promo_type_fixed'),
                        isSelected: _discountType == 'fixed_amount',
                        onTap: () =>
                            setState(() => _discountType = 'fixed_amount'),
                      ),
                    ),
                  ],
                ),
                verticalSpace12,
                PrimaryTextField(
                  controller: _valueCtrl,
                  hint: appTranslation().get('admin_promo_form_value_hint'),
                  label: appTranslation().get('admin_promo_form_value'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'مطلوب' : null,
                ),
                verticalSpace12,
                PrimaryTextField(
                  controller: _maxUseCtrl,
                  hint: '100',
                  label: appTranslation().get('admin_promo_form_max_use'),
                  keyboardType: TextInputType.number,
                ),
                verticalSpace20,
                BlocBuilder<AdminPromoCubit, AdminPromoState>(
                  buildWhen: (_, s) =>
                      s is AdminPromoCreating || s is AdminPromoActionSuccess || s is AdminPromoActionError,
                  builder: (context, state) {
                    final isLoading = state is AdminPromoCreating;
                    return PrimaryElevatedButton(
                      text: appTranslation().get('admin_promo_form_submit'),
                      isLoading: isLoading,
                      onPressed: isLoading ? null : () => _submit(context),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorsManager.primaryColor
              : ColorsManager.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? ColorsManager.primaryColor
                : ColorsManager.borderColor,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStylesManager.medium12.copyWith(
              color: isSelected ? Colors.white : ColorsManager.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
