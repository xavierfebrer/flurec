import 'package:flurec/ui/view/settings_encoder_view.dart';
import 'package:flurec/ui/view/state/settings_encoder_view_state.dart';
import 'package:hack2s_flutter_util/presenter/presenter.dart';

abstract class SettingsEncoderStatePresenter extends Presenter<SettingsEncoderView, SettingsEncoderViewState> {
  SettingsEncoderStatePresenter(SettingsEncoderView view, SettingsEncoderViewState viewState) : super(view, viewState);
}

class SettingsEncoderStatePresenterImpl extends SettingsEncoderStatePresenter {
  SettingsEncoderStatePresenterImpl(SettingsEncoderView view, SettingsEncoderViewState viewState) : super(view, viewState);
}
