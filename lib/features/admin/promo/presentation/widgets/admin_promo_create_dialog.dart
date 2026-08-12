import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
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
      'max_redemptions': int.tryParse(_maxUseCtrl.text),
      'max_redemptions_per_user': 1,
      'is_active': true,
      'user_target': _userTarget,
    });
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStylesManager.regular14.copyWith(
              color: ColorsManager.textSecondary,
            ),
          ),
          verticalSpace4,
        ],
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          decoration: InputDecoration(
            filled: true,
            fillColor: ColorsManager.surfacePrimary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: ColorsManager.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: ColorsManager.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: ColorsManager.themeActiveAccent),
            ),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appTranslation().get('admin_promo_create_title'),
                      style: TextStylesManager.bold18.copyWith(color: ColorsManager.primaryColor),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                verticalSpace20,
                
                // Code
                PrimaryTextField(
                  controller: _codeCtrl,
                  hint: appTranslation().get('admin_promo_form_code_hint'),
                  label: 'رمز الكود (Code)',
                  validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                ),
                verticalSpace12,
                
                // Name
                PrimaryTextField(
                  controller: _nameCtrl,
                  hint: 'مثال: خصم العودة للمدارس',
                  label: 'اسم الحملة',
                  validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                ),
                verticalSpace12,
                
                // Type
                _buildDropdown(
                  label: 'نوع الخصم',
                  value: _discountType,
                  items: const [
                    DropdownMenuItem(value: 'percentage', child: Text('نسبة مئوية (%)')),
                    DropdownMenuItem(value: 'fixed_amount', child: Text('مبلغ ثابت')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _discountType = val);
                  },
                ),
                verticalSpace12,
                
                // Value
                PrimaryTextField(
                  controller: _valueCtrl,
                  hint: '15',
                  label: 'قيمة الخصم',
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                ),
                verticalSpace12,

                // Target
                _buildDropdown(
                  label: 'المستهدفين',
                  value: _userTarget,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('الجميع', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: 'existing_users', child: Text('المستخدمين المشتركين فقط', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: 'new_users', child: Text('المستخدمين الجدد فقط', overflow: TextOverflow.ellipsis)),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _userTarget = val);
                  },
                ),
                verticalSpace12,
                
                // Max Use
                PrimaryTextField(
                  controller: _maxUseCtrl,
                  hint: 'مثال: 1000',
                  label: 'حد الاستخدام الأقصى (اختياري)',
                  keyboardType: TextInputType.number,
                ),
                verticalSpace24,

                // Action Buttons
                BlocBuilder<AdminPromoCubit, AdminPromoState>(
                  buildWhen: (_, s) =>
                      s is AdminPromoCreating || s is AdminPromoActionSuccess || s is AdminPromoActionError,
                  builder: (context, state) {
                    final isLoading = state is AdminPromoCreating;
                    return Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorsManager.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            onPressed: isLoading ? null : () => _submit(context),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text('حفظ', style: TextStylesManager.bold14),
                          ),
                        ),
                        horizontalSpace12,
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ColorsManager.textPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              side: BorderSide(color: ColorsManager.borderColor),
                            ),
                            onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                            child: Text('إلغاء', style: TextStylesManager.bold14),
                          ),
                        ),
                      ],
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
