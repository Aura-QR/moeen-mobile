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
    // Some endpoints wrap the model in a "presentation" key, while others might return it directly.
    final data = json.containsKey('presentation') ? (json['presentation'] as Map<String, dynamic>) : json;
    
    return PresentationModel(
      id: data['id'] as int? ?? 0,
      lessonId: data['lesson_id'] as int? ?? 0,
      status: data['status'] as String? ?? json['status'] as String? ?? 'pending',
      templateId: data['template_id'] as String?,
      filePath: data['file_path'] as String?,
      slideCount: data['slide_count'] as int?,
      generatedAt: data['generated_at'] as String?,
      generationError: data['generation_error'] as String?,
      slides: (data['slides'] as List<dynamic>?)
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
  final String? iconId;
  final String? iconUrl;

  PresentationSlideModel({
    required this.id,
    required this.slideOrder,
    required this.slideType,
    required this.title,
    required this.bodyText,
    this.iconKeyword,
    this.iconId,
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
      iconId: json['icon_id'] as String?,
      iconUrl: json['icon_url'] as String?,
    );
  }
}
