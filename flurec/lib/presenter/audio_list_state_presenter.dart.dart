import 'dart:io';

import 'package:flurec/domain/model/settings.dart';
import 'package:flurec/domain/repository/audio_file_repository.dart';
import 'package:flurec/ui/view/audio_list_view.dart';
import 'package:flurec/ui/view/state/audio_list_view_state.dart';
import 'package:flurec/util/constant.dart';
import 'package:flurec/util/settings_util.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hack2s_flutter_util/presenter/presenter.dart';
import 'package:hack2s_flutter_util/util/file_util.dart';
import 'package:hack2s_flutter_util/util/share_util.dart';

abstract class AudioListStatePresenter extends Presenter<AudioListView, AudioListViewState> {
  AudioListStatePresenter(AudioListView view, AudioListViewState viewState) : super(view, viewState);

  List<File> get files;

  FileSort get fileSort;

  Future<void> onSortSelected();

  Future<void> onShareSelected();

  Future<void> onItemSelected(File file);
}

class AudioListStatePresenterImpl extends AudioListStatePresenter {
  AudioFileRepository _audioFileRepository;
  late List<File> _files;
  late FileSort _fileSort;
  late Settings _settings;

  AudioListStatePresenterImpl(AudioListView view, AudioListViewState viewState, this._audioFileRepository) : super(view, viewState) {}

  @override
  Future<void> onViewInit() async {
    await super.onViewInit();
    _files = [];
    _fileSort = FileSort.DateDescending;
    _settings = Settings();
    viewState.initViewRotation();
    await _onRefresh();
  }

  @override
  Future<void> onAppResume() async {
    await super.onAppResume();
    await _onRefresh();
  }

  @override
  Future<void> onAppPause() async {
    await super.onAppPause();
    await _onRefresh();
  }

  @override
  Future<void> onAppStop() async {
    await super.onAppStop();
    await _onRefresh();
  }

  @override
  Future<void> onAppDestroy() async {
    await super.onAppDestroy();
    await _onRefresh();
  }

  @override
  Future<void> onViewDispose() async {
    await super.onViewDispose();
    await _onRefresh();
  }

  @override
  List<File> get files => _files;

  @override
  FileSort get fileSort => _fileSort;

  @override
  Future<void> onSortSelected() async {
    viewState.startViewRotation();
    _nextSort();
    await _onRefresh();
  }

  void _nextSort() {
    if (_fileSort.index < FileSort.values.length - 1) {
      _fileSort = FileSort.values[_fileSort.index + 1];
    } else {
      _fileSort = FileSort.values[0];
    }
  }

  Future<void> _onRefresh() async {
    _settings = await FlurecSettingsUtil.getSettingsModel();
    _files = await _audioFileRepository.getRecordingsFiles(appFolderName, appSubFolderName);
    await viewState.onRefreshAll();
  }

  @override
  Future<void> onShareSelected() async {
    if (_selectedItems.isNotEmpty) await Hack2sShareUtil.shareFiles(_selectedItems);
  }

  @override
  Future<void> onItemSelected(File file) async => await viewState.goToAudioDetail(file);
}
