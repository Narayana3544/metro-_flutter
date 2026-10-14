import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/active_trains_provider.dart';
import '../../providers/login_provider.dart';
import '../../providers/maintenance_bay_provider.dart';
import '../../providers/maintenance_purpose_provider.dart';
import '../../providers/status_provider.dart';
import '../../providers/train_provider.dart';
import '../../widgets/common/custom_header.dart';
import '../../widgets/common/responsive_container.dart';
import '../../widgets/maintenance-bay/ams_update_card.dart';
import '../../widgets/maintenance-bay/ams_update_controller.dart';
import '../../widgets/maintenance-bay/ams_update_form_rows.dart';

class AMSUpdateScreen extends StatefulWidget {
  const AMSUpdateScreen({super.key});

  @override
  State<AMSUpdateScreen> createState() => _AMSUpdateScreenState();
}

class _AMSUpdateScreenState extends State<AMSUpdateScreen> {
  String depot = 'Select Depot', track = '', line = '';
  bool hasExistingData = false, isOutward = false, isSaving = false;
  int selectedMbId = 0, selectedSlotId = 1, selectedHistoryIndex = -1;
  int selectedTrainSet = 0, selectedStatus = 0, selectedPurpose = 0;
  DateTime? fromDate = DateTime.now(), toDate;
  final TextEditingController remarksController = TextEditingController();
  List<DropdownOption> trainSetOptions = [], statusOptions = [], purposeOptions = [];
  List<Map<String, dynamic>> allocationHistory = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ld = context.read<LoginProvider>().loginData;
      final roleId = context.read<LoginProvider>().selectedRoleId ?? ld?.roleIds.split(',').first.trim() ?? '1';
      context.read<StatusProvider>().fetchStatuses();
      context.read<MaintenancePurposeProvider>().fetchMaintenancePurposes();
      context.read<TrainProvider>().fetchTrainSets(token: ld?.token, userSession: ld?.encodedUserSession, roleId: roleId);
      if (depot != 'Select Depot') {
        context.read<MaintenanceBayProvider>().fetchMaintenanceBay(AmsUpdateService.depotIds[depot] ?? 633);
      }
    });
  }

  @override
  void dispose() {
    remarksController.dispose();
    super.dispose();
  }

  void _onDepotChanged(String newDepot) {
    setState(() {
      depot = newDepot;
      _clearForm();
    });
    if (newDepot != 'Select Depot') {
      context.read<MaintenanceBayProvider>().fetchMaintenanceBay(AmsUpdateService.depotIds[newDepot] ?? 633);
    }
  }

  void _onTrackChanged(String newTrack) {
    final bay = context.read<MaintenanceBayProvider>().findBayForMarker(newTrack);
    final fallbackSlot = int.tryParse(newTrack.replaceAll(RegExp(r'\D'), '')) ?? 1;

    setState(() {
      track = newTrack;
      line = AmsUpdateService.getLineForSlot(newTrack);
      selectedHistoryIndex = -1;
      allocationHistory = [];
      if (bay != null) {
        selectedMbId = bay.id;
        selectedSlotId = bay.slot > 0 ? bay.slot : fallbackSlot;
        hasExistingData = bay.trainSetId > 0 || bay.trainSetName.isNotEmpty || bay.isAllocated;
        if (hasExistingData) {
          selectedTrainSet = bay.trainSetId;
          selectedStatus = bay.statusId;
          selectedPurpose = bay.purposeId;
          fromDate = bay.inward.isNotEmpty ? (DateTime.tryParse(bay.inward) ?? DateTime.now()) : DateTime.now();
          toDate = bay.outward.isNotEmpty ? DateTime.tryParse(bay.outward) : null;
          isOutward = bay.isOutward;
          remarksController.text = bay.remark;
        } else {
          _resetFields(fallbackSlot);
        }
      } else {
        selectedMbId = 0;
        _resetFields(fallbackSlot);
      }
    });

    if (bay != null && bay.id > 0) _loadBayDetails(bay.id);
  }

  void _resetFields(int fallbackSlot) {
    selectedSlotId = fallbackSlot;
    hasExistingData = false;
    selectedTrainSet = 0;
    selectedStatus = 0;
    selectedPurpose = 0;
    fromDate = DateTime.now();
    toDate = null;
    isOutward = false;
    remarksController.clear();
  }

  Future<void> _loadBayDetails(int mbId) async {
    final parsed = await AmsUpdateService.fetchParsedBayDetails(mbId, context.read<MaintenanceBayProvider>());
    if (!mounted || parsed == null) return;
    setState(() {
      allocationHistory = parsed.allocations;
      if (parsed.trainSet != null) {
        hasExistingData = true;
        selectedTrainSet = parsed.trainSet!;
        selectedStatus = parsed.status ?? selectedStatus;
        selectedPurpose = parsed.purpose ?? selectedPurpose;
        if (parsed.inward != null) fromDate = parsed.inward;
        if (parsed.outward != null) toDate = parsed.outward;
        if (parsed.isOutward != null) isOutward = parsed.isOutward!;
        if (parsed.remarks != null && remarksController.text.isEmpty) remarksController.text = parsed.remarks!;
      }
    });
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

  void _onAssignFromHistory(Map<String, dynamic> alloc, int index) {
    if (selectedTrainSet > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please remove current Train Set first then Assign'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() {
      selectedHistoryIndex = index;
      selectedTrainSet = int.tryParse('${alloc['mbaTrainSet'] ?? 0}') ?? 0;
      selectedStatus = int.tryParse('${alloc['mbaStatus'] ?? 0}') ?? 0;
      selectedPurpose = int.tryParse('${alloc['mbaPurpose'] ?? 0}') ?? 0;
      final allocOnStr = '${alloc['mbaAllocatedOn'] ?? ''}';
      if (allocOnStr.isNotEmpty) fromDate = DateTime.tryParse(allocOnStr) ?? DateTime.now();
      remarksController.text = '${alloc['mbaRemarks'] ?? ''}';
    });
  }

  void _clearForm() {
    setState(() {
      track = '';
      line = '';
      _resetFields(1);
      selectedMbId = 0;
      allocationHistory = [];
      selectedHistoryIndex = -1;
    });
  }

  Future<void> _handleSave() async {
    if (depot == 'Select Depot' || depot.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Depot first.'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (track.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Bay / Track.'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (selectedTrainSet == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Train Set.'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (selectedStatus == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Maintenance Status.'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (selectedPurpose == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Maintenance Purpose.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    final bayProvider = context.read<MaintenanceBayProvider>();
    final activeProvider = context.read<ActiveTrainsProvider>();
    final userId = context.read<LoginProvider>().loginData?.id ?? 1;

    try {
      final success = await AmsUpdateService.saveAllocation(
        bayProvider: bayProvider,
        activeProvider: activeProvider,
        depot: depot,
        track: track,
        mbId: hasExistingData ? selectedMbId : 0,
        slotId: selectedSlotId,
        trainSetId: selectedTrainSet,
        statusId: selectedStatus,
        purposeId: selectedPurpose,
        fromDate: fromDate ?? DateTime.now(),
        toDate: toDate,
        remarks: remarksController.text,
        isOutward: isOutward,
        hasExistingData: hasExistingData,
        userId: userId,
        trainSetOptions: trainSetOptions,
        statusOptions: statusOptions,
        purposeOptions: purposeOptions,
      );

      if (!mounted) return;
      if (success) {
        setState(() {
          hasExistingData = true;
          final updatedBay = bayProvider.findBayForMarker(track);
          if (updatedBay != null && updatedBay.id > 0) selectedMbId = updatedBay.id;
        });
        messenger.showSnackBar(
          const SnackBar(content: Text('Bay allocation saved. Map updated.'), backgroundColor: Color(0xFF10B981)),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(content: const Text('Failed to save allocation.'), backgroundColor: Colors.red.shade700),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Error saving allocation: $e'), backgroundColor: Colors.red.shade700),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tp = context.watch<TrainProvider>();
    final sp = context.watch<StatusProvider>();
    final pp = context.watch<MaintenancePurposeProvider>();
    final bp = context.watch<MaintenanceBayProvider>();

    trainSetOptions = AmsUpdateService.buildTrainSetOptions(tp.trainSets, selectedTrainSet);
    statusOptions = AmsUpdateService.buildStatusOptions(sp.statuses, selectedStatus);
    purposeOptions = AmsUpdateService.buildPurposeOptions(pp.purposes, selectedPurpose);
    final bayOptions = AmsUpdateService.buildBayOptions(depot, bp);
    final isSaveDisabled = isSaving;

    return ColoredBox(
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      child: Column(
        children: [
          CustomHeader(
            title: "AMS UPDATE",
            subtitle: depot == 'Select Depot'
                ? "Track Allocation Overview"
                : "$depot Depot - Track Allocation",
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ResponsiveContainer(
                  maxWidth: 860,
                  child: AMSUpdateFormCard(
                    depot: depot,
                    track: track,
                    line: line,
                    hasExistingData: hasExistingData,
                    bayOptions: bayOptions,
                    selectedTrainSet: selectedTrainSet,
                    selectedStatus: selectedStatus,
                    selectedPurpose: selectedPurpose,
                    trainSetOptions: trainSetOptions,
                    statusOptions: statusOptions,
                    purposeOptions: purposeOptions,
                    fromDate: fromDate,
                    toDate: toDate,
                    isOutward: isOutward,
                    remarksController: remarksController,
                    futureAllocations: futureAllocations,
                    selectedHistoryIndex: selectedHistoryIndex,
                    isSaving: isSaving,
                    isSaveDisabled: isSaveDisabled,
                    isDark: isDark,
                    onDepotChanged: _onDepotChanged,
                    onTrackChanged: _onTrackChanged,
                    findBay: (opt) => bp.findBayForMarker(opt),
                    onTrainSetChanged: (val) => setState(() => selectedTrainSet = val ?? 0),
                    onStatusChanged: (val) => setState(() => selectedStatus = val ?? 0),
                    onPurposeChanged: (val) => setState(() => selectedPurpose = val ?? 0),
                    onPickFromDate: () async {
                      final dt = await AmsUpdateService.pickDateTime(context, fromDate ?? DateTime.now());
                      if (dt != null) setState(() => fromDate = dt);
                    },
                    onPickToDate: () async {
                      final dt = await AmsUpdateService.pickDateTime(context, toDate ?? fromDate ?? DateTime.now(), minDate: fromDate);
                      if (dt != null) setState(() => toDate = dt);
                    },
                    onOutwardChanged: (val) => setState(() => isOutward = val ?? false),
                    formatDisplayDateTime: AmsUpdateService.formatDisplayDateTime,
                    onAssignFromHistory: _onAssignFromHistory,
                    onClear: _clearForm,
                    onSave: _handleSave,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
