package com.nexthouse.instant.nexthouse_instant

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val CHANNEL = "nexthouse/photo_editor"
	private var pendingResult: MethodChannel.Result? = null
	private val EDIT_REQUEST = 9001

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"openEditor" -> {
						val imagePath: String? = call.argument("imagePath")
						val intent = Intent(this, PhotoEditorActivity::class.java)
						intent.putExtra("imagePath", imagePath)
						pendingResult = result
						startActivityForResult(intent, EDIT_REQUEST)
					}
					else -> result.notImplemented()
				}
			}
	}

	override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
		super.onActivityResult(requestCode, resultCode, data)
		if (requestCode == EDIT_REQUEST) {
			val outPath = data?.getStringExtra("edited")
			if (resultCode == Activity.RESULT_OK && outPath != null) {
				pendingResult?.success(outPath)
			} else if (resultCode == Activity.RESULT_CANCELED) {
				pendingResult?.error("EDIT_CANCELLED", "Editing cancelled", null)
			} else {
				pendingResult?.error("EDIT_FAILED", "Editing failed", null)
			}
			pendingResult = null
		}
	}
}
