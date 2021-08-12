import 'dart:io';

import 'package:flurec/util/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hack2s_flutter_util/util/file_util.dart';
import 'package:hack2s_flutter_util/util/util.dart';

class FlurecViewUtil {
  static String getFileSubtitle(File file) {
    FileStat fileStat = Hack2sFileUtil.getFileStat(file);
    String paddingStart = "  ";
    String paddingBetween = "   ";
    return "$paddingStart${Hack2sUtil.getFormattedFileSize(fileStat.size)}$paddingBetween${Hack2sUtil.getFormattedDateTime(
      fileStat.changed,
      separatorDate: "/",
      separatorTime: ":",
      separatorDateTime: " ",
      includeMS: false,
      replaceDateByToday: true,
      replaceDateByYesterday: true,
    )}";
  }

  static ButtonStyle getPlayerButtonStyle(bool active) {
    return ButtonStyle(
      enableFeedback: false,
      side: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) {
          return getPlayerShapeSide(active, true);
        }
        return getPlayerShapeSide(active, false);
      }),
      animationDuration: Duration(milliseconds: FlurecConstant.ANIMATION_DURATION_MS_BUTTON_PLAYER),
      shape: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) {
          return getPlayerShape(active, true);
        }
        return getPlayerShape(active, false);
      }),
      elevation: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) {
          return active ? FlurecConstant.ELEVATION_BUTTON_PLAYER_ON_PRESSED : FlurecConstant.ELEVATION_BUTTON_PLAYER_OFF_PRESSED;
        }
        return active ? FlurecConstant.ELEVATION_BUTTON_PLAYER_ON : FlurecConstant.ELEVATION_BUTTON_PLAYER_OFF;
      }),
      textStyle: null,
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        return getBackgroundColors(active, states.contains(MaterialState.pressed));
      }),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        return getForegroundColors(active, states.contains(MaterialState.pressed));
      }),
      shadowColor: MaterialStateProperty.resolveWith((states) {
        return getShadowColors(active, states.contains(MaterialState.pressed));
      }),
      overlayColor: MaterialStateProperty.resolveWith((states) {
        double opacity;
        if (states.contains(MaterialState.focused)) {
          opacity = 0.125;
        } else if (states.contains(MaterialState.hovered)) {
          opacity = 0.1;
        } else {
          opacity = 0.15;
        }
        return getForegroundColors(active, states.contains(MaterialState.pressed), opacity: opacity);
      }),
    );
  }

  static CircleBorder getPlayerShape(bool active, bool pressed) => CircleBorder(side: getPlayerShapeSide(active, pressed));

  static BorderSide getPlayerShapeSide(bool active, bool interacted) {
    return BorderSide(
      width: active
          ? interacted
              ? FlurecConstant.BORDER_SIZE_BUTTON_PLAYER_ON_PRESSED
              : FlurecConstant.BORDER_SIZE_BUTTON_PLAYER_ON
          : interacted
              ? FlurecConstant.BORDER_SIZE_BUTTON_PLAYER_OFF_PRESSED
              : FlurecConstant.BORDER_SIZE_BUTTON_PLAYER_OFF,
      color: getBorderColors(active, interacted),
      style: BorderStyle.solid,
    );
  }

  static Color getForegroundColors(bool active, bool interacted, {double opacity = 1.0}) {
    return (active
            ? interacted
                ? FlurecConstant.COLOR_PRIMARY
                : FlurecConstant.COLOR_PRIMARY_LIGHT
            : interacted
                ? FlurecConstant.COLOR_SECONDARY_DARK
                : FlurecConstant.COLOR_SECONDARY)
        .withOpacity(opacity);
  }

  static Color getBackgroundColors(bool active, bool interacted, {double opacity = 1.0}) {
    return (active
            ? interacted
                ? FlurecConstant.COLOR_PRIMARY_DARK
                : FlurecConstant.COLOR_PRIMARY
            : interacted
                ? FlurecConstant.COLOR_PRIMARY_LIGHT
                : FlurecConstant.COLOR_PRIMARY_LIGHT)
        .withOpacity(opacity);
  }

  static Color getBorderColors(bool active, bool interacted, {double opacity = 1.0}) {
    return (active
            ? interacted
                ? FlurecConstant.COLOR_PRIMARY
                : FlurecConstant.COLOR_PRIMARY_LIGHT
            : interacted
                ? FlurecConstant.COLOR_SECONDARY_DARK
                : FlurecConstant.COLOR_SECONDARY)
        .withOpacity(opacity);
  }

  static Color getShadowColors(bool active, bool interacted, {double opacity = 1.0}) {
    return (active
            ? interacted
                ? FlurecConstant.COLOR_PRIMARY_DARK
                : FlurecConstant.COLOR_PRIMARY
            : interacted
                ? FlurecConstant.COLOR_SECONDARY_DARK
                : FlurecConstant.COLOR_SECONDARY)
        .withOpacity(opacity);
  }

  static Widget getLoadingWidget() => Center(child: CircularProgressIndicator());

  static Widget getRecordStartButton(VoidCallback? onPressed) => Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(FlurecConstant.PADDING_IN_VIEW),
        child: SizedBox(
          width: FlurecConstant.SIZE_BUTTON_RECORD,
          height: FlurecConstant.SIZE_BUTTON_RECORD,
          child: OutlinedButton(
              style: FlurecViewUtil.getPlayerButtonStyle(false),
              child: Icon(
                Icons.mic_rounded,
                size: 96.0,
              ),
              onPressed: () {
                if (onPressed != null) onPressed();
              }),
        ),
      );

  static Widget getRecordStopButton(VoidCallback? onPressed) => Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(FlurecConstant.PADDING_IN_VIEW),
      child: SizedBox(
        width: FlurecConstant.SIZE_BUTTON_RECORD,
        height: FlurecConstant.SIZE_BUTTON_RECORD,
        child: OutlinedButton(
            style: FlurecViewUtil.getPlayerButtonStyle(true),
            child: Icon(
              Icons.stop_rounded,
              size: 96.0,
            ),
            onPressed: () {
              if (onPressed != null) onPressed();
            }),
      ));
}
