class ClassSheetColumn {
  final String label;
  final num? max;

  const ClassSheetColumn({required this.label, this.max});

  ClassSheetColumn copyWith({String? label, num? max, bool clearMax = false}) => ClassSheetColumn(
        label: label ?? this.label,
        max: clearMax ? null : (max ?? this.max),
      );

  factory ClassSheetColumn.fromJson(Map<String, dynamic> json) => ClassSheetColumn(
        label: json['label']?.toString() ?? '',
        max: json['max'] != null ? num.tryParse(json['max'].toString()) : null,
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        if (max != null) 'max': max,
      };
}
