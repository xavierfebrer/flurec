import 'package:flurec/view/screen/audio_detail/AudioDetailScreen.dart';
import 'package:flurec/view/screen/audio_list/AudioListScreen.dart';
import 'package:flurec/view/screen/home/AudioRecordScreen.dart';
import 'package:flurec/view/screen/settings/SettingsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FlurecNavigator {
  static FlurecNavigator _instance;

  static FlurecNavigator getInstance() {
    if (_instance == null) _instance = FlurecNavigator();
    return _instance;
  }

  void navigateToHome(BuildContext context, [bool clearStack = true, Function() onNavigateBack]) {
    _navigateToScreen(context, AudioRecordScreen(), clearStack, onNavigateBack);
  }

  void navigateToAudioList(BuildContext context, [bool clearStack = true, Function() onNavigateBack]) {
    _navigateToScreen(context, AudioListScreen(), clearStack, onNavigateBack);
  }

  void navigateToAudioDetail(BuildContext context, String filePath, [bool clearStack = true, Function() onNavigateBack]) {
    _navigateToScreen(context, AudioDetailScreen(filePath), clearStack, onNavigateBack);
  }

  void navigateToSettings(BuildContext context, [bool clearStack = true, Function() onNavigateBack]) {
    _navigateToScreen(context, SettingsScreen(), clearStack, onNavigateBack);
  }

  void _navigateToScreen(BuildContext context, Widget screen, [bool clearStack = true, Function() onNavigateBack]) {
    var route = MaterialPageRoute(builder: (context) => screen);
    if (clearStack) {
      Navigator.of(context).pushAndRemoveUntil(route, (route) => false).then((value) {
        if (onNavigateBack != null) onNavigateBack();
      });
    } else {
      Navigator.of(context).push(route).then((value) {
        if (onNavigateBack != null) onNavigateBack();
      });
    }
  }
}
