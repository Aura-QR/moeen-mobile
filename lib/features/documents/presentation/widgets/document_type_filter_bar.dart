import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/presentation/cubit/my_documents_cubit.dart';

/// «الكل» plus one chip per document type.
class DocumentTypeFilterBar extends StatelessWidget {
  const DocumentTypeFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MyDocumentsCubit, MyDocumentsState, String?>(
      selector: (state) => state.type,
      builder: (context, selected) => SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            for (final type in <String?>[null, ...DocumentTypes.all])
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  label: Text(
                    appTranslation().get(type == null ? 'document_filter_all' : DocumentTypes.labelKey(type)),
                    style: TextStylesManager.medium13.copyWith(
                      color: selected == type ? ColorsManager.white : ColorsManager.mainText,
                    ),
                  ),
                  selected: selected == type,
                  showCheckmark: false,
                  selectedColor: ColorsManager.primaryColor,
                  backgroundColor: ColorsManager.surfacePrimary,
                  side: BorderSide(color: selected == type ? ColorsManager.primaryColor : ColorsManager.borderLightGray),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (_) => MyDocumentsCubit.get(context).setType(type),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
