import 'package:flutter/material.dart';
import 'package:moean/features/reading_comprehension/presentation/widgets/reading_passage_tab.dart';
import 'package:moean/features/reading_comprehension/presentation/widgets/reading_questions_tab.dart';
import 'package:moean/features/reading_comprehension/presentation/widgets/reading_vocabulary_tab.dart';

/// The three editor tabs: passage, vocabulary and questions.
class ReadingEditorBody extends StatelessWidget {
  const ReadingEditorBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBarView(
      children: [
        ReadingPassageTab(),
        ReadingVocabularyTab(),
        ReadingQuestionsTab(),
      ],
    );
  }
}
