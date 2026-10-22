package android.print

import android.os.CancellationSignal
import android.os.ParcelFileDescriptor
import java.io.File

/**
 * Runs a [PrintDocumentAdapter] straight into a PDF file, without the system
 * print dialog. It lives in android.print because the layout and write
 * callbacks can only be subclassed from this package.
 */
object PdfPrintWriter {
    fun write(
        adapter: PrintDocumentAdapter,
        attributes: PrintAttributes,
        output: File,
        onDone: (error: String?) -> Unit,
    ) {
        adapter.onStart()
        adapter.onLayout(null, attributes, null, object : PrintDocumentAdapter.LayoutResultCallback() {
            override fun onLayoutFinished(info: PrintDocumentInfo, changed: Boolean) {
                val descriptor = ParcelFileDescriptor.open(
                    output,
                    ParcelFileDescriptor.MODE_READ_WRITE or ParcelFileDescriptor.MODE_CREATE or ParcelFileDescriptor.MODE_TRUNCATE,
                )
                adapter.onWrite(
                    arrayOf(PageRange.ALL_PAGES),
                    descriptor,
                    CancellationSignal(),
                    object : PrintDocumentAdapter.WriteResultCallback() {
                        override fun onWriteFinished(pages: Array<out PageRange>) {
                            descriptor.close()
                            adapter.onFinish()
                            onDone(if (pages.isEmpty()) "No page created" else null)
                        }

                        override fun onWriteFailed(error: CharSequence?) {
                            descriptor.close()
                            adapter.onFinish()
                            onDone(error?.toString() ?: "Write failed")
                        }

                        override fun onWriteCancelled() {
                            descriptor.close()
                            adapter.onFinish()
                            onDone("Write cancelled")
                        }
                    },
                )
            }

            override fun onLayoutFailed(error: CharSequence?) {
                adapter.onFinish()
                onDone(error?.toString() ?: "Layout failed")
            }

            override fun onLayoutCancelled() {
                adapter.onFinish()
                onDone("Layout cancelled")
            }
        }, null)
    }
}
