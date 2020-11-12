import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:screen/screen.dart';

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

  static Future<Duration> startPlayer(FlutterSoundPlayer player, String completeFilePathWithExtension, List<Codec> codecs, {VoidCallback onFinish}) async {
    Duration duration;
    for (Codec codec in codecs) {
      try {
        duration = await player.startPlayer(
          fromURI: completeFilePathWithExtension,
          codec: codec,
          whenFinished: () {
            if (onFinish != null) onFinish();
          },
        );
      } catch (e) {
        duration = null;
      }
      if (duration != null) {
        break;
      }
    }
    Screen.keepOn(duration != null);
    return duration;
  }

  static Future<bool> stopPlayer(FlutterSoundPlayer player) async {
    Screen.keepOn(false);
    try {
      await player.stopPlayer();
      return true;
    } catch (e) {}
    return false;
  }

  static Future<bool> resumePlayer(FlutterSoundPlayer player) async {
    Screen.keepOn(false);
    try {
      await player.resumePlayer();
      return true;
    } catch (e) {}
    return false;
  }

  static Future<bool> pausePlayer(FlutterSoundPlayer player) async {
    Screen.keepOn(false);
    try {
      await player.pausePlayer();
      return true;
    } catch (e) {}
    return false;
  }

  static Future<bool> disposePlayer(FlutterSoundPlayer player) async {
    Screen.keepOn(false);
    try {
      await player?.closeAudioSession();
      return true;
    } catch (e) {}
    return false;
  }
}
