import 'package:flurec/domain/repository/audio_record_repository.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:hack2s_flutter_util/util/audio_record_util.dart';

class AudioRecordRepositoryImpl extends AudioRecordRepository {
  FlutterSoundRecorder? recorder;

  @override
  Future<bool> initializeRecorder() async {
    recorder = FlutterSoundRecorder();
    return await Hack2sAudioRecordUtil.openAudioSession(recorder!);
  }

  @override
  Future<bool> startRecording(Codec codec, String completeFilePathWithExtension) async =>
      await Hack2sAudioRecordUtil.startRecorder(recorder!, completeFilePathWithExtension, codec: codec);

  @override
  Future<bool> stopRecording() async => await Hack2sAudioRecordUtil.stopRecorder(recorder);

  @override
  Future<bool> disposeRecorder() async {
    recorder = null;
    return await Hack2sAudioRecordUtil.disposeRecorder(recorder);
  }
}
