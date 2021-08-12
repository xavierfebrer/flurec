import 'package:flurec/ui/view/audio_detail_view.dart';
import 'package:flurec/ui/view/state/audio_detail_view_state.dart';
import 'package:hack2s_flutter_util/presenter/presenter.dart';

abstract class AudioDetailStatePresenter extends Presenter<AudioDetailView, AudioDetailViewState> {
  AudioDetailStatePresenter(AudioDetailView view, AudioDetailViewState viewState) : super(view, viewState);
}

class AudioDetailStatePresenterImpl extends AudioDetailStatePresenter {
  AudioDetailStatePresenterImpl(AudioDetailView view, AudioDetailViewState viewState) : super(view, viewState);
}
