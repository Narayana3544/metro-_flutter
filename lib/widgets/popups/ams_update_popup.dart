import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/maintenance_bay_model.dart';
import '../../providers/login_provider.dart';
import '../../providers/maintenance_bay_provider.dart';
import '../../providers/maintenance_purpose_provider.dart';
import '../../providers/status_provider.dart';
import '../../providers/train_provider.dart';

class DropdownOption {
  final int value;
  final String label;

  const DropdownOption({required this.value, required this.label});
}

class AMSUpdatePopup extends StatefulWidget {
  final String initialDepot;
  final String initialTrack;
  final MaintenanceBayModel? existingBay;

  const AMSUpdatePopup({
    super.key,
    required this.initialDepot,
    required this.initialTrack,
    this.existingBay,
  });

  @override
  State<AMSUpdatePopup> createState() => _AMSUpdatePopupState();
}

class _AMSUpdatePopupState extends State<AMSUpdatePopup> {
  late String depot;
  late String track;
  late String line;

  bool hasExistingData = false;
  int existingId = 0;
  int selectedSlot = 1;
  bool isOutward = false;

  int selectedTrainSet = 0;
  int selectedStatus = 0;
  int selectedPurpose = 0;

  DateTime? fromDate;
  DateTime? toDate;

  final TextEditingController remarksController = TextEditingController();

  List<DropdownOption> trainSetOptions = [];
  List<DropdownOption> statusOptions = [];
  List<DropdownOption> purposeOptions = [];

  List<Map<String, dynamic>> allocationHistory = [];
  int selectedHistoryIndex = -1;
  bool isSaving = false;
  bool isLoadingDetails = false;

  final Map<String, int> depotIds = {
    'UPPAL': 633,
    'MIYAPUR': 9373,
    'Uppal': 633,
    'Miyapur': 9373,
  };

  @override
  void initState() {
    super.initState();
    depot = widget.initialDepot;
    track = widget.initialTrack;
    line = _getLineForSlot(track);

    // Initial slot deduction
    final digits = track.replaceAll(RegExp(r'\D'), '');
    selectedSlot = int.tryParse(digits) ?? 1;
    fromDate = DateTime.now();

    // Populate from widget.existingBay or search in provider
    _initFromExistingBay(widget.existingBay);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    remarksController.dispose();
    super.dispose();
  }

  String _getLineForSlot(String slotName) {
    final upper = slotName.toUpperCase();
    if (upper.contains('SBL')) return 'SBL';
    if (upper.contains('IBL')) return 'IBL';
    if (upper.contains('MAIN')) return 'MAIN';
    if (upper.contains('PW')) return 'PW';
    if (upper.contains('WP')) return 'WP';
    if (upper.contains('WL')) return 'WL';
    if (upper.contains('TT')) return 'TT';
    return upper.replaceAll(RegExp(r'[^A-Z]'), '');
  }

  void _initFromExistingBay(MaintenanceBayModel? bay) {
    if (bay == null) {
      final bayProvider = context.read<MaintenanceBayProvider>();
      bay = bayProvider.findBayForMarker(track);
    }

    if (bay != null) {
      existingId = bay.id;
      if (bay.slot > 0) {
        selectedSlot = bay.slot;
      }

      final hasData = bay.trainSetId > 0 || bay.trainSetName.isNotEmpty || bay.isAllocated;
      hasExistingData = hasData;

      if (hasData) {
        selectedTrainSet = bay.trainSetId;
        selectedStatus = bay.statusId;
        selectedPurpose = bay.purposeId;

        if (bay.inward.isNotEmpty) {
          fromDate = DateTime.tryParse(bay.inward) ?? DateTime.now();
        }
        if (bay.outward.isNotEmpty) {
          toDate = DateTime.tryParse(bay.outward);
        }
        isOutward = bay.isOutward;
        remarksController.text = bay.remark;
      }
    }
  }

  void _loadInitialData() {
    final loginData = context.read<LoginProvider>().loginData;
    final roleId = context.read<LoginProvider>().selectedRoleId ??
        loginData?.roleIds.split(',').first.trim() ??
        '1';

    // 1. Fetch statuses
    context.read<StatusProvider>().fetchStatuses();

    // 2. Fetch purposes
    context.read<MaintenancePurposeProvider>().fetchMaintenancePurposes();

    // 3. Fetch trainsets
    context.read<TrainProvider>().fetchTrainSets(
          token: loginData?.token,
          userSession: loginData?.encodedUserSession,
          roleId: roleId,
        );

    // 4. If existing ID available, fetch full detail including allocation history
    if (existingId > 0) {
      _fetchBayDetails(existingId);
    } else {
      // Check if provider has latest bay info
      final bayProvider = context.read<MaintenanceBayProvider>();
      final found = bayProvider.findBayForMarker(track);
      if (found != null && found.id > 0) {
        existingId = found.id;
        _initFromExistingBay(found);
        _fetchBayDetails(found.id);
      }
    }
  }

