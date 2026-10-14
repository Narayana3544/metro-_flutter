import 'package:flutter/material.dart';

import 'app_sidebar.dart';
import '../screens/wheel_measurements/wheel_measurement_form_screen.dart';
import '../screens/wheel_measurements/wheel_measurement_history_screen.dart';
import '../screens/wheel_measurements/wheel_tolerances_screen.dart';

class WheelMeasurementsNavigationScreen extends StatefulWidget {
  const WheelMeasurementsNavigationScreen({super.key});

  @override
  State<WheelMeasurementsNavigationScreen> createState() =>
      _WheelMeasurementsNavigationScreenState();
}

class _WheelMeasurementsNavigationScreenState
    extends State<WheelMeasurementsNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    WheelMeasurementFormScreen(),
    WheelMeasurementHistoryScreen(),
    WheelTolerancesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AppSidebar(currentModule: 'wheel_measurements'),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: theme.primaryColor,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note_outlined),
            activeIcon: Icon(Icons.edit_note),
            label: 'Record Entry',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_outlined),
            activeIcon: Icon(Icons.verified),
            label: 'Tolerances',
          ),
        ],
      ),
    );
  }
}
