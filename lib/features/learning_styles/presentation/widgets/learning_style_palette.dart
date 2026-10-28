import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/features/learning_styles/data/models/learning_styles_models.dart';

/// A stable colour for each learning-style key, for the chart and the tags.
Color learningStyleColor(String key) {
  switch (key) {
    case LearningStyleKeys.visual:
      return ColorsManager.primaryColor;
    case LearningStyleKeys.auditory:
      return ColorsManager.statusActivity;
    case LearningStyleKeys.readWrite:
      return ColorsManager.secondaryColor;
    case LearningStyleKeys.kinesthetic:
      return ColorsManager.successColor;
    default:
      return ColorsManager.secondaryText;
  }
}
