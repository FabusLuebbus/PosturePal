import 'package:flutter/material.dart';
import 'package:esense_flutter/esense.dart';
import 'package:provider/provider.dart';

import 'backend/orientation_manager.dart';
import 'backend/esense_client.dart';
import 'pages/home_page.dart';

/// The entry point of the PosturePal application.
///
/// Initializes and runs the [MyApp] widget.
void main() => runApp(const MyApp());

/// The root widget of the PosturePal application.
///
/// Sets up the [ChangeNotifierProvider] and configures the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'PosturePal',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
            ),
            darkTheme: ThemeData.dark(),
            themeMode: context.watch<MyAppState>().darkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: HomePage(),
          );
        },
      ),
    );
  }
}

/// Manages the central state of the PosturePal application.
///
/// Handles connection to the eSense device, orientation calculations, and user preferences.
class MyAppState extends ChangeNotifier {
  /// The client used to communicate with the eSense device.
  late EsenseClient esenseClient;

  /// The current orientation based on sensor data.
  ESenseOrientation orientation = ESenseOrientation();

  /// Service responsible for calculating orientation from sensor readings.
  OrientationManager orientationService = OrientationManager();

  bool _darkMode = true;
  bool _invertYAxis = false;
  int _yawCorrection = 0;
  int _maxPitch = 35;
  int _maxRoll = 35;
  String _deviceName = "eSense-0338";
  ConnectionType _connectionStatus = ConnectionType.disconnected;

  /// Indicates whether dark mode is enabled.
  bool get darkMode => _darkMode;

  /// Indicates whether the Y-axis is inverted.
  bool get invertYAxis => _invertYAxis;

  /// The correction value to account for the earable being angled to its rotational plane.
  int get yawCorrection => _yawCorrection;

  /// The maximum pitch angle displayed.
  int get maxPitch => _maxPitch;

  /// The maximum roll angle displayed.
  int get maxRoll => _maxRoll;

  /// The name of the connected eSense device.
  String get deviceName => _deviceName;

  /// The current connection status to the eSense device.
  String get connectionStatus => _connectionStatus.toString();

  /// Creates a [MyAppState] instance and initializes the [EsenseClient].
  MyAppState() {
    esenseClient = EsenseClient(_updateConnectionStatus);
  }

  /// Updates the connection status and notifies listeners.
  ///
  /// [status] is the new connection status.
  void _updateConnectionStatus(ConnectionType status) {
    setConnectionStatus(status);
    notifyListeners();
  }

  /// Connects to the eSense device with the specified [deviceName].
  ///
  /// Initiates the connection process and handles sensor events.
  void connectToESense(String deviceName) {
    esenseClient.connect(_handleSensorEvent, deviceName);
  }

  /// Handles incoming sensor events from the eSense device.
  ///
  /// [event] contains the sensor data used to calculate orientation.
  void _handleSensorEvent(SensorEvent event) {
    if (event.accel != null && event.accel?.length == 3) {
      SensorReadingInt sensorReading = SensorReadingInt(
        accX: event.accel![0],
        accY: event.accel![1],
        accZ: event.accel![2],
      );
      orientation = orientationService.calculateOrientation(
          sensorReading: sensorReading);
      notifyListeners();
    }
  }

  /// Sets the dark mode preference.
  ///
  /// [value] is `true` to enable dark mode, `false` to disable.
  void setDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  /// Sets the Y-axis inversion preference.
  ///
  /// [value] is `true` to invert the Y-axis, `false` to keep it normal.
  void setInvertYAxis(bool value) {
    _invertYAxis = value;
    orientationService.setInvertYAxis(invertYAxis);
    notifyListeners();
  }

  /// Sets the yaw correction value.
  ///
  /// [value] is the new yaw correction to apply.
  void setYawCorrection(int value) {
    _yawCorrection = value;
    orientationService.setYawCorrection(value);
    notifyListeners();
  }

  /// Sets the maximum allowable pitch angle.
  ///
  /// [value] is the new maximum pitch angle in degrees.
  void setMaxPitch(int value) {
    _maxPitch = value;
    notifyListeners();
  }

  /// Sets the maximum allowable roll angle.
  ///
  /// [value] is the new maximum roll angle in degrees.
  void setMaxRoll(int value) {
    _maxRoll = value;
    notifyListeners();
  }

  /// Sets the name of the eSense device to connect to.
  ///
  /// [value] is the device name.
  void setDeviceName(String value) {
    _deviceName = value;
    notifyListeners();
  }

  /// Sets the current connection status.
  ///
  /// [value] is the new connection status.
  void setConnectionStatus(ConnectionType value) {
    _connectionStatus = value;
    notifyListeners();
  }
}