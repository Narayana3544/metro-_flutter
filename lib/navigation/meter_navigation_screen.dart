import 'package:flutter/material.dart';

import 'app_sidebar.dart';
import '../screens/meter/meter_dashboard_screen.dart';

class MeterNavigationScreen extends StatelessWidget {
  const MeterNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      drawer: AppSidebar(currentModule: 'meter'),
      body: MeterDashboardScreen(),
    );
  }
}