  Future<void> _fetchBayDetails(int mbId) async {
    setState(() => isLoadingDetails = true);
    try {
      final bayProvider = context.read<MaintenanceBayProvider>();
      final data = await bayProvider.repository.getMaintenanceBayById(mbId);

      if (!mounted) return;

      final dynamic resObj = data.containsKey('response') ? data['response'] : data;
      Map<String, dynamic>? detail;
      if (resObj is Map<String, dynamic>) {
        detail = resObj['maintenanceBay'] is Map<String, dynamic>
            ? resObj['maintenanceBay'] as Map<String, dynamic>
            : (resObj['data'] is Map<String, dynamic>
                ? resObj['data'] as Map<String, dynamic>
                : resObj);
      } else if (resObj is List && resObj.isNotEmpty && resObj.first is Map<String, dynamic>) {
        detail = resObj.first as Map<String, dynamic>;
      }

      if (detail != null) {
        final allocations = detail['allocations'] ??
            detail['Allocations'] ??
            detail['mbaAllocations'] ??
            detail['mba_allocations'] ??
            [];

        if (allocations is List) {
          allocationHistory = allocations.whereType<Map<String, dynamic>>().toList();
        }

        // Also refresh slot & existing values if needed
        final rawTrainSet = detail['mb_train_set'] ?? detail['mbTrainSet'] ?? detail['trainSet'] ?? 0;
        final trainSetVal = int.tryParse('$rawTrainSet') ?? 0;

        if (trainSetVal > 0) {
          hasExistingData = true;
          selectedTrainSet = trainSetVal;

          final rawStatus = detail['mb_status'] ?? detail['mbStatus'] ?? detail['status'] ?? 0;
          selectedStatus = int.tryParse('$rawStatus') ?? selectedStatus;

          final rawPurpose = detail['mb_purpose'] ?? detail['mbPurpose'] ?? detail['purpose'] ?? 0;
          selectedPurpose = int.tryParse('$rawPurpose') ?? selectedPurpose;

          final rawInward = detail['mb_inward'] ?? detail['mbInward'] ?? detail['fromDate'] ?? '';
          if (rawInward.toString().isNotEmpty) {
            fromDate = DateTime.tryParse(rawInward.toString()) ?? fromDate;
          }

          final rawOutward = detail['mb_outward'] ?? detail['mbOutward'] ?? detail['toDate'] ?? '';
          if (rawOutward.toString().isNotEmpty) {
            toDate = DateTime.tryParse(rawOutward.toString()) ?? toDate;
          }

          final rawIsOutward = detail['isOutward'] ?? detail['mb_isOutward'] ?? detail['mbIsOutward'];
          if (rawIsOutward != null) {
            isOutward = rawIsOutward == true || rawIsOutward == 'true' || rawIsOutward == 1;
          }

          final rawRemarks = detail['mb_remark'] ?? detail['mbRemark'] ?? detail['remarks'] ?? '';
          if (rawRemarks.toString().isNotEmpty && remarksController.text.isEmpty) {
            remarksController.text = rawRemarks.toString();
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching bay details: $e');
    } finally {
      if (mounted) setState(() => isLoadingDetails = false);
    }
  }

  List<Map<String, dynamic>> get futureAllocations {
    final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final future = allocationHistory.where((a) {
      final allocOn = a['mbaAllocatedOn'] ?? a['mba_allocated_on'] ?? a['createdOn'] ?? '';
      if (allocOn.toString().isEmpty) return false;
      final dt = DateTime.tryParse(allocOn.toString());
      return dt != null && !dt.isBefore(todayStart);
    }).toList();

    return future.isNotEmpty ? future : allocationHistory;
  }

  String get currentTrainSetName {
    if (selectedTrainSet == 0) return '';
    final opt = trainSetOptions.where((o) => o.value == selectedTrainSet);
    return opt.isNotEmpty ? opt.first.label : 'TS-$selectedTrainSet';
  }

  void _onAssignFromHistory(Map<String, dynamic> allocation, int index) {
    if (selectedTrainSet > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please remove "$currentTrainSetName" first then Assign'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final tsVal = int.tryParse('${allocation['mbaTrainSet'] ?? allocation['mba_train_set'] ?? 0}') ?? 0;
    final statusVal = int.tryParse('${allocation['mbaStatus'] ?? allocation['mba_status'] ?? 0}') ?? 0;
    final purposeVal = int.tryParse('${allocation['mbaPurpose'] ?? allocation['mba_purpose'] ?? 0}') ?? 0;
    final allocOnStr = '${allocation['mbaAllocatedOn'] ?? allocation['mba_allocated_on'] ?? ''}';
    final remarks = '${allocation['mbaRemarks'] ?? allocation['mba_remarks'] ?? ''}';

    setState(() {
      selectedHistoryIndex = index;
      selectedTrainSet = tsVal;
      selectedStatus = statusVal;
      selectedPurpose = purposeVal;
      if (allocOnStr.isNotEmpty) {
        fromDate = DateTime.tryParse(allocOnStr) ?? DateTime.now();
      }
      remarksController.text = remarks;
    });
  }

  String _formatToLocalIso(DateTime dt) {
    final yyyy = dt.year.toString().padLeft(4, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$yyyy-$mm-${dd}T$hh:$min:00';
  }

  String _formatDisplayDateTime(DateTime? dt) {
    if (dt == null) return '';
    final yyyy = dt.year.toString().padLeft(4, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$dd-$mm-$yyyy $hh:$min';
  }

  Future<DateTime?> _pickDateTime(DateTime initial, {DateTime? minDate}) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(minDate ?? DateTime(2020)) ? (minDate ?? DateTime(2020)) : initial,
      firstDate: minDate ?? DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (pickedDate == null || !mounted) return null;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial.hour, minute: initial.minute),
    );
    if (pickedTime == null || !mounted) return null;

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  Future<void> _handleSave() async {
    if (selectedTrainSet == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a Train Set.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (selectedStatus == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a Status.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (selectedPurpose == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a Purpose.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final depotUpper = depot.toUpperCase();
    final depotId = depotIds[depotUpper] ?? (depotUpper == 'UPPAL' ? 633 : 9373);

    // CRITICAL: mbId is existingId (0 for empty, existing DB id for update).
    // NEVER derive MbId from slot or button label!
    final mbId = existingId;
    final userId = context.read<LoginProvider>().loginData?.id ?? 1;

    final inwardDate = _formatToLocalIso(fromDate ?? DateTime.now());
    final outwardDate = (hasExistingData && toDate != null) ? _formatToLocalIso(toDate!) : '';

    setState(() => isSaving = true);

    final bayProvider = context.read<MaintenanceBayProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final success = await bayProvider.saveMaintenanceBay(
        mbId: mbId,
        mbDepot: depotId,
        mbSlot: selectedSlot,
        mbTrainSet: selectedTrainSet,
        mbStatus: selectedStatus,
        mbPurpose: selectedPurpose,
        mbInward: inwardDate,
        mbOutward: outwardDate,
        mbRemark: remarksController.text.trim(),
        isOutward: hasExistingData ? isOutward : false,
        userId: userId,
      );

      if (!mounted) return;

      if (success) {
        final trainOpt = trainSetOptions.where((o) => o.value == selectedTrainSet);
        final tsName = trainOpt.isNotEmpty ? trainOpt.first.label : 'TS-$selectedTrainSet';
        final statusOpt = statusOptions.where((o) => o.value == selectedStatus);
        final stName = statusOpt.isNotEmpty ? statusOpt.first.label : '';
        final purposeOpt = purposeOptions.where((o) => o.value == selectedPurpose);
        final prName = purposeOpt.isNotEmpty ? purposeOpt.first.label : '';

        // Update local provider immediately so CAD map & table reflect without delay
        bayProvider.setOrUpdateBayAllocation(
          markerOrSlotName: track,
          depotId: depotId,
          slot: selectedSlot,
          trainSetId: selectedTrainSet,
          trainSetName: tsName,
          statusId: selectedStatus,
          statusName: stName,
          purposeId: selectedPurpose,
          purposeName: prName,
          inward: inwardDate,
          outward: outwardDate,
          remark: remarksController.text.trim(),
          isOutward: hasExistingData ? isOutward : false,
          id: mbId,
        );

        // Refresh live bays immediately from backend
        bayProvider.fetchMaintenanceBay(depotId);

        messenger.showSnackBar(
          const SnackBar(
            content: Text('Maintenance bay allocation saved successfully.'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
        navigator.pop('saved');
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Failed to save maintenance bay allocation.'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('An error occurred while saving allocation: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final trainProvider = context.watch<TrainProvider>();
    final statusProvider = context.watch<StatusProvider>();
    final purposeProvider = context.watch<MaintenancePurposeProvider>();

    // Build Train Set Options
    final seenTs = <int>{0};
    trainSetOptions = [
      const DropdownOption(value: 0, label: 'Select Train Set'),
    ];
    for (final t in trainProvider.trainSets) {
      if (t.id > 0 && seenTs.add(t.id)) {
        trainSetOptions.add(DropdownOption(value: t.id, label: t.no.isNotEmpty ? t.no : 'TS-${t.id}'));
      }
    }
    if (selectedTrainSet > 0 && seenTs.add(selectedTrainSet)) {
      trainSetOptions.add(DropdownOption(value: selectedTrainSet, label: 'TS-$selectedTrainSet'));
    }

    // Build Status Options
    final seenSt = <int>{0};
    statusOptions = [
      const DropdownOption(value: 0, label: 'Select Status'),
    ];
    for (final s in statusProvider.statuses) {
      if (s.id > 0 && seenSt.add(s.id)) {
        statusOptions.add(DropdownOption(value: s.id, label: s.name.isNotEmpty ? s.name : 'Status ${s.id}'));
      }
    }
    if (selectedStatus > 0 && seenSt.add(selectedStatus)) {
      statusOptions.add(DropdownOption(value: selectedStatus, label: 'Status $selectedStatus'));
    }

    // Build Purpose Options
    final seenPr = <int>{0};
    purposeOptions = [
      const DropdownOption(value: 0, label: 'Select Purpose'),
    ];
    for (final p in purposeProvider.purposes) {
      if (p.id > 0 && seenPr.add(p.id)) {
        purposeOptions.add(DropdownOption(value: p.id, label: p.name.isNotEmpty ? p.name : 'Purpose ${p.id}'));
      }
    }
    if (selectedPurpose > 0 && seenPr.add(selectedPurpose)) {
      purposeOptions.add(DropdownOption(value: selectedPurpose, label: 'Purpose $selectedPurpose'));
    }

    final isSaveDisabled = isSaving || selectedTrainSet == 0 || selectedStatus == 0 || selectedPurpose == 0;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 820),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header (NxAMS Style) ──────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Selected - $track ---Bay Selection',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    splashRadius: 20,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const Divider(height: 18),

              // ── Subheader Info Row (Line & Status) ─────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
                      ),
                      children: [
                        const TextSpan(text: 'Line: '),
                        TextSpan(
                          text: '$line Line',
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
                      ),
                      children: [
                        const TextSpan(text: 'Status: '),
                        TextSpan(
                          text: hasExistingData ? 'Edit Details' : 'Empty',
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Form Content ──────────────────────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Row 1: Train Set, Status, Purpose
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 650;
                          final trainSetField = _buildDropdown(
                            label: 'Train Set',
                            value: selectedTrainSet,
                            options: trainSetOptions,
                            onChanged: (val) {
                              setState(() => selectedTrainSet = val ?? 0);
                            },
                          );

                          final statusField = _buildDropdown(
                            label: 'Status',
                            value: selectedStatus,
                            options: statusOptions,
                            onChanged: (val) {
                              setState(() => selectedStatus = val ?? 0);
                            },
                          );

                          final purposeField = _buildDropdown(
                            label: 'Purpose',
                            value: selectedPurpose,
                            options: purposeOptions,
                            onChanged: (val) {
                              setState(() => selectedPurpose = val ?? 0);
                            },
                          );

                          if (isNarrow) {
                            return Column(
                              children: [
                                trainSetField,
                                const SizedBox(height: 12),
                                statusField,
                                const SizedBox(height: 12),
                                purposeField,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(child: trainSetField),
                              const SizedBox(width: 14),
                              Expanded(child: statusField),
                              const SizedBox(width: 14),
                              Expanded(child: purposeField),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 14),

                      // Row 2: From Date, To Date, Outward Checkbox
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 650;

                          final fromDateField = _buildDatePicker(
                            label: 'From Date *',
                            value: fromDate,
                            enabled: true,
                            onTap: () async {
                              final dt = await _pickDateTime(fromDate ?? DateTime.now());
                              if (dt != null) setState(() => fromDate = dt);
                            },
                          );

                          final toDateField = _buildDatePicker(
                            label: 'To Date',
                            value: toDate,
                            enabled: hasExistingData,
                            onTap: hasExistingData
                                ? () async {
                                    final dt = await _pickDateTime(
                                      toDate ?? fromDate ?? DateTime.now(),
                                      minDate: fromDate,
                                    );
                                    if (dt != null) setState(() => toDate = dt);
                                  }
                                : null,
                          );

                          final outwardCheckbox = Padding(
                            padding: const EdgeInsets.only(top: 22),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: isOutward,
                                  onChanged: hasExistingData
                                      ? (val) => setState(() => isOutward = val ?? false)
                                      : null,
                                ),
                                Text(
                                  'Outward',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: hasExistingData
                                        ? (isDark ? Colors.white : const Color(0xFF475569))
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (isNarrow) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                fromDateField,
                                const SizedBox(height: 12),
                                toDateField,
                                const SizedBox(height: 4),
                                outwardCheckbox,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: fromDateField),
                              const SizedBox(width: 14),
                              Expanded(child: toDateField),
                              const SizedBox(width: 14),
                              outwardCheckbox,
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 14),

                      // Row 3: Remarks
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Remarks',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: remarksController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Remarks',
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                              contentPadding: const EdgeInsets.all(12),
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
                          ),
                        ],
                      ),

                      // ── Allocation History Section (NxAMS Style) ──────────────
                      if (futureAllocations.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildAllocationHistorySection(isDark),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Dialog Actions (NxAMS Footer: Cancel & Save) ──────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel Button (btn-outline-danger style)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFDC2626)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),

                  const SizedBox(width: 12),

                  // Save Button (btn-success style)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF10B981).withValues(alpha: 0.5),
                      disabledForegroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      elevation: 2,
                    ),
                    onPressed: isSaveDisabled ? null : _handleSave,
                    icon: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save, size: 16),
                    label: Text(
                      isSaving ? 'Saving...' : 'Save',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required int value,
    required List<DropdownOption> options,
    required ValueChanged<int?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final seen = <int>{};
    final uniqueOptions = options.where((o) => seen.add(o.value)).toList();
    final effectiveValue = uniqueOptions.any((o) => o.value == value)
        ? value
        : (uniqueOptions.isNotEmpty ? uniqueOptions.first.value : null);

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
        DropdownButtonFormField<int>(
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
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required bool enabled,
    required VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              value != null ? _formatDisplayDateTime(value) : 'Select date & time',
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

  Widget _buildAllocationHistorySection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.3) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(6),
            border: const Border(
              left: BorderSide(color: Color(0xFF2563EB), width: 4),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.history, size: 16, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              const Text(
                'Allocation History',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${futureAllocations.length}',
                  style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          constraints: const BoxConstraints(maxHeight: 180),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 36,
                dataRowMinHeight: 36,
                dataRowMaxHeight: 42,
                columns: const [
                  DataColumn(label: Text('Train Set', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Purpose', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Allocated On', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                ],
                rows: futureAllocations.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;

                  final tsName = item['mbaTrainSetName'] ?? item['mba_train_set_name'] ?? '—';
                  final stName = item['mbaStatusName'] ?? item['mba_status_name'] ?? '—';
                  final prName = item['mbaPurposeName'] ?? item['mba_purpose_name'] ?? '—';
                  final allocOn = item['mbaAllocatedOn'] ?? item['mba_allocated_on'] ?? '—';
                  final remarks = item['mbaRemarks'] ?? item['mba_remarks'] ?? '—';

                  final isAssigned = selectedHistoryIndex == idx;

                  return DataRow(
                    selected: isAssigned,
                    cells: [
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$tsName',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                      ),
                      DataCell(Text('$stName', style: const TextStyle(fontSize: 12))),
                      DataCell(Text('$prName', style: const TextStyle(fontSize: 12))),
                      DataCell(Text('$allocOn', style: const TextStyle(fontSize: 12))),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: Text(
                            '$remarks',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      DataCell(
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedTrainSet > 0
                                ? Colors.grey.shade400
                                : const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () => _onAssignFromHistory(item, idx),
                          icon: const Icon(Icons.arrow_downward, size: 12),
                          label: const Text('Assign', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
