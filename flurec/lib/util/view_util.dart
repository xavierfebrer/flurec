import 'package:flurec/util/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FlurecViewUtil {
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

  static Widget getLoadingWidget<T>(Future<T> futureToLoad,
      {T? initialData, LoadingActionEmpty<T>? onLoadEmpty, LoadingActionData<T>? onLoadData, LoadingActionError<T>? onLoadError}) {
    return FutureBuilder<T>(
      initialData: initialData,
      future: futureToLoad,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasError) {
          return onLoadError != null ? onLoadError(context, snapshot.error) : Center(child: Text("Error"));
        } else if (snapshot.hasData && snapshot.data != null) {
          return onLoadData != null ? onLoadData(context, snapshot.data!, snapshot.connectionState != ConnectionState.done) : Center(child: Text("${snapshot.data}"));
        }
        return onLoadEmpty != null ? onLoadEmpty(context) : Center(child: CircularProgressIndicator());
      },
    );
  }
}

typedef LoadingActionEmpty<T> = Widget Function(BuildContext context);
typedef LoadingActionData<T> = Widget Function(BuildContext context, T data, bool isInitialData);
typedef LoadingActionError<T> = Widget Function(BuildContext context, Object? error);
