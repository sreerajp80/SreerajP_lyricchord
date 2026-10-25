package `in`.sreerajp.lyricchord

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.print.LcHtmlToPdf
import android.provider.OpenableColumns
import android.provider.Settings
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.InputStream
import java.util.concurrent.Executors

// FlutterFragmentActivity, not FlutterActivity: local_auth (Stage Lock) can only
// show its prompt from a FragmentActivity. With a plain FlutterActivity every
// unlock failed and the user was stuck in a locked Stage Mode.
class MainActivity : FlutterFragmentActivity() {

    private val channelName = "in.sreerajp.lyricchord/html_pdf"
    private val fileChannelName = "in.sreerajp.lyricchord/file_intent"
    private val quietChannelName = "in.sreerajp.lyricchord/quiet_mode"
    private var fileChannel: MethodChannel? = null
    private var lastHandledUri: String? = null

    // Imported files are read off the main thread so a slow or large file
    // cannot freeze the app.
    private val ioExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    private val quietPrefs by lazy {
        getSharedPreferences(QUIET_PREFS, Context.MODE_PRIVATE)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // If the app was killed while Quiet Mode was on, give the phone its
        // ringer back now.
        restoreLeftoverQuietMode()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "convertHtml" -> {
                        val html = call.argument<String>("html")
                        if (html == null) {
                            result.error("bad_args", "html is required", null)
                            return@setMethodCallHandler
                        }
                        // widthPts is the widest the page may be; the real
                        // width is picked from the song's longest line.
                        val widthPts = call.argument<Double>("widthPts") ?: 595.28
                        val minWidthPts = call.argument<Double>("minWidthPts") ?: widthPts
                        val heightPts = call.argument<Double>("heightPts") ?: 841.89
                        val marginPts = call.argument<Double>("marginPts") ?: 20.0
                        val timeoutMs = (call.argument<Int>("timeoutMs") ?: 20000).toLong()

                        LcHtmlToPdf(this).convert(
                            html,
                            widthPts,
                            minWidthPts,
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
                "getInitialFile" -> readFileFromIntent(intent, force = false) { fileData ->
                    result.success(fileData)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, quietChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enableQuietMode" -> result.success(enableQuietMode())
                    "disableQuietMode" -> result.success(disableQuietMode())
                    "openQuietModeAccessSettings" -> result.success(openQuietModeAccessSettings())
                    else -> result.notImplemented()
                }
            }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        readFileFromIntent(intent, force = true) { fileData ->
            if (fileData != null) {
                fileChannel?.invokeMethod("onFileOpened", fileData)
            }
        }
    }

    override fun onDestroy() {
        // Closing the app must not leave the phone silent.
        if (isFinishing) disableQuietMode()
        ioExecutor.shutdown()
        super.onDestroy()
    }

    // --- Stage Quiet Mode ----------------------------------------------------

    /** Returns "ok", "needs_access" or "failed". */
    private fun enableQuietMode(): String {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as? AudioManager
            ?: return "failed"
        // Since Android 7, silencing the ringer can switch Do Not Disturb on, so
        // Android only allows it once the user has granted DND access.
        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        if (notificationManager?.isNotificationPolicyAccessGranted != true) {
            return "needs_access"
        }
        return try {
            if (!quietPrefs.contains(KEY_PREVIOUS_RINGER)) {
                // commit(), not apply(): it must be on disk before we change the
                // ringer, so a crash right after can still be undone.
                quietPrefs.edit().putInt(KEY_PREVIOUS_RINGER, audioManager.ringerMode).commit()
            }
            audioManager.ringerMode = AudioManager.RINGER_MODE_SILENT
            "ok"
        } catch (e: SecurityException) {
            quietPrefs.edit().remove(KEY_PREVIOUS_RINGER).commit()
            "needs_access"
        } catch (e: Exception) {
            quietPrefs.edit().remove(KEY_PREVIOUS_RINGER).commit()
            "failed"
        }
    }

    /** Puts back the ringer mode saved by [enableQuietMode]. */
    private fun disableQuietMode(): Boolean {
        if (!quietPrefs.contains(KEY_PREVIOUS_RINGER)) return true
        val previous = quietPrefs.getInt(KEY_PREVIOUS_RINGER, AudioManager.RINGER_MODE_NORMAL)
        return try {
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as? AudioManager
            audioManager?.ringerMode = previous
            true
        } catch (e: Exception) {
            false
        } finally {
            quietPrefs.edit().remove(KEY_PREVIOUS_RINGER).commit()
        }
    }

    /** Restores the ringer after a crash, unless the user already changed it. */
    private fun restoreLeftoverQuietMode() {
        if (!quietPrefs.contains(KEY_PREVIOUS_RINGER)) return
        try {
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as? AudioManager
            if (audioManager?.ringerMode == AudioManager.RINGER_MODE_SILENT) {
                audioManager.ringerMode =
                    quietPrefs.getInt(KEY_PREVIOUS_RINGER, AudioManager.RINGER_MODE_NORMAL)
            }
        } catch (e: Exception) {
            // Nothing more we can do; never block app start.
        } finally {
            quietPrefs.edit().remove(KEY_PREVIOUS_RINGER).commit()
        }
    }

    /** Opens the system page where the user can grant Do Not Disturb access. */
    private fun openQuietModeAccessSettings(): Boolean {
        return try {
            startActivity(
                Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
            true
        } catch (e: Exception) {
            false
        }
    }

    // --- File-open import ----------------------------------------------------

    /**
     * Reads the file an intent points at on a background thread and hands the
     * result to [onResult] on the main thread.
     *
     * The result is `null` (nothing to import), or a map with `fileName` and
     * either `bytes` (the raw file, decoded on the Dart side) or `error`
     * (`too_large` / `unreadable`).
     */
    private fun readFileFromIntent(
        intent: Intent?,
        force: Boolean,
        onResult: (Map<String, Any>?) -> Unit,
    ) {
        val uris = intent?.let { getUrisFromIntent(it) } ?: emptyList()
        // Text shared from another app (no file), e.g. a chord sheet copied
        // out of a chat. Only used when the share carries no file.
        val sharedText = if (uris.isEmpty() && intent?.action == Intent.ACTION_SEND) {
            intent.getStringExtra(Intent.EXTRA_TEXT)
        } else {
            null
        }
        if (uris.isEmpty() && sharedText.isNullOrEmpty()) {
            onResult(null)
            return
        }
        // The same share must not be imported twice when the app starts again.
        val handledKey = if (uris.isNotEmpty()) {
            uris.joinToString("|")
        } else {
            "text:" + sharedText.hashCode()
        }
        if (!force && handledKey == lastHandledUri) {
            onResult(null)
            return
        }
        lastHandledUri = handledKey

        try {
            ioExecutor.execute {
                val fileData = if (uris.isNotEmpty()) {
                    readAllFileData(uris)
                } else {
                    sharedTextData(sharedText!!)
                }
                mainHandler.post { onResult(fileData) }
            }
        } catch (e: Exception) {
            onResult(null)
        }
    }

    /** Shared text as a payload, with the same size limit as a file. */
    private fun sharedTextData(text: String): Map<String, Any> {
        val bytes = text.toByteArray(Charsets.UTF_8)
        if (bytes.size > MAX_IMPORT_FILE_BYTES) {
            return mapOf("fileName" to SHARED_TEXT_NAME, "error" to "too_large")
        }
        return mapOf("fileName" to SHARED_TEXT_NAME, "bytes" to bytes)
    }

    /**
     * Reads every shared file into one payload named after the first file.
     *
     * Several files (SEND_MULTIPLE) are joined with a `{new_song}` line, which
     * the ChordPro parser already splits on. The size limit applies to the
     * total. One unreadable or too-large file fails the whole share, so the
     * user is told instead of getting only some of the songs.
     */
    private fun readAllFileData(uris: List<Uri>): Map<String, Any> {
        if (uris.size == 1) return readFileData(uris.first())
        val firstName = getFileNameFromUri(uris.first())
        val out = ByteArrayOutputStream()
        val separator = "\n{new_song}\n".toByteArray(Charsets.UTF_8)
        for ((index, uri) in uris.withIndex()) {
            val data = readFileData(uri)
            val bytes = data["bytes"] as? ByteArray
                ?: return data + ("fileName" to firstName)
            if (index > 0) out.write(separator)
            // A UTF-8 byte-order mark in the middle would land in a lyric.
            val start = if (bytes.size >= 3 &&
                bytes[0] == 0xEF.toByte() &&
                bytes[1] == 0xBB.toByte() &&
                bytes[2] == 0xBF.toByte()
            ) 3 else 0
            out.write(bytes, start, bytes.size - start)
            if (out.size() > MAX_IMPORT_FILE_BYTES) {
                return mapOf("fileName" to firstName, "error" to "too_large")
            }
        }
        return mapOf("fileName" to firstName, "bytes" to out.toByteArray())
    }

    private fun readFileData(uri: Uri): Map<String, Any> {
        val fileName = getFileNameFromUri(uri)
        val declaredSize = getFileSizeFromUri(uri)
        if (declaredSize != null && declaredSize > MAX_IMPORT_FILE_BYTES) {
            return mapOf("fileName" to fileName, "error" to "too_large")
        }
        return try {
            val stream = openInputStream(uri)
                ?: return mapOf("fileName" to fileName, "error" to "unreadable")
            val bytes = stream.use { readLimited(it) }
                ?: return mapOf("fileName" to fileName, "error" to "too_large")
            mapOf("fileName" to fileName, "bytes" to bytes)
        } catch (e: Exception) {
            mapOf("fileName" to fileName, "error" to "unreadable")
        }
    }

    /** Reads at most [MAX_IMPORT_FILE_BYTES]; `null` if the stream is longer. */
    private fun readLimited(input: InputStream): ByteArray? {
        val out = ByteArrayOutputStream()
        val buffer = ByteArray(8192)
        var total = 0L
        while (true) {
            val read = input.read(buffer)
            if (read < 0) break
            total += read
            if (total > MAX_IMPORT_FILE_BYTES) return null
            out.write(buffer, 0, read)
        }
        return out.toByteArray()
    }

    private fun getUrisFromIntent(intent: Intent): List<Uri> {
        intent.data?.let { return listOf(it) }
        return when (intent.action) {
            Intent.ACTION_SEND -> {
                @Suppress("DEPRECATION")
                val uri = intent.getParcelableExtra(Intent.EXTRA_STREAM) as? Uri
                listOfNotNull(uri)
            }
            Intent.ACTION_SEND_MULTIPLE -> {
                @Suppress("DEPRECATION")
                val list = intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)
                list?.filterNotNull()?.take(MAX_SHARED_FILES) ?: emptyList()
            }
            else -> emptyList()
        }
    }

    private fun openInputStream(uri: Uri): InputStream? {
        if (uri.scheme == "file") {
            val path = uri.path
            if (path != null) {
                try {
                    return java.io.File(path).inputStream()
                } catch (e: Exception) {
                    // Fall through to the content resolver.
                }
            }
        }
        try {
            return contentResolver.openInputStream(uri)
        } catch (e: Exception) {
            // Try the typed descriptor below.
        }
        try {
            return contentResolver.openTypedAssetFileDescriptor(uri, "*/*", null)?.createInputStream()
        } catch (e: Exception) {
            // Unreadable.
        }
        return null
    }

    private fun getFileSizeFromUri(uri: Uri): Long? {
        try {
            if (uri.scheme == "file") {
                return uri.path?.let { java.io.File(it).length() }
            }
            contentResolver.query(uri, arrayOf(OpenableColumns.SIZE), null, null, null)?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val index = cursor.getColumnIndex(OpenableColumns.SIZE)
                    if (index >= 0 && !cursor.isNull(index)) return cursor.getLong(index)
                }
            }
        } catch (e: Exception) {
            // Unknown size; the limited read still protects us.
        }
        return null
    }

    private fun getFileNameFromUri(uri: Uri): String {
        var name = "imported.chordpro"
        if (uri.scheme == "content") {
            try {
                contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)?.use { cursor ->
                    if (cursor.moveToFirst()) {
                        val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                        if (index >= 0) {
                            val displayName = cursor.getString(index)
                            if (!displayName.isNullOrEmpty()) {
                                name = displayName
                            }
                        }
                    }
                }
            } catch (e: Exception) {
                // Keep the default name.
            }
        } else if (uri.scheme == "file") {
            uri.lastPathSegment?.let { name = it }
        }
        return name
    }

    companion object {
        // Keep in step with AppConstants.maxImportFileBytes on the Dart side.
        private const val MAX_IMPORT_FILE_BYTES = 5L * 1024 * 1024
        // A share of more files than this is cut short; the size limit above
        // still applies to the total.
        private const val MAX_SHARED_FILES = 50
        private const val SHARED_TEXT_NAME = "shared.txt"
        private const val QUIET_PREFS = "lc_quiet_mode"
        private const val KEY_PREVIOUS_RINGER = "previous_ringer_mode"
    }
}
