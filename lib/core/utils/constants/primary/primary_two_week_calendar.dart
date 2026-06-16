// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:moean/core/theme/colors.dart';
// import 'package:moean/core/theme/text_styles.dart';
// import 'package:moean/core/utils/constants/spacing.dart';

// class PrimaryTwoWeekCalendar extends StatelessWidget {
//   final DateTime currentWeekStart;
//   final DateTime selectedDate;
//   final VoidCallback onPreviousWeek;
//   final VoidCallback onNextWeek;
//   final Function(DateTime) onDateSelected;

//   const PrimaryTwoWeekCalendar({
//     super.key,
//     required this.currentWeekStart,
//     required this.selectedDate,
//     required this.onPreviousWeek,
//     required this.onNextWeek,
//     required this.onDateSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: ColorsManager.surfacePrimary,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: ColorsManager.borderColor),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.04),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 DateFormat('MMMM yyyy').format(currentWeekStart),
//                 style: TextStylesManager.bold16.copyWith(color: ColorsManager.textPrimary),
//               ),
//               Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.chevron_left, size: 24),
//                     onPressed: onPreviousWeek,
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.chevron_right, size: 24),
//                     onPressed: onNextWeek,
//                   ),
//                 ],
//               )
//             ],
//           ),
//           verticalSpace12,
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: List.generate(7, (index) {
//               final dayDate = currentWeekStart.add(Duration(days: index));
//               final dayStr = DateFormat('EE').format(dayDate).toUpperCase(); // e.g., MO, TU
//               return SizedBox(
//                 width: 32,
//                 child: Center(
//                   child: Text(
//                     dayStr.substring(0, 2),
//                     style: TextStylesManager.bold12.copyWith(color: Colors.grey),
//                   ),
//                 ),
//               );
//             }),
//           ),
//           verticalSpace8,
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 7,
//               mainAxisSpacing: 8,
//               crossAxisSpacing: 8,
//             ),
//             itemCount: 14,
//             itemBuilder: (context, index) {
//               final date = currentWeekStart.add(Duration(days: index));
//               final isSelected = date.year == selectedDate.year &&
//                   date.month == selectedDate.month &&
//                   date.day == selectedDate.day;
              
//               final now = DateTime.now();
//               final today = DateTime(now.year, now.month, now.day);
//               final currentDate = DateTime(date.year, date.month, date.day);
//               final isBeforeToday = currentDate.isBefore(today);

//               return GestureDetector(
//                 onTap: isBeforeToday ? null : () => onDateSelected(date),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: isSelected ? ColorsManager.primaryColor : Colors.transparent,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Center(
//                     child: Text(
//                       '${date.day}',
//                       style: TextStylesManager.medium14.copyWith(
//                         color: isSelected
//                             ? Colors.white
//                             : (isBeforeToday ? Colors.grey.withValues(alpha: 0.3) : ColorsManager.textPrimary),
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
