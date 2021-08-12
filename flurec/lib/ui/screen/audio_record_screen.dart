import 'package:auto_size_text/auto_size_text.dart';
import 'package:flurec/di/locator.dart';
import 'package:flurec/presenter/audio_record_state_presenter.dart.dart';
import 'package:flurec/ui/model/record_state.dart';
import 'package:flurec/ui/navigation/flurec_navigator.dart';
import 'package:flurec/ui/view/audio_record_view.dart';
import 'package:flurec/ui/view/state/audio_record_view_state.dart';
import 'package:flurec/ui/view/util/view_util.dart';
import 'package:flurec/util/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hack2s_flutter_util/util/app_data_provider.dart';
import 'package:hack2s_flutter_util/view/screen/base_screen.dart';
import 'package:hack2s_flutter_util/view/util/view_util.dart';

class AudioRecordScreen extends BaseScreen<AudioRecordView, AudioRecordViewState> implements AudioRecordView {
  @override
  AudioRecordScreenState createState() => AudioRecordScreenState(this);
}

class AudioRecordScreenState extends BaseScreenState<AudioRecordView, AudioRecordViewState, AudioRecordStatePresenter, AudioRecordScreen>
    implements AudioRecordViewState {
  AudioRecordScreenState(AudioRecordScreen screen) : super(screen) {
    presenter = AudioRecordStatePresenterImpl(this.screen, this, Locator.getIt(), Locator.getIt());
  }

  @override
  Widget build(BuildContext context) => Hack2sViewUtil.getBaseState(
        context,
        appBar: getAppBar(),
        body: getBody(),
      );

  AppBar getAppBar() => Hack2sViewUtil.getAppBar(
        context,
        title: Hack2sAppDataProvider.appDataProvider.APP_NAME,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.list_rounded),
            onPressed: () async => await presenter.onShowRecordingsSelected(),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async => await presenter.onSettingsSelected(),
          ),
        ],
      );

  Widget getBody() => SafeArea(child: getBodyContent());

  Widget getBodyContent() {
    List<Widget> widgetsBody = [];
    widgetsBody.add(Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.fromLTRB(FlurecConstant.PADDING_IN_VIEW, FlurecConstant.PADDING_IN_VIEW, FlurecConstant.PADDING_IN_VIEW, 50),
      child: AutoSizeText("${presenter.stateInfo.info}"),
    ));
    if (presenter.stateInfo.state == RecordState.INIT) {
      widgetsBody.add(FlurecViewUtil.getRecordStartButton(() async => await presenter.onStartRecordSelected()));
    } else if (presenter.stateInfo.state == RecordState.RECORDING) {
      widgetsBody.add(FlurecViewUtil.getRecordStopButton(() async => await presenter.onStopRecordSelected()));
    } else {
      widgetsBody.add(FlurecViewUtil.getLoadingWidget());
    }
    return Stack(
      children: widgetsBody,
    );
  }

  @override
  Future<void> goToShowRecordings() async => FlurecNavigator.navigateToAudioList(context, false, () async => await presenter.onAppResume());

  @override
  Future<void> goToSettings() async => FlurecNavigator.navigateToSettings(context, false, () async => await presenter.onAppResume());

  @override
  TargetPlatform getTargetPlatform() => Theme.of(context).platform;
}
