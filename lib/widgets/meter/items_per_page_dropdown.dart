import 'package:flutter/material.dart';

class ItemsPerPageDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const ItemsPerPageDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Items",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),

        const SizedBox(width: 6),

        DropdownButtonHideUnderline(
          child: () {
            const allowed = [10, 20, 50, 75, 100];
            final effectiveValue = allowed.contains(value) ? value : allowed.first;
            return DropdownButton<int>(
              value: effectiveValue,
              borderRadius: BorderRadius.circular(10),
              isDense: true,
              items: allowed.map((v) => DropdownMenuItem(value: v, child: Text("$v"))).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            );
          }(),
        ),
      ],
    );
  }
}
