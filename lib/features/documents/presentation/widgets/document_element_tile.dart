import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/cubit/document_element_cubit.dart';
import 'package:moean/features/documents/presentation/document_element_label.dart';
import 'package:moean/features/documents/presentation/widgets/document_element_sheet.dart';

/// «يُحسب شاهدًا لـ: …» with «تغيير», under a [DocumentElementCubit].
class DocumentElementTile extends StatelessWidget {
  const DocumentElementTile({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = DocumentElementCubit.get(context);
    return BlocBuilder<DocumentElementCubit, DocumentElementState>(
      buildWhen: (previous, current) => previous.status != current.status || previous.element != current.element,
      builder: (context, state) {
        if (state.status == DocumentElementStatus.failure) return const SizedBox.shrink();
        final current = state.current;
        final value = state.status == DocumentElementStatus.loading
            ? '…'
            : current == null
                ? appTranslation().get('document_element_none')
                : elementLabel(current.title, current.number);
        return Container(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 6, 6),
          decoration: BoxDecoration(
            color: ColorsManager.primaryColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.workspace_premium_outlined, size: 20, color: ColorsManager.primaryColor),
              horizontalSpace10,
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: '${appTranslation().get('document_element_label')} ',
                    style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
                    children: [
                      TextSpan(
                        text: value,
                        style: TextStylesManager.bold13.copyWith(color: ColorsManager.mainText),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: state.status == DocumentElementStatus.ready
                    ? () => DocumentElementSheet.open(context, cubit)
                    : null,
                child: Text(appTranslation().get('document_element_change')),
              ),
            ],
          ),
        );
      },
    );
  }
}
