import 'dart:ui';

import 'package:flutter_sound/flutter_sound.dart';

abstract class AudioPlayRepository {
  Future<bool> initializePlayer();

  Future<Duration?> startPlaying(String completeFilePathWithExtension, List<Codec> codecs, {VoidCallback? onFinish});

  Future<bool> stopPlaying();

  Future<bool> disposePlayer();
}
