import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';

/// A widget that visualizes the device's pitch and roll orientations.
///
/// The [PitchRollVisualizer] displays a graphical representation of the device's
/// current pitch and roll angles. It listens to orientation changes from the
/// [MyAppState] and updates the visualizer accordingly with smooth animations.
class PitchRollVisualizer extends StatefulWidget {
  /// Creates a [PitchRollVisualizer] widget.
  const PitchRollVisualizer({Key? key}) : super(key: key);

  @override
  _PitchRollVisualizerState createState() => _PitchRollVisualizerState();
}

/// The state for the [PitchRollVisualizer] widget.
///
/// Manages the animation of pitch and roll values and handles calibration
/// through user interaction.
class _PitchRollVisualizerState extends State<PitchRollVisualizer>
    with SingleTickerProviderStateMixin {
  /// The current pitch value in degrees.
  ///
  /// Positive values indicate an upward tilt, while negative values indicate
  /// a downward tilt.
  double pitch = 0;

  /// The current roll value in degrees.
  ///
  /// Positive values indicate a tilt to the right, while negative values indicate
  /// a tilt to the left.
  double roll = 0;

  /// Controller for managing animations of pitch and roll values.
  late AnimationController _controller;

  /// Tween for animating pitch values.
  late Tween<double> _pitchTween;

  /// Tween for animating roll values.
  late Tween<double> _rollTween;

  /// Animation for pitch values.
  late Animation<double> _pitchAnimation;

  /// Animation for roll values.
  late Animation<double> _rollAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pitchTween = Tween(begin: 0.0, end: 0.0);
    _rollTween = Tween(begin: 0.0, end: 0.0);

    _pitchAnimation = _pitchTween.animate(_controller);
    _rollAnimation = _rollTween.animate(_controller);

    _controller.addListener(() {
      setState(() {});
    });
  }

  /// Updates the pitch and roll values with smooth animations.
  ///
  /// [newPitch] and [newRoll] are the updated orientation angles received from
  /// the [MyAppState]. This method creates new tweens from the current animation
  /// values to the new target values and triggers the animation controller.
  ///
  /// - [newPitch]: The updated pitch angle in degrees.
  /// - [newRoll]: The updated roll angle in degrees.
  void updateValues(double newPitch, double newRoll) {
    _pitchTween = Tween(begin: _pitchAnimation.value, end: newPitch);
    _rollTween = Tween(begin: _rollAnimation.value, end: newRoll);

    _pitchAnimation = _pitchTween.animate(_controller);
    _rollAnimation = _rollTween.animate(_controller);

    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    updateValues(appState.orientation.pitch, appState.orientation.roll);
    var screenSize = MediaQuery.of(context).size;
    double sizeLimit = min(screenSize.width, screenSize.height) * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posture Tracking'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: CustomPaint(
              size: Size(sizeLimit, sizeLimit), // Define the size of the circle area
              painter: PitchRollPainter(
                pitch: _pitchAnimation.value,
                roll: _rollAnimation.value,
                maxPitch: appState.maxPitch,
                maxRoll: appState.maxRoll,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: appState.orientationService.calibrate,
                child: const Text("Calibrate"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A custom painter that draws the pitch and roll indicators.
///
/// The [PitchRollPainter] visualizes the device's orientation by drawing
/// concentric circles and an indicator that moves based on the current
/// pitch and roll values. The indicator's color changes based on its distance
/// from the center, providing a visual cue of the posture's accuracy.
class PitchRollPainter extends CustomPainter {
  /// The current pitch value in degrees.
  final double pitch;

  /// The current roll value in degrees.
  final double roll;

  /// The maximum allowable pitch angle in degrees.
  final int maxPitch;

  /// The maximum allowable roll angle in degrees.
  final int maxRoll;

  /// Creates a [PitchRollPainter] with the specified orientation values.
  ///
  /// - [pitch]: The current pitch angle in degrees.
  /// - [roll]: The current roll angle in degrees.
  /// - [maxPitch]: The maximum allowable pitch angle in degrees.
  /// - [maxRoll]: The maximum allowable roll angle in degrees.
  PitchRollPainter({
    required this.pitch,
    required this.roll,
    required this.maxPitch,
    required this.maxRoll,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);

    // Draw the darker background circle
    Paint backgroundPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw the outer circle
    Paint outerCirclePaint = Paint()
      ..color = Colors.grey[500]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, radius, outerCirclePaint);

    // Draw the inner circles
    Paint innerCirclePaint = Paint()
      ..color = Colors.grey[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, 2 * radius / 3, innerCirclePaint);
    canvas.drawCircle(center, radius / 3, innerCirclePaint);

    // Normalize pitch and roll values to the range [-1, 1]
    final double normalizedPitch = (pitch / maxPitch).clamp(-1.0, 1.0);
    final double normalizedRoll = (roll / maxRoll).clamp(-1.0, 1.0);

    // Calculate the indicator's position based on pitch and roll
    Offset centerToIndicatorOffset = Offset(
      normalizedRoll * radius,
      normalizedPitch * radius,
    );
    double length = centerToIndicatorOffset.distance;
    if (length > radius) {
      centerToIndicatorOffset = centerToIndicatorOffset.scale(radius / length, radius / length);
    }
    final Offset indicatorPosition = center + centerToIndicatorOffset;

    // Calculate the normalized distance from the center for color interpolation
    final double distanceFromCenter = (indicatorPosition - center).distance / radius;

    // Determine the indicator's color based on its distance from the center
    final Color indicatorColor = Color.lerp(
      Colors.green,
      Colors.red,
      distanceFromCenter.clamp(0.0, 1.0),
    )!;

    // Paint for the indicator
    Paint indicatorPaint = Paint()
      ..color = indicatorColor
      ..style = PaintingStyle.fill;

    // Draw the indicator circle
    canvas.drawCircle(indicatorPosition, radius / 8, indicatorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
