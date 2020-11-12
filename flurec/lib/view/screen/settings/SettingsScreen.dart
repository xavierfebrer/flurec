import 'package:flurec/model/Settings.dart';
import 'package:flurec/util/AppUtil.dart';
import 'package:flurec/util/Constant.dart';
import 'package:flurec/util/PopupUtil.dart';
import 'package:flurec/util/ViewUtil.dart';
import 'package:flurec/view/navigation/FlurecNavigator.dart';
import 'package:flurec/view/screen/BaseScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingsScreen extends BaseScreen {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends BaseScreenState<SettingsScreen> {
  Settings settings;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future(() {
        return true;
      }),
      child: Scaffold(
        backgroundColor: Constant.COLOR_PRIMARY_LIGHT,
        appBar: getAppBar(),
        body: getBody(),
      ),
    );
  }

  Widget getAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        "Settings",
        style: TextStyle(color: Constant.COLOR_TEXT_LIGHT),
      ),
      automaticallyImplyLeading: true,
      centerTitle: false,
      iconTheme: IconThemeData(color: Constant.COLOR_PRIMARY_LIGHT),
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
      child: Container(
        child: getBodyWithoutData(),
      ),
    );
  }

  Widget getBodyWithoutData() {
    return ViewUtil.getLoadingWidget(AppUtil.getSettingsModel(), onLoadData: (context, data, isInitialData) {
      settings = data;
      return getBodyWithData();
    });
  }

  Widget getBodyWithData() {
    return Scrollbar(
      child: ListView.separated(
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Constant.COLOR_DIVIDER,
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> onRefreshData() async {
    setState(() {});
  }

  int getSettingsCount() {
    return 6;
  }

  String getSettingsOption(int index) {
    if (index == 0) {
      return "Encoder: ${AppUtil.getCodecName(settings.currentEncoderCodec)}";
    } else if (index == 1) {
      return "Auto play when possible";
    } else if (index == 2) {
      return "Confirm delete";
    } else if (index == 3) {
      return "Confirm rename";
    } else if (index == 4) {
      return "Show delete success information";
    } else if (index == 5) {
      return "Show rename success information";
    } else
      return "";
  }

  bool isSettingsOptionBool(int index) => index != 0;

  Future<void> onSettingTapped(BuildContext context, int index) async {
    if (index == 0) {
      FlurecNavigator.getInstance().navigateToSettingsEncoder(context, false, () {
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
      await AppUtil.setSettingsModel(settings);
      await onRefreshData();
    }
  }

  Widget getTrailingListTile(int index) {
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
    PopupUtil.showPopup(context, "Restore Settings", "Do you want to restore the default settings?", "Restore", "Cancel",
        textStyleConfirmButtonText: TextStyle(color: Theme.of(context).primaryColorDark),
        textStyleCancelButtonText: TextStyle(color: Theme.of(context).accentColor), onConfirm: () async {
      await AppUtil.setSettingsModel(Settings());
      await onRefreshData();
    });
  }
}
