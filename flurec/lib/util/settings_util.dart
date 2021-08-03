import 'package:flurec/model/settings.dart';
import 'package:flurec/util/constant.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlurecSettingsUtil {
  static Future<Settings> getSettingsModel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Settings settings = Settings(
      autoPlayWhenVisitingDetail:
          prefs.getBool(FlurecConstant.PREFS_KEY_AUTO_PLAY_WHEN_VISITING_DETAIL) ?? FlurecConstant.DEFAULT_AUTO_PLAY_WHEN_VISITING_DETAIL,
      showDeleteSuccessInfo:
          prefs.getBool(FlurecConstant.PREFS_KEY_SHOW_DELETE_SUCCESS_INFO) ?? FlurecConstant.DEFAULT_SHOW_DELETE_SUCCESS_INFO,
      showRenameSuccessInfoFiles:
          prefs.getBool(FlurecConstant.PREFS_KEY_SHOW_RENAME_SUCCESS_INFO) ?? FlurecConstant.DEFAULT_SHOW_RENAME_SUCCESS_INFO,
      showConfirmationDeleteFiles:
          prefs.getBool(FlurecConstant.PREFS_KEY_SHOW_CONFIRMATION_DELETE_FILES) ?? FlurecConstant.DEFAULT_SHOW_CONFIRMATION_DELETE_FILES,
      showConfirmationRenameFiles:
          prefs.getBool(FlurecConstant.PREFS_KEY_SHOW_CONFIRMATION_RENAME_FILES) ?? FlurecConstant.DEFAULT_SHOW_CONFIRMATION_RENAME_FILES,
      currentEncoderCodec:
          Codec.values[prefs.getInt(FlurecConstant.PREFS_KEY_CURRENT_ENCODER_CODEC_INDEX) ?? FlurecConstant.DEFAULT_CURRENT_ENCODER_CODEC_INDEX.index],
    );
    return settings;
  }

  static Future<bool> setSettingsModel(Settings settings) async {
    bool result = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    result = result && await prefs.setBool(FlurecConstant.PREFS_KEY_AUTO_PLAY_WHEN_VISITING_DETAIL, settings.autoPlayWhenVisitingDetail);
    result = result && await prefs.setBool(FlurecConstant.PREFS_KEY_SHOW_DELETE_SUCCESS_INFO, settings.showDeleteSuccessInfo);
    result = result && await prefs.setBool(FlurecConstant.PREFS_KEY_SHOW_RENAME_SUCCESS_INFO, settings.showRenameSuccessInfoFiles);
    result = result && await prefs.setBool(FlurecConstant.PREFS_KEY_SHOW_CONFIRMATION_DELETE_FILES, settings.showConfirmationDeleteFiles);
    result = result && await prefs.setBool(FlurecConstant.PREFS_KEY_SHOW_CONFIRMATION_RENAME_FILES, settings.showConfirmationRenameFiles);
    result = result && await prefs.setInt(FlurecConstant.PREFS_KEY_CURRENT_ENCODER_CODEC_INDEX, settings.currentEncoderCodec.index);
    return result;
  }
}