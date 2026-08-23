
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:moean/features/curriculum/presentation/screens/curriculum_books_screen.dart';
import 'package:moean/features/curriculum/presentation/cubit/curriculum_distribution_cubit.dart';
import 'package:moean/features/curriculum/presentation/cubit/curriculum_books_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  testWidgets('Test books screen', (WidgetTester tester) async {
    await initInjections();
    sl<ThemeCubit>().init(isDark: true);
    
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => CurriculumDistributionCubit()),
            BlocProvider(create: (_) => CurriculumBooksCubit()),
          ],
          child: const CurriculumBooksScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  });
}

