package com.nexthouse.instant.nexthouse_instant

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.view.KeyEvent
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.nexthouse.instant/kiosk"
    private var isKioskMode = false

    private val keySequence = mutableListOf<Int>()
    private var lastKeyTime: Long = 0
    private val SEQUENCE_TIMEOUT_MS = 4000 // 4 seconds to complete the pattern
    private val TARGET_SEQUENCE = listOf(
        KeyEvent.KEYCODE_VOLUME_UP,
        KeyEvent.KEYCODE_VOLUME_DOWN,
        KeyEvent.KEYCODE_VOLUME_UP,
        KeyEvent.KEYCODE_VOLUME_DOWN,
        KeyEvent.KEYCODE_VOLUME_UP,
        KeyEvent.KEYCODE_VOLUME_DOWN
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startKioskMode" -> {
                    startKiosk()
                    result.success(true)
                }
                "stopKioskMode" -> {
                    stopKiosk()
                    result.success(true)
                }
                "isKioskMode" -> {
                    result.success(isKioskMode)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (isKioskMode && event.action == KeyEvent.ACTION_DOWN) {
            val keyCode = event.keyCode
            if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN || keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
                val now = System.currentTimeMillis()
                if (now - lastKeyTime > SEQUENCE_TIMEOUT_MS) {
                    keySequence.clear()
                }
                lastKeyTime = now
                keySequence.add(keyCode)
                
                if (keySequence.size > TARGET_SEQUENCE.size) {
                    keySequence.removeAt(0)
                }

                if (keySequence == TARGET_SEQUENCE) {
                    keySequence.clear()
                    stopKiosk()
                    Toast.makeText(this, "Kiosk mode deactivated", Toast.LENGTH_SHORT).show()
                }
                return true // Consume key press
            }
        }
        return super.dispatchKeyEvent(event)
    }

    private fun startKiosk() {
        try {
            val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
            val adminName = ComponentName(this, KioskAdminReceiver::class.java)
            if (dpm.isDeviceOwnerApp(packageName)) {
                dpm.setLockTaskPackages(adminName, arrayOf(packageName))
            }
            startLockTask()
            isKioskMode = true
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun stopKiosk() {
        try {
            stopLockTask()
            isKioskMode = false
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
