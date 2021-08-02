import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:share/share.dart';

class ShareUtil {
  static Future<void> shareText(BuildContext context, String text, {String? subject, Rect? sharePositionOrigin}) async {
    Share.share(text, subject: subject, sharePositionOrigin: sharePositionOrigin);
  }

  static Future<void> shareFiles(BuildContext context, List<String> filePats, {List<String>? mimeTypes, String? subject, String? text, Rect? sharePositionOrigin}) async {
    if (filePats.isNotEmpty) {
      Share.shareFiles(filePats, mimeTypes: mimeTypes, subject: subject);
    }
  }

  static Future<void> shareFile(BuildContext context, String filePath, {List<String>? mimeTypes, String? subject, String? text, Rect? sharePositionOrigin}) async {
    return shareFiles(context, [filePath], subject: subject, mimeTypes: mimeTypes);
  }
}
