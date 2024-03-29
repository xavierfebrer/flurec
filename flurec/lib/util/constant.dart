

import 'dart:ui';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:hack2s_flutter_util/util/constant.dart';

class FlurecConstant {
  static const String APP_NAME = "Flurec";
  static const String LOG_TAG = "LOG_$APP_NAME";
  static const Color COLOR_PRIMARY = Color(0xFFF44336);
  static const Color COLOR_ACCENT = Color(0xFF03A9F4);
  static final Color COLOR_PRIMARY_LIGHT = Color.lerp(COLOR_PRIMARY, Hack2sConstant.COLOR_WHITE, 0.80)!;
  static final Color COLOR_PRIMARY_DARK = Color.lerp(COLOR_PRIMARY, Hack2sConstant.COLOR_BLACK, 0.20)!;
  static final Color COLOR_ACCENT_LIGHT = Color.lerp(COLOR_ACCENT, Hack2sConstant.COLOR_WHITE, 0.20)!;
  static final Color COLOR_ACCENT_DARK = Color.lerp(COLOR_ACCENT, Hack2sConstant.COLOR_BLACK, 0.20)!;
  static final Color COLOR_TEXT_DARK = Color.lerp(Hack2sConstant.COLOR_BLACK, Hack2sConstant.COLOR_WHITE, 0.05)!;
  static final Color COLOR_TEXT_DARK_2 = Color.lerp(COLOR_TEXT_DARK, COLOR_TEXT_LIGHT, 0.45)!;
  static final Color COLOR_TEXT_LIGHT = Color.lerp(Hack2sConstant.COLOR_WHITE, Hack2sConstant.COLOR_BLACK, 0.05)!;
  static final Color COLOR_TEXT_LIGHT_2 = Color.lerp(COLOR_TEXT_LIGHT, Hack2sConstant.COLOR_BLACK, 0.45)!;
  static final Color COLOR_DIVIDER = Color.lerp(Hack2sConstant.COLOR_BLACK, Hack2sConstant.COLOR_WHITE, 0.75)!;
  static const double PADDING_IN_VIEW = 16.0;
  static const String FOLDER_NAME_RECORDINGS = "recordings";
  static const String FILE_NAME_RECORDING_BASE = "rec";
  static const double SIZE_BUTTON_RECORD = 250.0;
  static const double SIZE_BUTTON_PLAY = SIZE_BUTTON_RECORD * 0.75;
  static const double BORDER_SIZE_BUTTON_PLAYER_ON = 12.0;
  static const double BORDER_SIZE_BUTTON_PLAYER_OFF = BORDER_SIZE_BUTTON_PLAYER_ON * 0.3;
  static const double BORDER_SIZE_BUTTON_PLAYER_ON_PRESSED = BORDER_SIZE_BUTTON_PLAYER_ON * 1.5;
  static const double BORDER_SIZE_BUTTON_PLAYER_OFF_PRESSED = BORDER_SIZE_BUTTON_PLAYER_OFF * 1.5;
  static const double ELEVATION_BUTTON_PLAYER_ON = 16.0;
  static const double ELEVATION_BUTTON_PLAYER_ON_PRESSED = ELEVATION_BUTTON_PLAYER_ON * 0.15;
  static const double ELEVATION_BUTTON_PLAYER_OFF = ELEVATION_BUTTON_PLAYER_ON * 0.50;
  static const double ELEVATION_BUTTON_PLAYER_OFF_PRESSED = ELEVATION_BUTTON_PLAYER_OFF * 0.15;
  static const int ANIMATION_DURATION_MS_BUTTON_PLAYER = 190;
  static const Codec DEFAULT_CODEC = Codec.aacADTS; // available in all supported platforms, otherwise review logic
  static const bool DEFAULT_AUTO_PLAY_WHEN_VISITING_DETAIL = false;
  static const bool DEFAULT_SHOW_DELETE_SUCCESS_INFO = true;
  static const bool DEFAULT_SHOW_RENAME_SUCCESS_INFO = true;
  static const bool DEFAULT_SHOW_CONFIRMATION_DELETE_FILES = true;
  static const bool DEFAULT_SHOW_CONFIRMATION_RENAME_FILES = true;
  static const Codec DEFAULT_CURRENT_ENCODER_CODEC_INDEX = DEFAULT_CODEC;
  static const String PREFS_KEY_AUTO_PLAY_WHEN_VISITING_DETAIL = "PREFS_AUTO_PLAY_WHEN_VISITING_DETAIL";
  static const String PREFS_KEY_SHOW_DELETE_SUCCESS_INFO = "PREFS_KEY_SHOW_DELETE_SUCCESS_INFO";
  static const String PREFS_KEY_SHOW_RENAME_SUCCESS_INFO = "PREFS_KEY_SHOW_RENAME_SUCCESS_INFO";
  static const String PREFS_KEY_SHOW_CONFIRMATION_DELETE_FILES = "PREFS_SHOW_CONFIRMATION_DELETE_FILES";
  static const String PREFS_KEY_SHOW_CONFIRMATION_RENAME_FILES = "PREFS_SHOW_CONFIRMATION_RENAME_FILES";
  static const String PREFS_KEY_CURRENT_ENCODER_CODEC_INDEX = "PREFS_KEY_CURRENT_ENCODER_CODEC_INDEX";
  static const bool ENABLE_SHARE = false;
}