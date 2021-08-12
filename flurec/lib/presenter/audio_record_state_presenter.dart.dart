import 'package:flurec/domain/model/settings.dart';
import 'package:flurec/domain/repository/audio_file_repository.dart';
import 'package:flurec/domain/repository/audio_record_repository.dart';
import 'package:flurec/ui/model/record_state.dart';
import 'package:flurec/ui/model/record_state_info.dart';
import 'package:flurec/ui/view/audio_record_view.dart';
import 'package:flurec/ui/view/state/audio_record_view_state.dart';
import 'package:flurec/util/constant.dart';
import 'package:flurec/util/settings_util.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:hack2s_flutter_util/presenter/presenter.dart';
import 'package:hack2s_flutter_util/util/app_data_provider.dart';
import 'package:hack2s_flutter_util/util/audio_util.dart';
import 'package:hack2s_flutter_util/util/debug_util.dart';

abstract class AudioRecordStatePresenter extends Presenter<AudioRecordView, AudioRecordViewState> {
  AudioRecordStatePresenter(AudioRecordView view, AudioRecordViewState viewState) : super(view, viewState);

  Settings get settings;

  RecordStateInfo get stateInfo;

  Future<void> onStartRecordSelected();

  Future<void> onStopRecordSelected();

  Future<void> onShowRecordingsSelected();

  Future<void> onSettingsSelected();
}

class AudioRecordStatePresenterImpl extends AudioRecordStatePresenter {
  AudioFileRepository _audioFileRepository;
  AudioRecordRepository _audioRecordRepository;
  late Settings _settings;
  late RecordStateInfo _recordStateInfo;

  AudioRecordStatePresenterImpl(
      AudioRecordView view, AudioRecordViewState viewState, this._audioFileRepository, this._audioRecordRepository)
      : super(view, viewState) {
    _settings = Settings();
    _recordStateInfo = RecordStateInfo(RecordState.NOT_INIT, "Start Ok");
  }

  @override
  Future<void> onViewInit() async {
    await super.onViewInit();
    await _initRecorder();
  }

  @override
  Future<void> onAppResume() async {
    await super.onAppResume();
    await _initRecorder();
  }

  @override
  Future<void> onAppPause() async {
    await super.onAppPause();
    await _disposeRecorder();
  }

  @override
  Future<void> onAppStop() async {
    await super.onAppStop();
    await _audioRecordRepository.disposeRecorder();
  }

  @override
  Future<void> onAppDestroy() async {
    await super.onAppDestroy();
    await _audioRecordRepository.disposeRecorder();
  }

  @override
  Future<void> onViewDispose() async {
    await super.onViewDispose();
    await _audioRecordRepository.disposeRecorder();
  }

  @override
  Settings get settings => _settings;

  @override
  RecordStateInfo get stateInfo => _recordStateInfo;

  @override
  Future<void> onStartRecordSelected() async => await _startRecorder();

  @override
  Future<void> onStopRecordSelected() async => await _stopRecorder(true);

  @override
  Future<void> onShowRecordingsSelected() async {
    await _stopRecorder(false);
    await viewState.goToShowRecordings();
  }

  @override
  Future<void> onSettingsSelected() async {
    await _stopRecorder(false);
    await viewState.goToSettings();
  }

  Future<void> _initRecorder() async {
    await _disposeRecorder();
    if (await _audioRecordRepository.initializeRecorder()) {
      _recordStateInfo = RecordStateInfo(RecordState.INIT, "");
    } else {
      _recordStateInfo = RecordStateInfo(RecordState.NOT_INIT, "Error");
    }
    await _onRefresh();
  }

  Future<void> _onRefresh() async {
    _settings = await FlurecSettingsUtil.getSettingsModel();
    await viewState.onRefreshAll();
  }

  Future<void> _startRecorder() async {
    Codec codec = settings.currentEncoderCodec;
    var availablePlatformCodecs = await Hack2sAudioUtil.getAvailableEncoderCodecs(viewState.getTargetPlatform());
    if (!(availablePlatformCodecs).contains(codec)) {
      _recordStateInfo = RecordStateInfo(RecordState.INIT,
          "The selected codec: $codec, is not supported. Supported encoder codecs: ${availablePlatformCodecs.join(", ")}");
    } else {
      String extension = Hack2sAudioUtil.getExtensionForCodec(codec);
      String completeFilePathWithExtension = await _audioFileRepository.getNewRecordingFilePath(
          Hack2sAppDataProvider.appDataProvider.APP_NAME,
          FlurecConstant.FOLDER_NAME_RECORDINGS,
          FlurecConstant.FILE_NAME_RECORDING_BASE,
          extension);
      if (await _audioRecordRepository.startRecording(codec, completeFilePathWithExtension)) {
        _recordStateInfo = RecordStateInfo(RecordState.RECORDING, "");
      } else {
        _recordStateInfo = RecordStateInfo(RecordState.INIT, "Error starting to record sound.");
      }
    }
    await _onRefresh();
  }

  Future<void> _stopRecorder(bool refresh) async {
    if (await _audioRecordRepository.stopRecording()) {
      _recordStateInfo = RecordStateInfo(RecordState.INIT, "");
    } else {
      _recordStateInfo = RecordStateInfo(RecordState.INIT, "Error");
    }
    if(refresh) await _onRefresh();
  }

  Future<void> _disposeRecorder() async {
    await _stopRecorder(false);
    if (await _audioRecordRepository.disposeRecorder()) {
      _recordStateInfo = RecordStateInfo(RecordState.DISPOSED, "");
    } else {
      _recordStateInfo = RecordStateInfo(RecordState.DISPOSED, "Error");
    }
  }
}
