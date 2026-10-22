package com.haderedu.app

import android.app.Activity
import android.os.Handler
import android.os.Looper
import android.print.PdfPrintWriter
import android.print.PrintAttributes
import android.view.ViewGroup
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.FrameLayout
import java.io.File

/**
 * Turns the self-contained A4 page from `GET /documents/{id}/print` into PDF
 * bytes on the device, portrait or landscape (certificates, the activities plan).
 *
 * Replaces printing's convertHtml, which never completes on recent Android:
 * its WebView is never attached to a window, so the page never finishes
 * loading. Here the WebView is attached (hidden behind the Flutter view),
 * kept referenced until done, and a timeout guarantees an answer.
 */
class HtmlPdfConverter(private val activity: Activity) {
    private val handler = Handler(Looper.getMainLooper())

    fun convert(html: String, landscape: Boolean, onResult: (bytes: ByteArray?, error: String?) -> Unit) {
        val content = activity.findViewById<ViewGroup>(android.R.id.content)
        val webView = WebView(activity)
        var finished = false
        var timeout: Runnable? = null
        var render: Runnable? = null

        fun finish(bytes: ByteArray?, error: String?) {
            if (finished) return
            finished = true
            timeout?.let(handler::removeCallbacks)
            render?.let(handler::removeCallbacks)
            content.removeView(webView)
            webView.destroy()
            onResult(bytes, error)
        }

        webView.webViewClient = object : WebViewClient() {
            override fun onPageFinished(view: WebView, url: String?) {
                // Fires once per frame on some versions; only the first one prints.
                if (render != null || finished) return
                // Lets the embedded fonts and images finish decoding first.
                render = Runnable { print(webView, landscape, ::finish) }.also { handler.postDelayed(it, RENDER_DELAY_MS) }
            }
        }

        // Index 0 keeps it under the Flutter view, out of sight and touch.
        val (width, height) = if (landscape) A4_HEIGHT_PX to A4_WIDTH_PX else A4_WIDTH_PX to A4_HEIGHT_PX
        content.addView(webView, 0, FrameLayout.LayoutParams(width, height))
        timeout = Runnable { finish(null, "Timed out") }.also { handler.postDelayed(it, TIMEOUT_MS) }
        webView.loadDataWithBaseURL(null, html, "text/html", "UTF-8", null)
    }

    private fun print(webView: WebView, landscape: Boolean, finish: (ByteArray?, String?) -> Unit) {
        val output = File.createTempFile("document", ".pdf", activity.cacheDir)
        val attributes = PrintAttributes.Builder()
            .setMediaSize(PrintAttributes.MediaSize.ISO_A4.let { if (landscape) it.asLandscape() else it })
            .setResolution(PrintAttributes.Resolution("pdf", "pdf", 600, 600))
            // The page sets its own margins with @page.
            .setMinMargins(PrintAttributes.Margins.NO_MARGINS)
            .build()

        try {
            PdfPrintWriter.write(webView.createPrintDocumentAdapter("document"), attributes, output) { error ->
                val bytes = if (error == null) output.readBytes() else null
                output.delete()
                finish(bytes, error)
            }
        } catch (e: Exception) {
            output.delete()
            finish(null, e.message ?: "Print failed")
        }
    }

    private companion object {
        // A4 at 96 dpi, so the page lays out at its print width.
        const val A4_WIDTH_PX = 794
        const val A4_HEIGHT_PX = 1123
        const val RENDER_DELAY_MS = 400L
        const val TIMEOUT_MS = 45_000L
    }
}
