import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/classes/data/repositories/classes_repository.dart';
import 'package:moean/features/classes/presentation/cubit/madrasati_import_cubit.dart';
import 'package:moean/features/classes/presentation/widgets/madrasati_class_tile.dart';

/// «استيراد من مدرستي»: reads classes and student names from Madrasati
/// (through the backend, with the connected Madrasati account), shows them
/// for review, and saves them to «فصولي». Pops with true when something was saved.
class MadrasatiImportSheet extends StatelessWidget {
  const MadrasatiImportSheet({super.key});

  static Future<bool> show(BuildContext context, ClassesRepository repository) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BlocProvider(
        create: (_) => MadrasatiImportCubit(repository)..load(),
        child: const MadrasatiImportSheet(),
      ),
    );
    return saved ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = MadrasatiImportCubit.get(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: BlocConsumer<MadrasatiImportCubit, MadrasatiImportState>(
            listenWhen: (previous, current) => !previous.isDone && current.isDone,
            listener: (context, state) => Navigator.pop(context, state.savedAny),
            buildWhen: (previous, current) => !current.isDone,
            builder: (context, state) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  appTranslation().get('classes_madrasati_title'),
                  style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
                ),
                verticalSpace4,
                Text(
                  appTranslation().get('classes_madrasati_subtitle'),
                  style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
                ),
                verticalSpace12,
                Flexible(
                  child: ConditionalBuilder(
                    loadingState: state.status == MadrasatiImportStatus.loading,
                    emptyState: state.status == MadrasatiImportStatus.success && state.rows.isEmpty,
                    loadingBuilder: (_) => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    emptyBuilder: (_) => Text(appTranslation().get('classes_madrasati_empty'), textAlign: TextAlign.center),
                    successBuilder: (_) => ListView.separated(
                      shrinkWrap: true,
                      itemCount: state.rows.length,
                      separatorBuilder: (_, _) => Divider(height: 1, color: ColorsManager.borderLightGray),
                      itemBuilder: (context, index) => MadrasatiClassTile(
                        row: state.rows[index],
                        onToggle: state.isBusy || state.isRead ? null : () => cubit.toggle(index),
                      ),
                    ),
                  ),
                ),
                if (state.errorMessage != null) ...[
                  verticalSpace8,
                  Text(
                    appTranslation().get(state.errorMessage!),
                    style: TextStylesManager.regular13.copyWith(color: ColorsManager.errorColor),
                  ),
                ],
                verticalSpace16,
                if (state.rows.isNotEmpty)
                  PrimaryElevatedButton(
                    text: appTranslation().get(state.isRead ? 'classes_madrasati_save' : 'classes_madrasati_read'),
                    icon: Icon(state.isRead ? Icons.save_rounded : Icons.download_rounded),
                    isLoading: state.isBusy,
                    onPressed: state.isBusy ? null : (state.isRead ? cubit.save : cubit.read),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context, state.savedAny),
                  child: Text(appTranslation().get('cancel'), style: TextStylesManager.bold14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
