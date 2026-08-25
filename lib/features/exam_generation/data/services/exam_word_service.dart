import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';
import 'package:moean/features/exam_generation/data/models/exam_models.dart';

class ExamWordService {
  /// Detects if text is primarily English (LTR).
  static bool isEnglishText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    int englishCount = 0;
    int arabicCount = 0;

    for (final rune in trimmed.runes) {
      if ((rune >= 0x0041 && rune <= 0x005A) || (rune >= 0x0061 && rune <= 0x007A)) {
        englishCount++;
      } else if (rune >= 0x0600 && rune <= 0x06FF) {
        arabicCount++;
      }
    }

    if (arabicCount == 0 && englishCount > 0) return true;
    if (englishCount == 0 && arabicCount > 0) return false;

    // Mixed text: check first alphabetic character (skipping numbers/symbols)
    for (final rune in trimmed.runes) {
      if ((rune >= 0x0041 && rune <= 0x005A) || (rune >= 0x0061 && rune <= 0x007A)) {
        return englishCount > arabicCount;
      } else if (rune >= 0x0600 && rune <= 0x06FF) {
        return false; // Starts with Arabic character -> RTL paragraph
      }
    }

    return englishCount > arabicCount;
  }

  static bool isRtlText(String text) => !isEnglishText(text);

  static String _escapeXml(String? text) {
    if (text == null) return '';
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  static String _pPrXml(
    String text, {
    String? align,
    bool? isEnglish,
    String tabs = '',
    String spacing = '',
  }) {
    final english = isEnglish ?? isEnglishText(text);
    final requestedJc = align ?? (english ? 'left' : 'right');
    final bidiXml = english ? '' : '<w:bidi w:val="1"/>';

    // Word/LibreOffice/Pages flip the visual meaning of w:jc left/right
    // whenever w:bidi is present on the same paragraph. Compensate by
    // emitting the opposite value so the VISUAL result matches intent.
    String jcVal = requestedJc;
    if (!english) {
      if (requestedJc == 'right') {
        jcVal = 'left';
      } else if (requestedJc == 'left') {
        jcVal = 'right';
      }
    }

    return '''<w:pPr>
      $tabs
      $bidiXml
      $spacing
      <w:jc w:val="$jcVal"/>
    </w:pPr>''';
  }

  /// Generates run properties XML (`<w:rPr>`) dynamically based on text language
  static String _rPrXml(
    String text, {
    bool bold = false,
    String? color,
    int size = 24,
    bool? isEnglish,
    String extra = '',
  }) {
    final english = isEnglish ?? isEnglishText(text);
    const font = 'Arial';
    final boldXml = bold ? '<w:b/><w:bCs/>' : '';
    final colorXml = color != null ? '<w:color w:val="$color"/>' : '';

    if (english) {
      return '''<w:rPr>
        <w:rFonts w:ascii="$font" w:hAnsi="$font" w:cs="$font"/>
        $boldXml
        $colorXml
        <w:sz w:val="$size"/><w:szCs w:val="$size"/>
        <w:lang w:val="en-US"/>
        $extra
      </w:rPr>''';
    } else {
      return '''<w:rPr>
        <w:rFonts w:ascii="$font" w:hAnsi="$font" w:cs="$font"/>
        $boldXml
        $colorXml
        <w:sz w:val="$size"/><w:szCs w:val="$size"/>
        <w:rtl w:val="1"/>
        <w:lang w:val="ar-SA" w:bidi="ar-SA"/>
        $extra
      </w:rPr>''';
    }
  }

  /// Builds a complete `<w:r>` element for text
  static String _buildRun(
    String text, {
    bool bold = false,
    String? color,
    int size = 24,
    bool preserveSpace = false,
    bool? isEnglish,
    String extraPr = '',
  }) {
    final safeText = _escapeXml(text);
    final spaceAttr = preserveSpace ? ' xml:space="preserve"' : '';
    final rPr = _rPrXml(
      text,
      bold: bold,
      color: color,
      size: size,
      isEnglish: isEnglish,
      extra: extraPr,
    );
    return '<w:r>$rPr<w:t$spaceAttr>$safeText</w:t></w:r>';
  }

  /// Generates Uint8List bytes of a valid Microsoft Word (.docx) file matching ExamPdfService exactly
  static Future<Uint8List> generateWordBytes({
    required ExamEntity exam,
    required bool showAnswers,
    required String teacherName,
    required String schoolName,
    required String educationOffice,
  }) async {
    final questions = List<QuestionEntity>.from(exam.questions)
      ..sort((a, b) => a.questionOrder.compareTo(b.questionOrder));

    final dateStr = exam.createdAt.contains('T') ? exam.createdAt.split('T')[0] : exam.createdAt;

    Uint8List? ministryBytes;
    Uint8List? logoBytes;

    try {
      final ByteData minData = await rootBundle.load('assets/images/minstry.jpg');
      ministryBytes = minData.buffer.asUint8List();
    } catch (_) {}

    try {
      final ByteData logoData = await rootBundle.load('assets/images/logo_icon-removebg-preview.png');
      logoBytes = logoData.buffer.asUint8List();
    } catch (_) {}

    final bool hasImages = ministryBytes != null && logoBytes != null;

    final documentXml = _buildDocumentXml(
      exam: exam,
      questions: questions,
      showAnswers: showAnswers,
      teacherName: teacherName,
      schoolName: schoolName,
      educationOffice: educationOffice,
      date: dateStr,
      hasImages: hasImages,
    );

    final archive = Archive();

    // 1. [Content_Types].xml
    const contentTypesXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Default Extension="png" ContentType="image/png"/>
  <Default Extension="jpg" ContentType="image/jpeg"/>
  <Default Extension="jpeg" ContentType="image/jpeg"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
  <Override PartName="/word/settings.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml"/>
  <Override PartName="/word/fontTable.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.fontTable+xml"/>
</Types>''';
    archive.addFile(ArchiveFile('[Content_Types].xml', utf8.encode(contentTypesXml).length, utf8.encode(contentTypesXml)));

    // 2. _rels/.rels
    const relsXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>''';
    archive.addFile(ArchiveFile('_rels/.rels', utf8.encode(relsXml).length, utf8.encode(relsXml)));

    // 3. word/_rels/document.xml.rels
    final docRelsXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings" Target="settings.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/fontTable" Target="fontTable.xml"/>
  ${hasImages ? '<Relationship Id="rIdLogo" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/logo.png"/>' : ''}
  ${hasImages ? '<Relationship Id="rIdMinistry" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/ministry.jpg"/>' : ''}
</Relationships>''';
    archive.addFile(ArchiveFile('word/_rels/document.xml.rels', utf8.encode(docRelsXml).length, utf8.encode(docRelsXml)));

    // Add image files to archive if available
    if (logoBytes != null) {
      archive.addFile(ArchiveFile('word/media/logo.png', logoBytes.length, logoBytes));
    }
    if (ministryBytes != null) {
      archive.addFile(ArchiveFile('word/media/ministry.jpg', ministryBytes.length, ministryBytes));
    }

    // 4. word/settings.xml
    const settingsXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:settings xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:defaultTabStop w:val="720"/>
  <w:characterSpacingControl w:val="doNotCompress"/>
  <w:themeFontLang w:val="en-US" w:bidi="ar-SA"/>
  <w:compat>
    <w:compatSetting w:name="compatibilityMode" w:uri="http://schemas.microsoft.com/office/word" w:val="15"/>
  </w:compat>
</w:settings>''';
    archive.addFile(ArchiveFile('word/settings.xml', utf8.encode(settingsXml).length, utf8.encode(settingsXml)));

    // 5. word/fontTable.xml
    const fontTableXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:fonts xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:font w:name="Tajawal">
    <w:altName w:val="Arial"/>
    <w:charset w:val="178"/>
    <w:family w:val="swiss"/>
    <w:pitch w:val="variable"/>
  </w:font>
  <w:font w:name="Arial">
    <w:charset w:val="178"/>
    <w:family w:val="swiss"/>
    <w:pitch w:val="variable"/>
  </w:font>
  <w:font w:name="Segoe UI">
    <w:charset w:val="0"/>
    <w:family w:val="swiss"/>
    <w:pitch w:val="variable"/>
  </w:font>
</w:fonts>''';
    archive.addFile(ArchiveFile('word/fontTable.xml', utf8.encode(fontTableXml).length, utf8.encode(fontTableXml)));

    // 6. word/styles.xml
    final bool isExamRtl = !isEnglishText(exam.title);
    final String bidiXmlDefault = isExamRtl ? '<w:bidi w:val="1"/>' : '';
    final String jcXmlDefault = isExamRtl ? '<w:jc w:val="left"/>' : '';

    final stylesXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults>
    <w:rPrDefault>
      <w:rPr>
        <w:rFonts w:ascii="Arial" w:hAnsi="Arial" w:cs="Tajawal"/>
        <w:sz w:val="24"/>
        <w:szCs w:val="24"/>
        <w:lang w:val="en-US" w:bidi="ar-SA"/>
      </w:rPr>
    </w:rPrDefault>
    <w:pPrDefault>
      <w:pPr>
        $bidiXmlDefault
        <w:spacing w:after="100" w:line="240" w:lineRule="auto"/>
        $jcXmlDefault
      </w:pPr>
    </w:pPrDefault>
  </w:docDefaults>
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal">
    <w:name w:val="Normal"/>
    <w:qFormat/>
    <w:pPr>
      $bidiXmlDefault
      <w:spacing w:after="100" w:line="240" w:lineRule="auto"/>
      $jcXmlDefault
    </w:pPr>
    <w:rPr>
      <w:rFonts w:ascii="Arial" w:hAnsi="Arial" w:cs="Tajawal"/>
      <w:sz w:val="24"/>
      <w:szCs w:val="24"/>
      <w:lang w:val="en-US" w:bidi="ar-SA"/>
    </w:rPr>
  </w:style>
</w:styles>''';
    archive.addFile(ArchiveFile('word/styles.xml', utf8.encode(stylesXml).length, utf8.encode(stylesXml)));

    // 7. word/document.xml
    final docBytes = utf8.encode(documentXml);
    archive.addFile(ArchiveFile('word/document.xml', docBytes.length, docBytes));

    final zipData = ZipEncoder().encode(archive);
    return Uint8List.fromList(zipData);
  }

  static String _buildDocumentXml({
    required ExamEntity exam,
    required List<QuestionEntity> questions,
    required bool showAnswers,
    required String teacherName,
    required String schoolName,
    required String educationOffice,
    required String date,
    required bool hasImages,
  }) {
    final sb = StringBuffer();
    sb.write('''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
            xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
            xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
            xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
            xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
  <w:body>
''');

    final officeText = educationOffice.isNotEmpty ? educationOffice : 'الإدارة العامة للتعليم';
    final isOfficeEng = isEnglishText(officeText);

    final schoolText = schoolName.isNotEmpty ? schoolName : 'مواهب المملكة';
    final isSchoolEng = isEnglishText(schoolText);

    final isTeacherEng = teacherName.isNotEmpty && isEnglishText(teacherName);
    final teacherLabel = isTeacherEng ? 'Teacher: ' : 'المعلم: ';
    final teacherFullText = '$teacherLabel$teacherName';

    final isDateEng = isEnglishText(date);
    final dateLabel = isDateEng ? 'Date: ' : 'التاريخ: ';
    final dateFullText = '$dateLabel$date';

    // Header Table matching PDF Header exactly (width: 10466 dxa)
    sb.write('''
    <w:tbl>
      <w:tblPr>
        <w:tblW w:w="10466" w:type="dxa"/>
        <w:jc w:val="center"/>
        <w:bidiVisual w:val="1"/>
        <w:tblBorders>
          <w:top w:val="none"/><w:left w:val="none"/><w:bottom w:val="none"/><w:right w:val="none"/>
          <w:insideH w:val="none"/><w:insideV w:val="none"/>
        </w:tblBorders>
        <w:tblCellMar>
          <w:top w:w="240" w:type="dxa"/>
          <w:left w:w="280" w:type="dxa"/>
          <w:bottom w:w="240" w:type="dxa"/>
          <w:right w:w="280" w:type="dxa"/>
        </w:tblCellMar>
      </w:tblPr>
      <w:tblGrid>
        <w:gridCol w:w="7266"/>
        <w:gridCol w:w="3200"/>
      </w:tblGrid>
      <w:tr>
        <w:tc>
          <w:tcPr>
            <w:tcW w:w="7266" w:type="dxa"/>
            <w:shd w:val="clear" w:color="auto" w:fill="0B4A45"/>
            <w:vAlign w:val="center"/>
          </w:tcPr>
          <w:p>
            ${_pPrXml(officeText, isEnglish: isOfficeEng, spacing: '<w:spacing w:after="40"/>')}
            ${_buildRun(officeText, bold: true, color: 'FFFFFF', size: 32, isEnglish: isOfficeEng)}
          </w:p>
          <w:p>
            ${_pPrXml(schoolText, isEnglish: isSchoolEng, spacing: '<w:spacing w:after="160"/>')}
            ${_buildRun(schoolText, bold: true, color: '80DEEA', size: 20, isEnglish: isSchoolEng)}
          </w:p>
          <w:p>
            ${_pPrXml(teacherFullText, isEnglish: isTeacherEng, spacing: '<w:spacing w:after="40"/>')}
            ${_buildRun(teacherFullText, color: 'FFFFFF', size: 20, isEnglish: isTeacherEng)}
          </w:p>
          <w:p>
            ${_pPrXml(dateFullText, isEnglish: isDateEng, spacing: '<w:spacing w:after="0"/>')}
            ${_buildRun(dateFullText, color: 'FFFFFF', size: 20, isEnglish: isDateEng)}
          </w:p>
        </w:tc>
        <w:tc>
          <w:tcPr>
            <w:tcW w:w="3200" w:type="dxa"/>
            <w:shd w:val="clear" w:color="auto" w:fill="0B4A45"/>
            <w:vAlign w:val="center"/>
          </w:tcPr>
''');

    if (hasImages) {
      sb.write('''
          <w:p>
            <w:pPr><w:bidi w:val="1"/><w:spacing w:after="0"/><w:jc w:val="left"/></w:pPr>
            <w:r>
              <w:drawing>
                <wp:inline distT="0" distB="0" distL="0" distR="0">
                  <wp:extent cx="571500" cy="571500"/>
                  <wp:docPr id="1" name="Logo"/>
                  <a:graphic>
                    <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
                      <pic:pic>
                        <pic:nvPicPr>
                          <pic:cNvPr id="1" name="Logo"/>
                          <pic:cNvPicPr/>
                        </pic:nvPicPr>
                        <pic:blipFill>
                          <a:blip r:embed="rIdLogo"/>
                          <a:stretch><a:fillRect/></a:stretch>
                        </pic:blipFill>
                        <pic:spPr>
                          <a:xfrm><a:off x="0" y="0"/><a:ext cx="571500" cy="571500"/></a:xfrm>
                          <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
                        </pic:spPr>
                      </pic:pic>
                    </a:graphicData>
                  </a:graphic>
                </wp:inline>
              </w:drawing>
            </w:r>
            <w:r><w:t xml:space="preserve">  </w:t></w:r>
            <w:r>
              <w:drawing>
                <wp:inline distT="0" distB="0" distL="0" distR="0">
                  <wp:extent cx="571500" cy="571500"/>
                  <wp:docPr id="2" name="Ministry"/>
                  <a:graphic>
                    <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
                      <pic:pic>
                        <pic:nvPicPr>
                          <pic:cNvPr id="2" name="Ministry"/>
                          <pic:cNvPicPr/>
                        </pic:nvPicPr>
                        <pic:blipFill>
                          <a:blip r:embed="rIdMinistry"/>
                          <a:stretch><a:fillRect/></a:stretch>
                        </pic:blipFill>
                        <pic:spPr>
                          <a:xfrm><a:off x="0" y="0"/><a:ext cx="571500" cy="571500"/></a:xfrm>
                          <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
                        </pic:spPr>
                      </pic:pic>
                    </a:graphicData>
                  </a:graphic>
                </wp:inline>
              </w:drawing>
            </w:r>
          </w:p>
''');
    } else {
      sb.write('''
          <w:p>
            ${_pPrXml('المملكة العربية السعودية', align: 'left', isEnglish: false, spacing: '<w:spacing w:after="40"/>')}
            ${_buildRun('المملكة العربية السعودية', bold: true, color: 'FFFFFF', size: 22, isEnglish: false)}
          </w:p>
          <w:p>
            ${_pPrXml('وزارة التعليم', align: 'left', isEnglish: false, spacing: '<w:spacing w:after="40"/>')}
            ${_buildRun('وزارة التعليم', bold: true, color: 'FFFFFF', size: 22, isEnglish: false)}
          </w:p>
''');
    }

    sb.write('''
        </w:tc>
      </w:tr>
    </w:tbl>
''');

    // Exam Title
    final isTitleEng = isEnglishText(exam.title);
    sb.write('''
    <w:p>
      ${_pPrXml(exam.title, align: 'center', isEnglish: isTitleEng, spacing: '<w:spacing w:before="360" w:after="360"/>')}
      ${_buildRun(exam.title, bold: true, color: '073F49', size: 32, isEnglish: isTitleEng)}
    </w:p>
''');

    // Questions List
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final isQEng = isEnglishText(q.questionText);
      final pointsText = isQEng
          ? '[${q.points} point${q.points > 1 ? "s" : ""}]'
          : '[${q.points} درجة]';

      final tabVal = isQEng ? 'right' : 'left';
      final tabsXml = '<w:tabs><w:tab w:val="$tabVal" w:pos="9500"/></w:tabs>';

      // Question Title Row
      sb.write('''
    <w:p>
      ${_pPrXml(
        q.questionText,
        isEnglish: isQEng,
        tabs: tabsXml,
        spacing: '<w:spacing w:before="240" w:after="100"/>',
      )}
      ${_buildRun('${q.questionOrder}. ', bold: true, color: '1E293B', size: 24, preserveSpace: true, isEnglish: isQEng)}
      ${_buildRun(q.questionText, bold: true, color: '1E293B', size: 24, isEnglish: isQEng)}
      <w:r><w:tab/></w:r>
      ${_buildRun(pointsText, color: '64748B', size: 20, isEnglish: isQEng)}
    </w:p>
''');

      if (q.type == 'mcq') {
        final options = List<String>.from(q.options ?? []);
        const arabicLabels = ['أ', 'ب', 'ج', 'د', 'هـ', 'و', 'ز', 'ح'];
        const englishLabels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

        for (int j = 0; j < options.length; j++) {
          var opt = options[j].trim();
          final isCorrect = opt == q.correctAnswer;

          // Clean existing prefix like "أ. " or "أ) " if option string already has it to avoid "أ. أ."
          opt = opt.replaceAll(RegExp(r'^[أبجدأ-يA-Za-z0-9][\.\)\-]\s*'), '');

          final isOptEng = isEnglishText(opt);
          final textColor = (showAnswers && isCorrect) ? '15803D' : '1E293B';
          final isBold = showAnswers && isCorrect;

          final label = isQEng
              ? (j < englishLabels.length ? '${englishLabels[j]}.' : '${j + 1}.')
              : (j < arabicLabels.length ? '${arabicLabels[j]}.' : '${j + 1}.');

          final checkMark = (showAnswers && isCorrect) ? '  ✓' : '';

          sb.write('''
    <w:p>
      ${_pPrXml(
        q.questionText,
        isEnglish: isQEng,
        spacing: '<w:spacing w:after="80"/>',
      )}
      ${_buildRun('$label  ', bold: isBold, color: textColor, size: 24, preserveSpace: true, isEnglish: isQEng)}
      ${_buildRun(opt, bold: isBold, color: textColor, size: 24, isEnglish: isOptEng)}
      ${_buildRun(checkMark, bold: true, color: '15803D', size: 24, preserveSpace: true, isEnglish: isQEng)}
    </w:p>
''');
        }
      } else if (q.type == 'true_false') {
        final isTrueCorrect = showAnswers && (q.correctAnswer == 'صح' || q.correctAnswer.toLowerCase() == 'true');
        final isFalseCorrect = showAnswers && (q.correctAnswer == 'خطأ' || q.correctAnswer.toLowerCase() == 'false');

        final trueLabel = isQEng ? 'True' : 'صح';
        final falseLabel = isQEng ? 'False' : 'خطأ';

        final trueBox = isTrueCorrect ? '[✓]' : '[  ]';
        final falseBox = isFalseCorrect ? '[✓]' : '[  ]';

        final trueColor = isTrueCorrect ? '15803D' : '1E293B';
        final falseColor = isFalseCorrect ? '15803D' : '1E293B';

        sb.write('''
    <w:p>
      ${_pPrXml(
        q.questionText,
        isEnglish: isQEng,
        spacing: '<w:spacing w:before="60" w:after="80"/>',
      )}
      ${_buildRun('$trueBox ', bold: isTrueCorrect, color: trueColor, size: 24, preserveSpace: true, isEnglish: isQEng)}
      ${_buildRun('$trueLabel               ', bold: isTrueCorrect, color: trueColor, size: 24, preserveSpace: true, isEnglish: isQEng)}
      ${_buildRun('$falseBox ', bold: isFalseCorrect, color: falseColor, size: 24, preserveSpace: true, isEnglish: isQEng)}
      ${_buildRun(falseLabel, bold: isFalseCorrect, color: falseColor, size: 24, isEnglish: isQEng)}
    </w:p>
''');
      } else if (q.type == 'matching') {
        List<String> colA = [];
        List<String> colB = [];
        if (q.options is MatchingOptionsModel) {
          colA = (q.options as MatchingOptionsModel).columnA;
          colB = (q.options as MatchingOptionsModel).columnB;
        } else if (q.options is Map) {
          colA = List<String>.from(q.options['column_a'] ?? []);
          colB = List<String>.from(q.options['column_b'] ?? []);
        }

        final bidiTableXml = isQEng ? '' : '<w:bidiVisual w:val="1"/>';

        sb.write('''
    <w:tbl>
      <w:tblPr>
        <w:tblW w:w="10466" w:type="dxa"/>
        <w:jc w:val="center"/>
        $bidiTableXml
        <w:tblBorders>
          <w:top w:val="none"/><w:left w:val="none"/><w:bottom w:val="none"/><w:right w:val="none"/>
          <w:insideH w:val="none"/><w:insideV w:val="none"/>
        </w:tblBorders>
        <w:tblCellMar><w:top w:w="80" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tblCellMar>
      </w:tblPr>
      <w:tblGrid>
        <w:gridCol w:w="5233"/>
        <w:gridCol w:w="5233"/>
      </w:tblGrid>
''');
        final maxLen = colA.length > colB.length ? colA.length : colB.length;
        for (int row = 0; row < maxLen; row++) {
          final itemA = row < colA.length ? colA[row] : '';
          final itemB = row < colB.length ? colB[row] : '';

          final isItemAEng = itemA.isNotEmpty ? isEnglishText(itemA) : isQEng;
          final isItemBEng = itemB.isNotEmpty ? isEnglishText(itemB) : isQEng;

          sb.write('''
      <w:tr>
        <w:tc>
          <w:tcPr><w:tcW w:w="5233" w:type="dxa"/></w:tcPr>
          <w:p>
            ${_pPrXml(itemA, isEnglish: isItemAEng, spacing: '<w:spacing w:after="80"/>')}
            ${_buildRun('•  $itemA', size: 24, isEnglish: isItemAEng)}
          </w:p>
        </w:tc>
        <w:tc>
          <w:tcPr><w:tcW w:w="5233" w:type="dxa"/></w:tcPr>
          <w:p>
            ${_pPrXml(itemB, isEnglish: isItemBEng, spacing: '<w:spacing w:after="80"/>')}
            ${_buildRun('•  $itemB', size: 24, isEnglish: isItemBEng)}
          </w:p>
        </w:tc>
      </w:tr>
''');
        }
        sb.write('    </w:tbl>\n');
      } else if (q.type == 'essay') {
        sb.write('''
    <w:tbl>
      <w:tblPr>
        <w:tblW w:w="10466" w:type="dxa"/>
        <w:jc w:val="center"/>
        <w:tblBorders>
          <w:top w:val="single" w:sz="6" w:color="CBD5E1"/>
          <w:left w:val="single" w:sz="6" w:color="CBD5E1"/>
          <w:bottom w:val="single" w:sz="6" w:color="CBD5E1"/>
          <w:right w:val="single" w:sz="6" w:color="CBD5E1"/>
        </w:tblBorders>
        <w:shd w:val="clear" w:color="auto" w:fill="F8FAFC"/>
      </w:tblPr>
      <w:tblGrid>
        <w:gridCol w:w="10466"/>
      </w:tblGrid>
      <w:tr>
        <w:trPr><w:trHeight w:val="1400"/></w:trPr>
        <w:tc>
          <w:tcPr><w:tcW w:w="10466" w:type="dxa"/><w:shd w:val="clear" w:color="auto" w:fill="F8FAFC"/></w:tcPr>
          <w:p><w:pPr><w:spacing w:after="0"/></w:pPr><w:r><w:t></w:t></w:r></w:p>
        </w:tc>
      </w:tr>
    </w:tbl>
''');
      }

      // Show Correct Answer for non-MCQ / non-matching
      if (showAnswers && q.type != 'mcq' && q.type != 'matching' && q.correctAnswer.isNotEmpty) {
        final answerText = q.correctAnswer;
        final label = isQEng ? 'Answer: ' : 'الإجابة: ';
        final fullAnsText = '$label$answerText';

        sb.write('''
    <w:p>
      ${_pPrXml(
        q.questionText,
        isEnglish: isQEng,
        spacing: '<w:spacing w:before="120" w:after="160"/>',
      )}
      ${_buildRun(fullAnsText, bold: true, color: '15803D', size: 24, preserveSpace: true, isEnglish: isQEng)}
    </w:p>
''');
      }

      // Spacing after each question
      sb.write('''
    <w:p>
      <w:pPr><w:spacing w:after="140"/></w:pPr>
    </w:p>
''');
    }

    final bool isExamRtl = !isEnglishText(exam.title);
    sb.write('''
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="720" w:right="720" w:bottom="720" w:left="720" w:header="720" w:footer="720" w:gutter="0"/>
      ${isExamRtl ? '<w:bidi w:val="1"/>' : ''}
      <w:docGrid w:linePitch="360"/>
    </w:sectPr>
  </w:body>
</w:document>''');

    return sb.toString();
  }

  static Future<String> generateWordFile({
    required ExamEntity exam,
    required bool showAnswers,
    required String teacherName,
    required String schoolName,
    required String educationOffice,
  }) async {
    final bytes = await generateWordBytes(
      exam: exam,
      showAnswers: showAnswers,
      teacherName: teacherName,
      schoolName: schoolName,
      educationOffice: educationOffice,
    );

    final tempDir = await getTemporaryDirectory();
    final sanitizedTitle = exam.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final filePath = '${tempDir.path}/$sanitizedTitle.docx';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  static Future<void> shareWordExam({
    required ExamEntity exam,
    required bool showAnswers,
    required String teacherName,
    required String schoolName,
    required String educationOffice,
  }) async {
    final filePath = await generateWordFile(
      exam: exam,
      showAnswers: showAnswers,
      teacherName: teacherName,
      schoolName: schoolName,
      educationOffice: educationOffice,
    );

    await Share.shareXFiles(
      [
        XFile(
          filePath,
          mimeType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          name: '${exam.title}.docx',
        )
      ],
      text: 'اختبار: ${exam.title}',
    );
  }
}
