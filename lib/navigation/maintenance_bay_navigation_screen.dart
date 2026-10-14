import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/login_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/profile_provider.dart';
import '../screens/maintenance-bay/dashboard_screen.dart';
import '../screens/maintenance-bay/ams_update_screen.dart';
import '../screens/maintenance-bay/history_screen.dart';
import 'app_sidebar.dart';

class MaintenanceBayNavigationScreen extends StatefulWidget {
  const MaintenanceBayNavigationScreen({super.key});

  @override
  State<MaintenanceBayNavigationScreen> createState() =>
      _MaintenanceBayNavigationScreenState();
}

class _MaintenanceBayNavigationScreenState
    extends State<MaintenanceBayNavigationScreen> {
  int currentIndex = 0;
  String currentDepot = 'Uppal';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final login = context.read<LoginProvider>();
      final staffId = login.loginData?.staffId ?? 0;
      if (staffId > 0) {
        context.read<ProfileProvider>().fetchProfile(staffId.toString());
      }
      final userId = login.loginData?.id.toString();
      final unitId = login.loginData?.unitId.toString();
      final roleId = login.selectedRoleId ??
          login.loginData?.roleIds.split(',').firstOrNull?.trim();
      if (userId != null && userId.isNotEmpty && userId != '0') {
        context.read<NotificationProvider>().fetchNotifications(
              unitId: unitId,
              roleId: roleId,
              userId: userId,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        onNavigateToHistory: (depot) {
          setState(() {
            if (depot.isNotEmpty && depot != 'Select Depot') {
              currentDepot = depot;
            }
            currentIndex = 2; // Switch to History tab!
          });
        },
      ),
      const AMSUpdateScreen(),
      HistoryScreen(initialDepot: currentDepot),
    ];

    return Scaffold(
      drawer: const AppSidebar(currentModule: 'ams'),
      body: IndexedStack(index: currentIndex, children: screens),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note),
            label: 'Update',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

/// Backwards compatibility alias
typedef MainNavigationScreen = MaintenanceBayNavigationScreen;
