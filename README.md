# PosturePal

![PosturePal](lib/assets/icon_accel.png)

PosturePal is a Flutter application that uses eSense earables to track head position and orientation in real-time, helping users maintain proper posture throughout the day. This is a student project as part of the Mobile Computing & IoT lecture at KIT.

## Overview

Poor posture is a common problem in today's digital world, leading to neck pain, headaches, and long-term health issues. PosturePal provides a simple yet effective solution by using the accelerometer data from eSense earables to monitor head position and provide immediate visual feedback.

## Features

- **Real-time posture tracking**: Monitors head orientation using eSense earables
- **Visual feedback**: Intuitive visualization showing current head position
- **Rotation matrix yaw correction**: Advanced algorithm to account for earable positioning relative to the head's rotational plane
- **Customizable settings**: Adjust sensitivity and calibration to your preferences
- **Calibration**: Easily calibrate the system to your natural head position
- **Cross-platform**: Works on Android and Linux

## Requirements

- eSense earables (tested with eSense-0338)
- Android device or Linux computer with Bluetooth capability
- Flutter SDK (for building from source)

## Installation

### Pre-built Binaries

Download the latest APK from the releases section and install it on your Android device.

### Building from Source

1. Clone this repository
2. Ensure Flutter is installed and set up on your system
3. Run `flutter pub get` to install dependencies
4. Connect your device and run `flutter run`

## Usage

1. Launch the PosturePal app
2. Navigate to the Preferences page
3. Enter your eSense device name (e.g., "eSense-0338")
4. Press "Confirm" to save the device name
5. Press "Connect" to establish a connection with your eSense earables
6. Once connected, return to the Home page to see the posture visualization
7. Press "Calibrate" to set your current head position as the neutral position
8. The indicator will show your current head position relative to the calibrated position
   - Green indicator: Good posture
   - Yellow/Orange indicator: Moderate deviation from good posture
   - Red indicator: Poor posture

## Configuration Options

### General Settings

- **Invert Y-axis**: Flip the vertical movement of the indicator
- **Dark Mode**: Toggle between light and dark themes
- **Yaw Correction**: Adjust for the angle at which the earable is positioned relative to your head's rotational plane
- **Pitch Limit**: Set the maximum pitch angle displayed in the visualization
- **Roll Limit**: Set the maximum roll angle displayed in the visualization

### Connection Settings

- **Device Name**: The name of your eSense device (e.g., "eSense-0338")
- **Connection Status**: Shows the current connection state

## Technical Details

PosturePal uses the following technologies and approaches:

- **Flutter**: Cross-platform UI framework
- **Provider**: State management
- **eSense Flutter Plugin**: Communication with eSense earables
- **Accelerometer Data Processing**: 
  - Sliding window averaging for noise reduction
  - Rotation matrix transformations to align with head frame
  - Pitch and roll calculation from accelerometer vectors
- **Rotation Matrix Yaw Correction**:
  - Applies a mathematical rotation matrix to transform the accelerometer data
  - Compensates for the natural angle at which earables sit in the ear
  - Ensures accurate pitch and roll calculations regardless of earable positioning
  - Customizable via the yaw correction setting in preferences

## Troubleshooting

### Connection Issues

- Ensure Bluetooth is enabled on your device
- Verify the eSense earables are charged and powered on
- Double-check the device name in the preferences
- On Android, ensure location permissions are granted (required for Bluetooth scanning)
- Try restarting both the app and the eSense device

### Calibration Issues

- Make sure you're in a comfortable, neutral position when calibrating
- If the indicator seems too sensitive or not sensitive enough, adjust the pitch and roll limits
- If the indicator moves in unexpected directions, try adjusting the yaw correction value

## Privacy

PosturePal processes all data locally on your device. No data is sent to external servers.
