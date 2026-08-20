import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/privacy_policy/presentation/cubit/privacy_policy_cubit.dart';
import 'package:moean/features/privacy_policy/presentation/cubit/privacy_policy_state.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_header_card_widget.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_section_ai_usage_widget.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_section_cookies_widget.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_section_data_collected_widget.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_section_encryption_widget.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_section_intro_widget.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_section_madrasati_widget.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_section_no_selling_widget.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_section_teacher_rights_widget.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_section_updates_contact_widget.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_support_card_widget.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_toc_widget.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = PrivacyPolicyCubit.get(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: AppBar(
          backgroundColor: ColorsManager.background,
          elevation: 0,
          centerTitle: true,
          title: Text(
            appTranslation().get('privacy_policy_title'),
            style: TextStylesManager.bold18.copyWith(
              color: ColorsManager.primaryColor,
            ),
          ),
          leading: IconButton(
           icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: ColorsManager.mainText,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
        ), body: SafeArea(
          child: BlocListener<PrivacyPolicyCubit, PrivacyPolicyState>(
            listener: (context, state) {
              if (state is PrivacyPolicyPdfError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: ColorsManager.errorColor,
                  ),
                );
              }
            },
            child: SingleChildScrollView(
              controller: cubit.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const PrivacyHeaderCardWidget(),
                  verticalSpace16,
                  const PrivacyTocWidget(),
                  verticalSpace16,
                  const PrivacySupportCardWidget(),
                  verticalSpace16,
                  Container(
                    key: cubit.sectionKeys[0],
                    child: const PrivacySectionIntroWidget(),
                  ),
                  verticalSpace16,
                  Container(
                    key: cubit.sectionKeys[1],
                    child: const PrivacySectionDataCollectedWidget(),
                  ),
                  verticalSpace16,
                  Container(
                    key: cubit.sectionKeys[2],
                    child: const PrivacySectionAiUsageWidget(),
                  ),
                  verticalSpace16,
                  Container(
                    key: cubit.sectionKeys[3],
                    child: const PrivacySectionMadrasatiWidget(),
                  ),
                  verticalSpace16,
                  Container(
                    key: cubit.sectionKeys[4],
                    child: const PrivacySectionEncryptionWidget(),
                  ),
                  verticalSpace16,
                  Container(
                    key: cubit.sectionKeys[5],
                    child: const PrivacySectionNoSellingWidget(),
                  ),
                  verticalSpace16,
                  Container(
                    key: cubit.sectionKeys[6],
                    child: const PrivacySectionTeacherRightsWidget(),
                  ),
                  verticalSpace16,
                  Container(
                    key: cubit.sectionKeys[7],
                    child: const PrivacySectionCookiesWidget(),
                  ),
                  verticalSpace16,
                  Container(
                    key: cubit.sectionKeys[8],
                    child: const PrivacySectionUpdatesContactWidget(),
                  ),
                  verticalSpace32,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
