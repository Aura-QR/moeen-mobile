class PresentationModel {
  final int id;
  final int lessonId;
  final String status;
  final String? templateId;
  final String? filePath;
  final int? slideCount;
  final String? generatedAt;
  final String? generationError;
  final List<PresentationSlideModel> slides;

  PresentationModel({
    required this.id,
    required this.lessonId,
    required this.status,
    this.templateId,
    this.filePath,
    this.slideCount,
    this.generatedAt,
    this.generationError,
    this.slides = const [],
  });

  factory PresentationModel.fromJson(Map<String, dynamic> json) {
    return PresentationModel(
      id: json['id'] as int? ?? 0,
      lessonId: json['lesson_id'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      templateId: json['template_id'] as String?,
      filePath: json['file_path'] as String?,
      slideCount: json['slide_count'] as int?,
      generatedAt: json['generated_at'] as String?,
      generationError: json['generation_error'] as String?,
      slides: (json['slides'] as List<dynamic>?)
              ?.map((e) => PresentationSlideModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class PresentationSlideModel {
  final int id;
  final int slideOrder;
  final String slideType;
  final String title;
  final String bodyText;
  final String? iconKeyword;
  final String? iconUrl;

  PresentationSlideModel({
    required this.id,
    required this.slideOrder,
    required this.slideType,
    required this.title,
    required this.bodyText,
    this.iconKeyword,
    this.iconUrl,
  });

  factory PresentationSlideModel.fromJson(Map<String, dynamic> json) {
    return PresentationSlideModel(
      id: json['id'] as int,
      slideOrder: json['slide_order'] as int,
      slideType: json['slide_type'] as String,
      title: json['title'] as String,
      bodyText: json['body_text'] as String,
      iconKeyword: json['icon_keyword'] as String?,
      iconUrl: json['icon_url'] as String?,
    );
  }
}
