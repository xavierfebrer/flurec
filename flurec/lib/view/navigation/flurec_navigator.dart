import 'package:flurec/view/screen/audio_detail/audio_detail_screen.dart';
import 'package:flurec/view/screen/audio_list/audio_list_screen.dart';
import 'package:flurec/view/screen/home/audio_record_screen.dart';
import 'package:flurec/view/screen/settings/settings_encoder_screen.dart';
import 'package:flurec/view/screen/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FlurecNavigator {
  static final FlurecNavigator instance = FlurecNavigator();

  void navigateToHome(BuildContext context, [bool clearStack = true, Function()? onNavigateBack]) {
    _navigateToScreen(context, AudioRecordScreen(), clearStack, onNavigateBack);
  }

  void navigateToAudioList(BuildContext context, [bool clearStack = true, Function()? onNavigateBack]) {
    _navigateToScreen(context, AudioListScreen(), clearStack, onNavigateBack);
  }

  void navigateToAudioDetail(BuildContext context, String filePath, [bool clearStack = true, Function()? onNavigateBack]) {
    _navigateToScreen(context, AudioDetailScreen(filePath), clearStack, onNavigateBack);
  }

  void navigateToAudioDetailReplaced(BuildContext context, String filePath) {
    _navigateToScreenReplaced(context, AudioDetailScreen(filePath));
  }

  void navigateToSettings(BuildContext context, [bool clearStack = true, Function()? onNavigateBack]) {
    _navigateToScreen(context, SettingsScreen(), clearStack, onNavigateBack);
  }

  void navigateToSettingsEncoder(BuildContext context, [bool clearStack = true, Function()? onNavigateBack]) {
    _navigateToScreen(context, SettingsEncoderScreen(), clearStack, onNavigateBack);
  }

  void _navigateToScreen(BuildContext context, Widget screen, [bool clearStack = true, Function()? onNavigateBack]) {
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

  void _navigateToScreenReplaced(BuildContext context, Widget screen) {
    var route = MaterialPageRoute(builder: (context) => screen);
    Navigator.of(context).pushReplacement(route);
  }
}
