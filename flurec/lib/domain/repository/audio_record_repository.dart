import 'package:flutter_sound/flutter_sound.dart';

abstract class AudioRecordRepository {
  Future<bool> initializeRecorder();

  Future<bool> startRecording(Codec codec, String completeFilePathWithExtension);

  Future<bool> stopRecording();

  Future<bool> disposeRecorder();
}
