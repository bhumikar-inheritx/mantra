package com.deepmantra.deepMantra

import android.net.Uri
import com.ryanheise.audioservice.AudioServiceActivity
import java.io.File
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
  private val CHANNEL = "app.fileprovider"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "getContentUri" -> {
            val path = call.argument<String>("path")
            if (path == null) {
              result.error("ARG", "path is null", null)
              return@setMethodCallHandler
            }
            val file = File(path)
            val uri: Uri = FileProvider.getUriForFile(
              this,
              applicationContext.packageName + ".fileprovider",
              file
            )
            result.success(uri.toString())
          }
          else -> result.notImplemented()
        }
      }
  }
}
