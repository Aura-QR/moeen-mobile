import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/preparation_print/data/repositories/preparation_print_repository.dart';
import 'package:moean/features/preparation_print/presentation/cubit/preparation_history_cubit.dart';

String _date(DateTime d) => '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

/// «تحضيراتي»: the teacher's finished preparations; pick up to 10 and print them.
class PreparationHistoryScreen extends StatelessWidget {
  const PreparationHistoryScreen({super.key});

  static Widget create() => BlocProvider(
        create: (_) => PreparationHistoryCubit(PreparationPrintRepository())..load(),
        child: const PreparationHistoryScreen(),
      );

  Future<void> _onChange(BuildContext context, PreparationHistoryState state) async {
    final cubit = PreparationHistoryCubit.get(context);
    if (state.error != null && state.items.isNotEmpty) {
      showPrimarySnackBar(context, state.error!, isError: true);
      cubit.clearError();
    }
    final id = state.createdDocumentId;
    if (id != null) {
      cubit.clearCreated();
      await Navigator.pushNamed(context, Routes.preparationPrint, arguments: id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = PreparationHistoryCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(appTranslation().get('prep_history_title'), style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText)),
      ),
      body: BlocConsumer<PreparationHistoryCubit, PreparationHistoryState>(
        listenWhen: (a, b) => a.createdDocumentId != b.createdDocumentId || a.error != b.error,
        listener: _onChange,
        builder: (context, state) {
          if (state.isLoading) return const Center(child: CircularProgressIndicator());
          if (state.error != null && state.items.isEmpty) {
            return PrimaryErrorView(message: state.error!, onRetry: cubit.load);
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Text(appTranslation().get('prep_history_hint'), style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText)),
              ),
              SwitchListTile(
                value: state.showAll,
                onChanged: cubit.toggleShowAll,
                title: Text(appTranslation().get('prep_history_show_all'), style: TextStylesManager.regular13.copyWith(color: ColorsManager.mainText)),
                dense: true,
              ),
              Expanded(
                child: state.items.isEmpty
                    ? Center(child: Text(appTranslation().get(state.showAll ? 'prep_history_empty' : 'prep_history_empty_done'), style: TextStylesManager.regular14))
                    : NotificationListener<ScrollNotification>(
                        onNotification: (n) {
                          if (n.metrics.pixels > n.metrics.maxScrollExtent - 200) cubit.loadMore();
                          return false;
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, _) => verticalSpace8,
                          itemBuilder: (context, index) {
                            if (index >= state.items.length) {
                              return const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator()));
                            }
                            final item = state.items[index];
                            final order = state.picked.indexOf(item.id);
                            final full = order < 0 && state.picked.length >= PreparationHistoryState.maxPicked;
                            return Container(
                              decoration: BoxDecoration(
                                color: ColorsManager.surfacePrimary,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: order >= 0 ? ColorsManager.primaryColor : ColorsManager.borderLightGray),
                              ),
                              child: ListTile(
                                onTap: item.isDone && !full ? () => cubit.toggle(item.id) : null,
                                leading: item.isDone
                                    ? (order >= 0
                                        ? CircleAvatar(radius: 14, backgroundColor: ColorsManager.primaryColor, child: Text('${order + 1}', style: TextStylesManager.bold12.copyWith(color: Colors.white)))
                                        : Icon(Icons.check_box_outline_blank_rounded, color: full ? ColorsManager.borderLightGray : ColorsManager.primaryColor))
                                    : Icon(Icons.error_outline_rounded, color: ColorsManager.errorColor),
                                title: Text(item.title.isEmpty ? appTranslation().get('prep_history_lesson') : item.title,
                                    style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText), maxLines: 2, overflow: TextOverflow.ellipsis),
                                subtitle: Text(
                                  [
                                    if (item.date != null) _date(item.date!.toLocal()),
                                    appTranslation().get(item.isDone ? 'prep_history_done' : 'prep_history_not_done'),
                                  ].join(' · '),
                                  style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                                ),
                                trailing: item.isDone
                                    ? IconButton(
                                        icon: Icon(Icons.print_outlined, color: ColorsManager.primaryColor),
                                        tooltip: appTranslation().get('prep_history_print_one'),
                                        onPressed: state.isCreating ? null : () => cubit.print([item.id]),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<PreparationHistoryCubit, PreparationHistoryState>(
        buildWhen: (a, b) => a.picked != b.picked || a.isCreating != b.isCreating,
        builder: (context, state) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PrimaryElevatedButton(
              text: appTranslation().get('prep_history_print_selected').replaceAll('{count}', '${state.picked.length}'),
              icon: const Icon(Icons.print_rounded, size: 20),
              isLoading: state.isCreating,
              onPressed: state.picked.isEmpty || state.isCreating ? null : () => cubit.print(),
            ),
          ),
        ),
      ),
    );
  }
}
