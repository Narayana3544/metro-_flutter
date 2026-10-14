import 'package:flutter/material.dart';

import '../models/sidebar_module.dart';

import '../navigation/maintenance_bay_navigation_screen.dart';
import '../navigation/wheel_measurements_navigation_screen.dart';
import '../navigation/meter_navigation_screen.dart';
import '../navigation/checklist_navigation_screen.dart';

const List<SidebarModule> sidebarModules = [
  SidebarModule(
    id: 'ams',
    title: 'BAY LAYOUT',
    subtitle: 'Manage train allocation in depot bays',
    icon: Icons.train_rounded,
    color: Colors.blue,
    pageBuilder: MaintenanceBayNavigationScreen.new,
  ),
  SidebarModule(
    id: 'wheel_measurements',
    title: 'WHEEL MEASUREMENT',
    subtitle: 'Digital Wheel Gauge & Profiling',
    icon: Icons.radio_button_checked,
    color: Colors.indigo,
    pageBuilder: WheelMeasurementsNavigationScreen.new,
  ),
  SidebarModule(
    id: 'meter',
    title: 'Meter Module',
    subtitle: 'Energy Monitoring',
    icon: Icons.electric_meter,
    color: Colors.teal,
    pageBuilder: MeterNavigationScreen.new,
  ),
  SidebarModule(
    id: 'checklist',
    title: 'CHECKLIST MODULE',
    subtitle: 'Config Maintenance & Checksheets',
    icon: Icons.fact_check,
    color: Colors.deepOrange,
    pageBuilder: ChecklistNavigationScreen.new,
  ),
];
