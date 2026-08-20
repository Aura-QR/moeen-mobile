import 'package:flutter/services.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:moean/core/utils/cubit/theme/theme_state.dart';

class PrimaryTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String hint;
  final bool isPassword;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool enabled;
  final Color? fillColor;
  final Color? textColor;
  final Color? hintColor;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final int? maxLength;

  const PrimaryTextField({
    super.key,
    required this.controller,
    this.label,
    required this.hint,
    this.isPassword = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.fillColor,
    this.textColor,
    this.hintColor,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.focusNode,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.inputFormatters,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.maxLength,
  });

  @override
  State<PrimaryTextField> createState() => _PrimaryTextFieldState();
}

class _PrimaryTextFieldState extends State<PrimaryTextField> {
  late FocusNode _focusNode;
  late bool _ownsFocusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant PrimaryTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_onFocusChange);
      if (_ownsFocusNode) {
        _focusNode.dispose();
      }

      _focusNode = widget.focusNode ?? FocusNode();
      _ownsFocusNode = widget.focusNode == null;
      _focusNode.addListener(_onFocusChange);
    }
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return BlocBuilder<ThemeCubit, ThemeState>(
    builder: (context, state) {
      return TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.isPassword,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        inputFormatters: widget.inputFormatters,
        textDirection: widget.textDirection,
        textAlign: widget.textAlign,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        style: TextStylesManager.regular14.copyWith(
          color: widget.textColor ?? ColorsManager.textPrimary,
        ),
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onFieldSubmitted,
        decoration: InputDecoration(
          // تفعيل الخلفية هنا بدلاً من الـ Container
          filled: true,
          fillColor: widget.fillColor ?? ColorsManager.surfacePrimary,
          counterText: widget.maxLength != null ? '' : null,
          labelText: widget.label,
          labelStyle: TextStylesManager.regular14.copyWith(
            color: widget.textColor ?? ColorsManager.textSecondary,
          ),
          hintText: widget.hint,
          hintStyle: TextStylesManager.regular14.copyWith(
            color: widget.hintColor ?? ColorsManager.textSecondary.withValues(alpha: 0.85),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          prefixIcon: widget.prefixIcon,
          prefixIconConstraints: widget.prefixIconConstraints,
          prefixIconColor: widget.textColor ?? ColorsManager.textSecondary,
          suffixIcon: widget.suffixIcon,
          suffixIconConstraints: widget.suffixIconConstraints,
          suffixIconColor: widget.textColor ?? ColorsManager.textSecondary,
          
          // هنا نقوم بتعريف الحدود لكل الحالات وسيقوم فلاتر بمعالجة حجم الخطأ تلقائياً
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Colors.red), // لون الحقل عند الخطأ
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      );
    },
  );
}
}
