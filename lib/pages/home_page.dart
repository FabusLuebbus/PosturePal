import 'package:flutter/material.dart';
import 'package:posture_pal/pages/pitch_roll_visualizer.dart';
import 'package:posture_pal/pages/preferences_page.dart';

/// The main page of the Focus Pocus application.
///
/// The [HomePage] widget serves as the landing page, providing navigation
/// between different sections of the app, such as posture tracking and
/// preferences. It manages the current selected index and displays the
/// corresponding page based on user interaction with the [BottomNavigationBar].
class HomePage extends StatefulWidget {
  /// Creates a [HomePage] widget.
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

/// The state for the [HomePage] widget.
///
/// [HomePageState] manages the current selected index for navigation and
/// builds the UI accordingly. It handles the display of different pages and
/// updates the navigation bar based on user interaction.
class HomePageState extends State<HomePage> {
  /// The currently selected index of the [BottomNavigationBar].
  ///
  /// `0` corresponds to the [PitchRollVisualizer] page, and `1` corresponds
  /// to the [PreferencesPage].
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    /// Determines which page to display based on the [selectedIndex].
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = PitchRollVisualizer();
        break;
      case 1:
        page = PreferencesPage();
        break;
      default:
        throw UnimplementedError("No widget for index $selectedIndex");
    }

    /// The main content area displaying the selected page with a background color
    /// and an animated transition.
    var mainArea = ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Check if the orientation is landscape
          bool isLandscape = constraints.maxWidth > constraints.maxHeight;

          if (isLandscape) {
            // Landscape mode layout
            return Row(
              children: [
                /// Navigation bar on the left side in landscape mode.
                NavigationRail(
                  selectedIndex: selectedIndex,
                  groupAlignment: 0.0,
                  onDestinationSelected: (int index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  destinations: [
                    NavigationRailDestination(
                      icon: Image.asset(
                        "lib/assets/icon_accel.png",
                        width: 30,
                        height: 30,
                        color: colorScheme.onSurface,
                      ),
                      label: Text("Posture Tracking"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(
                        Icons.settings_outlined,
                        size: 30,
                        color: colorScheme.onSurface,
                      ),
                      label: Text("Preferences"),
                    ),
                  ],
                ),

                /// Main content area expands to fill the remaining space.
                Expanded(child: mainArea),
              ],
            );
          } else {
            // Portrait mode layout
            return Column(
              children: [
                /// Expands to fill the available space with the [mainArea].
                Expanded(child: mainArea),

                /// The bottom navigation bar allowing users to switch between pages.
                SafeArea(
                  child: BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Image.asset(
                          "lib/assets/icon_accel.png",
                          width: 30,
                          height: 30,
                          color: colorScheme.onSurface,
                        ),
                        label: "Posture Tracking",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.settings_outlined,
                          size: 30,
                          color: colorScheme.onSurface,
                        ),
                        label: "Preferences",
                      ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
