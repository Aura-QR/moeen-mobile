import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/certificates/presentation/cubit/certificate_cubit.dart';
import 'package:moean/features/certificates/presentation/widgets/certificate_form_widget.dart';
import 'package:moean/features/certificates/presentation/widgets/certificate_gender_tab_widget.dart';
import 'package:moean/features/certificates/presentation/widgets/certificate_generate_button_widget.dart';
import 'package:moean/features/certificates/presentation/widgets/certificate_template_grid_widget.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  @override
  void initState() {
    super.initState();
    CertificateCubit.get(context).loadTeacherProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: AppBar(
          backgroundColor: ColorsManager.background,
          elevation: 0,
          centerTitle: true,
          title: Text(
            appTranslation().get('certificates'),
            style: TextStylesManager.bold18
                .copyWith(color: ColorsManager.mainText),
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: ColorsManager.mainText,
              size: 20,
            ),
          ),
        ),
        body: BlocBuilder<CertificateCubit, CertificateState>(
          buildWhen: (prev, curr) =>
              curr is CertificateLoading || curr is CertificateLoaded,
          builder: (context, state) {
            if (state is CertificateLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: ColorsManager.primaryColor,
                ),
              );
            }
            return const _CertificateBodyWidget();
          },
        ),
      ),
    );
  }
}

class _CertificateBodyWidget extends StatelessWidget {
  const _CertificateBodyWidget();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/roaa.png', height: 60),
                  Image.asset('assets/images/minstry.jpg', height: 60),
                ],
              ),
              verticalSpace20,
              _CertificateSectionHeaderWidget(),
              verticalSpace20,
              const CertificateGenderTabWidget(),
              verticalSpace20,
              const CertificateTemplateGridWidget(),
              verticalSpace24,
              const CertificateFormWidget(),
            ]),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CertificateGenerateButtonWidget(),
                verticalSpace20,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CertificateSectionHeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                color: ColorsManager.primaryColor,
                size: 24,
              ),
            ),
            horizontalSpace12,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appTranslation().get('cert_section_title'),
                  style: TextStylesManager.bold20
                      .copyWith(color: ColorsManager.mainText),
                ),
                Text(
                  appTranslation().get('cert_choose_template'),
                  style: TextStylesManager.regular13
                      .copyWith(color: ColorsManager.secondaryText),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
