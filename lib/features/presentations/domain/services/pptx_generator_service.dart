import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:moean/features/presentations/data/models/presentation_models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';

class PptxGeneratorService {
  static Future<String> generatePresentation(
    PresentationModel presentation,
    String title, {
    String? templateId,
    String subjectName = '',
    String gradeName = '',
    String unitName = '',
  }) async {
    final completer = Completer<String>();
    
    // Read html and js
    final rawHtml = await rootBundle.loadString('assets/html/pptx_generator.html');
    final rawJs = await rootBundle.loadString('assets/js/pptxgen.bundle.js');
    
    // Inline JS
    final combinedHtml = rawHtml.replaceFirst('<script src="../js/pptxgen.bundle.js"></script>', '<script>\n$rawJs\n</script>');

    final randomImages = [
      AssetsHelper.scr1, AssetsHelper.scr2, AssetsHelper.scr3, AssetsHelper.scr4,
      AssetsHelper.scr5, AssetsHelper.scr6, AssetsHelper.scr7, AssetsHelper.scr8,
      AssetsHelper.scr9, AssetsHelper.scr10, AssetsHelper.scr11, AssetsHelper.scr12,
      AssetsHelper.scr13, AssetsHelper.scr14, AssetsHelper.scr15,
    ];
    final selectedImage = randomImages[Random().nextInt(randomImages.length)];
    
    String coverImageBase64 = '';
    try {
      final ByteData data = await rootBundle.load(selectedImage);
      final Uint8List bytes = data.buffer.asUint8List();
      final base64Str = base64Encode(bytes);
      coverImageBase64 = 'data:image/jpeg;base64,$base64Str';
    } catch (e) {
      print('Could not load random cover image: $e');
    }

    // Build context
    final jsonData = jsonEncode({
      'presentation': {
        'template_id': templateId ?? presentation.templateId ?? 'emerald-green', 
        'slides': presentation.slides.map((s) => {
          'title': s.title,
          'type': s.slideType,
          'icon_keyword': s.iconKeyword,
          'icon_id': s.iconId,
          'bodyText': s.bodyText,
          'order': 0, // Fallback order, array position will be used
        }).toList(),
      },
      'context': {
        'lessonTitle': title,
        'subjectName': subjectName,
        'gradeName': gradeName,
        'unitName': unitName,
        'coverImageBase64': coverImageBase64,
      }
    });

    HeadlessInAppWebView? headlessWebView;

    headlessWebView = HeadlessInAppWebView(
      initialData: InAppWebViewInitialData(data: combinedHtml),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
      ),
      onLoadStop: (controller, url) async {
        try {
          final result = await controller.callAsyncJavaScript(
            functionBody: "return await window.generatePptxBase64(data);",
            arguments: {"data": jsonData}
          );
          
          if (result?.value != null) {
            final res = result!.value as Map;
            if (res['success'] == true) {
              final base64String = res['base64'] as String;
              final bytes = base64Decode(base64String);
              
              final tempDir = await getTemporaryDirectory();
              final sanitizedTitle = title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '');
              final filePath = '${tempDir.path}/$sanitizedTitle.pptx';
              final file = File(filePath);
              
              await file.writeAsBytes(bytes);
              completer.complete(filePath);
            } else {
              completer.completeError("JS Error: ${res['error']}");
            }
          } else {
             completer.completeError("No result from JS");
          }
        } catch (e) {
          if (!completer.isCompleted) completer.completeError(e.toString());
        } finally {
          headlessWebView?.dispose();
        }
      },
      onReceivedError: (controller, request, error) {
         if (!completer.isCompleted) completer.completeError("WebView Error: ${error.description}");
         headlessWebView?.dispose();
      },
    );

    await headlessWebView.run();

    return completer.future;
  }
}
