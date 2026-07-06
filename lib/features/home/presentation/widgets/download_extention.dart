import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/home/presentation/cubit/extension_install_cubit.dart';
import 'package:moean/features/home/presentation/widgets/extension_ios_dialog.dart';

class DownloadExtention extends StatelessWidget {
  const DownloadExtention({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExtensionInstallCubit(),
      child: const _DownloadExtentionView(),
    );
  }
}

class _DownloadExtentionView extends StatelessWidget {
  const _DownloadExtentionView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExtensionInstallCubit, ExtensionInstallState>(
      listener: (context, state) {
        if (state is ExtensionInstallIosNotSupported) {
          ExtensionIosDialog.show(context);
        } else if (state is ExtensionInstallError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          color: ColorsManager.surfacePrimary,
          // SafeArea ensures Edge-to-Edge devices don't overlap the UI
          // with the system status bar or navigation bar.
          child: SafeArea(
            child:Scaffold(
              appBar: AppBar(
  backgroundColor: ColorsManager.background,
  elevation: 0,
  centerTitle: true,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios),
    onPressed: () => Navigator.pop(context),
  ),
  title: Text(
    appTranslation().get('app_name'),
    style: TextStylesManager.bold20.copyWith(
      color: ColorsManager.primaryColor,
    ),
  ),
  actions: [
    Image.asset(
      AssetsHelper.icon,
      width: 55,
      height: 55,
      fit: BoxFit.cover,
    ),
  ],
),
              body:  SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Greeting ---
                  Text(
                    appTranslation().get('ext_quetta_greeting_title'),
                    style: TextStylesManager.bold22.copyWith(
                      color: ColorsManager.mainText,
                    ),
                  ),
                  verticalSpace12,
                  Text(
                    appTranslation().get('ext_quetta_greeting_subtitle'),
                    style: TextStylesManager.bold14.copyWith(
                      color: ColorsManager.mainText,
                      height: 1.6,
                    ),
                  ),
                  verticalSpace32,

                  // --- Step 1 ---
                  _StepCard(
                    title: appTranslation().get('ext_quetta_step1_title'),
                    body: appTranslation().get('ext_quetta_step1_body'),
                    button: PrimaryElevatedButton(
                      onPressed: () =>
                          ExtensionInstallCubit.get(context).downloadQuetta(),
                      text: appTranslation().get('ext_quetta_btn_download'),
                      icon: const Icon(Icons.shop_rounded, color: Colors.white),
                    ),
                  ),
                  verticalSpace20,

                  // --- Step 2 ---
                  _StepCard(
                    title: appTranslation().get('ext_quetta_step2_title'),
                    body: appTranslation().get('ext_quetta_step2_body'),
                    button: BlocBuilder<ExtensionInstallCubit, ExtensionInstallState>(
                      builder: (context, state) {
                        if (state.isQuettaInstalled) {
                          return PrimaryElevatedButton(
                            onPressed: () => ExtensionInstallCubit.get(context)
                                .openExtensionInQuetta(),
                            text: appTranslation().get('ext_quetta_btn_open'),
                            icon: const Icon(Icons.rocket_launch_rounded,
                                color: Colors.white),
                          );
                        } else {
                          return PrimaryElevatedButton(
                            onPressed: () {
showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appTranslation().get('attention')),
        content: Text(appTranslation().get('should_download')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child:  Text(appTranslation().get('cancel')),
          ),
          
        ],
      ),
    );
  
                            },
                            text: appTranslation().get('ext_quetta_btn_open'),
                            icon: const Icon(Icons.rocket_launch_rounded,
                                color: Colors.white),
                          );}
                      },
                    ),
                  ),
                  verticalSpace20,

                  // --- Step 3 ---
                  _StepCard(
                    title: appTranslation().get('ext_quetta_step3_title'),
                    body: appTranslation().get('ext_quetta_step3_body'),
                    button: BlocBuilder<ExtensionInstallCubit, ExtensionInstallState>(
                      builder: (context, state) {
                        return PrimaryElevatedButton(
                          onPressed: () {
                            if (state.isQuettaInstalled) {
                              ExtensionInstallCubit.get(context)
                                  .openMadrasatiInQuetta();
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(appTranslation().get('attention')),
                                  content: Text(
                                      appTranslation().get('should_download')),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(appTranslation().get('cancel')),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          text: appTranslation().get('ext_quetta_btn_open_madrasati'),
                          icon: const Icon(Icons.open_in_browser_rounded,
                              color: Colors.white),
                        );
                      },
                    ),
                  ),
                  verticalSpace24,
                
                ],
              ),
            ),
         
            )),
        ),
      ),
    );
  }
}

/// A card representing a single step in the flow.
class _StepCard extends StatelessWidget {
  final String title;
  final String body;
  final Widget? button;

  const _StepCard({
    required this.title,
    required this.body,
    this.button,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorsManager.primaryColor.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primaryColor.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStylesManager.bold16.copyWith(
              color: ColorsManager.primaryColor,
            ),
          ),
          verticalSpace12,
          Text(
            body,
            style: TextStylesManager.bold14.copyWith(
              color: ColorsManager.mainText,
              height: 1.6,
            ),
          ),
          if (button != null) ...[
            verticalSpace20,
            SizedBox(
              width: double.infinity,
              height: 50,
              child: button!,
            ),
          ],
        ],
      ),
    );
  }
}

