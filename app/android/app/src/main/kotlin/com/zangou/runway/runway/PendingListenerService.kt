package com.zangou.runway.runway

import android.content.Intent
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import java.math.BigDecimal
import java.math.RoundingMode
import java.security.MessageDigest

// SB-010 · 通知监听采集（PRD §3 全量口径/待确认 / §5 通知原文零留存 / §4 本地优先）.
// 只提取结构化字段（金额分/商户/包名/去重键/时间戳），经广播发 MainActivity 转交 Dart；
// 标题/正文原文不写盘、不写库，函数返回即丢弃. 非目标包/无金额通知直接丢弃.
// 金额口径与 Dart 侧 parsePaymentNotice 对齐（`12.34元` / `￥12.34`）.
class PendingListenerService : NotificationListenerService() {

    companion object {
        const val ALIPAY = "com.eg.android.AlipayGphone"
        const val WECHAT = "com.tencent.mm"
        // when 毫秒可信下界（与 Dart 侧 notifyWhenMsThreshold 同值；秒级 ~1.7e9 必回退）.
        const val WHEN_MS_THRESHOLD = 1000000000000L
        private val AMOUNT_YUAN = Regex("""(\d+(?:\.\d{1,2})?)元""")
        private val AMOUNT_CNY = Regex("""￥\s*(\d+(?:\.\d{1,2})?)""")

        fun sha1Hex(s: String): String {
            val bytes = MessageDigest.getInstance("SHA-1")
                .digest(s.toByteArray(Charsets.UTF_8))
            return bytes.joinToString("") { "%02x".format(it.toInt() and 0xFF) }
        }

        // 内容哈希：SHA-1(包|标题trim|金额分)，与 Dart 侧 notifyContentHash 同口径.
        // §5：标题原文只进哈希预镜像，不明文落库.
        fun contentHashFor(pkg: String, title: String, fen: Int): String {
            return sha1Hex("$pkg|${title.trim()}|$fen")
        }

        fun isTrustedWhenMs(whenMs: Long?): Boolean {
            return whenMs != null && whenMs >= WHEN_MS_THRESHOLD
        }

        // 去重键：SB-010 验收 4『通知对象身份』（d6ae1ab 定稿，废时间桶），
        // 与 Dart 侧 makeNotifyKey 同口径（UTF-8，分隔符 `|`）.
        // when 可信：SHA-1(包|tag|id|when毫秒|内容哈希)；否则回退
        // SHA-1(包|tag|id|内容哈希|postTime秒).
        fun makeNotifyKey(
            pkg: String,
            tag: String,
            notifId: Int,
            whenMs: Long?,
            postTimeMs: Long?,
            title: String,
            fen: Int,
        ): String {
            val content = contentHashFor(pkg, title, fen)
            if (isTrustedWhenMs(whenMs)) {
                return sha1Hex("$pkg|$tag|$notifId|$whenMs|$content")
            }
            val postSec = (postTimeMs ?: 0L) / 1000L
            return sha1Hex("$pkg|$tag|$notifId|$content|$postSec")
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val pkg = sbn.packageName ?: return
        if (pkg != ALIPAY && pkg != WECHAT) return
        val extras = sbn.notification.extras
        val title = extras.getCharSequence("android.title")?.toString().orEmpty()
        val text = extras.getCharSequence("android.text")?.toString().orEmpty()
        val hit = AMOUNT_YUAN.find(text) ?: AMOUNT_CNY.find(text)
            ?: AMOUNT_YUAN.find(title) ?: AMOUNT_CNY.find(title) ?: return
        // 金额口径与 Dart 侧 parseAmountToFen 对齐：字符串→BigDecimal 右移 2 位
        // HALF_UP 取整（8.20→820；旧 toDouble*100+toInt 截断得 819，SB-010 第 1 轮问题 2）.
        val fen = try {
            BigDecimal(hit.groupValues[1]).movePointRight(2)
                .setScale(0, RoundingMode.HALF_UP).intValueExact()
        } catch (_: Exception) {
            return
        }
        if (fen <= 0) return
        // 商户截断 32 字，与 Dart 侧 parsePaymentNotice 同口径（SB-010 第 1 轮观察项）.
        val merchant = (title.ifEmpty { if (pkg == ALIPAY) "支付宝" else "微信支付" }).take(32)
        // SB-010 验收 4『通知对象身份』（R3 末轮）：身份三元组 key(pkg|tag|id)+when毫秒+
        // 内容哈希；when 缺失/非毫秒可信回退 postTime 秒. 第 1 轮已修项保留：
        // 键体哈希化（§5）+ BigDecimal HALF_UP + merchant32 均不动.
        val tag = sbn.tag ?: ""
        val notifId = sbn.id
        val postTimeMs = sbn.postTime
        val whenMs: Long? = try {
            val w = sbn.notification.`when`
            if (w > 0) w else null
        } catch (_: Exception) {
            null
        }
        val content = contentHashFor(pkg, title, fen)
        val key = makeNotifyKey(pkg, tag, notifId, whenMs, postTimeMs, title, fen)
        val occurredAtMs = if (isTrustedWhenMs(whenMs)) whenMs!! else postTimeMs
        val out = Intent(MainActivity.ACTION_PENDING).apply {
            setPackage(packageName)
            putExtra("packageName", pkg)
            putExtra("title", title)
            putExtra("amountFen", fen)
            putExtra("merchant", merchant)
            putExtra("notifyKey", key)
            putExtra("occurredAtMs", occurredAtMs)
            putExtra("tag", tag)
            putExtra("notifId", notifId)
            putExtra("whenMs", whenMs ?: 0L)
            putExtra("postTimeMs", postTimeMs)
            putExtra("contentHash", content)
        }
        sendBroadcast(out)
    }
}
