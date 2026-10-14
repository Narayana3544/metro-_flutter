import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/checklist_provider.dart';

/// Filter bar matching NxAMS Website Config Maintenance > Checklists filters:
/// Category, Jobplan, Checklist, Status, and Search/Reset actions.
class ConfigChecklistFilters extends StatelessWidget {
  const ConfigChecklistFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = context.watch<ChecklistProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _buildCategoryDropdown(context, provider)),
                const SizedBox(width: 8),
                Expanded(child: _buildJobPlanDropdown(context, provider)),
                const SizedBox(width: 8),
                Expanded(child: _buildChecklistDropdown(context, provider)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatusDropdown(context, provider)),
                const SizedBox(width: 12),
                _buildActionButtons(provider),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildCategoryDropdown(context, provider)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildJobPlanDropdown(context, provider)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _buildChecklistDropdown(context, provider)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatusDropdown(context, provider)),
                    const SizedBox(width: 8),
                    _buildActionButtons(provider),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildCategoryDropdown(BuildContext context, ChecklistProvider provider) {
    final categories = provider.categoryItems;
    final availableCodes = <String>['', ...categories.map((c) => c.code)];
    final currentValue = availableCodes.contains(provider.selectedCategory) ? provider.selectedCategory : '';

    return _buildDropdownField(
      context: context,
      label: 'Category',
      value: currentValue,
      items: [
        const DropdownMenuItem<String>(value: '', child: Text('ALL', style: TextStyle(fontWeight: FontWeight.bold))),
        ...categories.map((cat) => DropdownMenuItem<String>(
              value: cat.code,
              child: Text(cat.value, overflow: TextOverflow.ellipsis),
            )),
      ],
      onChanged: (val) => provider.setCategoryFilter(val ?? ''),
    );
  }

  Widget _buildJobPlanDropdown(BuildContext context, ChecklistProvider provider) {
    final jobPlans = provider.jobPlanItems;
    final availableIds = <String>['', ...jobPlans.map((j) => j.jobPlanId.toString())];
    final currentValue = availableIds.contains(provider.selectedJobPlan) ? provider.selectedJobPlan : '';

    return _buildDropdownField(
      context: context,
      label: 'Jobplan',
      value: currentValue,
      items: [
        const DropdownMenuItem<String>(value: '', child: Text('ALL', style: TextStyle(fontWeight: FontWeight.bold))),
        ...jobPlans.map((jp) => DropdownMenuItem<String>(
              value: jp.jobPlanId.toString(),
              child: Text(jp.jobPlanName, overflow: TextOverflow.ellipsis),
            )),
      ],
      onChanged: (val) => provider.setJobPlanFilter(val ?? ''),
    );
  }

  Widget _buildChecklistDropdown(BuildContext context, ChecklistProvider provider) {
    final checklistNames = provider.checklistNameItems;
    final availableNames = <String>['', ...checklistNames.map((c) => c.name)];
    final currentValue = availableNames.contains(provider.selectedChecklistName) ? provider.selectedChecklistName : '';

    return _buildDropdownField(
      context: context,
      label: 'Checklist',
      value: currentValue,
      items: [
        const DropdownMenuItem<String>(value: '', child: Text('ALL', style: TextStyle(fontWeight: FontWeight.bold))),
        ...checklistNames.map((item) => DropdownMenuItem<String>(
              value: item.name,
              child: Text(item.name, overflow: TextOverflow.ellipsis),
            )),
      ],
      onChanged: (val) => provider.setChecklistNameFilter(val ?? ''),
    );
  }

  Widget _buildStatusDropdown(BuildContext context, ChecklistProvider provider) {
    final availableStatuses = ChecklistProvider.statusItems.map((s) => s['code']!).toList();
    final currentValue = availableStatuses.contains(provider.selectedStatus) ? provider.selectedStatus : '';

    return _buildDropdownField(
      context: context,
      label: 'Status',
      value: currentValue,
      items: ChecklistProvider.statusItems.map((s) {
        return DropdownMenuItem<String>(
          value: s['code']!,
          child: Text(s['value']!, style: TextStyle(fontWeight: s['code']!.isEmpty ? FontWeight.bold : FontWeight.w500)),
        );
      }).toList(),
      onChanged: (val) => provider.setStatusFilter(val ?? ''),
    );
  }

  Widget _buildDropdownField({
    required BuildContext context,
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final seen = <String>{};
    final safeItems = items.where((it) => it.value != null && seen.add(it.value!)).toList();
    final effectiveValue = safeItems.any((it) => it.value == value)
        ? value
        : (safeItems.isNotEmpty ? safeItems.first.value : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isDark ? colors.surfaceContainerHighest : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.8)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: effectiveValue,
              icon: Icon(Icons.arrow_drop_down, color: colors.onSurfaceVariant),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.onSurface),
              items: safeItems,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ChecklistProvider provider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCircleButton(
          icon: Icons.search,
          tooltip: 'Search',
          onTap: () => provider.searchConfigChecklists(),
        ),
        const SizedBox(width: 6),
        _buildCircleButton(
          icon: Icons.refresh,
          tooltip: 'Reset',
          onTap: () => provider.resetConfigFilters(),
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF00D25B),
      borderRadius: BorderRadius.circular(20),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
