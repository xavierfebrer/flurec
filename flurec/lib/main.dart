import 'package:flurec/util/constant.dart';
import 'package:flurec/util/util.dart';
import 'package:flurec/view/screen/home/audio_record_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(FluRecApp());
  });
}

class FluRecApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = ThemeData(
      primarySwatch: Util.createMaterialColor(Constant.COLOR_PRIMARY),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
    return MaterialApp(
      title: Constant.APP_NAME,
      theme: themeData.copyWith(
          colorScheme: themeData.colorScheme.copyWith(secondary: Constant.COLOR_ACCENT)
      ),
      home: AudioRecordScreen(),
    );
  }
}
