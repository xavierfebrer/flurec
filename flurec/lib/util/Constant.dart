

import 'dart:ui';

import 'package:flutter_sound/flutter_sound.dart';

class Constant {
  static const String EMPTY_STRING = "";
  static const String APP_NAME = "Flurec";
  static const String LOG_TAG = "LOG_$APP_NAME";
  static const double ALPHA_MIN = 0.0;
  static const double ALPHA_MAX = 1.0;
  static const Color COLOR_TRANSPARENT = Color(0x00000000);
  static const Color COLOR_PRIMARY = Color(0xFFF44336);
  static const Color COLOR_PRIMARY_LIGHT = Color(0xFFFFCDD2);
  static const Color COLOR_PRIMARY_DARK = Color(0xFFD32F2F);
  static const Color COLOR_ACCENT = Color(0xFF03A9F4);
  static const Color COLOR_ACCENT_LIGHT = Color(0xFF0289D4);
  static const Color COLOR_ACCENT_DARK = Color(0xFF13BFFC);
  static const Color COLOR_TEXT = Color(0xFF212121);
  static const Color COLOR_TEXT_LIGHT = Color(0xFFFFFFFF);
  static const Color COLOR_TEXT_LIGHT_2 = Color(0xFF757575);
  static const Color COLOR_DIVIDER = Color(0xFFBDBDBD);
  static const double PADDING_IN_VIEW = 16.0;
  static const String FOLDER_NAME_RECORDINGS = "recordings";
  static const String FILE_NAME_RECORDING_BASE = "rec";
  static const double SIZE_BUTTON_RECORD = 250.0;
  static const double SIZE_BUTTON_PLAY = SIZE_BUTTON_RECORD * 0.75;
  static const double BORDER_SIZE_BUTTON_PLAYER_ON = 8.0;
  static const double BORDER_SIZE_BUTTON_PLAYER_OFF = 2.0;
  static const double BORDER_SIZE_BUTTON_PLAYER_ON_PRESSED = BORDER_SIZE_BUTTON_PLAYER_ON * 1.15;
  static const double BORDER_SIZE_BUTTON_PLAYER_OFF_PRESSED = BORDER_SIZE_BUTTON_PLAYER_OFF * 1.15;
  static const double ELEVATION_BUTTON_PLAYER_ON = 16.0;
  static const double ELEVATION_BUTTON_PLAYER_ON_PRESSED = ELEVATION_BUTTON_PLAYER_ON * 0.10;
  static const double ELEVATION_BUTTON_PLAYER_OFF = ELEVATION_BUTTON_PLAYER_ON * 0.50;
  static const double ELEVATION_BUTTON_PLAYER_OFF_PRESSED = ELEVATION_BUTTON_PLAYER_OFF * 0.10;
  static const int ANIMATION_DURATION_MS_BUTTON_PLAYER = 190;
  static const Codec DEFAULT_CODEC = Codec.aacADTS; // available in all supported platforms, otherwise review logic
  static const bool DEFAULT_AUTO_PLAY_WHEN_VISITING_DETAIL = true;
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
}