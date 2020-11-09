import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Constant.dart';

class Util {
  static Random _random = Random();

  static Random get random => _random;

  static void enableFullscreen(bool enable) {
    if (enable) {
      SystemChrome.setEnabledSystemUIOverlays([]);
    } else {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    }
  }

  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }

  static String formatDecimal(double value, {int numDecimalPlaces = 2}) {
    if (value != null) {
      return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : numDecimalPlaces);
    }
    return "$value";
  }

  static dynamic getRandomItem(List<dynamic> list) {
    return list != null ? list[random.nextInt(list.length)] : null;
  }

  static double getLinearValueFromPercent(double start, double end, timePercent) {
    return start + ((end - start) * timePercent);
  }
}