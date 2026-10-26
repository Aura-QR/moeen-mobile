import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_editable_list.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reports/data/models/report_block.dart';
import 'package:moean/features/reports/data/models/report_block_edits.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';
import 'package:moean/features/reports/presentation/widgets/report_fields_sheet.dart';
import 'package:moean/features/reports/presentation/widgets/report_table_row_tile.dart';
import 'package:moean/features/reports/presentation/widgets/report_tap_to_edit.dart';

/// A bar chart: a title, the labels, then each series with one value per label.
class ReportChartEditor extends StatelessWidget {
  final ChartBlock block;

  const ReportChartEditor({super.key, required this.block});

  String _value(ReportSeries series, int index) {
    if (index >= series.values.length) return '';
    final value = series.values[index];
    return value == value.roundToDouble() ? value.toInt().toString() : value.toString();
  }

  Future<void> _editTitle(BuildContext context) async {
    final cubit = ReportEditorCubit.get(context);
    final values = await ReportFieldsSheet.show(context, titleKey: 'report_chart_title', fields: [
      ReportField(label: '', initialValue: block.title, maxLength: 150),
    ]);
    if (values != null) cubit.updateBlock(block.copyWith(title: values.first.trim()));
  }

  Future<void> _editSeries(BuildContext context, int index) async {
    final cubit = ReportEditorCubit.get(context);
    final series = block.series[index];
    final values = await ReportFieldsSheet.show(context, titleKey: 'report_chart_series', fields: [
      ReportField(label: appTranslation().get('report_chart_series_name'), initialValue: series.name, maxLength: 80),
      for (var i = 0; i < block.labels.length; i++)
        ReportField(
          label: block.labels[i],
          initialValue: _value(series, i),
          maxLength: 10,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
    ]);
    if (values != null) cubit.updateBlock(block.setSeries(index, values.first, values.sublist(1)));
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ReportEditorCubit.get(context);
    final limits = cubit.state.limits;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportTapToEdit(
          text: block.title,
          placeholderKey: 'report_chart_title',
          style: TextStylesManager.bold14,
          onTap: () => _editTitle(context),
        ),
        PrimaryEditableList(
          title: appTranslation().get('report_chart_labels'),
          items: block.labels,
          maxItems: limits.chartLabels,
          maxLength: 60,
          addKey: 'report_add_item',
          onAdd: (text) => cubit.updateBlock(block.setLabels(block.labels.addLine(text, limits.chartLabels))),
          onEdit: (index, text) => cubit.updateBlock(block.setLabels(block.labels.editLine(index, text))),
          onRemove: (index) => cubit.updateBlock(block.setLabels(block.labels.removeLine(index))),
          onReorder: (oldIndex, newIndex) =>
              cubit.updateBlock(block.setLabels(block.labels.moveLine(oldIndex, newIndex))),
        ),
        verticalSpace8,
        for (var i = 0; i < block.series.length; i++)
          ReportTableRowTile(
            cells: [
              block.series[i].name.isEmpty
                  ? appTranslation().get('report_chart_series_n').replaceAll('{n}', '${i + 1}')
                  : block.series[i].name,
              [for (var v = 0; v < block.labels.length; v++) _value(block.series[i], v)].join(' - '),
            ],
            onTap: () => _editSeries(context, i),
            onRemove: block.series.length > 1 ? () => cubit.updateBlock(block.removeSeries(i)) : null,
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: block.series.length < limits.chartSeries
                ? () => cubit.updateBlock(block.addSeries(limits.chartSeries))
                : null,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(appTranslation().get('report_chart_add_series')),
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: block.compact,
          activeThumbColor: ColorsManager.primaryColor,
          onChanged: (compact) => cubit.updateBlock(block.copyWith(compact: compact)),
          title: Text(
            appTranslation().get('report_table_compact'),
            style: TextStylesManager.medium13.copyWith(color: ColorsManager.mainText),
          ),
        ),
      ],
    );
  }
}
