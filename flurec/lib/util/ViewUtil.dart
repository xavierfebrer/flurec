import 'package:flurec/util/Constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ViewUtil {
  static ButtonStyle getPlayerButtonStyle(bool active) {
    return ButtonStyle(
      enableFeedback: false,
      side: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) {
          return getPlayerShapeSide(active, true);
        }
        return getPlayerShapeSide(active, false);
      }),
      animationDuration: Duration(milliseconds: Constant.ANIMATION_DURATION_MS_BUTTON_PLAYER),
      shape: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) {
          return getPlayerShape(active, true);
        }
        return getPlayerShape(active, false);
      }),
      elevation: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) {
          return active ? Constant.ELEVATION_BUTTON_PLAYER_ON_PRESSED : Constant.ELEVATION_BUTTON_PLAYER_OFF_PRESSED;
        }
        return active ? Constant.ELEVATION_BUTTON_PLAYER_ON : Constant.ELEVATION_BUTTON_PLAYER_OFF;
      }),
      textStyle: null,
      backgroundColor: MaterialStateProperty.resolveWith((states) => Constant.COLOR_PRIMARY_LIGHT),
      foregroundColor: MaterialStateProperty.resolveWith((states) => getColors(active, states.contains(MaterialState.pressed))),
      shadowColor: MaterialStateProperty.resolveWith((states) => getColors(active, states.contains(MaterialState.pressed))),
      overlayColor: MaterialStateProperty.resolveWith((states) {
        double opacity;
        if (states.contains(MaterialState.focused)) {
          opacity = 0.15;
        } else if (states.contains(MaterialState.hovered)) {
          opacity = 0.1;
        } else {
          opacity = 0.2;
        }
        return getColors(active, states.contains(MaterialState.pressed), opacity: opacity);
      }),
    );
  }

  static CircleBorder getPlayerShape(bool active, bool pressed) => CircleBorder(side: getPlayerShapeSide(active, pressed));

  static BorderSide getPlayerShapeSide(bool active, bool interacted) {
    return BorderSide(
      width: active
          ? interacted
              ? Constant.BORDER_SIZE_BUTTON_PLAYER_ON_PRESSED
              : Constant.BORDER_SIZE_BUTTON_PLAYER_ON
          : interacted
              ? Constant.BORDER_SIZE_BUTTON_PLAYER_OFF_PRESSED
              : Constant.BORDER_SIZE_BUTTON_PLAYER_OFF,
      color: getColors(active, interacted),
      style: BorderStyle.solid,
    );
  }

  static Color getColors(bool active, bool interacted, {double opacity = 1.0}) {
    return (active
        ? interacted
        ? Constant.COLOR_PRIMARY_DARK
        : Constant.COLOR_PRIMARY
        : interacted
        ? Constant.COLOR_ACCENT
        : Constant.COLOR_ACCENT_DARK).withOpacity(opacity);
  }

  static Widget getLoadingWidget<T>(Future<T> futureToLoad, {T initialData, LoadingActionEmpty<T> onLoadEmpty, LoadingActionData<T> onLoadData, LoadingActionError<T> onLoadError}){
    return FutureBuilder<T>(
      initialData: initialData,
      future: futureToLoad,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if(snapshot.hasError){
          return onLoadError != null ? onLoadError(context, snapshot.error) : Center(child: Text("Error"));
        } else if(snapshot.hasData){
          return onLoadData != null ? onLoadData(context, snapshot.data, snapshot.connectionState != ConnectionState.done) : Center(child: Text("${snapshot.data}"));
        }
        return onLoadEmpty != null ? onLoadEmpty(context) : Center(child: CircularProgressIndicator());
      },
    );
  }
}
typedef LoadingActionEmpty<T> = Widget Function(BuildContext context);
typedef LoadingActionData<T> = Widget Function(BuildContext context, Object data, bool isInitialData);
typedef LoadingActionError<T> = Widget Function(BuildContext context, T data);

