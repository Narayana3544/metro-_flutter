import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/checklist_provider.dart';
import '../../../models/checklist_model.dart';
import 'add_edit_checklist_fields.dart';

/// Modal dialog to create or edit a Master Checklist matching NxAMS `AddChecklistComponent`
class AddEditChecklistDialog extends StatefulWidget {
  final JobPlanChecklistModel? checklist;

  const AddEditChecklistDialog({super.key, this.checklist});

  static Future<bool?> show(BuildContext context, {JobPlanChecklistModel? checklist}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddEditChecklistDialog(checklist: checklist),
    );
  }

  @override
  State<AddEditChecklistDialog> createState() => _AddEditChecklistDialogState();
}

class _AddEditChecklistDialogState extends State<AddEditChecklistDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _scheduleController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedJobPlanId;
  String? _selectedJobPlanName;
  bool _isActive = true;
  bool _isSubmitting = false;

  bool get isEdit => widget.checklist != null;

  @override
  void initState() {
    super.initState();
    final cl = widget.checklist;
    if (cl != null) {
      _nameController.text = cl.jpcChecklistName;
      _scheduleController.text = cl.scheduleName;
      _selectedCategoryId = cl.jpcCategory?.toString() ?? '';
      _selectedCategoryName = cl.assetCategoryCode;
      _selectedJobPlanId = cl.jobplanId > 0 ? cl.jobplanId.toString() : '';
      _selectedJobPlanName = cl.jobplanName;
      _isActive = cl.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  void _onJobPlanChanged(String? val, List<ChecklistJobPlanItem> jobPlans) {
    setState(() {
      _selectedJobPlanId = val;
      final jp = jobPlans.where((j) => j.jobPlanId.toString() == val).firstOrNull;
      if (jp != null) {
        _selectedJobPlanName = jp.jobPlanName;
        _scheduleController.text = jp.schedule;
      } else {
        _selectedJobPlanName = '';
        _scheduleController.text = '';
      }
    });
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _scheduleController.clear();
      _selectedCategoryId = null;
      _selectedCategoryName = null;
      _selectedJobPlanId = null;
      _selectedJobPlanName = null;
      _isActive = true;
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Category *')),
      );
      return;
    }
    if (_selectedJobPlanId == null || _selectedJobPlanId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Jobplan *')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final provider = context.read<ChecklistProvider>();

    final catId = int.tryParse(_selectedCategoryId!) ?? 0;
    final jpId = int.tryParse(_selectedJobPlanId!) ?? 0;
    final name = _nameController.text.trim();
    final sched = _scheduleController.text.trim().isEmpty ? 'Scheduled PM' : _scheduleController.text.trim();

    final catItem = provider.categoryItems.where((c) => c.code == _selectedCategoryId).firstOrNull;
    final catCode = catItem?.value.isNotEmpty == true ? catItem!.value : (_selectedCategoryName ?? 'RS');

    final success = isEdit
        ? await provider.updateChecklistName(
            jpcId: widget.checklist!.jpcId,
            checklistName: name,
            jobPlanId: jpId,
            jobPlanName: _selectedJobPlanName ?? widget.checklist!.jobplanName,
            categoryId: catId,
            categoryCode: catCode,
            scheduleName: sched,
            isActive: _isActive,
          )
        : await provider.createChecklist(
            jobPlanId: jpId,
            jobPlanName: _selectedJobPlanName ?? 'Inspection',
            checklistName: name,
            categoryId: catId,
            categoryCode: catCode,
            scheduleName: sched,
            isActive: _isActive,
          );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade700,
            content: Text(isEdit ? 'Checklist updated successfully ✓' : 'Checklist Saved Successfully ✓'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error while Saving checklist'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = context.watch<ChecklistProvider>();

    final categories = provider.categoryItems;
    final jobPlans = provider.jobPlanItems;

    // Resolve prefilled Category in edit mode if not yet matched by ID
    if (isEdit && (_selectedCategoryId == null || !categories.any((c) => c.code == _selectedCategoryId))) {
      final match = categories.where((c) =>
        c.code == widget.checklist!.jpcCategory?.toString() ||
        c.value.toLowerCase() == widget.checklist!.assetCategoryCode.toLowerCase()
      ).firstOrNull;
      if (match != null) {
        _selectedCategoryId = match.code;
        _selectedCategoryName = match.value;
      }
    }

    // Resolve prefilled Jobplan in edit mode if not yet matched by ID
    if (isEdit && (_selectedJobPlanId == null || !jobPlans.any((j) => j.jobPlanId.toString() == _selectedJobPlanId))) {
      final match = jobPlans.where((j) =>
        j.jobPlanId == widget.checklist!.jobplanId ||
        j.jobPlanName.toLowerCase() == widget.checklist!.jobplanName.toLowerCase()
      ).firstOrNull;
      if (match != null) {
        _selectedJobPlanId = match.jobPlanId.toString();
        _selectedJobPlanName = match.jobPlanName;
        if (_scheduleController.text.isEmpty) {
          _scheduleController.text = match.schedule;
        }
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.assignment_add, color: colors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isEdit ? 'Edit Checklist' : 'New Checklist Master',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  AddEditChecklistFields(
                    categories: categories,
                    jobPlans: jobPlans,
                    selectedCategoryId: _selectedCategoryId,
                    selectedJobPlanId: _selectedJobPlanId,
                    scheduleController: _scheduleController,
                    nameController: _nameController,
                    isActive: _isActive,
                    onCategoryChanged: (val) {
                      setState(() {
                        _selectedCategoryId = val;
                        final c = categories.where((x) => x.code == val).firstOrNull;
                        _selectedCategoryName = c?.value;
                      });
                    },
                    onJobPlanChanged: (val) => _onJobPlanChanged(val, jobPlans),
                    onActiveChanged: (v) => setState(() => _isActive = v ?? true),
                  ),

                  const SizedBox(height: 20),

                  // Actions: Reset + Save / Update
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Reset'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(color: Colors.red.shade400),
                        ),
                        onPressed: _isSubmitting ? null : _resetForm,
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save, size: 16),
                        label: Text(isEdit ? 'Update' : 'Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D25B),
                          foregroundColor: Colors.white,
                          elevation: 1,
                        ),
                        onPressed: _isSubmitting ? null : _handleSubmit,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
