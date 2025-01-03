import 'dart:async';
import 'dart:io';
import 'package:esense_flutter/esense.dart';
import 'package:permission_handler/permission_handler.dart';

/// A function type that handles sensor events from the eSense device.
///
/// [SensorEvent] contains the data emitted by the sensor.
typedef void OnSensorData(SensorEvent event);

/// A function type that handles connection status updates for the eSense device.
///
/// [ConnectionType] indicates the current status of the connection.
typedef void OnConnectionStatus(ConnectionType status);

/// Manages the connection and data communication with an eSense device.
///
/// The [EsenseClient] handles establishing the connection, listening for sensor
/// events, and updating the connection status. It ensures that the application
/// has the necessary permissions and manages reconnection attempts if the initial
/// connection fails.
class EsenseClient {
  /// The name of the eSense device to connect to.
  late String deviceName;

  /// Callback invoked when the connection status changes.
  final OnConnectionStatus onConnectionStatus;

  /// The current connection status of the eSense device.
  ConnectionType status = ConnectionType.disconnected;

  /// Subscription to the sensor events stream.
  StreamSubscription? subscription;

  /// Manager for handling eSense device operations.
  late ESenseManager eSenseManager;

  /// Creates an [EsenseClient] with the provided [onConnectionStatus] callback.
  ///
  /// The [onConnectionStatus] callback is triggered whenever the connection
  /// status changes.
  EsenseClient(this.onConnectionStatus);

  /// Connects to the eSense device with the specified [deviceName] and listens
  /// for sensor data using the [onData] callback.
  ///
  /// This method initializes the connection process, requests necessary permissions,
  /// and sets up listeners for sensor events.
  ///
  /// - [onData]: A callback function that handles incoming [SensorEvent] data.
  /// - [deviceName]: The name of the eSense device to connect to.
  void connect(OnSensorData onData, String deviceName) {
    status = ConnectionType.disconnected;
    if (subscription != null) {
      subscription!.cancel();
    }
    eSenseManager = ESenseManager(deviceName);
    _initialize(onData);
  }

  /// Initializes the connection by requesting permissions and connecting to the eSense device.
  ///
  /// - [onData]: A callback function that handles incoming [SensorEvent] data.
  Future<void> _initialize(OnSensorData onData) async {
    await _askForPermissions();
    await _connectToESense(onData);
  }

  /// Establishes a connection to the eSense device and listens for sensor events.
  ///
  /// Attempts to connect up to three times if the initial connection fails.
  ///
  /// - [onData]: A callback function that handles incoming [SensorEvent] data.
  Future<void> _connectToESense(OnSensorData onData) async {
    await _setupConnectionListener();
    var tries = 0;
    while (status != ConnectionType.connected) {
      if (tries > 3) {
        return;
      }
      print('Waiting to connect to eSense device...');
      await _startConnection();
      await Future.delayed(const Duration(seconds: 5));
      tries++;
    }
    eSenseManager.setSamplingRate(100);
    subscription = eSenseManager.sensorEvents.listen(onData);
  }

  /// Sets up a listener for connection events from the eSense device.
  ///
  /// This listener updates the [status] and invokes the [onConnectionStatus]
  /// callback whenever the connection status changes.
  Future<void> _setupConnectionListener() async {
    eSenseManager.connectionEvents.listen((event) {
      status = event.type;
      onConnectionStatus(event.type);
    });
  }

  /// Initiates the connection to the eSense device.
  ///
  /// Awaits the completion of the connection process.
  Future<void> _startConnection() async {
    await eSenseManager.connect();
  }

  /// Requests the necessary permissions for Bluetooth and location access.
  ///
  /// If the required permissions are not granted, a warning is printed to the console.
  Future<void> _askForPermissions() async {
    if (!(await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted)) {
      print('WARNING - no permission to use Bluetooth granted.');
    }
    if (Platform.isAndroid &&
        !(await Permission.locationWhenInUse.request().isGranted)) {
      print('WARNING - no permission to access location granted.');
    }
  }
}
