import 'package:flurec/ui/view/audio_record_view.dart';
import 'package:flutter/src/foundation/platform.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:hack2s_flutter_util/view/view/state/view_state.dart';

abstract class AudioRecordViewState extends ViewState<AudioRecordView> {

  Future<void> goToShowRecordings();

  Future<void> goToSettings();

  TargetPlatform getTargetPlatform();
}
