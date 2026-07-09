import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/admin/contact/presentation/cubit/admin_contact_cubit.dart';
import 'package:moean/features/admin/contact/presentation/widgets/admin_contact_stats_widget.dart';
import 'package:moean/features/admin/contact/presentation/widgets/admin_contact_list_widget.dart';

class AdminContactScreen extends StatelessWidget {
  const AdminContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminContactCubit()..getStats()..getTickets(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: ColorsManager.background,
          appBar: AppBar(
            backgroundColor: ColorsManager.surfacePrimary,
            elevation: 0,
            title: Text(
              appTranslation().get('admin_contact_title'),
              style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
            ),
            centerTitle: true,
            iconTheme: IconThemeData(color: ColorsManager.mainText),
          ),
          body:  Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                AdminContactStatsWidget(),
                verticalSpace24,
                Expanded(child: AdminContactListWidget()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
