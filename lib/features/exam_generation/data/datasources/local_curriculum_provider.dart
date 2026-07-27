class LocalCurriculumProvider {
  // Simulating Grade Stage, Grade, Subject, Unit structure
  // This is a temporary local provider until backend endpoints are available.

  static const List<String> gradeStages = [
    'المرحلة الابتدائية',
    'المرحلة المتوسطة',
    'المرحلة الثانوية',
  ];

  static const Map<String, List<String>> gradesByStage = {
    'المرحلة الابتدائية': ['الصف الأول', 'الصف الثاني', 'الصف الثالث', 'الصف الرابع', 'الصف الخامس', 'الصف السادس'],
    'المرحلة المتوسطة': ['الصف الأول المتوسط', 'الصف الثاني المتوسط', 'الصف الثالث المتوسط'],
    'المرحلة الثانوية': ['الصف الأول الثانوي', 'الصف الثاني الثانوي', 'الصف الثالث الثانوي'],
  };

  static const List<String> subjects = [
    'القرآن الكريم',
    'الدراسات الإسلامية',
    'اللغة العربية',
    'الرياضيات',
    'العلوم',
    'اللغة الإنجليزية',
    'الدراسات الاجتماعية',
    'الحاسب وتقنية المعلومات',
  ];

  static const List<String> semesters = [
    'الفصل الدراسي الأول',
    'الفصل الدراسي الثاني',
  ];

  // Dummy Units based on Subject
  static const Map<String, List<String>> unitsBySubject = {
    'العلوم': [
      'طبيعة العلم',
      'الخلايا وتصنيف المخلوقات الحية',
      'الحيوانات اللافقارية',
      'الحيوانات الفقارية',
    ],
    'الرياضيات': [
      'الجبر',
      'الهندسة',
      'الإحصاء والاحتمالات',
      'المعادلات',
    ],
    // Default fallback
    'default': [
      'الوحدة الأولى',
      'الوحدة الثانية',
      'الوحدة الثالثة',
      'الوحدة الرابعة',
    ],
  };

  // Dummy Lessons based on Unit
  static List<Map<String, dynamic>> getLessonsForUnit(String unit) {
    if (unit == 'طبيعة العلم') {
      return [
        {'id': 101, 'name': 'العلم وعملياته'},
        {'id': 102, 'name': 'النماذج العلمية'},
        {'id': 103, 'name': 'تقويم التفسيرات العلمية'},
      ];
    }
    if (unit == 'الخلايا وتصنيف المخلوقات الحية') {
      return [
        {'id': 104, 'name': 'عالم الخلايا'},
        {'id': 105, 'name': 'وظائف الخلايا'},
        {'id': 106, 'name': 'تصنيف المخلوقات الحية'},
      ];
    }
    
    // Fallback
    return [
      {'id': DateTime.now().millisecondsSinceEpoch % 1000 + 1, 'name': '$unit - الدرس الأول'},
      {'id': DateTime.now().millisecondsSinceEpoch % 1000 + 2, 'name': '$unit - الدرس الثاني'},
      {'id': DateTime.now().millisecondsSinceEpoch % 1000 + 3, 'name': '$unit - الدرس الثالث'},
      {'id': DateTime.now().millisecondsSinceEpoch % 1000 + 4, 'name': '$unit - الدرس الرابع'},
    ];
  }
}
