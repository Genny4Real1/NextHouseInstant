package com.nexthouse.instant.nexthouse_instant

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.Button
import androidx.appcompat.app.AppCompatActivity
import ja.burhanrashid52.photoeditor.PhotoEditor
import ja.burhanrashid52.photoeditor.PhotoEditorView

class PhotoEditorActivity : AppCompatActivity() {
    private var photoEditor: PhotoEditor? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_photo_editor)

        val photoEditorView = findViewById<PhotoEditorView>(R.id.photoEditorView)

        // Initialize PhotoEditor
        photoEditor = PhotoEditor.Builder(this, photoEditorView)
            .setPinchTextScalable(true)
            .build()

        // Load image from intent (file path or asset path)
        val imagePath = intent.getStringExtra("imagePath")
        if (!imagePath.isNullOrEmpty()) {
            try {
                val uri = Uri.parse(imagePath)
                if (uri.scheme == null) {
                    // treat as file path
                    photoEditorView.source.setImageURI(Uri.fromFile(java.io.File(imagePath)))
                } else {
                    photoEditorView.source.setImageURI(uri)
                }
            } catch (e: Exception) {
                // ignore
            }
        }

        // Save button
        findViewById<Button>(R.id.btn_save).setOnClickListener {
            val outFile = java.io.File(cacheDir, "edited_${System.currentTimeMillis()}.jpg")
            photoEditor?.saveAsFile(outFile.absolutePath, object : PhotoEditor.OnSaveListener {
                override fun onSuccess(imagePath: String) {
                    val data = Intent()
                    data.putExtra("edited", imagePath)
                    setResult(Activity.RESULT_OK, data)
                    finish()
                }

                override fun onFailure(exception: Exception) {
                    setResult(Activity.RESULT_CANCELED)
                    finish()
                }
            })
        }

        // Cancel button
        findViewById<Button>(R.id.btn_cancel).setOnClickListener {
            setResult(Activity.RESULT_CANCELED)
            finish()
        }
    }
}
