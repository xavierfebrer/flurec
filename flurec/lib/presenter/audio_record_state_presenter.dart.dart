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
import 'package:hack2s_flutter_util/util/constant.dart';

abstract class AudioRecordStatePresenter extends Presenter<AudioRecordView, AudioRecordViewState> {
  AudioRecordStatePresenter(AudioRecordView view, AudioRecordViewState viewState) : super(view, viewState);

  Settings get settings;

  RecordStateInfo get stateInfo;

  Future<void> onRecordStartSelected();

  Future<void> onRecordStopSelected();

  Future<void> onShowRecordingsSelected();

  Future<void> onSettingsSelected();
}

class AudioRecordStatePresenterImpl extends AudioRecordStatePresenter {
  AudioFileRepository _audioFileRepository;
  AudioRecordRepository _audioRecordRepository;
  late Settings _settings;
  late RecordStateInfo _stateInfo;

  AudioRecordStatePresenterImpl(
      AudioRecordView view, AudioRecordViewState viewState, this._audioFileRepository, this._audioRecordRepository)
      : super(view, viewState) {
    _settings = Settings();
    _stateInfo = RecordStateInfo(RecordState.NOT_INIT);
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
  RecordStateInfo get stateInfo => _stateInfo;

  @override
  Future<void> onRecordStartSelected() async => await _startRecorder();

  @override
  Future<void> onRecordStopSelected() async => await _stopRecorder(true);

  @override
  Future<void> onShowRecordingsSelected() async {
    await _disposeRecorder();
    await viewState.goToShowRecordings();
  }

  @override
  Future<void> onSettingsSelected() async {
    await _disposeRecorder();
    await viewState.goToSettings();
  }

  Future<void> _initRecorder() async {
    await _disposeRecorder();
    if (await _audioRecordRepository.initializeRecorder()) {
      _stateInfo = RecordStateInfo(RecordState.INIT);
    } else {
      _stateInfo = RecordStateInfo(RecordState.NOT_INIT, FlurecConstant.TEXT_ERROR);
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
      _stateInfo = RecordStateInfo(RecordState.INIT,
          FlurecConstant.TEXT_INVALID_CODECS(codec, availablePlatformCodecs));
    } else {
      String extension = Hack2sAudioUtil.getExtensionForCodec(codec);
      String completeFilePathWithExtension = await _audioFileRepository.getNewRecordingFilePath(
          Hack2sAppDataProvider.appDataProvider.APP_NAME,
          FlurecConstant.FOLDER_NAME_RECORDINGS,
          FlurecConstant.FILE_NAME_RECORDING_BASE,
          extension);
      if (await _audioRecordRepository.startRecording(codec, completeFilePathWithExtension)) {
        _stateInfo = RecordStateInfo(RecordState.RECORDING);
      } else {
        _stateInfo = RecordStateInfo(RecordState.INIT, FlurecConstant.TEXT_ERROR_STARTING_RECORD_SOUND);
      }
    }
    await _onRefresh();
  }

  Future<void> _stopRecorder(bool refresh) async {
    if (await _audioRecordRepository.stopRecording()) {
      _stateInfo = RecordStateInfo(RecordState.INIT);
    } else {
      _stateInfo = RecordStateInfo(RecordState.INIT);
    }
    if (refresh) await _onRefresh();
  }

  Future<void> _disposeRecorder() async {
    await _stopRecorder(false);
    if (await _audioRecordRepository.disposeRecorder()) {
      _stateInfo = RecordStateInfo(RecordState.DISPOSED);
    } else {
      _stateInfo = RecordStateInfo(RecordState.DISPOSED);
    }
  }
}
