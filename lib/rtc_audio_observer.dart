import 'dart:typed_data';

import 'package:flutter/services.dart';

class RtcAudioObserver {
  final _recordedAudioEventChannel =
      EventChannel('agora_rtc_channel/recorded_audio_observer');
  final _playbackAudioEventChannel =
      EventChannel('agora_rtc_channel/playback_audio_observer');

  /// * **sampleRate** The sample rate (samplesPerSec) which can be set as 8000, 16000, 32000, 44100, or 48000 Hz.
  /// * **channels** The number of channels (Mono - 1, Stereo - 2),
  /// * **samplesPerEvent** The number of samples in single event emitted by the stream.
  Stream<RtcAudioFrame> observeRecordedAudioFrames({
    int sampleRate = 48000,
    int channels = 2,
    int samplesPerEvent = 1024,
  }) {
    return _recordedAudioEventChannel.receiveBroadcastStream({
      'sampleRate': sampleRate,
      'channels': channels,
      'samplesPerCall': samplesPerEvent,
      'mode': 0, // read only
    }).map((event) {
      return RtcAudioFrame.fromMap((event as Map).cast<String, dynamic>());
    });
  }

  /// * **sampleRate** The sample rate (samplesPerSec) which can be set as 8000, 16000, 32000, 44100, or 48000 Hz.
  /// * **channels** The number of channels (Mono - 1, Stereo - 2),
  /// * **samplesPerEvent** The number of samples in single event emitted by the stream.
  Stream<RtcAudioFrame> observePlaybackAudioFrames({
    int sampleRate = 48000,
    int channels = 2,
    int samplesPerEvent = 1024,
  }) {
    return _playbackAudioEventChannel.receiveBroadcastStream({
      'sampleRate': sampleRate,
      'channels': channels,
      'samplesPerCall': samplesPerEvent,
      'mode': 0, // read only
    }).map((event) => RtcAudioFrame.fromMap(event as Map<String, dynamic>));
  }
}

class RtcAudioFrame {
  final Uint8List samples;
  final int numOfSamples;
  final int bytesPerSample;
  final int channels;
  final int samplesPerSec;

  const RtcAudioFrame({
    required this.samples,
    required this.numOfSamples,
    required this.bytesPerSample,
    required this.channels,
    required this.samplesPerSec,
  });

  factory RtcAudioFrame.fromMap(Map<String, dynamic> map) {
    return RtcAudioFrame(
      samples: map['samples'] ?? [],
      numOfSamples: map['numOfSamples'],
      bytesPerSample: map['bytesPerSample'],
      channels: map['channels'],
      samplesPerSec: map['samplesPerSec'],
    );
  }

  @override
  String toString() {
    return 'RtcAudioFrame(numOfSamples: $numOfSamples, bytesPerSample: $bytesPerSample, channels: $channels, samplesPerSec: $samplesPerSec, samples: $samples)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is RtcAudioFrame &&
        o.samples == samples &&
        o.numOfSamples == numOfSamples &&
        o.bytesPerSample == bytesPerSample &&
        o.channels == channels &&
        o.samplesPerSec == samplesPerSec;
  }

  @override
  int get hashCode {
    return samples.hashCode ^
        numOfSamples.hashCode ^
        bytesPerSample.hashCode ^
        channels.hashCode ^
        samplesPerSec.hashCode;
  }
}
