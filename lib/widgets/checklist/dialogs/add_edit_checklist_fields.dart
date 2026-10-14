import 'package:flutter/material.dart';
import '../../../models/checklist_model.dart';

/// Form fields for Add/Edit Checklist Master dialog
class AddEditChecklistFields extends StatelessWidget {
  final List<ChecklistCategoryItem> categories;
  final List<ChecklistJobPlanItem> jobPlans;
  final String? selectedCategoryId;
  final String? selectedJobPlanId;
  final TextEditingController scheduleController;
  final TextEditingController nameController;
  final bool isActive;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onJobPlanChanged;
  final ValueChanged<bool?> onActiveChanged;

  const AddEditChecklistFields({
    super.key,
    required this.categories,
    required this.jobPlans,
    required this.selectedCategoryId,
    required this.selectedJobPlanId,
    required this.scheduleController,
    required this.nameController,
    required this.isActive,
    required this.onCategoryChanged,
    required this.onJobPlanChanged,
    required this.onActiveChanged,
  });

  Widget _buildLabel(BuildContext context, String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        children: [
          TextSpan(text: label),
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  BoxDecoration _inputBoxDeco(ColorScheme colors, bool isDark) {
    return BoxDecoration(
      color: isDark ? colors.surfaceContainerHighest : Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Category *
        _buildLabel(context, 'Category', isRequired: true),
        const SizedBox(height: 6),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: _inputBoxDeco(colors, isDark),
          child: DropdownButtonHideUnderline(
            child: () {
              final seenCat = <String>{};
              final uniqueCats = categories.where((c) => seenCat.add(c.code)).toList();
              final isValValid = uniqueCats.any((c) => c.code == selectedCategoryId);
              return DropdownButton<String>(
                isExpanded: true,
                value: isValValid ? selectedCategoryId : null,
                hint: Text('Select Category', style: TextStyle(color: colors.outline, fontSize: 13)),
                items: uniqueCats.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat.code,
                    child: Text(cat.value, style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
                onChanged: onCategoryChanged,
              );
            }(),
          ),
        ),

        const SizedBox(height: 14),

        // 2. Jobplan *
        _buildLabel(context, 'Jobplan', isRequired: true),
        const SizedBox(height: 6),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: _inputBoxDeco(colors, isDark),
          child: DropdownButtonHideUnderline(
            child: () {
              final seenJp = <String>{};
              final uniqueJps = jobPlans.where((j) => seenJp.add(j.jobPlanId.toString())).toList();
              final isValValid = uniqueJps.any((j) => j.jobPlanId.toString() == selectedJobPlanId);
              return DropdownButton<String>(
                isExpanded: true,
                value: isValValid ? selectedJobPlanId : null,
                hint: Text('Select Jobplan', style: TextStyle(color: colors.outline, fontSize: 13)),
                items: uniqueJps.map((jp) {
                  return DropdownMenuItem<String>(
                    value: jp.jobPlanId.toString(),
                    child: Text(jp.jobPlanName, style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
                onChanged: onJobPlanChanged,
              );
            }(),
          ),
        ),

        const SizedBox(height: 14),

        // 3. Schedule *
        _buildLabel(context, 'Schedule', isRequired: true),
        const SizedBox(height: 6),
        TextFormField(
          controller: scheduleController,
          readOnly: true,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? colors.surfaceContainer : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            hintText: 'Select Jobplan to autofill schedule',
          ),
        ),

        const SizedBox(height: 14),

        // 4. Checklist Name *
        _buildLabel(context, 'Checklist Name', isRequired: true),
        const SizedBox(height: 6),
        TextFormField(
          controller: nameController,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            hintText: 'Enter CheckList Name',
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Checklist Name is required';
            }
            return null;
          },
        ),

        const SizedBox(height: 14),

        // 5. Active Checkbox
        Row(
          children: [
            Checkbox(
              value: isActive,
              activeColor: const Color(0xFF00D25B),
              onChanged: onActiveChanged,
            ),
            const Text(
              'Active',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
