import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/register/presentation/widgets/register_header_widget.dart';

class RegisterIllustrationWidget extends StatelessWidget {
  const RegisterIllustrationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child:
              RegisterHeaderWidget(),
             
        ),
        horizontalSpace16,
      
        Expanded(
          flex: 4,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              AssetsHelper.img2,
              fit: BoxFit.contain,
            ),
          ),
        ),
        
        ],
    );
  }
}
