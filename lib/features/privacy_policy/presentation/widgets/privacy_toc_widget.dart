import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/privacy_policy/presentation/cubit/privacy_policy_cubit.dart';
import 'package:moean/features/privacy_policy/presentation/cubit/privacy_policy_state.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_toc_item_widget.dart';

class PrivacyTocWidget extends StatelessWidget {
  const PrivacyTocWidget({super.key});

  static final List<({int index, String key, IconData icon})> _tocItems = [
    (index: 0, key: 'privacy_sec1_toc', icon: Icons.shield_outlined),
    (index: 1, key: 'privacy_sec2_toc', icon: Icons.storage_rounded),
    (index: 2, key: 'privacy_sec3_toc', icon: Icons.memory_rounded),
    (index: 3, key: 'privacy_sec4_toc', icon: Icons.language_rounded),
    (index: 4, key: 'privacy_sec5_toc', icon: Icons.lock_outline_rounded),
    (index: 5, key: 'privacy_sec6_toc', icon: Icons.share_rounded),
    (index: 6, key: 'privacy_sec7_toc', icon: Icons.person_outline_rounded),
    (index: 7, key: 'privacy_sec8_toc', icon: Icons.cookie_outlined),
    (index: 8, key: 'privacy_sec9_toc', icon: Icons.mail_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = PrivacyPolicyCubit.get(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorsManager.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.article_outlined,
                color: ColorsManager.primaryColor,
                size: 22,
              ),
              horizontalSpace8,
              Expanded(
                child: Text(
                  appTranslation().get('privacy_toc_title'),
                  style: TextStylesManager.bold16.copyWith(
                    color: ColorsManager.primaryColor,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          verticalSpace16,
          TextField(
            controller: cubit.searchController,
            onChanged: cubit.onSearchChanged,
            textAlign: TextAlign.right,
            style: TextStylesManager.regular14.copyWith(
              color: ColorsManager.mainText,
            ),
            decoration: InputDecoration(
              hintText: appTranslation().get('privacy_search_hint'),
              hintStyle: TextStylesManager.regular13.copyWith(
                color: ColorsManager.placeholder,
              ),
              suffixIcon: Icon(
                Icons.search_rounded,
                color: ColorsManager.placeholder,
                size: 20,
              ),
              filled: true,
              fillColor: ColorsManager.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: ColorsManager.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: ColorsManager.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: ColorsManager.primaryColor),
              ),
            ),
          ),
          verticalSpace12,
          BlocBuilder<PrivacyPolicyCubit, PrivacyPolicyState>(
            buildWhen: (prev, curr) => curr is PrivacyPolicyStateUpdated,
            builder: (context, state) {
              final activeIndex = cubit.activeSection;
              final query = cubit.searchQuery;

              final filteredList = _tocItems.where((item) {
                if (query.isEmpty) return true;
                final title = appTranslation().get(item.key).toLowerCase();
                return title.contains(query);
              }).toList();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredList.length,
                separatorBuilder: (context, index) => verticalSpace4,
                itemBuilder: (context, i) {
                  final item = filteredList[i];
                  return PrivacyTocItemWidget(
                    index: item.index,
                    title: appTranslation().get(item.key),
                    icon: item.icon,
                    isSelected: activeIndex == item.index,
                    onTap: () => cubit.scrollToSection(item.index),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
