import 'package:flurec/ui/model/record_state.dart';

abstract class StateInfo<S> {
  S state;
  String info;

  StateInfo(this.state, this.info);
}
