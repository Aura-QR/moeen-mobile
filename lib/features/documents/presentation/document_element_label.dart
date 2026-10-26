import 'package:moean/core/utils/constants/constants.dart';

/// «العنصر 4» for a Ministry element number.
String elementNumberLabel(int number) =>
    appTranslation().get('performance_element_number').replaceAll('{n}', '$number');

/// «العنصر 4: title», or the title alone when there's no number.
String elementLabel(String title, int? number) => number == null ? title : '${elementNumberLabel(number)}: $title';
