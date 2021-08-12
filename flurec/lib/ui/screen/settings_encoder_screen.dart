import 'package:flurec/domain/model/settings.dart';
import 'package:flurec/presenter/settings_encoder_state_presenter.dart.dart';
import 'package:flurec/ui/view/settings_encoder_view.dart';
import 'package:flurec/ui/view/state/settings_encoder_view_state.dart';
import 'package:flurec/util/constant.dart';
import 'package:flurec/util/settings_util.dart';
import 'package:flurec/ui/view/util/view_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:hack2s_flutter_util/util/audio_util.dart';
import 'package:hack2s_flutter_util/util/popup_util.dart';
import 'package:hack2s_flutter_util/view/screen/base_screen.dart';

class SettingsEncoderScreen extends BaseScreen<SettingsEncoderView, SettingsEncoderViewState> implements SettingsEncoderView {
  @override
  SettingsEncoderScreenState createState() => SettingsEncoderScreenState(this);
}

class SettingsEncoderScreenState
    extends BaseScreenState<SettingsEncoderView, SettingsEncoderViewState, SettingsEncoderStatePresenter, SettingsEncoderScreen>
    implements SettingsEncoderViewState {
  late Settings settings;
  late List<Codec> availablePlatformCodecs;

  SettingsEncoderScreenState(SettingsEncoderScreen screen) : super(screen) {
    presenter = SettingsEncoderStatePresenterImpl(this.screen, this);
  }

  @override
  void initState() {
    super.initState();
    availablePlatformCodecs = [];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future(() {
        return true;
      }),
      child: Scaffold(
        backgroundColor: FlurecConstant.COLOR_PRIMARY_LIGHT,
        appBar: getAppBar(),
        body: getBody(),
      ),
    );
  }

  AppBar getAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        "Encoder Settings",
        style: TextStyle(color: FlurecConstant.COLOR_TEXT_LIGHT),
      ),
      automaticallyImplyLeading: true,
      centerTitle: false,
      iconTheme: IconThemeData(color: FlurecConstant.COLOR_PRIMARY_LIGHT),
      actions: getAppBarOptionWidgets(),
    );
  }

  List<Widget> getAppBarOptionWidgets() {
    List<Widget> appBarWidgets = [];
    appBarWidgets.add(
      IconButton(
        icon: Icon(
          Icons.restore_rounded,
        ),
        onPressed: () {
          onRestoreSelected(context);
        },
      ),
    );
    return appBarWidgets;
  }

  Widget getBody() {
    return SafeArea(
      child: getBodyContent(),
    );
  }

  Widget getBodyContent() {
    return Container(); // TODO
    /* TODO FlurecViewUtil.getLoadingWidget<Settings>(FlurecSettingsUtil.getSettingsModel(), onLoadData: (context, data, isInitialData) {
      settings = data;
      return getBodyWithData();
    });*/
  }

  Widget getBodyWithData() {
    return FutureBuilder<List<Codec>>(
      future: Hack2sAudioUtil.getAvailableEncoderCodecs(Theme.of(context).platform),
      builder: (BuildContext context, AsyncSnapshot<List<Codec>> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          availablePlatformCodecs = snapshot.data ?? [];
          return Scrollbar(
            child: ListView.separated(
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: FlurecConstant.COLOR_DIVIDER,
              ),
              itemCount: availablePlatformCodecs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: getLeadingListTile(index),
                  title: Text(Hack2sAudioUtil.getCodecName(availablePlatformCodecs[index])),
                  onTap: () async {
                    await onSettingTapped(context, index);
                  },
                  isThreeLine: false,
                );
              },
            ),
          );
        }
      },
    );
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    onRefreshData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> onRefreshData() async {
    setState(() {});
  }

  Future<void> onSettingTapped(BuildContext context, int index) async {
    settings.currentEncoderCodec = availablePlatformCodecs[index];
    await FlurecSettingsUtil.setSettingsModel(settings);
    await onRefreshData();
  }

  Widget getLeadingListTile(int index) {
    return IconButton(
      icon: Icon(
          availablePlatformCodecs[index] == settings.currentEncoderCodec ? Icons.radio_button_on_rounded : Icons.radio_button_off_rounded),
      onPressed: () {},
    );
  }

  Future<void> onRestoreSelected(BuildContext context) async {
    Hack2sPopupUtil.showPopup(context, "Restore Encoder Settings", "Do you want to restore the default settings?", "Restore", "Cancel",
        textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
        textStyleCancelButtonText: TextStyle(color: Theme.of(context).colorScheme.secondary), onConfirm: () async {
      Settings defaultSettings = Settings();
      settings.currentEncoderCodec = defaultSettings.currentEncoderCodec;
      await FlurecSettingsUtil.setSettingsModel(settings);
      await onRefreshData();
    });
  }
}
