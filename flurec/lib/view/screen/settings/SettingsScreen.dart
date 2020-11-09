import 'package:flurec/util/Constant.dart';
import 'package:flurec/view/screen/BaseScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingsScreen extends BaseScreen {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends BaseScreenState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.COLOR_PRIMARY_LIGHT,
      appBar: getAppBar(),
      body: getBody(),
    );
  }

  Widget getAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Constant.COLOR_PRIMARY_LIGHT),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        "Settings",
        style: TextStyle(color: Constant.COLOR_TEXT_LIGHT),
      ),
      automaticallyImplyLeading: true,
      centerTitle: false,
      iconTheme: IconThemeData(color: Constant.COLOR_PRIMARY_LIGHT),
    );
  }

  Widget getBody() {
    return SafeArea(
      child: Container(),
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
}
