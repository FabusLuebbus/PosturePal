import 'dart:collection';
import 'dart:math';

/// Rounds a [value] to the specified number of decimal [places].
///
/// The [roundDouble] function multiplies the [value] by 10 raised to the
/// [places] power, rounds it to the nearest integer, and then divides it
/// back to obtain the rounded double.
///
/// - [value]: The double value to be rounded.
/// - [places]: The number of decimal places to round to.
///
/// Returns the [value] rounded to [places] decimal places.
double roundDouble(double value, int places) {
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

/// A sliding window that maintains a fixed number of recent double values.
///
/// The [SlidingWindow] class stores incoming values in a queue and calculates
/// their average once the window reaches its specified [size]. It also provides
/// an optional callback [onAdd] that is invoked whenever a new average is computed.
class SlidingWindow {
  /// The maximum number of values the sliding window can hold.
  final int size;

  /// Queue to store the most recent double values.
  final Queue<double> _values = Queue();

  /// The sum of the values currently in the sliding window.
  double _sum = 0;

  /// The current average of the values in the sliding window.
  ///
  /// If the sliding window has not yet reached its [size], [average] is set to `-1`.
  double average = 0;

  /// Optional callback invoked with the [average] whenever a new average is computed.
  final void Function(double average)? onAdd;

  /// Creates a [SlidingWindow] with the specified [size] and an optional [onAdd] callback.
  ///
  /// - [size]: The number of recent values to maintain for averaging.
  /// - [onAdd]: An optional callback that is triggered with the new [average] when
  ///   the sliding window reaches its full [size].
  SlidingWindow({required this.size, this.onAdd});

  /// Adds a new [value] to the sliding window.
  ///
  /// The [value] is first scaled by dividing by 1000 and rounding to two decimal
  /// places using the [roundDouble] function. If the absolute value of the scaled
  /// [value] is less than `0.1`, it is set to `0` to eliminate minor fluctuations.
  ///
  /// The scaled [value] is then added to the internal queue. If the queue exceeds
  /// the specified [size], the oldest value is removed to maintain the window size.
  ///
  /// Once the sliding window is full (i.e., contains [size] elements), the [average]
  /// is calculated. If the absolute value of the [average] is less than `0.1`, it is
  /// set to `0`. If an [onAdd] callback is provided, it is invoked with the new [average].
  ///
  /// - [value]: The integer value to be added to the sliding window.
  void add(int value) {
    double scaledValue = roundDouble(value / 1000, 2);
    if (scaledValue.abs() < 0.1) {
      scaledValue = 0;
    }
    _values.addLast(scaledValue);
    _sum += scaledValue;

    if (_values.length > size) {
      _sum -= _values.removeFirst();
    }

    if (_values.length == size) {
      average = _sum / size;
      if (average.abs() < 0.1) {
        average = 0;
      }
      if (onAdd != null) {
        onAdd!(average);
      }
    } else {
      average = -1;
    }
  }
}
