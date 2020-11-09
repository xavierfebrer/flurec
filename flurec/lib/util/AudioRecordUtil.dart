import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecordUtil {
  static Future<bool> openAudioSession(FlutterSoundRecorder recorder,
      {AudioFocus focus = AudioFocus.requestFocusTransient,
      SessionCategory category = SessionCategory.playAndRecord,
      SessionMode mode = SessionMode.modeDefault,
      int audioFlags = outputToSpeaker,
      AudioDevice device = AudioDevice.speaker}) async {
    try {
      await recorder.openAudioSession(
          focus: AudioFocus.requestFocusTransient,
          category: SessionCategory.playAndRecord,
          mode: SessionMode.modeDefault,
          audioFlags: outputToSpeaker,
          device: AudioDevice.speaker);
      return true;
    } catch (e) {}
    return false;
  }

  static Future<bool> startRecorder(FlutterSoundRecorder recorder, String completeFilePathWithExtension,
      {Codec codec = Codec.aacADTS,
      int sampleRate = 16000,
      int numChannels = 1,
      int bitRate = 16000,
      AudioFocus focus = AudioFocus.requestFocusTransient,
      SessionCategory category = SessionCategory.playAndRecord,
      SessionMode mode = SessionMode.modeDefault,
      int audioFlags = outputToSpeaker,
      AudioDevice device = AudioDevice.speaker}) async {
    try {
      Map<PermissionGroup, PermissionStatus> status = await PermissionHandler().requestPermissions([PermissionGroup.microphone, PermissionGroup.speech]);
      if (status[PermissionGroup.microphone] != PermissionStatus.granted) throw RecordingPermissionException("Microphone permission not granted");
      if (!await recorder.isEncoderSupported(codec)) throw Exception("encoder not supported for codec: $codec");
      await recorder.startRecorder(
        codec: codec,
        toFile: completeFilePathWithExtension,
        toStream: null,
        sampleRate: sampleRate,
        numChannels: numChannels,
        bitRate: bitRate,
        audioSource: AudioSource.defaultSource,
      );
      return true;
    } catch (e) {}
    return false;
  }

  static Future<bool> stopRecorder(FlutterSoundRecorder recorder) async {
    try {
      await recorder.stopRecorder();
      return true;
    } catch (e) {}
    return false;
  }

  static Future<bool> resumeRecorder(FlutterSoundRecorder recorder, {VoidCallback onSuccess, VoidCallback onFail}) async {
    try {
      await recorder.resumeRecorder();
      return true;
    } catch (e) {}
    return false;
  }

  static Future<bool> pauseRecorder(FlutterSoundRecorder recorder) async {
    try {
      await recorder.pauseRecorder();
      return true;
    } catch (e) {}
    return false;
  }

  static Future<void> disposeRecorder(FlutterSoundRecorder recorder) async {
    try {
      await recorder?.closeAudioSession();
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
