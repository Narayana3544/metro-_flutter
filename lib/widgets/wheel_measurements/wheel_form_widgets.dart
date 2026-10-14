import 'package:flutter/material.dart';
import '../../models/wheel_measurement_model.dart';

/// Top header bar for TrainSet selection and KM Reading input
class WheelFormHeaderBar extends StatelessWidget {
  final String selectedTrainSet;
  final List<String> trainsets;
  final TextEditingController kmReadingController;
  final bool isDark;
  final ValueChanged<String?> onTrainSetChanged;

  const WheelFormHeaderBar({
    super.key,
    required this.selectedTrainSet,
    required this.trainsets,
    required this.kmReadingController,
    required this.isDark,
    required this.onTrainSetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                const Icon(Icons.train_outlined, color: Colors.blue, size: 20),
                const SizedBox(width: 6),
                const Text("TrainSet: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: () {
                        final uniqueTrainsets = trainsets.toSet().toList();
                        final effectiveValue = uniqueTrainsets.contains(selectedTrainSet)
                            ? selectedTrainSet
                            : (uniqueTrainsets.isNotEmpty ? uniqueTrainsets.first : null);

                        return DropdownButton<String>(
                          value: effectiveValue,
                          isDense: true,
                          isExpanded: true,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          items: uniqueTrainsets.map((ts) {
                            return DropdownMenuItem<String>(value: ts, child: Text(ts));
                          }).toList(),
                          onChanged: onTrainSetChanged,
                        );
                      }(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const Icon(Icons.speed, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: kmReadingController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      labelText: "KM Reading",
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Car summary stats card highlighting allowable and actual differential variance
class CarSummaryStatsCard extends StatelessWidget {
  final CarItem car;
  final bool isDark;

  const CarSummaryStatsCard({
    super.key,
    required this.car,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final allWheels = car.wheelSets.expand((ws) => ws.wheels).toList();
    final dias = allWheels.map((w) => w.dia).whereType<double>().toList();

    double maxCarDiff = 0.0;
    if (dias.isNotEmpty) {
      final minDia = dias.reduce((a, b) => a < b ? a : b);
      final maxDia = dias.reduce((a, b) => a > b ? a : b);
      maxCarDiff = maxDia - minDia;
    }

    final isMotor = car.carType != "TC CAR";
    final maxAllowedCarDiff = isMotor
        ? WheelTolerances.maxSameCarMotorDiff
        : WheelTolerances.maxSameCarTrailerDiff;
    final isCarDiffViolated = maxCarDiff > maxAllowedCarDiff;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: isCarDiffViolated
          ? (isDark ? const Color(0xFF451A1A) : const Color(0xFFFEE2E2))
          : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${car.carNum} Differential Dia Variance",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  "Allowed limit: ≤ ${maxAllowedCarDiff.toStringAsFixed(1)} mm (${isMotor ? 'Motor' : 'Trailer'})",
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isCarDiffViolated ? Colors.red : Colors.green.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${maxCarDiff.toStringAsFixed(2)} mm ${isCarDiffViolated ? '⚠️ EXCEEDED' : '✓ OK'}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom persistent bar for Save Draft and Submit to NxAMS
class WheelFormBottomBar extends StatelessWidget {
  final bool isSaving;
  final bool isDark;
  final VoidCallback onSaveDraft;
  final VoidCallback onSubmit;

  const WheelFormBottomBar({
    super.key,
    required this.isSaving,
    required this.isDark,
    required this.onSaveDraft,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isSaving ? null : onSaveDraft,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text("Save Draft"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : onSubmit,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.cloud_upload_outlined, size: 18),
                label: Text(isSaving ? "Syncing..." : "Submit to NxAMS"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper modal sheet for quick tolerance rules reference
class QuickToleranceModal {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "NxAMS Wheel Tolerance Limits",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              _buildModalRow("Diameter (Dia)", "780.0 - 860.5 mm"),
              _buildModalRow("Flange Thickness (FT)", "25.0 - 33.0 mm"),
              _buildModalRow("Flange Height (FH)", "28.0 - 36.0 mm"),
              _buildModalRow("QR Dimension", "≥ 6.5 mm"),
              _buildModalRow("Ovality", "≤ 0.5 mm"),
              _buildModalRow("Warp", "≤ 1.0 mm"),
              _buildModalRow("Within Same Axle", "≤ 1.0 mm"),
              _buildModalRow("Within Same Bogie (Motor / Trailer)", "≤ 3.0 mm / ≤ 6.0 mm"),
              _buildModalRow("Within Same Car (Motor / Trailer)", "≤ 6.0 mm / ≤ 13.0 mm"),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Got it"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildModalRow(String name, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
