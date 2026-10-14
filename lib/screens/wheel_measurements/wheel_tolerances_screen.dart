import 'package:flutter/material.dart';
import '../../models/wheel_measurement_model.dart';
import '../../widgets/common/custom_header.dart';
import '../../widgets/wheel_measurements/wheel_tolerance_widgets.dart';

class WheelTolerancesScreen extends StatelessWidget {
  const WheelTolerancesScreen({super.key});

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade700),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          const CustomHeader(
            title: "WHEEL TOLERANCES",
            subtitle: "NxAMS Acceptability Standards & Criteria",
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const WheelStandardsBanner(),
                const SizedBox(height: 16),
                _buildSectionHeader("1. Dimensional Criteria (Per Wheel)", Icons.straighten),
                const SizedBox(height: 8),
                WheelCriteriaCard(
                  title: "Wheel Diameter (Dia)",
                  range: "${WheelTolerances.minDia} - ${WheelTolerances.maxDia} mm",
                  description: "Nominal new wheel: 860.5 mm. Condemning wear limit: 780.0 mm.",
                  color: Colors.blue,
                  icon: Icons.circle_outlined,
                  isDark: isDark,
                ),
                WheelCriteriaCard(
                  title: "Flange Thickness (FT)",
                  range: "${WheelTolerances.minFT} - ${WheelTolerances.maxFT} mm",
                  description: "Safety critical to prevent derailment over switches and turnouts.",
                  color: Colors.teal,
                  icon: Icons.line_weight,
                  isDark: isDark,
                ),
                WheelCriteriaCard(
                  title: "Flange Height (FH)",
                  range: "${WheelTolerances.minFH} - ${WheelTolerances.maxFH} mm",
                  description: "Monitored to prevent flange root interference.",
                  color: Colors.indigo,
                  icon: Icons.height,
                  isDark: isDark,
                ),
                WheelCriteriaCard(
                  title: "QR Dimension",
                  range: "≥ ${WheelTolerances.minQR} mm",
                  description: "Minimum flange gradient dimension to prevent climbing rails.",
                  color: Colors.orange,
                  icon: Icons.trending_up,
                  isDark: isDark,
                ),
                WheelCriteriaCard(
                  title: "Ovality (Out-of-roundness)",
                  range: "≤ ${WheelTolerances.maxOvality} mm",
                  description: "Maximum allowable out-of-roundness deviation on tread.",
                  color: Colors.purple,
                  icon: Icons.blur_circular,
                  isDark: isDark,
                ),
                WheelCriteriaCard(
                  title: "Warp (Axial Runout)",
                  range: "≤ ${WheelTolerances.maxWarp} mm",
                  description: "Lateral face runout tolerance across wheel circumference.",
                  color: Colors.deepPurple,
                  icon: Icons.flip_camera_android,
                  isDark: isDark,
                ),
                WheelCriteriaCard(
                  title: "Distance Internal Flanges (DIF)",
                  range: "${WheelTolerances.minDIF} - ${WheelTolerances.maxDIF} mm",
                  description: "Back-to-back distance measured between inner wheel faces.",
                  color: Colors.brown,
                  icon: Icons.compare_arrows,
                  isDark: isDark,
                ),
                WheelCriteriaCard(
                  title: "Distance Across Flanges (DAF)",
                  range: "${WheelTolerances.minDAF} - ${WheelTolerances.maxDAF} mm",
                  description: "Overall distance across outer flange tips.",
                  color: Colors.blueGrey,
                  icon: Icons.unfold_more,
                  isDark: isDark,
                ),
                const SizedBox(height: 20),
                _buildSectionHeader("2. Differential Wear Acceptability", Icons.difference_outlined),
                const SizedBox(height: 8),
                WheelDiffTable(isDark: isDark),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
