import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/features/thank_you_certificates/presentation/cubit/certificates_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_header_section.dart';

/// «الترويسة» of the certificates: read-only defaults, with «تعديل لهذا المستند فقط».
class CertificatesHeaderSection extends StatelessWidget {
  const CertificatesHeaderSection({super.key});

  Future<void> _editDefaults(BuildContext context) async {
    final cubit = CertificatesCubit.get(context);
    final saved = await Navigator.pushNamed(context, Routes.documentDefaults);
    if (saved == true) cubit.reloadDefaults();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = CertificatesCubit.get(context);
    return BlocBuilder<CertificatesCubit, CertificatesState>(
      buildWhen: (previous, current) =>
          previous.defaults != current.defaults || previous.isOverridingHeader != current.isOverridingHeader,
      builder: (context, state) => DocumentHeaderSection(
        defaults: state.defaults,
        isOverriding: state.isOverridingHeader,
        overrideControllers: cubit.header.controllers,
        onOverrideChanged: cubit.setHeaderOverride,
        onEditDefaults: () => _editDefaults(context),
      ),
    );
  }
}
