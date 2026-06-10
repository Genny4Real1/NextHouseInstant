package com.nexthouse.instant.nexthouse_instant

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.nexthouse.instant/kiosk"
    private var isKioskMode = false

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
