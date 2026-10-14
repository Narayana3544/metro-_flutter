import 'package:flutter/material.dart';
import '../../models/wheel_measurement_model.dart';
export 'wheel_record_detail_sheet.dart';

/// Filter bar for wheel measurement history
class WheelMeasurementFilterBar extends StatelessWidget {
  final String selectedTrainSet;
  final List<String> trainsets;
  final bool isDark;
  final ValueChanged<String> onTrainSetChanged;

  const WheelMeasurementFilterBar({
    super.key,
    required this.selectedTrainSet,
    required this.trainsets,
    required this.isDark,
    required this.onTrainSetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_alt_outlined, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          const Text(
            "Filter:",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: DropdownButtonHideUnderline(
                child: () {
                  final uniqueTrainsets = trainsets.toSet().toList();
                  final target = selectedTrainSet == '0' ? 'All Trainsets' : selectedTrainSet;
                  final effectiveValue = uniqueTrainsets.contains(target)
                      ? target
                      : (uniqueTrainsets.contains('All Trainsets')
                          ? 'All Trainsets'
                          : (uniqueTrainsets.isNotEmpty ? uniqueTrainsets.first : null));

                  return DropdownButton<String>(
                    value: effectiveValue,
                    isExpanded: true,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    items: uniqueTrainsets.map((ts) {
                      return DropdownMenuItem<String>(
                        value: ts,
                        child: Text(ts),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) onTrainSetChanged(val);
                    },
                  );
                }(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card representation of a historical wheel measurement record
class WheelRecordCard extends StatelessWidget {
  final WheelMeasurementListItem record;
  final bool isDark;
  final VoidCallback onTap;

  const WheelRecordCard({
    super.key,
    required this.record,
    required this.isDark,
    required this.onTap,
  });

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade500),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.train, color: Color(0xFF1E3A8A), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        record.tsNumber.isNotEmpty ? record.tsNumber : "TS-00",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade400),
                    ),
                    child: Text(
                      "Avg: ${record.averageDia.toStringAsFixed(2)} mm",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoColumn(
                      "Measured Date",
                      record.measuredDate.isNotEmpty ? record.measuredDate.split('T')[0] : "--",
                      Icons.calendar_today_outlined,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                      "Work Order",
                      record.woNumber.isNotEmpty ? record.woNumber : "--",
                      Icons.assignment_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoColumn(
                      "Purpose / Schedule",
                      record.schedule.isNotEmpty ? record.schedule : "--",
                      Icons.schedule_outlined,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                      "KM Reading",
                      record.kmReading > 0 ? "${record.kmReading.toStringAsFixed(0)} km" : "--",
                      Icons.speed_outlined,
                    ),
                  ),
                ],
              ),
              if (record.remarks.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  "Remarks: ${record.remarks}",
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state when no wheel measurements exist
class WheelHistoryEmptyView extends StatelessWidget {
  const WheelHistoryEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text(
            "No wheel measurements recorded yet",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            "Use the Record Entry tab to submit digital wheel measurements.",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
