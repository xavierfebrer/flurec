import 'package:flurec/util/Constant.dart';
import 'package:flurec/util/Util.dart';
import 'package:flurec/view/screen/home/HomeScreen.dart';
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
    return MaterialApp(
      title: Constant.APP_NAME,
      theme: ThemeData(
        primarySwatch: Util.createMaterialColor(Constant.COLOR_PRIMARY),
        accentColor: Constant.COLOR_ACCENT,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}
