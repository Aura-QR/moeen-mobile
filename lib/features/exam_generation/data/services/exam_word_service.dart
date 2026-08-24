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
  static bool isEnglishText(String text) {
    if (text.trim().isEmpty) return false;
    int englishCount = 0;
    int arabicCount = 0;

    for (final rune in text.runes) {
      if ((rune >= 0x0041 && rune <= 0x005A) || (rune >= 0x0061 && rune <= 0x007A)) {
        englishCount++;
      } else if (rune >= 0x0600 && rune <= 0x06FF) {
        arabicCount++;
      }
    }

    return englishCount > arabicCount;
  }

  static String _escapeXml(String? text) {
    if (text == null) return '';
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
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
  <w:bidi w:val="1"/>
  <w:defaultTabStop w:val="720"/>
  <w:characterSpacingControl w:val="doNotCompress"/>
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
    const stylesXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults>
    <w:rPrDefault>
      <w:rPr>
        <w:rFonts w:ascii="Tajawal" w:hAnsi="Tajawal" w:cs="Tajawal" w:eastAsia="Tajawal"/>
        <w:sz w:val="24"/>
        <w:szCs w:val="24"/>
        <w:rtl w:val="1"/>
        <w:lang w:val="ar-SA" w:bidi="ar-SA" w:eastAsia="ar-SA"/>
      </w:rPr>
    </w:rPrDefault>
    <w:pPrDefault>
      <w:pPr>
        <w:bidi w:val="1"/>
        <w:jc w:val="right"/>
        <w:spacing w:after="100" w:line="240" w:lineRule="auto"/>
      </w:pPr>
    </w:pPrDefault>
  </w:docDefaults>
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal">
    <w:name w:val="Normal"/>
    <w:qFormat/>
    <w:pPr>
      <w:bidi w:val="1"/>
      <w:jc w:val="right"/>
    </w:pPr>
    <w:rPr>
      <w:rFonts w:ascii="Tajawal" w:hAnsi="Tajawal" w:cs="Tajawal"/>
      <w:sz w:val="24"/>
      <w:szCs w:val="24"/>
      <w:rtl w:val="1"/>
      <w:lang w:val="ar-SA" w:bidi="ar-SA"/>
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

    final safeOffice = _escapeXml(educationOffice.isNotEmpty ? educationOffice : 'الإدارة العامة للتعليم');
    final safeSchool = _escapeXml(schoolName.isNotEmpty ? schoolName : 'مواهب المملكة');
    final safeTeacher = _escapeXml(teacherName);
    final safeDate = _escapeXml(date);
    final safeExamTitle = _escapeXml(exam.title);

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
            <w:pPr><w:bidi w:val="1"/><w:jc w:val="right"/><w:spacing w:after="40"/></w:pPr>
            <w:r><w:rPr><w:rFonts w:ascii="Tajawal" w:hAnsi="Tajawal" w:cs="Tajawal"/><w:b/><w:color w:val="FFFFFF"/><w:sz w:val="32"/><w:szCs w:val="32"/><w:rtl w:val="1"/><w:lang w:val="ar-SA" w:bidi="ar-SA"/></w:rPr><w:t>\u200F$safeOffice</w:t></w:r>
          </w:p>
          <w:p>
            <w:pPr><w:bidi w:val="1"/><w:jc w:val="right"/><w:spacing w:after="160"/></w:pPr>
            <w:r><w:rPr><w:rFonts w:ascii="Tajawal" w:hAnsi="Tajawal" w:cs="Tajawal"/><w:b/><w:color w:val="80DEEA"/><w:sz w:val="20"/><w:szCs w:val="20"/><w:rtl w:val="1"/><w:lang w:val="ar-SA" w:bidi="ar-SA"/></w:rPr><w:t>\u200F$safeSchool</w:t></w:r>
          </w:p>
          <w:p>
            <w:pPr><w:bidi w:val="1"/><w:jc w:val="right"/><w:spacing w:after="40"/></w:pPr>
            <w:r><w:rPr><w:rFonts w:ascii="Tajawal" w:hAnsi="Tajawal" w:cs="Tajawal"/><w:color w:val="FFFFFF"/><w:sz w:val="20"/><w:szCs w:val="20"/><w:rtl w:val="1"/><w:lang w:val="ar-SA" w:bidi="ar-SA"/></w:rPr><w:t>\u200Fالمعلم: $safeTeacher</w:t></w:r>
          </w:p>
          <w:p>
            <w:pPr><w:bidi w:val="1"/><w:jc w:val="right"/><w:spacing w:after="0"/></w:pPr>
            <w:r><w:rPr><w:rFonts w:ascii="Tajawal" w:hAnsi="Tajawal" w:cs="Tajawal"/><w:color w:val="FFFFFF"/><w:sz w:val="20"/><w:szCs w:val="20"/><w:rtl w:val="1"/><w:lang w:val="ar-SA" w:bidi="ar-SA"/></w:rPr><w:t>\u200Fالتاريخ: $safeDate</w:t></w:r>
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
            <w:pPr><w:bidi w:val="1"/><w:jc w:val="left"/><w:spacing w:after="0"/></w:pPr>
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
            <w:pPr><w:bidi w:val="1"/><w:jc w:val="left"/><w:spacing w:after="40"/></w:pPr>
            <w:r><w:rPr><w:rFonts w:ascii="Tajawal" w:hAnsi="Tajawal" w:cs="Tajawal"/><w:b/><w:color w:val="FFFFFF"/><w:sz w:val="22"/><w:szCs w:val="24"/><w:rtl w:val="1"/><w:lang w:val="ar-SA" w:bidi="ar-SA"/></w:rPr><w:t>\u200Fالمملكة العربية السعودية</w:t></w:r>
          </w:p>
          <w:p>
            <w:pPr><w:bidi w:val="1"/><w:jc w:val="left"/><w:spacing w:after="40"/></w:pPr>
            <w:r><w:rPr><w:rFonts w:ascii="Tajawal" w:hAnsi="Tajawal" w:cs="Tajawal"/><w:b/><w:color w:val="FFFFFF"/><w:sz w:val="22"/><w:szCs w:val="24"/><w:rtl w:val="1"/><w:lang w:val="ar-SA" w:bidi="ar-SA"/></w:rPr><w:t>\u200Fوزارة التعليم</w:t></w:r>
          </w:p>
''');
    }

    sb.write('''
        </w:tc>
      </w:tr>
    </w:tbl>
''');

    // Exam Title
    final isExamTitleEnglish = isEnglishText(exam.title);
    sb.write('''
    <w:p>
      <w:pPr>
        <w:bidi w:val="${isExamTitleEnglish ? "0" : "1"}"/>
        <w:jc w:val="center"/>
        <w:spacing w:before="360" w:after="360"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:rFonts w:ascii="Tajawal" w:hAnsi="Tajawal" w:cs="Tajawal"/>
          <w:b/>
          <w:color w:val="073F49"/>
          <w:sz w:val="32"/>
          <w:szCs w:val="32"/>
          <w:rtl w:val="${isExamTitleEnglish ? "0" : "1"}"/>
          <w:lang w:val="${isExamTitleEnglish ? "en-US" : "ar-SA"}" w:bidi="${isExamTitleEnglish ? "en-US" : "ar-SA"}"/>
        </w:rPr>
        <w:t>${isExamTitleEnglish ? "" : "\u200F"}$safeExamTitle</w:t>
      </w:r>
    </w:p>
''');

    // Questions List
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final isQEnglish = isEnglishText(q.questionText);
      final safeQText = _escapeXml(q.questionText);
      final pointsText = isQEnglish
          ? '[${q.points} point${q.points > 1 ? "s" : ""}]'
          : '[${q.points} درجة]';

      // Question Title Row: Standard paragraph aligned to the starting side with points appended
      sb.write('''
    <w:p>
      <w:pPr>
        <w:bidi w:val="${isQEnglish ? "0" : "1"}"/>
        <w:jc w:val="${isQEnglish ? "left" : "right"}"/>
        <w:tabs>
          <w:tab w:val="${isQEnglish ? "right" : "left"}" w:pos="10466"/>
        </w:tabs>
        <w:spacing w:before="240" w:after="100"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:rFonts w:ascii="Tajawal" w:hAnsi="Tajawal" w:cs="Tajawal"/>
          <w:b/>
          <w:color w:val="1E293B"/>
          <w:sz w:val="24"/>
          <w:szCs w:val="24"/>
          <w:rtl w:val="${isQEnglish ? "0" : "1"}"/>
          <w:lang w:val="${isQEnglish ? "en-US" : "ar-SA"}" w:bidi="${isQEnglish ? "en-US" : "ar-SA"}"/>
        </w:rPr>
        <w:t xml:space="preserve">${isQEnglish ? "" : "\u200F"}${q.questionOrder}. </w:t>
      </w:r>
      <w:r>
        <w:rPr>
          <w:rFonts w:ascii="Tajawal" w:hAnsi="Tajawal" w:cs="Tajawal"/>
          <w:b/>
          <w:color w:val="1E293B"/>
          <w:sz w:val="24"/>
          <w:szCs w:val="24"/>
          <w:rtl w:val="${isQEnglish ? "0" : "1"}"/>
          <w:lang w:val="${isQEnglish ? "en-US" : "ar-SA"}" w:bidi="${isQEnglish ? "en-US" : "ar-SA"}"/>
        </w:rPr>
        <w:t>$safeQText</w:t>
      </w:r>
      <w:r><w:tab/></w:r>
      <w:r>
        <w:rPr>
          <w:rFonts w:ascii="Tajawal" w:hAnsi="Tajawal" w:cs="Tajawal"/>
          <w:color w:val="64748B"/>
          <w:sz w:val="20"/>
          <w:szCs w:val="20"/>
          <w:rtl w:val="${isQEnglish ? "0" : "1"}"/>
          <w:lang w:val="${isQEnglish ? "en-US" : "ar-SA"}" w:bidi="${isQEnglish ? "en-US" : "ar-SA"}"/>
        </w:rPr>
        <w:t>${isQEnglish ? "" : "\u200F"}$pointsText</w:t>
      </w:r>
    </w:p>
''');

      if (q.type == 'mcq') {
        final options = List<String>.from(q.options ?? []);
        for (final opt in options) {
          final isCorrect = opt == q.correctAnswer;
          final safeOpt = _escapeXml(opt);
          final mark = (showAnswers && isCorrect) ? '●' : '○';
          final markColor = (showAnswers && isCorrect) ? '15803D' : '94A3B8';
          final textColor = (showAnswers && isCorrect) ? '15803D' : '1E293B';
          final isBold = showAnswers && isCorrect;

          sb.write('''
    <w:p>
      <w:pPr>
        <w:bidi w:val="${isQEnglish ? "0" : "1"}"/>
        <w:jc w:val="${isQEnglish ? "left" : "right"}"/>
        ${isQEnglish ? '<w:ind w:left="280"/>' : '<w:ind w:right="280"/>'}
        <w:spacing w:after="80"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:rFonts w:ascii="Tajawal" w:hAnsi="Tajawal" w:cs="Tajawal"/>
          ${isBold ? '<w:b/>' : ''}
          <w:color w:val="$markColor"/>
          <w:sz w:val="24"/>
          <w:szCs w:val="24"/>
          <w:rtl w:val="${isQEnglish ? "0" : "1"}"/>
          <w:lang w:val="${isQEnglish ? "en-US" : "ar-SA"}" w:bidi="${isQEnglish ? "en-US" : "ar-SA"}"/>
        </w:rPr>
        <w:t xml:space="preserve">${isQEnglish ? "" : "\u200F"}$mark   </w:t>
      </w:r>
      <w:r>
        <w:rPr>
          <w:rFonts w:ascii="Tajawal" w:hAnsi="Tajawal" w:cs="Tajawal"/>
          ${isBold ? '<w:b/>' : ''}
          <w:color w:val="$textColor"/>
          <w:sz w:val="24"/>
          <w:szCs w:val="24"/>
          <w:rtl w:val="${isQEnglish ? "0" : "1"}"/>
          <w:lang w:val="${isQEnglish ? "en-US" : "ar-SA"}" w:bidi="${isQEnglish ? "en-US" : "ar-SA"}"/>
        </w:rPr>
        <w:t>$safeOpt</w:t>
      </w:r>
    </w:p>
''');
        }
      } else if (q.type == 'true_false') {
        final isTrueCorrect = showAnswers && (q.correctAnswer == 'صح' || q.correctAnswer.toLowerCase() == 'true');
        final isFalseCorrect = showAnswers && (q.correctAnswer == 'خطأ' || q.correctAnswer.toLowerCase() == 'false');

        final trueLabel = isQEnglish ? 'True' : 'صح';
        final falseLabel = isQEnglish ? 'False' : 'خطأ';

        final trueMark = isTrueCorrect ? '●' : '○';
        final falseMark = isFalseCorrect ? '●' : '○';
        final trueColor = isTrueCorrect ? '15803D' : '1E293B';
        final falseColor = isFalseCorrect ? '15803D' : '1E293B';
        final trueMarkColor = isTrueCorrect ? '15803D' : '94A3B8';
        final falseMarkColor = isFalseCorrect ? '15803D' : '94A3B8';

        sb.write('''
    <w:p>
      <w:pPr>
        <w:bidi w:val="${isQEnglish ? "0" : "1"}"/>
        <w:jc w:val="${isQEnglish ? "left" : "right"}"/>
        ${isQEnglish ? '<w:ind w:left="280"/>' : '<w:ind w:right="280"/>'}
        <w:spacing w:before="60" w:after="80"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:rFonts w:ascii="Tajawal" w:hAnsi="Tajawal" w:cs="Tajawal"/>
          ${isTrueCorrect ? '<w:b/>' : ''}
          <w:color w:val="$trueMarkColor"/>
          <w:sz w:val="24"/><w:szCs w:val="24"/>
          <w:rtl w:val="${isQEnglish ? "0" : "1"}"/>
          <w:lang w:val="${isQEnglish ? "en-US" : "ar-SA"}" w:bidi="${isQEnglish ? "en-US" : "ar-SA"}"/>
        </w:rPr>
        <w:t xml:space="preserve">${isQEnglish ? "" : "\u200F"}$trueMark   </w:t>
      </w:r>
      <w:r>
        <w:rPr>
          <w:rFonts w:ascii="Tajawal" w:hAnsi="Tajawal" w:cs="Tajawal"/>
          ${isTrueCorrect ? '<w:b/>' : ''}
          <w:color w:val="$trueColor"/>
          <w:sz w:val="24"/><w:szCs w:val="24"/>
          <w:rtl w:val="${isQEnglish ? "0" : "1"}"/>
          <w:lang w:val="${isQEnglish ? "en-US" : "ar-SA"}" w:bidi="${isQEnglish ? "en-US" : "ar-SA"}"/>
        </w:rPr>
        <w:t xml:space="preserve">$trueLabel               </w:t>
      </w:r>
      <w:r>
        <w:rPr>
          <w:rFonts w:ascii="Tajawal" w:hAnsi="Tajawal" w:cs="Tajawal"/>
          ${isFalseCorrect ? '<w:b/>' : ''}
          <w:color w:val="$falseMarkColor"/>
          <w:sz w:val="24"/><w:szCs w:val="24"/>
          <w:rtl w:val="${isQEnglish ? "0" : "1"}"/>
          <w:lang w:val="${isQEnglish ? "en-US" : "ar-SA"}" w:bidi="${isQEnglish ? "en-US" : "ar-SA"}"/>
        </w:rPr>
        <w:t xml:space="preserve">$falseMark   </w:t>
      </w:r>
      <w:r>
        <w:rPr>
          <w:rFonts w:ascii="Tajawal" w:hAnsi="Tajawal" w:cs="Tajawal"/>
          ${isFalseCorrect ? '<w:b/>' : ''}
          <w:color w:val="$falseColor"/>
          <w:sz w:val="24"/><w:szCs w:val="24"/>
          <w:rtl w:val="${isQEnglish ? "0" : "1"}"/>
          <w:lang w:val="${isQEnglish ? "en-US" : "ar-SA"}" w:bidi="${isQEnglish ? "en-US" : "ar-SA"}"/>
        </w:rPr>
        <w:t>$falseLabel</w:t>
      </w:r>
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

        sb.write('''
    <w:tbl>
      <w:tblPr>
        <w:tblW w:w="10466" w:type="dxa"/>
        <w:jc w:val="center"/>
        ${isQEnglish ? '' : '<w:bidiVisual w:val="1"/>'}
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
          final itemA = row < colA.length ? _escapeXml(colA[row]) : '';
          final itemB = row < colB.length ? _escapeXml(colB[row]) : '';

          sb.write('''
      <w:tr>
        <w:tc>
          <w:tcPr><w:tcW w:w="5233" w:type="dxa"/></w:tcPr>
          <w:p>
            <w:pPr><w:bidi w:val="${isQEnglish ? "0" : "1"}"/><w:jc w:val="${isQEnglish ? "left" : "right"}"/><w:spacing w:after="80"/></w:pPr>
            <w:r><w:rPr><w:rFonts w:ascii="Tajawal" w:hAnsi="Tajawal" w:cs="Tajawal"/><w:sz w:val="24"/><w:szCs w:val="24"/><w:rtl w:val="${isQEnglish ? "0" : "1"}"/><w:lang w:val="${isQEnglish ? "en-US" : "ar-SA"}" w:bidi="${isQEnglish ? "en-US" : "ar-SA"}"/></w:rPr><w:t>${isQEnglish ? "" : "\u200F"}•  $itemA</w:t></w:r>
          </w:p>
        </w:tc>
        <w:tc>
          <w:tcPr><w:tcW w:w="5233" w:type="dxa"/></w:tcPr>
          <w:p>
            <w:pPr><w:bidi w:val="${isQEnglish ? "0" : "1"}"/><w:jc w:val="${isQEnglish ? "left" : "right"}"/><w:spacing w:after="80"/></w:pPr>
            <w:r><w:rPr><w:rFonts w:ascii="Tajawal" w:hAnsi="Tajawal" w:cs="Tajawal"/><w:sz w:val="24"/><w:szCs w:val="24"/><w:rtl w:val="${isQEnglish ? "0" : "1"}"/><w:lang w:val="${isQEnglish ? "en-US" : "ar-SA"}" w:bidi="${isQEnglish ? "en-US" : "ar-SA"}"/></w:rPr><w:t>${isQEnglish ? "" : "\u200F"}•  $itemB</w:t></w:r>
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
        <w:bidiVisual w:val="1"/>
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
        final safeAnswer = _escapeXml(q.correctAnswer);
        final label = isQEnglish ? 'Answer: ' : 'الإجابة: ';
        sb.write('''
    <w:p>
      <w:pPr>
        <w:bidi w:val="${isQEnglish ? "0" : "1"}"/>
        <w:jc w:val="${isQEnglish ? "left" : "right"}"/>
        ${isQEnglish ? '<w:ind w:left="280"/>' : '<w:ind w:right="280"/>'}
        <w:spacing w:before="120" w:after="160"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:rFonts w:ascii="Tajawal" w:hAnsi="Tajawal" w:cs="Tajawal"/>
          <w:b/>
          <w:color w:val="15803D"/>
          <w:sz w:val="24"/>
          <w:szCs w:val="24"/>
          <w:rtl w:val="${isQEnglish ? "0" : "1"}"/>
          <w:lang w:val="${isQEnglish ? "en-US" : "ar-SA"}" w:bidi="${isQEnglish ? "en-US" : "ar-SA"}"/>
        </w:rPr>
        <w:t xml:space="preserve">${isQEnglish ? "" : "\u200F"}$label$safeAnswer</w:t>
      </w:r>
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

    sb.write('''
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="720" w:right="720" w:bottom="720" w:left="720" w:header="720" w:footer="720" w:gutter="0"/>
      <w:bidi w:val="1"/>
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
