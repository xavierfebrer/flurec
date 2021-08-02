import 'package:flurec/util/constant.dart';
import 'package:flurec/view/screen/home/audio_record_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hack2s_flutter_util/util/app_util.dart';
import 'package:hack2s_flutter_util/view/app/base_app.dart';

void main() {
  Hack2sAppUtil.runApplication([DeviceOrientation.portraitUp], () => FlurecApp());
}

class FlurecApp extends BaseApp {
  FlurecApp({Key? key}) : super(key: key);

  @override
  Widget getWidget() => Hack2sAppUtil.getDefaultMaterialApp(
      FlurecConstant.APP_NAME, Hack2sAppUtil.getDefaultThemeData(FlurecConstant.COLOR_PRIMARY, FlurecConstant.COLOR_ACCENT), AudioRecordScreen());
}
