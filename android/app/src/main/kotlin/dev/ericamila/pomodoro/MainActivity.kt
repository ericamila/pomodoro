package dev.ericamila.pomodoro

import android.media.RingtoneManager
import android.net.Uri
import androidx.annotation.NonNull
import android.database.Cursor
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "dev.ericamila.pomodoro/ringtones"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getRingtones") {
                val ringtones = getRingtones()
                if (ringtones != null) {
                    result.success(ringtones)
                } else {
                    result.error("UNAVAILABLE", "Ringtones not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getRingtones(): List<Map<String, String>>? {
        val ringtoneList = mutableListOf<Map<String, String>>()

        val manager = RingtoneManager(this)
        manager.setType(RingtoneManager.TYPE_ALARM)
        val cursor: Cursor = manager.cursor

        while (cursor.moveToNext()) {
            val title = cursor.getString(RingtoneManager.TITLE_COLUMN_INDEX)
            val uri = "${cursor.getString(RingtoneManager.URI_COLUMN_INDEX)}/${cursor.getString(RingtoneManager.ID_COLUMN_INDEX)}"

            val ringtone = mapOf("title" to title, "uri" to uri)
            ringtoneList.add(ringtone)
        }
        cursor.close()
        return ringtoneList
    }
}
