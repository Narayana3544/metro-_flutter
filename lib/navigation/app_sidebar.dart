import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/sidebar_modules.dart';
import '../providers/login_provider.dart';
import '../screens/auth/login_screen.dart';
import '../widgets/sidebar/sidebar_header.dart';
import '../widgets/sidebar/sidebar_logout.dart';
import '../widgets/sidebar/sidebar_module_tile.dart';

class AppSidebar extends StatelessWidget {
  final String currentModule;

  const AppSidebar({super.key, this.currentModule = "ams"});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header with live user data, avatar, and notification icon
            const SidebarHeader(),

            // Scrollable Modules list (prevents any RenderFlex overflow on small screens)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(18, 16, 18, 6),
                      child: Text(
                        "MODULES",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    ...sidebarModules.map(
                      (module) => SidebarModuleTile(
                        title: module.title,
                        subtitle: module.subtitle,
                        icon: module.icon,
                        color: module.color,
                        selected: currentModule == module.id,
                        onTap: () {
                          if (currentModule != module.id) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => module.pageBuilder()),
                            );
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),

            // Logout pinned at bottom
            SidebarLogout(
              onTap: () async {
                final logout = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Logout"),
                        ),
                      ],
                    );
                  },
                );
                if (!context.mounted) return;

                if (logout == true) {
                  await context.read<LoginProvider>().logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
