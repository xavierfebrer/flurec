import 'package:flurec/domain/model/settings.dart';
import 'package:flurec/presenter/settings_view_state_presenter.dart.dart';
import 'package:flurec/ui/navigation/flurec_navigator.dart';
import 'package:flurec/ui/view/settings_view.dart';
import 'package:flurec/ui/view/state/settings_view_state.dart';
import 'package:flurec/util/constant.dart';
import 'package:flurec/util/settings_util.dart';
import 'package:flurec/ui/view/util/view_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hack2s_flutter_util/util/audio_util.dart';
import 'package:hack2s_flutter_util/util/popup_util.dart';
import 'package:hack2s_flutter_util/view/screen/base_screen.dart';

class SettingsScreen extends BaseScreen<SettingsView, SettingsViewState> implements SettingsView {
  @override
  SettingsScreenState createState() => SettingsScreenState(this);
}

class SettingsScreenState extends BaseScreenState<SettingsView, SettingsViewState, SettingsStatePresenter, SettingsScreen>
    implements SettingsViewState {
  late Settings settings;

  SettingsScreenState(SettingsScreen screen) : super(screen) {
    presenter = SettingsStatePresenterImpl(this.screen, this);
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
        "Settings",
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
    /* TODO return FlurecViewUtil.getLoadingWidget<Settings>(FlurecSettingsUtil.getSettingsModel(), onLoadData: (context, data, isInitialData) {
      settings = data;
      return getBodyWithData();
    });*/
  }

  Widget getBodyWithData() {
    return Scrollbar(
      child: ListView.separated(
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: FlurecConstant.COLOR_DIVIDER,
        ),
        itemCount: getSettingsCount(),
        itemBuilder: (context, index) {
          return ListTile(
            trailing: getTrailingListTile(index),
            title: Text(getSettingsOption(index)),
            onTap: index == 0
                ? () {
                    onSettingTapped(context, index);
                  }
                : null,
            isThreeLine: false,
          );
        },
      ),
    );
  }

  Future<void> onRefreshData() async {
    setState(() {});
  }

  int getSettingsCount() {
    return 6;
  }

  String getSettingsOption(int index) {
    if (index == 0) {
      return "Encoder: ${Hack2sAudioUtil.getCodecName(settings.currentEncoderCodec)}";
    } else if (index == 1) {
      return "Auto play in Audio Detail";
    } else if (index == 2) {
      return "Confirm delete";
    } else if (index == 3) {
      return "Confirm rename";
    } else if (index == 4) {
      return "Show delete information";
    } else if (index == 5) {
      return "Show rename information";
    } else
      return "";
  }

  bool isSettingsOptionBool(int index) => index != 0;

  Future<void> onSettingTapped(BuildContext context, int index) async {
    if (index == 0) {
      FlurecNavigator.navigateToSettingsEncoder(context, false, () {
        onRefreshData();
      });
    } else {
      if (index == 1) {
        settings.autoPlayWhenVisitingDetail = !settings.autoPlayWhenVisitingDetail;
      } else if (index == 2) {
        settings.showConfirmationDeleteFiles = !settings.showConfirmationDeleteFiles;
      } else if (index == 3) {
        settings.showConfirmationRenameFiles = !settings.showConfirmationRenameFiles;
      } else if (index == 4) {
        settings.showDeleteSuccessInfo = !settings.showDeleteSuccessInfo;
      } else if (index == 5) {
        settings.showRenameSuccessInfoFiles = !settings.showRenameSuccessInfoFiles;
      }
      await FlurecSettingsUtil.setSettingsModel(settings);
      await onRefreshData();
    }
  }

  Widget? getTrailingListTile(int index) {
    if (isSettingsOptionBool(index)) {
      bool value;
      if (index == 1) {
        value = settings.autoPlayWhenVisitingDetail;
      } else if (index == 2) {
        value = settings.showConfirmationDeleteFiles;
      } else if (index == 3) {
        value = settings.showConfirmationRenameFiles;
      } else if (index == 4) {
        value = settings.showDeleteSuccessInfo;
      } else if (index == 5) {
        value = settings.showRenameSuccessInfoFiles;
      } else {
        value = false;
      }
      return Switch(
        value: value,
        onChanged: (bool newValue) {
          onSettingTapped(context, index);
        },
      );
    } else {
      return null;
    }
  }

  Future<void> onRestoreSelected(BuildContext context) async {
    Hack2sPopupUtil.showPopup(context, "Restore Settings", "Do you want to restore the default settings?", "Restore", "Cancel",
        textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
        textStyleCancelButtonText: TextStyle(color: Theme.of(context).colorScheme.secondary), onConfirm: () async {
      await FlurecSettingsUtil.setSettingsModel(Settings());
      await onRefreshData();
    });
  }
}
