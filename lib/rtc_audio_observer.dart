import 'dart:typed_data';

import 'package:flutter/services.dart';

class RtcAudioObserver {
  final _recordedAudioEventChannel =
      EventChannel('agora_rtc_channel/recorded_audio_observer');
  final _playbackAudioEventChannel =
      EventChannel('agora_rtc_channel/playback_audio_observer');

  Stream<RtcAudioFrame> observeRecordedAudioFrames() {
    return _recordedAudioEventChannel.receiveBroadcastStream().map((event) {
      return RtcAudioFrame.fromMap((event as Map).cast<String, dynamic>());
    });
  }

  Stream<RtcAudioFrame> observePlaybackAudioFrames() {
    return _playbackAudioEventChannel
        .receiveBroadcastStream()
        .map((event) => RtcAudioFrame.fromMap(event as Map<String, dynamic>));
  }
}

class RtcAudioFrame {
  final Uint8List samples;
  final int numOfSamples;
  final int bytesPerSample;
  final int channels;
  final int samplesPerSec;

  const RtcAudioFrame({
    this.samples,
    this.numOfSamples,
    this.bytesPerSample,
    this.channels,
    this.samplesPerSec,
  });

  factory RtcAudioFrame.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

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
    return 'RtcAudioFrame(samples: $samples, numOfSamples: $numOfSamples, bytesPerSample: $bytesPerSample, channels: $channels, samplesPerSec: $samplesPerSec)';
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
