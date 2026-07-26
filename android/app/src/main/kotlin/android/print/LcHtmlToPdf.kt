package android.print

import android.app.Activity
import android.os.CancellationSignal
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import android.view.ViewGroup
import android.webkit.JavascriptInterface
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.FrameLayout
import java.io.File
import kotlin.math.ceil
import kotlin.math.roundToInt

/**
 * Renders self-contained, local HTML to a PDF using a real [WebView] that is
 * ATTACHED to the activity window.
 *
 * Why this exists: the `printing` plugin's `convertHtml` builds a WebView that
 * is never attached to a window. On newer Android / WebView versions the print
 * document callbacks then never fire, so the export hangs forever (confirmed on
 * device). Attaching the WebView (even off-screen) makes it lay out, so the
 * print callbacks run and the PDF is produced.
 *
 * This class lives in package `android.print` on purpose: the
 * `PrintDocumentAdapter.LayoutResultCallback` / `WriteResultCallback`
 * constructors are package-private, so a subclass must sit in this package.
 *
 * Fully offline: JavaScript is local only, network loads are blocked at the
 * WebView, and only the given local HTML (with data-URI fonts) is ever loaded.
 */
class LcHtmlToPdf(private val activity: Activity) {

    /** Result callback: exactly one of [bytes] / [error] is non-null. */
    fun interface Callback {
        fun onResult(bytes: ByteArray?, error: String?)
    }

    private val mainHandler = Handler(Looper.getMainLooper())

    fun convert(
        html: String,
        widthPts: Double,
        heightPts: Double,
        marginPts: Double,
        timeoutMs: Long,
        callback: Callback,
    ) {
        mainHandler.post { start(html, widthPts, heightPts, marginPts, timeoutMs, callback) }
    }

    private fun start(
        html: String,
        widthPts: Double,
        heightPts: Double,
        marginPts: Double,
        timeoutMs: Long,
        callback: Callback,
    ) {
        val root = activity.findViewById<ViewGroup>(android.R.id.content)
        if (root == null) {
            callback.onResult(null, "No window to render in")
            return
        }

        val webView = WebView(activity)
        webView.settings.javaScriptEnabled = true
        webView.settings.blockNetworkLoads = true // enforce offline
        webView.settings.allowFileAccess = false

        var finished = false
        var timeoutRunnable: Runnable? = null

        fun cleanup() {
            timeoutRunnable?.let { mainHandler.removeCallbacks(it) }
            try {
                root.removeView(webView)
            } catch (_: Exception) {
            }
            try {
                webView.destroy()
            } catch (_: Exception) {
            }
        }

        fun finish(bytes: ByteArray?, error: String?) {
            if (finished) return
            finished = true
            cleanup()
            callback.onResult(bytes, error)
        }

        // Attach off-screen so the WebView lays out but never appears on screen.
        val widthPx = ceil(widthPts * 96.0 / 72.0).toInt().coerceAtLeast(1)
        val heightPx = ceil(heightPts * 96.0 / 72.0).toInt().coerceAtLeast(1)
        val params = FrameLayout.LayoutParams(widthPx, heightPx)
        webView.translationX = 100000f
        root.addView(webView, params)

        // JavaScript calls this once the embedded fonts are ready to draw.
        webView.addJavascriptInterface(
            object {
                @JavascriptInterface
                fun onReady() {
                    mainHandler.post {
                        render(webView, widthPts, heightPts, marginPts, ::finish)
                    }
                }
            },
            "AndroidPdf",
        )

        webView.webViewClient = object : WebViewClient() {
            override fun onPageFinished(view: WebView, url: String) {
                super.onPageFinished(view, url)
                // Wait for the embedded @font-face fonts before printing, so
                // Malayalam is shaped correctly and not with fallback glyphs.
                view.evaluateJavascript(
                    "document.fonts.ready.then(function(){" +
                        "window.AndroidPdf.onReady();});",
                    null,
                )
            }
        }

        timeoutRunnable = Runnable { finish(null, "Rendering timed out") }
        mainHandler.postDelayed(timeoutRunnable, timeoutMs)

        webView.loadDataWithBaseURL(null, html, "text/html", "UTF-8", null)
    }

    private fun render(
        webView: WebView,
        widthPts: Double,
        heightPts: Double,
        marginPts: Double,
        finish: (ByteArray?, String?) -> Unit,
    ) {
        try {
            val mediaSize = PrintAttributes.MediaSize(
                "lc-page",
                "Page",
                (widthPts * 1000.0 / 72.0).roundToInt(),
                (heightPts * 1000.0 / 72.0).roundToInt(),
            )
            val marginMils = (marginPts * 1000.0 / 72.0).roundToInt()
            val attributes = PrintAttributes.Builder()
                .setMediaSize(mediaSize)
                .setResolution(PrintAttributes.Resolution("pdf", "pdf", 600, 600))
                .setMinMargins(
                    PrintAttributes.Margins(marginMils, marginMils, marginMils, marginMils),
                )
                .build()

            val adapter = webView.createPrintDocumentAdapter("lyricchord")
            val outFile = File.createTempFile("lyricchord", ".pdf", activity.cacheDir)

            adapter.onLayout(
                null,
                attributes,
                null,
                object : PrintDocumentAdapter.LayoutResultCallback() {
                    override fun onLayoutFinished(info: PrintDocumentInfo?, changed: Boolean) {
                        try {
                            val pfd = ParcelFileDescriptor.open(
                                outFile,
                                ParcelFileDescriptor.MODE_READ_WRITE,
                            )
                            adapter.onWrite(
                                arrayOf(PageRange.ALL_PAGES),
                                pfd,
                                CancellationSignal(),
                                object : PrintDocumentAdapter.WriteResultCallback() {
                                    override fun onWriteFinished(pages: Array<out PageRange>?) {
                                        super.onWriteFinished(pages)
                                        if (pages == null || pages.isEmpty()) {
                                            outFile.delete()
                                            finish(null, "No pages produced")
                                            return
                                        }
                                        try {
                                            val bytes = outFile.readBytes()
                                            outFile.delete()
                                            finish(bytes, null)
                                        } catch (e: Exception) {
                                            outFile.delete()
                                            finish(null, e.message ?: "Could not read PDF")
                                        }
                                    }

                                    override fun onWriteFailed(error: CharSequence?) {
                                        super.onWriteFailed(error)
                                        outFile.delete()
                                        finish(null, error?.toString() ?: "PDF write failed")
                                    }
                                },
                            )
                        } catch (e: Exception) {
                            outFile.delete()
                            finish(null, e.message ?: "PDF write failed")
                        }
                    }

                    override fun onLayoutFailed(error: CharSequence?) {
                        super.onLayoutFailed(error)
                        outFile.delete()
                        finish(null, error?.toString() ?: "PDF layout failed")
                    }
                },
                null,
            )
        } catch (e: Exception) {
            finish(null, e.message ?: "PDF render failed")
        }
    }
}
