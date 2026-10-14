import 'package:flutter/material.dart';

import 'app_sidebar.dart';

import '../screens/CheckList/work_orders_screen.dart';
import '../screens/CheckList/checklist_screen.dart';
import '../screens/CheckList/work_order_history_screen.dart';

class ChecklistNavigationScreen extends StatefulWidget {
  const ChecklistNavigationScreen({super.key});

  @override
  State<ChecklistNavigationScreen> createState() =>
      _ChecklistNavigationScreenState();
}

class _ChecklistNavigationScreenState extends State<ChecklistNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Widget> screens = [
      const ChecklistScreen(),
      WorkOrdersScreen(
        onSwitchToChecklist: () => setState(() => _currentIndex = 0),
      ),
      const WorkOrderHistoryScreen(),
    ];

    return Scaffold(
      drawer: const AppSidebar(currentModule: 'checklist'),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: theme.primaryColor,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            activeIcon: Icon(Icons.fact_check),
            label: 'Checklists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Work Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
