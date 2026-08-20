import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/admin/payments/presentation/cubit/admin_payments_cubit.dart';

class AdminPaymentsSearchFilterWidget extends StatefulWidget {
  const AdminPaymentsSearchFilterWidget({super.key});

  @override
  State<AdminPaymentsSearchFilterWidget> createState() => _AdminPaymentsSearchFilterWidgetState();
}

class _AdminPaymentsSearchFilterWidgetState extends State<AdminPaymentsSearchFilterWidget> {
  final TextEditingController _searchController = TextEditingController();
  
  // Filter options
  final List<String> _filters = [
    'all',
    'pending',
    'paid',
    'failed',
    'manual',
    'moyasar'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    AdminPaymentsCubit.get(context).getPayments(
      search: _searchController.text.trim(),
    );
  }

  void _onFilterChanged(String filter) {
    AdminPaymentsCubit.get(context).getPayments(
      filter: filter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = AdminPaymentsCubit.get(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: appTranslation().get('admin_payments_search_hint'),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: (_) => _onSearch(),
                ),
              ),
              horizontalSpace16,
              ElevatedButton(
                onPressed: _onSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('بحث'),
              ),
            ],
          ),
          verticalSpace16,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                final isSelected = cubit.currentFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: FilterChip(
                    label: Text(appTranslation().get('filter_$filter')),
                    selected: isSelected,
                    onSelected: (_) => _onFilterChanged(filter),
                    selectedColor: ColorsManager.primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: ColorsManager.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? ColorsManager.primaryColor : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
