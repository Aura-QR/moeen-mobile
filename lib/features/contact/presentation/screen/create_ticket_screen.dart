import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/contact/presentation/cubit/contact_cubit.dart';
import 'package:moean/features/contact/presentation/cubit/contact_state.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    ContactCubit.get(context).getContactTypes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContactCubit, ContactState>(
      listener: (context, state) {
        if (state is ContactSubmitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message, style: TextStylesManager.bold14)),
          );
          context.pop();
        } else if (state is ContactSubmitError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error, style: TextStylesManager.bold14)),
          );
        }
      },
      builder: (context, state) {
        final cubit = ContactCubit.get(context);
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: ColorsManager.background,
            appBar:
            //  AppBar(
            //   backgroundColor: ColorsManager.background,
            //   elevation: 0,
            //   centerTitle: true,
            //   title: Text(
            //     appTranslation().get('new_request'),
            //     style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
            //   ),
            //   leading: IconButton(
            //     icon: Icon(Icons.arrow_forward, color: ColorsManager.mainText),
            //     onPressed: () => context.pop(),
            //   ),
            // ),
            AppBar(
          backgroundColor: ColorsManager.background,
          elevation: 0,
          centerTitle: true,
         title: Text(
                appTranslation().get('new_request'),
                style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
              ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: ColorsManager.mainText,
              size: 20,
            ),
          ),
        ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CreateTicketInfoWidget(),
                    verticalSpace24,
                    Text(
                      appTranslation().get('name'),
                      style: TextStylesManager.bold14,
                    ),
                    verticalSpace8,
                    PrimaryTextField(
                      controller: _nameController,
                      hint: appTranslation().get('name'),
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return appTranslation().get('field_required');
                        }
                        return null;
                      },
                    ),
                    verticalSpace16,
                    Text(
                      appTranslation().get('email'),
                      style: TextStylesManager.bold14,
                    ),
                    verticalSpace8,
                    PrimaryTextField(
                      controller: _emailController,
                      hint: appTranslation().get('email'),
                      prefixIcon: const Icon(Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return appTranslation().get('field_required');
                        }
                        return null;
                      },
                    ),
                    verticalSpace16,
                    Text(
                      appTranslation().get('phone'),
                      style: TextStylesManager.bold14,
                    ),
                    verticalSpace8,
                    PrimaryTextField(
                      controller: _phoneController,
                      hint: '966 5X XXX XXXX+',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      keyboardType: TextInputType.phone,
                    ),
                    verticalSpace16,
                    Text(
                      appTranslation().get('request_type'),
                      style: TextStylesManager.bold14,
                    ),
                    verticalSpace8,
                    CreateTicketTypesDropdownWidget(
                      cubit: cubit,
                      state: state,
                      selectedType: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                        });
                      },
                    ),
                    verticalSpace16,
                    Text(
                      appTranslation().get('message'),
                      style: TextStylesManager.bold14,
                    ),
                    verticalSpace8,
                    PrimaryTextField(
                      controller: _messageController,
                      hint: appTranslation().get('write_details_here'),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return appTranslation().get('field_required');
                        }
                        return null;
                      },
                    ),
                    verticalSpace32,
                    ConditionalBuilder(
                      loadingState: state is ContactSubmitLoading,
                      successBuilder: (context) => PrimaryElevatedButton(
                        text: appTranslation().get('send_request'),
                        icon: const Icon(Icons.send_outlined, color: ColorsManager.white, size: 20),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (_selectedType == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(appTranslation().get('please_select_request_type'))),
                              );
                              return;
                            }
                            cubit.submitContactRequest(
                              name: _nameController.text,
                              email: _emailController.text,
                              phone: _phoneController.text,
                              type: _selectedType!,
                              message: _messageController.text,
                            );
                          }
                        },
                      ),
                    ),
                    verticalSpace32,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}

class CreateTicketInfoWidget extends StatelessWidget {
  const CreateTicketInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.statusSuccess.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: ColorsManager.statusWarning),
              horizontalSpace8,
              Text(
                appTranslation().get('before_sending_request'),
                style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
              ),
            ],
          ),
          verticalSpace12,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline, color: ColorsManager.statusSuccess, size: 18),
              horizontalSpace8,
              Expanded(
                child: Text(
                  appTranslation().get('help_us_help_you'),
                  style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                ),
              ),
            ],
          ),
          verticalSpace8,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline, color: ColorsManager.statusSuccess, size: 18),
              horizontalSpace8,
              Expanded(
                child: Text(
                  appTranslation().get('where_error_happened'),
                  style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CreateTicketTypesDropdownWidget extends StatelessWidget {
  final ContactCubit cubit;
  final ContactState state;
  final String? selectedType;
  final ValueChanged<String?> onChanged;

  const CreateTicketTypesDropdownWidget({
    super.key,
    required this.cubit,
    required this.state,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (state is ContactTypesLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsManager.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedType,
          isExpanded: true,
          hint: Text(
            appTranslation().get('select_request_type'),
            style: TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText),
          ),
          items: cubit.types.map<DropdownMenuItem<String>>((dynamic type) {
            return DropdownMenuItem<String>(
              value: type['value'],
              child: Text(type['label'], style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

