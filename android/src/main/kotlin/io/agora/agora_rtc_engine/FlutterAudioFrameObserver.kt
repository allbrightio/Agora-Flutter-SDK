package io.agora.agora_rtc_engine

import android.os.Handler
import android.os.Looper
import io.agora.rtc.Constants
import io.agora.rtc.IAudioFrameObserver
import io.flutter.plugin.common.EventChannel

class MainThreadEventSink(private val eventSink: EventChannel.EventSink) : EventChannel.EventSink {
    private val handler = Handler(Looper.getMainLooper())

  override fun endOfStream() {
    handler.post {
      eventSink.endOfStream()
    }
  }

  override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
    handler.post {
      eventSink.error(errorCode, errorMessage, errorDetails)
    }
  }

  override fun success(event: Any?) {
    handler.post {
      eventSink.success(event)
    }
  }
}


class FlutterAudioFrameObserver(private val rtcEnginePlugin: AgoraRtcEnginePlugin) : IAudioFrameObserver {


  val onRecordFrameStreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
      rtcEnginePlugin.engine()?.setRecordingAudioFrameParameters(16000, 1, Constants.RAW_AUDIO_FRAME_OP_MODE_READ_ONLY, 1024)
      onRecordFrameSink = events?.let { MainThreadEventSink(it) }
      if (onPlaybackFrameSink == null) {
        rtcEnginePlugin.engine()?.registerAudioFrameObserver(this@FlutterAudioFrameObserver)
      }
    }

    override fun onCancel(arguments: Any?) {
      onRecordFrameSink?.endOfStream()
      onRecordFrameSink = null
      if (onPlaybackFrameSink == null) {
        rtcEnginePlugin.engine()?.registerAudioFrameObserver(null)
      }
    }
  }

  val onPlaybackStreamHandler = object : EventChannel.StreamHandler {
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
      onPlaybackFrameSink = events?.let {  MainThreadEventSink(it) }
      if (onRecordFrameSink == null) {
        rtcEnginePlugin.engine()?.registerAudioFrameObserver(this@FlutterAudioFrameObserver)
      }
    }

    override fun onCancel(arguments: Any?) {
      onPlaybackFrameSink?.endOfStream()
      onPlaybackFrameSink = null
      if (onRecordFrameSink == null) {
        rtcEnginePlugin.engine()?.registerAudioFrameObserver(null)
      }
    }
  }

  private var onRecordFrameSink: EventChannel.EventSink? = null
  private var onPlaybackFrameSink: EventChannel.EventSink? = null

  override fun onRecordFrame(samples: ByteArray?, numOfSamples: Int, bytesPerSample: Int, channels: Int, samplesPerSec: Int): Boolean {
    onRecordFrameSink?.success(mapOf(
      "samples" to samples,
      "numOfSamples" to numOfSamples,
      "bytesPerSample" to bytesPerSample,
      "channels" to channels,
      "samplesPerSec" to samplesPerSec
    ))
    return true
  }

  override fun onPlaybackFrame(samples: ByteArray?, numOfSamples: Int, bytesPerSample: Int, channels: Int, samplesPerSec: Int): Boolean {
    onPlaybackFrameSink?.success(
      mapOf(
        "samples" to samples,
        "numOfSamples" to numOfSamples,
        "bytesPerSample" to bytesPerSample,
        "channels" to channels,
        "samplesPerSec" to samplesPerSec
      )
    )
    return true
  }
}
