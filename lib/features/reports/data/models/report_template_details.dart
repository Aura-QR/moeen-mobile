/// `GET /tools/reports/{key}`: the starting form plus the «✨ اكتب لي» flags.
class ReportTemplateDetails {
  final Map<String, dynamic> input;

  /// The template supports «✨ اكتب لي» (`report_template` AI job).
  final bool ai;

  /// The box's placeholder; empty when the server sent `null`.
  final String briefHint;

  const ReportTemplateDetails({this.input = const {}, this.ai = false, this.briefHint = ''});

  factory ReportTemplateDetails.fromJson(Map<String, dynamic> json) {
    final input = json['input'];
    return ReportTemplateDetails(
      input: input is Map ? Map<String, dynamic>.from(input) : const {},
      ai: json['ai'] == true,
      briefHint: (json['brief_hint'] ?? '').toString(),
    );
  }
}
