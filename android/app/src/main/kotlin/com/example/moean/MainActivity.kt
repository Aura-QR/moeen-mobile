package com.haderedu.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val converter = HtmlPdfConverter(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HTML_PDF_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method != "convert") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val html = call.argument<String>("html")
            if (html == null) {
                result.error("bad_args", "html is required", null)
                return@setMethodCallHandler
            }
            converter.convert(html) { bytes, error ->
                if (bytes != null) result.success(bytes) else result.error("convert_failed", error, null)
            }
        }
    }

    private companion object {
        const val HTML_PDF_CHANNEL = "com.haderedu.app/html_pdf"
    }
}
