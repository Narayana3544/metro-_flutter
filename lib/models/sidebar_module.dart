import 'package:flutter/material.dart';

class SidebarModule {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget Function() pageBuilder;

  const SidebarModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.pageBuilder,
  });

  Widget get page => pageBuilder();
}