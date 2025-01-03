import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';

/// A page that allows users to configure application preferences.
///
/// The [PreferencesPage] provides various settings related to general application
/// behavior and the connection to the eSense device. Users can toggle options,
/// input numerical values, and manage the device connection from this page.
class PreferencesPage extends StatelessWidget {
  /// Creates a [PreferencesPage] widget.
  ///
  /// The [key] parameter is passed to the superclass.
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          buildSectionTitle("General"),
          buildSwitchTile(
            context,
            title: 'Invert Y axis',
            subtitle: 'Invert the movement of the indicator on the Y axis (pitch)',
            value: appState.invertYAxis,
            onChanged: (value) {
              appState.setInvertYAxis(value);
            },
          ),
          buildSwitchTile(
            context,
            title: 'Dark Mode',
            subtitle: 'Use a dark theme for the app',
            value: appState.darkMode,
            onChanged: (value) {
              appState.setDarkMode(value);
            },
          ),
          buildIntInputTile(
            context,
            title: 'Yaw Correction',
            subtitle: 'The angle of the earable relative to your head',
            currentValue: appState.yawCorrection.toString(),
            onSubmitted: (value) {
              final intValue = int.tryParse(value);
              if (intValue == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid integer value'),
                  ),
                );
              } else {
                appState.setYawCorrection(intValue);
              }
            },
          ),
          buildIntInputTile(
            context,
            title: 'Pitch Limit',
            subtitle: 'Maximum pitch angle displayed',
            currentValue: appState.maxPitch.toString(),
            onSubmitted: (value) {
              final intValue = int.tryParse(value);
              if (intValue == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid integer value'),
                  ),
                );
              } else {
                appState.setMaxPitch(intValue);
              }
            },
          ),
          buildIntInputTile(
            context,
            title: 'Roll Limit',
            subtitle: 'Maximum roll angle displayed',
            currentValue: appState.maxRoll.toString(),
            onSubmitted: (value) {
              final intValue = int.tryParse(value);
              if (intValue == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid integer value'),
                  ),
                );
              } else {
                appState.setMaxRoll(intValue);
              }
            },
          ),
          buildSectionTitle("eSense Connection"),
          ListTile(
            title: const Text('Device Name'),
            subtitle: const Text("The name of the eSense device to connect to"),
            trailing: SizedBox(
              width: 130,
              child: TextField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: "eSense-XXXX",
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  appState.setDeviceName(value);
                },
              ),
            ),
          ),
          ListTile(
            title: const Text('Status'),
            subtitle: Text(appState.connectionStatus),
          ),
          ElevatedButton(
            onPressed: () {
              appState.connectToESense(appState.deviceName);
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  /// Builds a section title widget with the given [title].
  ///
  /// The section title is styled with increased font size and bold weight to
  /// differentiate it from other list items.
  ///
  /// - [title]: The text to display as the section title.
  ///
  /// Returns a [Padding] widget containing the styled [Text] widget.
  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Builds a switch tile for boolean preferences.
  ///
  /// The [buildSwitchTile] creates a [SwitchListTile] with the specified
  /// [title], optional [subtitle], current [value], and [onChanged] callback.
  ///
  /// - [context]: The build context.
  /// - [title]: The primary text for the switch.
  /// - [subtitle]: Optional secondary text providing more details.
  /// - [value]: The current boolean value of the switch.
  /// - [onChanged]: Callback invoked when the switch value changes.
  ///
  /// Returns a [SwitchListTile] widget configured with the provided parameters.
  Widget buildSwitchTile(
      BuildContext context, {
        required String title,
        String? subtitle,
        required bool value,
        required ValueChanged<bool> onChanged,
      }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: onChanged,
    );
  }

  /// Builds an input tile for integer preferences.
  ///
  /// The [buildIntInputTile] creates a [ListTile] containing a [TextField]
  /// for users to input integer values. It includes the specified [title],
  /// optional [subtitle], current [currentValue], and [onSubmitted] callback.
  ///
  /// - [context]: The build context.
  /// - [title]: The primary text for the input field.
  /// - [subtitle]: Optional secondary text providing more details.
  /// - [currentValue]: The current string representation of the integer value.
  /// - [onSubmitted]: Callback invoked when the user submits the input.
  ///
  /// Returns a [ListTile] widget containing the configured [TextField].
  Widget buildIntInputTile(
      BuildContext context, {
        required String title,
        String? subtitle,
        required String currentValue,
        required ValueChanged<String> onSubmitted,
      }) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: SizedBox(
        width: 100,
        child: TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: currentValue,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: onSubmitted,
        ),
      ),
    );
  }
}
