import 'dart:math';

import 'package:filesize/filesize.dart' as filesize;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red,
        g = color.green,
        b = color.blue;

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

  static minZeroes(int desiredValueLength, int value, {bool addFront: true}) {
    String valueStr = "$value";
    String finalValue = valueStr;
    while (finalValue.length < desiredValueLength) {
      finalValue = addFront ? "0$finalValue" : "${finalValue}0";
    }
    return finalValue;
  }

  static String getFormattedDateTime(DateTime dateTime, {
    bool addDate = true,
    bool addTime = true,
    String separatorDate = "/",
    String separatorTime = ":",
    String separatorTimeMS = ".",
    String separatorDateTime = " ",
    bool includeMS = false,
    bool replaceDateByTodayOrYesterday = false,
  }) {
    String date;
    if (addDate) {
      if (replaceDateByTodayOrYesterday) {
        DateTime now = DateTime.now();
        DateTime today = new DateTime(now.year, now.month, now.day);
        DateTime yesterday = new DateTime(now.year, now.month, now.day).subtract(Duration(days: 1));
        if(dateTime.year == today.year && dateTime.month == today.month && dateTime.day == today.day){
          date = "Today";
        } else if(dateTime.year == yesterday.year && dateTime.month == yesterday.month && dateTime.day == yesterday.day){
          date = "Yesterday";
        } else {
          date = "${Util.minZeroes(4, dateTime.year)}$separatorDate${Util.minZeroes(2, dateTime.month)}$separatorDate${Util.minZeroes(2, dateTime.day)}";
        }
      } else {
        date = "${Util.minZeroes(4, dateTime.year)}$separatorDate${Util.minZeroes(2, dateTime.month)}$separatorDate${Util.minZeroes(2, dateTime.day)}";
      }
    } else {
      date = "";
    }
    String time;
    if (addTime) {
      time = "${Util.minZeroes(2, dateTime.hour)}$separatorTime${Util.minZeroes(2, dateTime.minute)}$separatorTime${Util.minZeroes(2, dateTime.second)}${(includeMS
          ? "$separatorTimeMS${Util.minZeroes(4, dateTime.millisecond)}"
          : "")}";
    } else {
      time = "";
    }
    separatorDateTime = date.isNotEmpty && time.isNotEmpty ? separatorDateTime : "";
    return "$date$separatorDateTime$time";
  }

  static String getFormattedSize(int size) => filesize.filesize(size);
}
extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
