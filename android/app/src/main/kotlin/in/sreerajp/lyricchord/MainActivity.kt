package `in`.sreerajp.lyricchord

import android.content.Intent
import android.net.Uri
import android.print.LcHtmlToPdf
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.InputStreamReader

class MainActivity : FlutterActivity() {

    private val channelName = "in.sreerajp.lyricchord/html_pdf"
    private val fileChannelName = "in.sreerajp.lyricchord/file_intent"
    private var fileChannel: MethodChannel? = null
    private var lastHandledUri: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "convertHtml" -> {
                        val html = call.argument<String>("html")
                        if (html == null) {
                            result.error("bad_args", "html is required", null)
                            return@setMethodCallHandler
                        }
                        val widthPts = call.argument<Double>("widthPts") ?: 595.28
                        val heightPts = call.argument<Double>("heightPts") ?: 841.89
                        val marginPts = call.argument<Double>("marginPts") ?: 32.0
                        val timeoutMs = (call.argument<Int>("timeoutMs") ?: 20000).toLong()

                        LcHtmlToPdf(this).convert(
                            html,
                            widthPts,
                            heightPts,
                            marginPts,
                            timeoutMs,
                        ) { bytes, error ->
                            if (bytes != null) {
                                result.success(bytes)
                            } else {
                                result.error("convert_failed", error ?: "unknown error", null)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        fileChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, fileChannelName)
        fileChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialFile" -> {
                    val fileData = extractFileData(intent, force = false)
                    result.success(fileData)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val fileData = extractFileData(intent, force = true)
        if (fileData != null) {
            fileChannel?.invokeMethod("onFileOpened", fileData)
        }
    }

    private fun extractFileData(intent: Intent?, force: Boolean = false): Map<String, String>? {
        if (intent == null) return null
        val uri: Uri? = getUriFromIntent(intent)
        if (uri != null) {
            val uriStr = uri.toString()
            if (!force && uriStr == lastHandledUri) {
                return null
            }
            try {
                openInputStream(uri)?.use { inputStream ->
                    val reader = BufferedReader(InputStreamReader(inputStream))
                    val content = reader.readText()
                    val fileName = getFileNameFromUri(uri)
                    lastHandledUri = uriStr
                    return mapOf(
                        "content" to content,
                        "fileName" to fileName
                    )
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        return null
    }

    private fun getUriFromIntent(intent: Intent): Uri? {
        if (intent.data != null) return intent.data
        if (intent.action == Intent.ACTION_SEND) {
            @Suppress("DEPRECATION")
            return intent.getParcelableExtra(Intent.EXTRA_STREAM) as? Uri
        }
        return null
    }

    private fun openInputStream(uri: Uri): java.io.InputStream? {
        if (uri.scheme == "file") {
            val path = uri.path
            if (path != null) {
                try {
                    return java.io.File(path).inputStream()
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
        try {
            return contentResolver.openInputStream(uri)
        } catch (e: Exception) {
            e.printStackTrace()
        }
        try {
            return contentResolver.openTypedAssetFileDescriptor(uri, "*/*", null)?.createInputStream()
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }

    private fun getFileNameFromUri(uri: Uri): String {
        var name = "imported.chordpro"
        if (uri.scheme == "content") {
            try {
                contentResolver.query(uri, arrayOf(android.provider.OpenableColumns.DISPLAY_NAME), null, null, null)?.use { cursor ->
                    if (cursor.moveToFirst()) {
                        val index = cursor.getColumnIndex(android.provider.OpenableColumns.DISPLAY_NAME)
                        if (index >= 0) {
                            val displayName = cursor.getString(index)
                            if (!displayName.isNullOrEmpty()) {
                                name = displayName
                            }
                        }
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        } else if (uri.scheme == "file") {
            uri.lastPathSegment?.let { name = it }
        }
        return name
    }
}

