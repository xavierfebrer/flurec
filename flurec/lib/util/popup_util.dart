import 'package:flutter/material.dart';

class PopupUtil {
  static Future<void> showPopup(BuildContext context, String? title, String? description, String? confirmButtonText, String? cancelButtonText,
      {bool barrierDismissible = true,
      Function()? onConfirm,
      Function()? onCancel,
      TextStyle? textStyleTitle,
      TextStyle? textStyleDescription,
      TextStyle? textStyleConfirmButtonText,
      TextStyle? textStyleCancelButtonText}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title ?? "",
            style: textStyleTitle,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  description ?? "",
                  style: textStyleDescription,
                ),
              ],
            ),
          ),
          actions: getActionWidgets(context, confirmButtonText, cancelButtonText,
              textStyleConfirmButtonText: textStyleConfirmButtonText, textStyleCancelButtonText: textStyleCancelButtonText, onConfirm: onConfirm, onCancel: onCancel),
        );
      },
    );
  }

  static Future<void> showPopupEdit(BuildContext context, String? title, String? description, String? confirmButtonText, String? cancelButtonText,
      {bool barrierDismissible = true,
      Function()? onConfirm,
      Function()? onCancel,
      Function(String newText)? onChanged,
      TextStyle? textStyleTitle,
      TextStyle? textStyleDescription,
      TextStyle? textStyleConfirmButtonText,
      TextStyle? textStyleCancelButtonText}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title ?? "",
            style: textStyleTitle,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: TextEditingController(text: description ?? ""),
                  onChanged: onChanged,
                  style: textStyleDescription,
                )
              ],
            ),
          ),
          actions: getActionWidgets(context, confirmButtonText, cancelButtonText,
              textStyleConfirmButtonText: textStyleConfirmButtonText, textStyleCancelButtonText: textStyleCancelButtonText, onConfirm: onConfirm, onCancel: onCancel),
        );
      },
    );
  }

  static List<Widget> getActionWidgets(BuildContext context, String? confirmButtonText, String? cancelButtonText,
      {TextStyle? textStyleConfirmButtonText, TextStyle? textStyleCancelButtonText, Function()? onConfirm, Function()? onCancel}) {
    List<Widget> widgetList = [];
    if (confirmButtonText != null && confirmButtonText.isNotEmpty) {
      widgetList.add(FlatButton(
        child: Text(
          confirmButtonText,
          style: textStyleConfirmButtonText,
        ),
        onPressed: () {
          Navigator.of(context).pop();
          if (onConfirm != null) onConfirm();
        },
      ));
    }
    if (cancelButtonText != null && cancelButtonText.isNotEmpty) {
      widgetList.add(FlatButton(
        child: Text(
          cancelButtonText,
          style: textStyleCancelButtonText,
        ),
        onPressed: () {
          Navigator.of(context).pop();
          if (onCancel != null) onCancel();
        },
      ));
    }
    return widgetList;
  }
}
