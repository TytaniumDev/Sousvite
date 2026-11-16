package com.tytaniumdev.sousvite

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

/**
 * The app's only activity. A link shared into the app from another app's
 * share sheet arrives as an ACTION_SEND intent; this turns it into the
 * deep link `sousvite://open/import?shared=…`, which Flutter's deep linking
 * hands to the router like any other link.
 */
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        intent = asImportLink(intent)
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        val link = asImportLink(intent)
        setIntent(link)
        super.onNewIntent(link)
    }

    private fun asImportLink(intent: Intent?): Intent? {
        if (intent?.action != Intent.ACTION_SEND || intent.type != "text/plain") {
            return intent
        }
        val shared = intent.getStringExtra(Intent.EXTRA_TEXT) ?: return intent
        val link = Uri.Builder()
            .scheme("sousvite")
            .authority("open")
            .path("/import")
            .appendQueryParameter("shared", shared)
            .build()
        return Intent(Intent.ACTION_VIEW, link)
    }
}
