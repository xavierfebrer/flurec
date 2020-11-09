import 'dart:math' as math;

class MathUtil {
  static double toDegrees(double radians) {
    return radians * (180.0/math.pi);
  }

  static double toRadians(double degrees) {
    return degrees * (math.pi/180.0);
  }
}
