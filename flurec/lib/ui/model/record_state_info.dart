import 'package:flurec/ui/model/record_state.dart';
import 'package:flurec/ui/model/state_info.dart';
import 'package:hack2s_flutter_util/util/constant.dart';

class RecordStateInfo extends StateInfo<RecordState> {
  RecordStateInfo(RecordState state, [String info = Hack2sConstant.EMPTY_STRING]) : super(state, info);
}
