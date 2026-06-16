// import 'package:flutter/material.dart';
// import 'package:moean/core/utils/constants/assets_helper.dart';

// class LoginIllustrationWidget extends StatelessWidget {
//   const LoginIllustrationWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 220,
//       width: double.infinity,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // Background decorative circle
//           Positioned(
//             top: 10,
//             child: Container(
//               width: 200,
//               height: 200,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: const Color(0xFF0E7A5E).withValues(alpha: 0.06),
//               ),
//             ),
//           ),
//           // Sparkle decoration top-left
//           const Positioned(
//             top: 18,
//             left: 40,
//             child: _SparkleIcon(size: 16),
//           ),
//           // Sparkle decoration top-right
//           const Positioned(
//             top: 30,
//             right: 50,
//             child: _SparkleIcon(size: 12),
//           ),
//           // Sparkle decoration bottom-right
//           const Positioned(
//             bottom: 20,
//             right: 30,
//             child: _SparkleIcon(size: 10),
//           ),
//           // Main illustration image
//           Image.asset(
//             AssetsHelper.img6,
//             height: 180,
//             fit: BoxFit.contain,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SparkleIcon extends StatelessWidget {
//   final double size;
//   const _SparkleIcon({required this.size});

//   @override
//   Widget build(BuildContext context) {
//     return Icon(
//       Icons.auto_awesome,
//       size: size,
//       color: const Color(0xFFE2AD3B),
//     );
//   }
// }
