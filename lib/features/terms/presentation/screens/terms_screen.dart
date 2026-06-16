// import 'package:flutter/material.dart';
// import 'package:lucide_icons_flutter/lucide_icons.dart';
// import 'package:moean/core/theme/colors.dart';
// import 'package:moean/core/theme/text_styles.dart';
// import 'package:moean/core/utils/constants/constants.dart';
// import 'package:moean/core/utils/constants/spacing.dart';
// import 'package:moean/core/utils/extensions/context_extension.dart';
// import 'package:moean/features/terms/presentation/widgets/terms_expansion_item.dart';

// class TermsScreen extends StatelessWidget {
//   const TermsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorsManager.background,
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildHeader(context),
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     TermsExpansionItem(
//                       title: appTranslation().get('terms_nature_of_service'),
//                       content: appTranslation().get(
//                         'terms_nature_of_service_desc',
//                       ),
//                       icon: LucideIcons.stethoscope,
//                       isExpandedInitially: true,
//                     ),
//                     verticalSpace12,
//                     TermsExpansionItem(
//                       title: appTranslation().get('terms_account_creation'),
//                       content: appTranslation().get(
//                         'terms_account_creation_desc',
//                       ),
//                       icon: LucideIcons.user,
//                     ),
//                     verticalSpace12,
//                     TermsExpansionItem(
//                       title: appTranslation().get('terms_booking_services'),
//                       content: appTranslation().get(
//                         'terms_booking_services_desc',
//                       ),
//                       icon: LucideIcons.calendar,
//                     ),
//                     verticalSpace12,
//                     TermsExpansionItem(
//                       title: appTranslation().get(
//                         'terms_pharmacies_prescriptions',
//                       ),
//                       content: appTranslation().get(
//                         'terms_pharmacies_prescriptions_desc',
//                       ),
//                       icon: LucideIcons.briefcaseMedical,
//                     ),
//                     verticalSpace12,
//                     TermsExpansionItem(
//                       title: appTranslation().get(
//                         'terms_medical_record_privacy',
//                       ),
//                       content: appTranslation().get(
//                         'terms_medical_record_privacy_desc',
//                       ),
//                       icon: LucideIcons.shield,
//                     ),
//                     verticalSpace12,
//                     TermsExpansionItem(
//                       title: appTranslation().get('terms_privacy_policy'),
//                       content: appTranslation().get(
//                         'terms_privacy_policy_desc',
//                       ),
//                       icon: LucideIcons.fileText,
//                     ),
//                     verticalSpace12,
//                     TermsExpansionItem(
//                       title: appTranslation().get('terms_payment_refunds'),
//                       content: appTranslation().get(
//                         'terms_payment_refunds_desc',
//                       ),
//                       icon: LucideIcons.creditCard,
//                     ),
//                     verticalSpace12,
//                     TermsExpansionItem(
//                       title: appTranslation().get('terms_limits_of_liability'),
//                       content: appTranslation().get(
//                         'terms_limits_of_liability_desc',
//                       ),
//                       icon: LucideIcons.alarmClock,
//                     ),
//                     verticalSpace12,
//                     TermsExpansionItem(
//                       title: appTranslation().get('terms_prohibited_use'),
//                       content: appTranslation().get(
//                         'terms_prohibited_use_desc',
//                       ),
//                       icon: LucideIcons.ban,
//                     ),
//                     verticalSpace12,
//                     TermsExpansionItem(
//                       title: appTranslation().get('terms_notifications'),
//                       content: appTranslation().get('terms_notifications_desc'),
//                       icon: LucideIcons.bell,
//                     ),
//                     verticalSpace12,
//                     TermsExpansionItem(
//                       title: appTranslation().get('terms_account_termination'),
//                       content: appTranslation().get(
//                         'terms_account_termination_desc',
//                       ),
//                       icon: LucideIcons.userMinus,
//                     ),
//                     verticalSpace12,
//                     TermsExpansionItem(
//                       title: appTranslation().get('terms_governing_law'),
//                       content: appTranslation().get('terms_governing_law_desc'),
//                       icon: LucideIcons.scale,
//                     ),
//                     verticalSpace24,
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: _buildBottomBar(context),
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
//       decoration: BoxDecoration(
//         color: ColorsManager.themeActiveAccent.withValues(
//           alpha: 0.08,
//         ),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(30),
//           bottomRight: Radius.circular(30),
//         ),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               IconButton(
//                 onPressed: () => context.pop(),
//                 icon: const Icon(
//                   Icons.arrow_back_ios,
//                   color: ColorsManager.primaryColor,
//                   size: 20,
//                 ),
//               ),
//             ],
//           ),
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white.withValues(alpha: 0.2),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               LucideIcons.fileCheck,
//               color: ColorsManager.themeActiveAccent,
//               size: 32,
//             ),
//           ),
//           verticalSpace12,
//           Text(
//             appTranslation().get('terms_screen_title'),
//             style: TextStylesManager.bold20.copyWith(
//               color: ColorsManager.primaryColor,
//             ),
//           ),
//           verticalSpace4,
//           Text(
//             appTranslation().get('terms_screen_subtitle'),
//             style: TextStylesManager.regular12.copyWith(
//               color: ColorsManager.primaryColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomBar(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: ColorsManager.background,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: ColorsManager.primaryColor,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         onPressed: () => context.pop(),
//         child: Text(
//           appTranslation().get('terms_agree_button'),
//           style: TextStylesManager.bold16.copyWith(color: Colors.white),
//         ),
//       ),
//     );
//   }
// }
