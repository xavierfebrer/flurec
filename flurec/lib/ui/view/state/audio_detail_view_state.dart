import 'package:flurec/ui/view/audio_detail_view.dart';
import 'package:flutter/src/foundation/platform.dart';
import 'package:hack2s_flutter_util/view/view/state/view_state.dart';

abstract class AudioDetailViewState extends ViewState<AudioDetailView> {
  TargetPlatform getTargetPlatform();
}
