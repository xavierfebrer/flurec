import 'package:flurec/di/locator.dart';
import 'package:flurec/ui/screen/audio_record_screen.dart';
import 'package:flurec/util/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hack2s_flutter_util/util/app_data_provider.dart';
import 'package:hack2s_flutter_util/util/app_util.dart';
import 'package:hack2s_flutter_util/view/app/base_app.dart';

Future<void> main() async {
  await Hack2sAppUtil.runApplication([DeviceOrientation.portraitUp], FlurecAppDataProvider(), () async {
    return await Future(() async {
      await Locator.initializeDI();
      return FlurecApp();
    });
  });
}

class FlurecApp extends BaseApp {
  FlurecApp({Key? key}) : super(key: key);

  @override
  Widget getWidget() => Hack2sAppUtil.getDefaultMaterialApp(AudioRecordScreen());
}

class FlurecAppDataProvider extends Hack2sAppDataProvider {
  @override
  String get APP_NAME => FlurecConstant.APP_NAME;

  @override
  Color get COLOR_PRIMARY => FlurecConstant.COLOR_PRIMARY;

  @override
  Color get COLOR_SECONDARY => FlurecConstant.COLOR_SECONDARY;

  @override
  Color COLOR_TEXT([bool darkMode = false]) => FlurecConstant.COLOR_TEXT(darkMode);

  @override
  Color COLOR_TEXT_2([bool darkMode = false]) => FlurecConstant.COLOR_TEXT_2(darkMode);

  @override
  FontWeight get TEXT_FONT_WEIGHT_LIGHT => FlurecConstant.TEXT_FONT_WEIGHT_LIGHT;

  @override
  FontWeight get TEXT_FONT_WEIGHT => FlurecConstant.TEXT_FONT_WEIGHT;

  @override
  FontWeight get TEXT_FONT_WEIGHT_MEDIUM => FlurecConstant.TEXT_FONT_WEIGHT_MEDIUM;

  @override
  FontWeight get TEXT_FONT_WEIGHT_SEMI_BOLD => FlurecConstant.TEXT_FONT_WEIGHT_SEMI_BOLD;

  @override
  FontWeight get TEXT_FONT_WEIGHT_BOLD => FlurecConstant.TEXT_FONT_WEIGHT_BOLD;

  @override
  double get TEXT_LETTER_SPACING => FlurecConstant.TEXT_LETTER_SPACING;

  @override
  double get TEXT_PRIMARY_FONT_SIZE => FlurecConstant.TEXT_PRIMARY_FONT_SIZE;

  @override
  double get TEXT_SECONDARY_FONT_SIZE => FlurecConstant.TEXT_SECONDARY_FONT_SIZE;
}
