package com.tytaniumdev.sousvite

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import java.io.File

/**
 * The app's only activity. What another app's share sheet sends arrives as
 * an ACTION_SEND intent; this turns it into a deep link, which Flutter's
 * deep linking hands to the router like any other link:
 *
 * - a link: `sousvite://open/import?shared=…`
 * - an Umami export (a zip file), copied into the app's cache first:
 *   `sousvite://open/import?archive=<path>`
 */
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        intent?.let { intent = asImportLink(it) }
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        val link = asImportLink(intent)
        setIntent(link)
        super.onNewIntent(link)
    }

    private fun asImportLink(intent: Intent): Intent {
        if (intent.action != Intent.ACTION_SEND) return intent
        val query = when (intent.type) {
            "text/plain" -> intent.getStringExtra(Intent.EXTRA_TEXT)
                ?.let { "shared" to it }
            in ZIP_TYPES -> sharedFile(intent)
                ?.let { copyToCache(it) }
                ?.let { "archive" to it.path }
            else -> null
        } ?: return intent
        val link = Uri.Builder()
            .scheme("sousvite")
            .authority("open")
            .path("/import")
            .appendQueryParameter(query.first, query.second)
            .build()
        return Intent(Intent.ACTION_VIEW, link)
    }

    private fun sharedFile(intent: Intent): Uri? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(Intent.EXTRA_STREAM)
        }

    /**
     * Copies the shared file where Flutter can read it, because the
     * permission to read [uri] lasts only as long as this intent. The app
     * deletes the copy once it's imported. Null if it can't be read.
     */
    private fun copyToCache(uri: Uri): File? = try {
        val folder = File(cacheDir, "shared").apply { mkdirs() }
        val copy = File.createTempFile("umami", ".zip", folder)
        contentResolver.openInputStream(uri)?.use { input ->
            copy.outputStream().use { input.copyTo(it) }
        } ?: return null
        copy
    } catch (e: Exception) {
        null
    }

    private companion object {
        val ZIP_TYPES = setOf("application/zip", "application/x-zip-compressed")
    }
}
