package com.nexthouse.instant.nexthouse_instant

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent

class KioskAdminReceiver : DeviceAdminReceiver() {
    override fun onEnabled(context: Context, intent: Intent) {
        super.onEnabled(context, intent)
    }
}
