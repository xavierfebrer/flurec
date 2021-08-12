import 'package:flurec/ui/view/settings_view.dart';
import 'package:flurec/ui/view/state/settings_view_state.dart';
import 'package:hack2s_flutter_util/presenter/presenter.dart';

abstract class SettingsStatePresenter extends Presenter<SettingsView, SettingsViewState> {
  SettingsStatePresenter(SettingsView view, SettingsViewState viewState) : super(view, viewState);
}

class SettingsStatePresenterImpl extends SettingsStatePresenter {
  SettingsStatePresenterImpl(SettingsView view, SettingsViewState viewState) : super(view, viewState);
}
