import 'package:flutter/material.dart';
import 'package:moean/core/router/app_router.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/lab/data/models/lab_experiment_model.dart';
import 'package:moean/features/lab/presentation/cubit/lab_library_cubit.dart';
import 'package:moean/features/lab/presentation/widgets/lab_experiment_card.dart';

class LabExperimentsListView extends StatefulWidget {
  final List<LabExperimentModel> experiments;
  final bool isLoadingMore;

  const LabExperimentsListView({
    super.key,
    required this.experiments,
    required this.isLoadingMore,
  });

  @override
  State<LabExperimentsListView> createState() => _LabExperimentsListViewState();
}

class _LabExperimentsListViewState extends State<LabExperimentsListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      LabLibraryCubit.get(context).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: widget.experiments.length + (widget.isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => verticalSpace12,
      itemBuilder: (context, index) {
        if (index >= widget.experiments.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ColorsManager.primaryColor,
                ),
              ),
            ),
          );
        }

        final item = widget.experiments[index];
        return LabExperimentCard(
          experiment: item,
          onTap: () {
            AppRouter.push(
              Routes.labExperiment,
              arguments: LabExperimentArgs(key: item.key, name: item.name),
              context: context,
            );
          },
        );
      },
    );
  }
}
