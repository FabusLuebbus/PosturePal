import 'dart:math';

import 'package:posture_pal/backend/sliding_window.dart';

/// Manages the calculation and calibration of device orientation based on sensor data.
///
/// The [OrientationManager] processes raw accelerometer data, applies
/// rotation transformations, and calculates the device's pitch and roll angles.
/// It also provides methods to calibrate orientation targets and adjust yaw corrections.
class OrientationManager {
  /// The yaw angle correction in degrees.
  ///
  /// Describes the "yaw" angle at which the earable is positioned relative to the
  /// "pitch" rotation plane.
  int _yawCorrection = 0;

  /// Sliding window for the X-axis accelerometer data.
  final SlidingWindow _accX = SlidingWindow(size: 10);

  /// Sliding window for the Y-axis accelerometer data.
  final SlidingWindow _accY = SlidingWindow(size: 10);

  /// Sliding window for the Z-axis accelerometer data.
  final SlidingWindow _accZ = SlidingWindow(size: 10);

  /// The most recent raw orientation calculated from sensor data.
  ESenseOrientation _rawOrientation = ESenseOrientation();

  /// The target pitch angle for calibration.
  double _pitchTarget = 0;

  /// The target roll angle for calibration.
  double _rollTarget = 0;

  /// Sign modifier for pitch calculations to handle Y-axis inversion.
  int _pitchSign = 1;

  /// Calculates the current orientation based on the provided [sensorReading].
  ///
  /// This method processes raw sensor data by adding it to sliding windows,
  /// averaging the values, applying rotation matrices, and computing the
  /// pitch and roll angles.
  ///
  /// - [sensorReading]: The raw sensor data from the eSense device.
  ///
  /// Returns an [ESenseOrientation] object containing the calculated pitch and roll angles.
  ESenseOrientation calculateOrientation({
    required SensorReadingInt sensorReading,
  }) {
    // Add the sensor reading to the sliding windows
    _accX.add(sensorReading.accX);
    _accY.add(sensorReading.accY);
    _accZ.add(sensorReading.accZ);

    // Calculate the average accelerometer values and scale them down
    SensorReading processedReading = SensorReading(
      accX: _accX.average / 1000,
      accY: _accY.average / 1000,
      accZ: _accZ.average / 1000,
    );

    // Apply the rotation matrix to align with the head's frame
    SensorReading transformed = _applyRotationMatrix(sensorReading: processedReading);

    double alignedAccX = transformed.accX;
    double alignedAccY = transformed.accY;
    double alignedAccZ = transformed.accZ;

    // Calculate pitch and roll in the aligned frame
    double rollRaw = atan(alignedAccZ / sqrt(pow(alignedAccX, 2) + pow(alignedAccY, 2))) * 180 / pi;
    double pitchRaw = -atan(alignedAccY / sqrt(pow(alignedAccX, 2) + pow(alignedAccZ, 2))) * 180 / pi;
    _rawOrientation = ESenseOrientation(pitch: pitchRaw, roll: rollRaw);

    // Calculate difference between target and raw pitch and roll
    double pitch = _pitchSign * (pitchRaw - _pitchTarget);
    double roll = rollRaw - _rollTarget;

    return ESenseOrientation(pitch: pitch, roll: roll);
  }

  /// Calibrates the orientation targets based on the current raw orientation.
  ///
  /// Sets the [_pitchTarget] and [_rollTarget] to the current raw pitch and roll values,
  /// effectively zeroing the orientation calculations relative to the current position.
  void calibrate() {
    _pitchTarget = _rawOrientation.pitch;
    _rollTarget = _rawOrientation.roll;
  }

  /// Sets the yaw correction angle.
  ///
  /// [yawCorrection] is the angle in degrees used to adjust the yaw rotation.
  void setYawCorrection(int yawCorrection) {
    _yawCorrection = yawCorrection;
  }

  /// Sets whether the Y-axis should be inverted.
  ///
  /// [invertYAxis] is `true` to invert the Y-axis, which affects pitch calculations.
  void setInvertYAxis(bool invertYAxis) {
    if (invertYAxis) {
      _pitchSign = -1;
    } else {
      _pitchSign = 1;
    }
  }

  /// Applies a rotation matrix to transform accelerometer data.
  ///
  /// This method rotates the raw accelerometer data based on the current yaw correction
  /// to align it with the head's frame of reference.
  ///
  /// - [sensorReading]: The processed sensor data after averaging.
  ///
  /// Returns a [SensorReading] object containing the transformed accelerometer values.
  SensorReading _applyRotationMatrix({
    required SensorReading sensorReading,
  }) {
    double accX = sensorReading.accX;
    double accY = sensorReading.accY;
    double accZ = sensorReading.accZ;

    double yawRad = _yawCorrection * pi / 180; // Convert to radians
    double cosYaw = cos(yawRad);
    double sinYaw = sin(yawRad);

    // Combined rotation matrix for yaw correction
    List<List<double>> rotationMatrix = [
      [1, 0, 0],
      [0, cosYaw, -sinYaw],
      [0, sinYaw, cosYaw],
    ];

    // Apply the rotation matrix to the accelerometer data
    double transformedX = rotationMatrix[0][0] * accX +
        rotationMatrix[0][1] * accY +
        rotationMatrix[0][2] * accZ;
    double transformedY = rotationMatrix[1][0] * accX +
        rotationMatrix[1][1] * accY +
        rotationMatrix[1][2] * accZ;
    double transformedZ = rotationMatrix[2][0] * accX +
        rotationMatrix[2][1] * accY +
        rotationMatrix[2][2] * accZ;

    return SensorReading(
      accX: transformedX,
      accY: transformedY,
      accZ: transformedZ,
    );
  }
}

/// Represents the orientation of the device with pitch and roll angles.
///
/// The [ESenseOrientation] class holds the pitch and roll values in degrees, providing
/// a simple structure to convey the device's current orientation state.
class ESenseOrientation {
  /// The pitch angle in degrees.
  ///
  /// Positive values indicate upward tilt, while negative values indicate downward tilt.
  final double pitch;

  /// The roll angle in degrees.
  ///
  /// Positive values indicate a tilt to the right, while negative values indicate a tilt to the left.
  final double roll;

  /// Creates an [ESenseOrientation] with the specified [pitch] and [roll] angles.
  ///
  /// Both [pitch] and [roll] default to `0` if not specified.
  ESenseOrientation({
    this.pitch = 0,
    this.roll = 0,
  });
}

/// Represents a sensor reading with double-precision accelerometer data.
///
/// The [SensorReading] class is used to store processed accelerometer values.
class SensorReading {
  /// Accelerometer reading along the X-axis
  final double accX;

  /// Accelerometer reading along the Y-axis
  final double accY;

  /// Accelerometer reading along the Z-axis
  final double accZ;

  /// Creates a [SensorReading] with the specified accelerometer values.
  ///
  /// All parameters are required and represent the acceleration along each axis.
  SensorReading({
    required this.accX,
    required this.accY,
    required this.accZ,
  });
}

/// Represents a sensor reading with integer accelerometer data.
///
/// The [SensorReadingInt] class is used to store raw accelerometer values before processing.
class SensorReadingInt {
  /// Raw accelerometer reading along the X-axis.
  final int accX;

  /// Raw accelerometer reading along the Y-axis.
  final int accY;

  /// Raw accelerometer reading along the Z-axis.
  final int accZ;

  /// Creates a [SensorReadingInt] with the specified raw accelerometer values.
  ///
  /// All parameters are required and represent the raw acceleration data.
  SensorReadingInt({
    required this.accX,
    required this.accY,
    required this.accZ,
  });
}
