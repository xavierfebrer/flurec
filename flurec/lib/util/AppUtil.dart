import 'package:flurec/model/Settings.dart';
import 'package:flurec/util/Constant.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUtil {
  static Future<Settings> getSettingsModel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Settings settings = Settings(
      autoPlayWhenVisitingDetail: prefs.getBool(Constant.PREFS_KEY_AUTO_PLAY_WHEN_VISITING_DETAIL) ?? Constant.DEFAULT_AUTO_PLAY_WHEN_VISITING_DETAIL,
      showDeleteSuccessInfo: prefs.getBool(Constant.PREFS_KEY_SHOW_DELETE_SUCCESS_INFO) ?? Constant.DEFAULT_SHOW_DELETE_SUCCESS_INFO,
      showRenameSuccessInfoFiles: prefs.getBool(Constant.PREFS_KEY_SHOW_RENAME_SUCCESS_INFO) ?? Constant.DEFAULT_SHOW_RENAME_SUCCESS_INFO,
      showConfirmationDeleteFiles: prefs.getBool(Constant.PREFS_KEY_SHOW_CONFIRMATION_DELETE_FILES) ?? Constant.DEFAULT_SHOW_CONFIRMATION_DELETE_FILES,
      showConfirmationRenameFiles: prefs.getBool(Constant.PREFS_KEY_SHOW_CONFIRMATION_RENAME_FILES) ?? Constant.DEFAULT_SHOW_CONFIRMATION_RENAME_FILES,
      currentEncoderCodec: Codec.values[prefs.getInt(Constant.PREFS_KEY_CURRENT_ENCODER_CODEC_INDEX) ?? Constant.DEFAULT_CURRENT_ENCODER_CODEC_INDEX.index],
    );
    return settings;
  }

  static Future<bool> setSettingsModel(Settings settings) async {
    if (settings == null) return false;
    bool result = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    result = result && await prefs.setBool(Constant.PREFS_KEY_AUTO_PLAY_WHEN_VISITING_DETAIL, settings.autoPlayWhenVisitingDetail);
    result = result && await prefs.setBool(Constant.PREFS_KEY_SHOW_DELETE_SUCCESS_INFO, settings.showDeleteSuccessInfo);
    result = result && await prefs.setBool(Constant.PREFS_KEY_SHOW_RENAME_SUCCESS_INFO, settings.showRenameSuccessInfoFiles);
    result = result && await prefs.setBool(Constant.PREFS_KEY_SHOW_CONFIRMATION_DELETE_FILES, settings.showConfirmationDeleteFiles);
    result = result && await prefs.setBool(Constant.PREFS_KEY_SHOW_CONFIRMATION_RENAME_FILES, settings.showConfirmationRenameFiles);
    result = result && await prefs.setInt(Constant.PREFS_KEY_CURRENT_ENCODER_CODEC_INDEX, settings.currentEncoderCodec.index);
    return result;
  }

  static String getCodecName(Codec codec) {
    String codecName;
    if (codec == Codec.aacADTS) {
      codecName = "ADTS AAC";
    } else if (codec == Codec.opusOGG) {
      codecName = "OGG OPUS";
    } else if (codec == Codec.opusCAF) {
      codecName = "CAF OPUS";
    } else if (codec == Codec.mp3) {
      codecName = "MP3";
    } else if (codec == Codec.vorbisOGG) {
      codecName = "OGG VORBIS";
    } else if (codec == Codec.pcm16) {
      codecName = "PCM Linear 16";
    } else if (codec == Codec.pcm16WAV) {
      codecName = "WAV Linear 16 PCM";
    } else if (codec == Codec.pcm16AIFF) {
      codecName = "AIFF Linear 16 PCM";
    } else if (codec == Codec.pcm16CAF) {
      codecName = "CAF Linear 16 PCM";
    } else if (codec == Codec.flac) {
      codecName = "FLAC";
    } else if (codec == Codec.aacMP4) {
      codecName = "MPEG4 AAC";
    } else if (codec == Codec.amrWB) {
      codecName = "AMR-WB";
    } else if (codec == Codec.amrNB) {
      codecName = "AMR-NB";
    } else if (codec == Codec.pcm8) {
      codecName = "Raw PCM Linear 8";
    } else if (codec == Codec.pcmFloat32) {
      codecName = "Raw PCM 32 Float";
    } else if (codec == Codec.pcmWebM) {
      codecName = "WEBM PCM";
    } else if (codec == Codec.opusWebM) {
      codecName = "WEBM OPUS";
    } else if (codec == Codec.vorbisWebM) {
      codecName = "WEBM VORBIS";
    } else {
      return null;
    }
    codecName = "$codecName (${getExtensionForCodec(codec)})";
    return codecName;
  }

  static String getExtensionForCodec(Codec codec, {bool withStartingDot = true}) {
    String extension;
    if (codec == Codec.aacADTS) {
      extension = "aac";
    } else if (codec == Codec.opusOGG || codec == Codec.vorbisOGG) {
      extension = "ogg";
    } else if (codec == Codec.opusCAF) {
      extension = "caf";
    } else if (codec == Codec.mp3) {
      extension = "mp3";
    } else if (codec == Codec.pcm16 || codec == Codec.pcm8 || codec == Codec.pcmFloat32) {
      extension = "pcm";
    } else if (codec == Codec.pcm16WAV) {
      extension = "wav";
    } else if (codec == Codec.pcm16AIFF) {
      extension = "aiff";
    } else if (codec == Codec.pcm16CAF) {
      extension = "caf";
    } else if (codec == Codec.flac) {
      extension = "flac";
    } else if (codec == Codec.aacMP4) {
      extension = "mp4";
    } else if (codec == Codec.amrWB || codec == Codec.amrNB) {
      extension = "amr";
    } else if (codec == Codec.pcmWebM || codec == Codec.opusWebM || codec == Codec.vorbisWebM) {
      extension = "webm";
    } else {
      return null;
    }
    return extension = (withStartingDot ? "." : "") + extension;
  }

  static Future<List<Codec>> getCodecsForExtension(String extension) async {
    List<Codec> codecs = List<Codec>();
    if (extension.endsWith("adts")) {
      codecs.add(Codec.aacADTS);
    } else if (extension.endsWith("ogg")) {
      codecs.add(Codec.opusOGG);
      codecs.add(Codec.vorbisOGG);
    } else if (extension.endsWith("caf")) {
      codecs.add(Codec.opusCAF);
      codecs.add(Codec.pcm16CAF);
    } else if (extension.endsWith("mp3")) {
      codecs.add(Codec.mp3);
    } else if (extension.endsWith("pcm")) {
      codecs.add(Codec.pcm8);
      codecs.add(Codec.pcm16);
      codecs.add(Codec.pcmFloat32);
    } else if (extension.endsWith("wav")) {
      codecs.add(Codec.pcm16WAV);
    } else if (extension.endsWith("aiff")) {
      codecs.add(Codec.pcm16AIFF);
    } else if (extension.endsWith("flac")) {
      codecs.add(Codec.flac);
    } else if (extension.endsWith("mp4")) {
      codecs.add(Codec.aacMP4);
    } else if (extension.endsWith("amr")) {
      codecs.add(Codec.amrWB);
      codecs.add(Codec.amrNB);
    } else if (extension.endsWith("webm")) {
      codecs.add(Codec.pcmWebM);
      codecs.add(Codec.opusWebM);
      codecs.add(Codec.vorbisWebM);
    }
    return codecs;
  }

  static Future<List<Codec>> getAvailableEncoderCodecs(TargetPlatform platform) async {
    List<Codec> availableCodecs = List<Codec>();
    if (platform == TargetPlatform.android) {
      availableCodecs.addAll([
        Codec.aacADTS,
        Codec.pcm16,
        Codec.pcm16WAV,
        Codec.aacMP4,
        Codec.amrWB,
        Codec.amrNB,
        Codec.opusWebM,
      ]);
    } else if (platform == TargetPlatform.iOS) {
      availableCodecs.addAll([
        Codec.aacADTS,
        Codec.opusOGG,
        Codec.opusCAF,
        Codec.pcm16,
        Codec.pcm16WAV,
        Codec.pcm16CAF,
        Codec.flac,
        Codec.aacMP4,
      ]);
    } else {
      availableCodecs.addAll(Codec.values..remove(Codec.defaultCodec));
    }
    return availableCodecs;
  }

  static Future<List<Codec>> getAvailableDecoderCodecs(TargetPlatform platform) async {
    List<Codec> availableCodecs = List<Codec>();
    if (platform == TargetPlatform.android) {
      availableCodecs.addAll([
        Codec.aacADTS,
        Codec.opusOGG,
        Codec.opusCAF,
        Codec.mp3,
        Codec.vorbisOGG,
        Codec.pcm16,
        Codec.pcm16WAV,
        Codec.pcm16AIFF,
        Codec.pcm16CAF,
        Codec.flac,
        Codec.aacMP4,
        Codec.amrWB,
        Codec.amrNB,
        Codec.opusWebM,
        Codec.vorbisWebM,
      ]);
    } else if (platform == TargetPlatform.iOS) {
      availableCodecs.addAll([
        Codec.aacADTS,
        Codec.opusOGG,
        Codec.opusCAF,
        Codec.mp3,
        Codec.pcm16,
        Codec.pcm16WAV,
        Codec.pcm16AIFF,
        Codec.pcm16CAF,
        Codec.flac,
        Codec.aacMP4,
        Codec.vorbisWebM,
      ]);
    } else {
      availableCodecs.addAll(Codec.values..remove(Codec.defaultCodec));
    }
    return availableCodecs;
  }
}
