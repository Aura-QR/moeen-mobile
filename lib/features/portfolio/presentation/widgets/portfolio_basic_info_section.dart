import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/portfolio/data/models/portfolio_model.dart';
import 'package:moean/features/portfolio/presentation/cubit/portfolio_editor_cubit.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_expandable_card_widget.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_role_dropdown_widget.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_signature_row_widget.dart';

/// «البيانات الأساسية»: role, the prefilled cover fields and signatures.
/// The controllers are local form state; saving goes through the cubit.
class PortfolioBasicInfoSection extends StatefulWidget {
  final PortfolioProfileModel profile;

  const PortfolioBasicInfoSection({super.key, required this.profile});

  @override
  State<PortfolioBasicInfoSection> createState() => _PortfolioBasicInfoSectionState();
}

class _PortfolioBasicInfoSectionState extends State<PortfolioBasicInfoSection> {
  late final Map<String, TextEditingController> _fields;
  late final List<(TextEditingController, TextEditingController)> _signatures;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _fields = {
      'portfolio_field_name': TextEditingController(text: p.name),
      'portfolio_field_specialty': TextEditingController(text: p.specialty),
      'portfolio_field_stage': TextEditingController(text: p.stage),
      'portfolio_field_school': TextEditingController(text: p.schoolName),
      'portfolio_field_year': TextEditingController(text: p.academicYear),
      'portfolio_field_phone': TextEditingController(text: p.phone),
      'portfolio_field_email': TextEditingController(text: p.email),
    };
    _signatures = [
      for (final s in p.signatures) (TextEditingController(text: s.title), TextEditingController(text: s.name)),
    ];
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    for (final (title, name) in _signatures) {
      title.dispose();
      name.dispose();
    }
    super.dispose();
  }

  void _addSignature() => setState(() => _signatures.add((TextEditingController(), TextEditingController())));

  void _removeSignature(int index) {
    final (title, name) = _signatures.removeAt(index);
    setState(() {});
    title.dispose();
    name.dispose();
  }

  String? _value(String key) {
    final text = _fields[key]!.text.trim();
    return text.isEmpty ? null : text;
  }

  void _save() {
    PortfolioEditorCubit.get(context).saveProfile(PortfolioProfileModel(
      name: _value('portfolio_field_name'),
      specialty: _value('portfolio_field_specialty'),
      stage: _value('portfolio_field_stage'),
      schoolName: _value('portfolio_field_school'),
      academicYear: _value('portfolio_field_year'),
      phone: _value('portfolio_field_phone'),
      email: _value('portfolio_field_email'),
      signatures: [
        for (final (title, name) in _signatures)
          if (title.text.trim().isNotEmpty)
            PortfolioSignatureModel(title: title.text.trim(), name: name.text.trim().isEmpty ? null : name.text.trim()),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return PortfolioExpandableCardWidget(
      leading: Icon(Icons.badge_outlined, color: ColorsManager.primaryColor),
      title: Text(
        appTranslation().get('portfolio_basic_info'),
        style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
      ),
      children: [
        const PortfolioRoleDropdownWidget(),
        verticalSpace14,
        for (final entry in _fields.entries) ...[
          PrimaryTextField(controller: entry.value, hint: appTranslation().get(entry.key)),
          verticalSpace10,
        ],
        verticalSpace6,
        Text(
          appTranslation().get('portfolio_signatures'),
          style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
        ),
        verticalSpace8,
        for (var i = 0; i < _signatures.length; i++)
          PortfolioSignatureRowWidget(
            key: ObjectKey(_signatures[i].$1),
            titleController: _signatures[i].$1,
            nameController: _signatures[i].$2,
            onRemove: () => _removeSignature(i),
          ),
        if (_signatures.length < PortfolioEditorCubit.maxSignatures)
          TextButton.icon(
            onPressed: _addSignature,
            icon: const Icon(Icons.add_rounded),
            label: Text(appTranslation().get('portfolio_add_signature')),
          ),
        verticalSpace10,
        BlocSelector<PortfolioEditorCubit, PortfolioEditorState, bool>(
          selector: (state) => state.isSaving,
          builder: (context, isSaving) => PrimaryElevatedButton(
            text: appTranslation().get('save_changes'),
            isLoading: isSaving,
            onPressed: _save,
          ),
        ),
      ],
    );
  }
}
