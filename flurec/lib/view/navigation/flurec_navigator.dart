import 'package:flurec/view/screen/audio_detail/audio_detail_screen.dart';
import 'package:flurec/view/screen/audio_list/audio_list_screen.dart';
import 'package:flurec/view/screen/home/audio_record_screen.dart';
import 'package:flurec/view/screen/settings/settings_encoder_screen.dart';
import 'package:flurec/view/screen/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hack2s_flutter_util/view/navigation/navigator.dart';

class FlurecNavigator {

  static void navigateToHome(BuildContext context, [bool clearStack = true, Function()? onNavigateBack]) {
    Hack2sNavigator.navigateToScreen(context, AudioRecordScreen(), clearStack, onNavigateBack);
  }

  static void navigateToAudioList(BuildContext context, [bool clearStack = true, Function()? onNavigateBack]) {
    Hack2sNavigator.navigateToScreen(context, AudioListScreen(), clearStack, onNavigateBack);
  }

  static void navigateToAudioDetail(BuildContext context, String filePath, [bool clearStack = true, Function()? onNavigateBack]) {
    Hack2sNavigator.navigateToScreen(context, AudioDetailScreen(filePath), clearStack, onNavigateBack);
  }

  static void navigateToAudioDetailReplaced(BuildContext context, String filePath) {
    Hack2sNavigator.navigateToScreenReplaced(context, AudioDetailScreen(filePath));
  }

  static void navigateToSettings(BuildContext context, [bool clearStack = true, Function()? onNavigateBack]) {
    Hack2sNavigator.navigateToScreen(context, SettingsScreen(), clearStack, onNavigateBack);
  }

  static void navigateToSettingsEncoder(BuildContext context, [bool clearStack = true, Function()? onNavigateBack]) {
    Hack2sNavigator.navigateToScreen(context, SettingsEncoderScreen(), clearStack, onNavigateBack);
  }
}