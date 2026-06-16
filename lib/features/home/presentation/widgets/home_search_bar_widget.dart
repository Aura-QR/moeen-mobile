import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/features/home/presentation/cubit/home_cubit.dart';

class HomeSearchBarWidget extends StatelessWidget {
  const HomeSearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = HomeCubit.get(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child:PrimaryTextField(controller: cubit.searchController, 
             hint: appTranslation().get('search_hint'),
              onChanged: cubit.onSearchChanged,
               prefixIcon : const Icon(Icons.search, color: ColorsManager.textBody, size: 20),
    suffixIcon : Icon(
        Icons.tune_rounded,
        color: ColorsManager.primaryColor,
        size: 20,
      ),
            ),
          ),
        ],
      ),
    );
  }
}
