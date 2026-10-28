import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/nafs/presentation/screens/nafs_create_screen.dart';
import 'package:moean/features/tahsili/presentation/screens/tahsili_tab_view.dart';

class NationalExamsScreen extends StatelessWidget {
  final int initialIndex;

  const NationalExamsScreen({
    super.key,
    this.initialIndex = 0,
  });

  static Widget create({int initialIndex = 0}) => NationalExamsScreen(
        initialIndex: initialIndex,
      );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialIndex,
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: AppBar(
          backgroundColor: ColorsManager.background,
          elevation: 0,
          centerTitle: true,
          title: Text(
            appTranslation().get('national_exams_title'),
            style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
          ),
          bottom: TabBar(
            indicatorColor: ColorsManager.primaryColor,
            labelColor: ColorsManager.primaryColor,
            unselectedLabelColor: ColorsManager.secondaryText,
            labelStyle: TextStylesManager.bold14,
            unselectedLabelStyle: TextStylesManager.medium14,
            tabs: [
              Tab(text: appTranslation().get('nafs_title')),
              Tab(text: appTranslation().get('tahsili_title')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            NafsCreateScreen.create(isEmbedded: true),
            TahsiliTabView.create(),
          ],
        ),
      ),
    );
  }
}
