import 'package:flurec/view/screen/BaseScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AudioDetailScreen extends BaseScreen {
  @override
  _AudioDetailScreenState createState() => _AudioDetailScreenState();
}

class _AudioDetailScreenState extends BaseScreenState<AudioDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: getAppBar(),
      body: getBody(),
    );
  }

  Widget getAppBar() {
    return AppBar();
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
