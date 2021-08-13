import 'dart:io';

import 'package:flurec/ui/view/audio_list_view.dart';
import 'package:hack2s_flutter_util/view/view/state/view_state.dart';

abstract class AudioListViewState extends ViewState<AudioListView> {
  Future<void> startViewRotation();
  Future<void> goToAudioDetail(File file);
}
