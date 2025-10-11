package com.tiagoneves.notebox

import android.Manifest
import android.content.pm.PackageManager
import android.media.MediaRecorder
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "notebox/recorder"
    private var recorder: MediaRecorder? = null
    private var outputPath: String? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        val path = call.argument<String>("path")
                        if (path == null) {
                            result.error("ARG", "Missing 'path'", null); return@setMethodCallHandler
                        }
                        startRecording(path, result)
                    }
                    "stop" -> stopRecording(result)
                    "isRecording" -> result.success(recorder != null)
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasMicPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= 23) {
            checkSelfPermission(Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED
        } else true
    }

    private fun startRecording(path: String, result: MethodChannel.Result) {
        if (recorder != null) {
            result.error("STATE", "Already recording", null)
            return
        }
        if (!hasMicPermission()) {
            requestPermissions(arrayOf(Manifest.permission.RECORD_AUDIO), 1001)
            result.error("PERM", "No mic permission", null)
            return
        }
        outputPath = path
        recorder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) MediaRecorder(this) else MediaRecorder()
        try {
            recorder?.apply {
                setAudioSource(MediaRecorder.AudioSource.MIC)
                setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                setAudioEncodingBitRate(128000)
                setAudioSamplingRate(44100)
                setOutputFile(path)
                prepare()
                start()
            }
            result.success(true)
        } catch (e: Exception) {
            recorder?.release()
            recorder = null
            outputPath = null
            result.error("START_FAIL", e.message, null)
        }
    }

    private fun stopRecording(result: MethodChannel.Result) {
        val r = recorder ?: run { result.success(null); return }
        try {
            r.stop()
        } catch (_: Exception) {
            // ignora stop falhado
        }
        r.reset()
        r.release()
        recorder = null
        val out = outputPath
        outputPath = null
        result.success(out)
    }
}
