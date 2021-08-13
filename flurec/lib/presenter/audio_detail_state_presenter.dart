import 'package:flurec/domain/model/settings.dart';
import 'package:flurec/domain/repository/audio_file_repository.dart';
import 'package:flurec/domain/repository/audio_play_repository.dart';
import 'package:flurec/ui/model/play_state.dart';
import 'package:flurec/ui/model/play_state_info.dart';
import 'package:flurec/ui/view/audio_detail_view.dart';
import 'package:flurec/ui/view/state/audio_detail_view_state.dart';
import 'package:flurec/util/constant.dart';
import 'package:flurec/util/settings_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:hack2s_flutter_util/presenter/presenter.dart';
import 'package:hack2s_flutter_util/util/audio_util.dart';
import 'package:hack2s_flutter_util/util/constant.dart';

abstract class AudioDetailStatePresenter extends Presenter<AudioDetailView, AudioDetailViewState> {
  final String filePath;

  AudioDetailStatePresenter(AudioDetailView view, AudioDetailViewState viewState, this.filePath) : super(view, viewState);

  PlayStateInfo get stateInfo;

  Settings get settings;

  String get newEditNameText;

  bool get playedFirstTime;

  Future<void> onPlayStartSelected();

  Future<void> onPlayStopSelected();
}

class AudioDetailStatePresenterImpl extends AudioDetailStatePresenter {
  AudioFileRepository _audioFileRepository;
  AudioPlayRepository _audioPlayRepository;
  late PlayStateInfo _stateInfo;
  late Settings _settings;
  late String _newEditNameText;
  late bool _playedFirstTime;

  AudioDetailStatePresenterImpl(
      AudioDetailView view, AudioDetailViewState viewState, String filePath, this._audioFileRepository, this._audioPlayRepository)
      : super(view, viewState, filePath) {
    _stateInfo = PlayStateInfo(PlayState.NOT_INIT);
    _settings = Settings();
    _newEditNameText = Hack2sConstant.EMPTY_STRING;
    _playedFirstTime = false;
  }

  @override
  Future<void> onViewInit() async {
    await super.onViewInit();
    await _initPlayer();
  }

  @override
  Future<void> onAppResume() async {
    await super.onAppResume();
    await _initPlayer();
  }

  @override
  Future<void> onAppPause() async {
    await super.onAppPause();
    await _disposePlayer();
  }

  @override
  Future<void> onAppStop() async {
    await super.onAppStop();
    await _audioPlayRepository.disposePlayer();
  }

  @override
  Future<void> onAppDestroy() async {
    await super.onAppDestroy();
    await _audioPlayRepository.disposePlayer();
  }

  @override
  Future<void> onViewDispose() async {
    await super.onViewDispose();
    await _audioPlayRepository.disposePlayer();
  }

  @override
  PlayStateInfo get stateInfo => _stateInfo;

  @override
  Settings get settings => _settings;

  @override
  String get newEditNameText => _newEditNameText;

  @override
  bool get playedFirstTime => _playedFirstTime;

  @override
  Future<void> onPlayStartSelected() async => await _startPlayer();

  @override
  Future<void> onPlayStopSelected() async => await _stopPlayer(true);

  Future<void> _initPlayer() async {
    await _disposePlayer();
    if (await _audioPlayRepository.initializePlayer()) {
      _stateInfo = PlayStateInfo(PlayState.INIT);
    } else {
      _stateInfo = PlayStateInfo(PlayState.NOT_INIT, FlurecConstant.TEXT_ERROR);
    }
    await _onRefresh();
  }

  Future<void> _onRefresh() async {
    _settings = await FlurecSettingsUtil.getSettingsModel();
    if (!playedFirstTime && settings.autoPlayWhenVisitingDetail) { // TODO review if this is working and it is a good position to place it
      _playedFirstTime = true;
      onPlayStartSelected();
    }
    await viewState.onRefreshAll();
  }

  Future<void> _startPlayer() async {
    TargetPlatform platform = viewState.getTargetPlatform();
    List<Codec> availablePlatformCodecs = await Hack2sAudioUtil.getAvailableDecoderCodecs(platform);
    List<Codec> finalCodecs = [];
    finalCodecs.addAll(availablePlatformCodecs);
    Duration? duration = await _audioPlayRepository.startPlaying(filePath, finalCodecs, onFinish: () => _stopPlayer(true));
    if (duration != null) {
      _stateInfo = PlayStateInfo(PlayState.PLAYING, Hack2sConstant.EMPTY_STRING);
    } else {
      _stateInfo = PlayStateInfo(PlayState.INIT, FlurecConstant.TEXT_ERROR_STARTING_PLAY_SOUND);
    }
    await _onRefresh();
  }

  Future<void> _stopPlayer(bool refresh) async {
    if (await _audioPlayRepository.stopPlaying()) {
      _stateInfo = PlayStateInfo(PlayState.INIT);
    } else {
      _stateInfo = PlayStateInfo(PlayState.INIT);
    }
    if (refresh) await _onRefresh();
  }

  Future<void> _disposePlayer() async {
    await _stopPlayer(false);
    if (await _audioPlayRepository.disposePlayer()) {
      _stateInfo = PlayStateInfo(PlayState.DISPOSED);
    } else {
      _stateInfo = PlayStateInfo(PlayState.DISPOSED);
    }
  }
}
