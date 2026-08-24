import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/privacy_policy/presentation/cubit/privacy_policy_cubit.dart';
import 'package:moean/features/privacy_policy/presentation/cubit/privacy_policy_state.dart';

class PrivacyHeaderCardWidget extends StatelessWidget {
  const PrivacyHeaderCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = PrivacyPolicyCubit.get(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorsManager.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 16,
                  color: ColorsManager.primaryColor,
                ),
                horizontalSpace6,
                Text(
                  appTranslation().get('privacy_official_document_badge'),
                  style: TextStylesManager.bold12.copyWith(
                    color: ColorsManager.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          verticalSpace16,
          Text(
            appTranslation().get('privacy_hero_title'),
            style: TextStylesManager.bold22.copyWith(
              color: ColorsManager.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          verticalSpace12,
          Text(
            appTranslation().get('privacy_hero_desc'),
            style: TextStylesManager.regular13.copyWith(
              color: ColorsManager.placeholder,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          verticalSpace12,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16,
                color: ColorsManager.placeholder,
              ),
              horizontalSpace6,
              Text(
                appTranslation().get('privacy_last_updated'),
                style: TextStylesManager.regular12.copyWith(
                  color: ColorsManager.placeholder,
                ),
              ),
            ],
          ),
          verticalSpace20,
          // Row(
          //   children: [
          //     Expanded(
          //       child: OutlinedButton.icon(
          //         onPressed: cubit.shareLink,
          //         icon: Icon(
          //           Icons.share_outlined,
          //           size: 18,
          //           color: ColorsManager.primaryColor,
          //         ),
          //         label: Text(
          //           appTranslation().get('privacy_share_link'),
          //           style: TextStylesManager.bold13.copyWith(
          //             color: ColorsManager.primaryColor,
          //           ),
          //         ),
          //         style: OutlinedButton.styleFrom(
          //           side: BorderSide(color: ColorsManager.borderColor),
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(24),
          //           ),
          //           padding: const EdgeInsets.symmetric(vertical: 12),
          //         ),
          //       ),
          //     ),
          //     horizontalSpace12,
          //     BlocBuilder<PrivacyPolicyCubit, PrivacyPolicyState>(
          //       builder: (context, state) {
          //         final isGenerating = state is PrivacyPolicyPdfGenerating;
          //         return Expanded(
          //           child: OutlinedButton.icon(
          //             onPressed: isGenerating ? null : cubit.printPdf,
          //             icon: isGenerating
          //                 ? SizedBox(
          //                     width: 18,
          //                     height: 18,
          //                     child: CircularProgressIndicator(
          //                       strokeWidth: 2,
          //                       color: ColorsManager.primaryColor,
          //                     ),
          //                   )
          //                 : Icon(
          //                     Icons.print_outlined,
          //                     size: 18,
          //                     color: ColorsManager.primaryColor,
          //                   ),
          //             label: Text(
          //               appTranslation().get('privacy_print_pdf'),
          //               style: TextStylesManager.bold13.copyWith(
          //                 color: ColorsManager.primaryColor,
          //               ),
          //             ),
          //             style: OutlinedButton.styleFrom(
          //               side: BorderSide(color: ColorsManager.borderColor),
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(24),
          //               ),
          //               padding: const EdgeInsets.symmetric(vertical: 12),
          //             ),
          //           ),
          //         );
          //       },
          //     ),
          //   ],
          // ),
        
        ],
      ),
    );
  }
}
