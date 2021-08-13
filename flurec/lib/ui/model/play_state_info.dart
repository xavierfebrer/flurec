import 'package:flurec/ui/model/play_state.dart';
import 'package:flurec/ui/model/state_info.dart';
import 'package:hack2s_flutter_util/util/constant.dart';

class PlayStateInfo extends StateInfo<PlayState> {
  PlayStateInfo(PlayState state, [String info = Hack2sConstant.EMPTY_STRING]) : super(state, info);
}
