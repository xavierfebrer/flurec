
import 'dart:developer' as dev;

import 'Constant.dart';

class DebugUtil{
  static void log(Object tag, String info){
    dev.log("${Constant.LOG_TAG} $tag: $info");
  }
}