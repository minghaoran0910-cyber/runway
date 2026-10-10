package com.zangou.runway

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// SB-010 · 通道宿主（CONTRACT 见 packages/android_notification_collector）.
// 方法：isListenerEnabled / openListenerSettings；推送：onPending（结构化-only，无原文）.
// 未授权/撤销→ Dart 侧降级为手动，永不抛崩（崩溃=打回）.
class MainActivity : FlutterActivity() {

    companion object {
        const val CHANNEL = "runway/notify_collector"
        const val ACTION_PENDING = "com.zangou.runway.PENDING_PUSH"
    }

    private var channel: MethodChannel? = null

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action != ACTION_PENDING) return
            val map = mapOf(
                "packageName" to (intent.getStringExtra("packageName") ?: ""),
                "title" to (intent.getStringExtra("title") ?: ""),
                "amountFen" to intent.getIntExtra("amountFen", 0),
                "merchant" to (intent.getStringExtra("merchant") ?: ""),
                "notifyKey" to (intent.getStringExtra("notifyKey") ?: ""),
                "occurredAtMs" to intent.getLongExtra("occurredAtMs", System.currentTimeMillis()),
                "tag" to (intent.getStringExtra("tag") ?: ""),
                "notifId" to intent.getIntExtra("notifId", 0),
                "whenMs" to intent.getLongExtra("whenMs", 0L),
                "postTimeMs" to intent.getLongExtra("postTimeMs", System.currentTimeMillis()),
                "contentHash" to (intent.getStringExtra("contentHash") ?: "")
            )
            channel?.invokeMethod("onPending", map)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "isListenerEnabled" -> result.success(isListenerEnabled())
                "openListenerSettings" -> {
                    openListenerSettings()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        val filter = IntentFilter(ACTION_PENDING)
        if (Build.VERSION.SDK_INT >= 33) {
            registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            registerReceiver(receiver, filter)
        }
    }

    override fun onDestroy() {
        try {
            unregisterReceiver(receiver)
        } catch (_: Exception) {
            // 重复解绑保护：Activity 重建时 receiver 可能已注销.
        }
        super.onDestroy()
    }

    private fun isListenerEnabled(): Boolean {
        val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
            ?: return false
        return flat.contains(packageName)
    }

    private fun openListenerSettings() {
        try {
            startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
        } catch (_: Exception) {
            // 无设置页的 ROM：停留本页，Dart 侧已降级为手动.
        }
    }
}
