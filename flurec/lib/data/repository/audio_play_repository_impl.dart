import 'dart:ui';

import 'package:flurec/domain/repository/audio_play_repository.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:hack2s_flutter_util/util/audio_play_util.dart';

class AudioPlayRepositoryImpl extends AudioPlayRepository {
  FlutterSoundPlayer? player;

  @override
  Future<bool> initializePlayer() async {
    player = FlutterSoundPlayer();
    return await Hack2sAudioPlayUtil.openAudioSession(player!);
  }

  @override
  Future<Duration?> startPlaying(String completeFilePathWithExtension, List<Codec> codecs, {VoidCallback? onFinish}) async {
    return await Hack2sAudioPlayUtil.startPlayer(player!, completeFilePathWithExtension, codecs, onFinish: onFinish);
    /* TODO () {
      onStopSelected();
    }*/
  }

  @override
  Future<bool> stopPlaying() async => await Hack2sAudioPlayUtil.stopPlayer(player);

  @override
  Future<bool> disposePlayer() async {
    player = null;
    return await Hack2sAudioPlayUtil.disposePlayer(player);
  }
}
