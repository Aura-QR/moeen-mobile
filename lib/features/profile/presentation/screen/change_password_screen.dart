import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/features/profile/presentation/cubit/change_password_cubit.dart';
import 'package:moean/features/profile/presentation/cubit/change_password_state.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChangePasswordCubit(),
      child: const _ChangePasswordScreenBody(),
    );
  }
}

class _ChangePasswordScreenBody extends StatefulWidget {
  const _ChangePasswordScreenBody();

  @override
  State<_ChangePasswordScreenBody> createState() => _ChangePasswordScreenBodyState();
}

class _ChangePasswordScreenBodyState extends State<_ChangePasswordScreenBody> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.surfacePrimary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: ColorsManager.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          appTranslation().get('change_password'),
          style: TextStylesManager.bold18.copyWith(
            color: ColorsManager.textPrimary,
          ),
        ),
      ),
      body: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  appTranslation().get('save_changes'),
                  style: TextStylesManager.medium14.copyWith(color: Colors.white),
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is ChangePasswordFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: TextStylesManager.medium14.copyWith(color: Colors.white),
                ),
                backgroundColor: ColorsManager.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_person_outlined,
                      size: 64,
                      color: ColorsManager.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    appTranslation().get('about_password'),
                    textAlign: TextAlign.center,
                    style: TextStylesManager.regular14.copyWith(
                      color: ColorsManager.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ColorsManager.surfacePrimary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ColorsManager.borderColor,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('current_password'),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _currentPasswordController,
                          hint: appTranslation().get('current_password'),
                          isPassword: !_isCurrentPasswordVisible,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isCurrentPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: ColorsManager.textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return appTranslation().get('password_required');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('new_password'),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _newPasswordController,
                          hint: appTranslation().get('new_password'),
                          isPassword: !_isNewPasswordVisible,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: ColorsManager.textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _isNewPasswordVisible = !_isNewPasswordVisible;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return appTranslation().get('password_required');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('confirm_new_password'),
                        const SizedBox(height: 8),
                        PrimaryTextField(
                          controller: _confirmPasswordController,
                          hint: appTranslation().get('confirm_new_password'),
                          isPassword: !_isConfirmPasswordVisible,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: ColorsManager.textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return appTranslation().get('confirm_password_required');
                            }
                            if (value != _newPasswordController.text) {
                              return appTranslation().get('passwords_not_match');
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  PrimaryElevatedButton(
                    text: appTranslation().get('save_changes'),
                    isLoading: state is ChangePasswordLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ChangePasswordCubit.get(context).changePassword(
                          currentPassword: _currentPasswordController.text,
                          password: _newPasswordController.text,
                          passwordConfirmation: _confirmPasswordController.text,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String key) {
    return Text(
      appTranslation().get(key),
      style: TextStylesManager.medium14.copyWith(
        color: ColorsManager.textPrimary,
      ),
    );
  }
}
