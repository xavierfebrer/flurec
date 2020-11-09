import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/flutter_sound.dart';

class AudioPlayUtil {
  static Future<bool> openAudioSession(
    FlutterSoundPlayer player, {
    AudioFocus focus = AudioFocus.requestFocusAndStopOthers,
    SessionCategory category = SessionCategory.playback,
    SessionMode mode = SessionMode.modeDefault,
    int audioFlags = outputToSpeaker,
    AudioDevice device = AudioDevice.speaker,
    bool withUI = false,
  }) async {
    try {
      await player.openAudioSession(
        focus: focus,
        category: category,
        mode: mode,
        audioFlags: audioFlags,
        device: device,
        withUI: withUI,
      );
      return true;
    } catch (e) {}
    return false;
  }

  static Future<Duration> startPlayer(FlutterSoundPlayer player, String completeFilePathWithExtension,
      {Codec codec,
      Uint8List fromDataBuffer,
      int sampleRate, // Used only when Codec == Codec.pcm16
      VoidCallback onFinish}) async {
    try {
      if (codec == Codec.pcm16 && sampleRate == null) throw Exception("sampleRate must not be null when using codec: $codec");
      //if (!await player.isDecoderSupported(codec)) throw Exception("decoder not supported for codec: $codec");
      Duration duration = await player.startPlayer(
        fromURI: completeFilePathWithExtension,
        codec: codec,
        fromDataBuffer: fromDataBuffer,
        sampleRate: sampleRate,
        whenFinished: () {
          if (onFinish != null) onFinish();
        },
      );
      return duration;
    } catch (e) {}
    return null;
  }

  static Future<bool> stopPlayer(FlutterSoundPlayer player) async {
    try {
      await player.stopPlayer();
      return true;
    } catch (e) {}
    return false;
  }

  static Future<bool> resumePlayer(FlutterSoundPlayer player) async {
    try {
      await player.resumePlayer();
      return true;
    } catch (e) {}
    return false;
  }

  static Future<bool> pausePlayer(FlutterSoundPlayer player) async {
    try {
      await player.pausePlayer();
      return true;
    } catch (e) {}
    return false;
  }

  static Future<FlutterSoundPlayer> disposePlayer(FlutterSoundPlayer player) async {
    try {
      await player?.closeAudioSession();
    } catch (e) {}
  }

  static String getExtensionForCodec(Codec codec, {bool withStartingDot = true}) {
    if (codec == Codec.aacADTS) {
      return (withStartingDot ? "." : "") + "aac";
    } else {
      return null;
    }
  }
}
