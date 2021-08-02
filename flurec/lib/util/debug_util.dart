
import 'dart:developer' as dev;

import 'constant.dart';

class DebugUtil{
  static void log(Object tag, String info){
    dev.log("${Constant.LOG_TAG} $tag: $info");
  }
}