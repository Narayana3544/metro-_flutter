import 'package:flutter/material.dart';
import '../../models/maintenance_bay_model.dart';

class DropdownOption {
  final int value;
  final String label;

  const DropdownOption({required this.value, required this.label});
}

class AmsDropdownField extends StatelessWidget {
  final String label;
  final int value;
  final List<DropdownOption> options;
  final ValueChanged<int?> onChanged;
  final bool isDark;

  const AmsDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        () {
          final seen = <int>{};
          final uniqueOptions = options.where((o) => seen.add(o.value)).toList();
          final effectiveValue = uniqueOptions.any((o) => o.value == value)
              ? value
              : (uniqueOptions.isNotEmpty ? uniqueOptions.first.value : null);

          return DropdownButtonFormField<int>(
            key: ValueKey('${label}_${uniqueOptions.length}_$effectiveValue'),
            value: effectiveValue,
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
            ),
            items: uniqueOptions.map((opt) {
              return DropdownMenuItem<int>(
                value: opt.value,
              child: Text(
                opt.label,
                style: TextStyle(
                  fontSize: 13,
                  color: opt.value == 0
                      ? Colors.grey.shade500
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        );
      }(),
      ],
    );
  }
}

class AmsDateTimePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final bool enabled;
  final VoidCallback? onTap;
  final bool isDark;
  final String Function(DateTime?) formatDisplayDateTime;

  const AmsDateTimePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.enabled,
    required this.onTap,
    required this.isDark,
    required this.formatDisplayDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: enabled
                ? (isDark ? Colors.grey.shade300 : const Color(0xFF475569))
                : Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(6),
          child: InputDecorator(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              suffixIcon: Icon(
                Icons.calendar_today,
                size: 16,
                color: enabled ? const Color(0xFF2563EB) : Colors.grey.shade400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
              ),
            ),
            child: Text(
              value != null ? formatDisplayDateTime(value) : 'Select date & time',
              style: TextStyle(
                fontSize: 13,
                color: enabled
                    ? (isDark ? Colors.white : Colors.black87)
                    : Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Row 1: Depot selection and Bay / Track selection dropdown
class AMSUpdateDepotBayRow extends StatelessWidget {
  final String depot;
  final String track;
  final List<String> bayOptions;
  final bool isDark;
  final ValueChanged<String> onDepotChanged;
  final ValueChanged<String> onTrackChanged;
  final MaintenanceBayModel? Function(String) findBay;

  const AMSUpdateDepotBayRow({
    super.key,
    required this.depot,
    required this.track,
    required this.bayOptions,
    required this.isDark,
    required this.onDepotChanged,
    required this.onTrackChanged,
    required this.findBay,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 650;

        final depotDropdown = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Depot',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              key: ValueKey('depot_$depot'),
              value: (depot == 'Uppal' || depot == 'Miyapur' || depot == 'Select Depot') ? depot : 'Select Depot',
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Select Depot', child: Text('Select Depot')),
                DropdownMenuItem(value: 'Uppal', child: Text('UPPAL')),
                DropdownMenuItem(value: 'Miyapur', child: Text('MIYAPUR')),
              ],
              onChanged: (val) {
                if (val != null) onDepotChanged(val);
              },
            ),
          ],
        );

        final bayDropdown = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bay / Track',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            () {
              final uniqueBays = bayOptions.toSet().toList();
              final effectiveTrack = uniqueBays.contains(track) ? track : null;

              return DropdownButtonFormField<String>(
                key: ValueKey('track_${depot}_${uniqueBays.length}_$effectiveTrack'),
                value: effectiveTrack,
                isExpanded: true,
                hint: Text(
                  depot == 'Select Depot'
                      ? 'Please Select Depot First'
                      : 'Select Bay / Track',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    ),
                  ),
                ),
                items: uniqueBays.map((opt) {
                  final b = findBay(opt);
                  final isAlloc = b != null && b.isAllocated;
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          opt,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isAlloc
                              ? const Color(0xFF10B981).withValues(alpha: 0.15)
                              : Colors.grey.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isAlloc
                              ? (b.trainSetName.isNotEmpty ? b.trainSetName : 'TS-${b.trainSetId}')
                              : 'Empty',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isAlloc ? FontWeight.bold : FontWeight.normal,
                            color: isAlloc ? const Color(0xFF047857) : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onTrackChanged(val);
              },
            );
          }(),
          ],
        );

        if (isNarrow) {
          return Column(
            children: [
              depotDropdown,
              const SizedBox(height: 14),
              bayDropdown,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: depotDropdown),
            const SizedBox(width: 14),
            Expanded(child: bayDropdown),
          ],
        );
      },
    );
  }
}
