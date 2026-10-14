import 'package:flutter/material.dart';
import '../../constants/website_bay_markers.dart';
import '../../models/maintenance_purpose_model.dart';
import '../../models/status_model.dart';
import '../../models/train_model.dart';
import '../../providers/active_trains_provider.dart';
import '../../providers/maintenance_bay_provider.dart';
import 'ams_update_form_rows.dart';

class AmsUpdateService {
  static const Map<String, int> depotIds = {
    'UPPAL': 633,
    'MIYAPUR': 9373,
    'Uppal': 633,
    'Miyapur': 9373,
  };

  static String formatToLocalIso(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}T${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00';

  static String formatDisplayDateTime(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  static Future<DateTime?> pickDateTime(BuildContext context, DateTime initial, {DateTime? minDate}) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(minDate ?? DateTime(2020)) ? (minDate ?? DateTime(2020)) : initial,
      firstDate: minDate ?? DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (pickedDate == null || !context.mounted) return null;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial.hour, minute: initial.minute),
    );
    if (pickedTime == null || !context.mounted) return null;
    return DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
  }

  static String getLineForSlot(String slotName) {
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

  static List<DropdownOption> buildTrainSetOptions(List<dynamic> trainSets, int selectedTrainSet) {
    final seen = <int>{0};
    final list = <DropdownOption>[
      const DropdownOption(value: 0, label: 'Select Train Set'),
    ];
    for (final t in trainSets) {
      final id = (t is TrainModel) ? t.id : (int.tryParse('${t.id}') ?? 0);
      final no = (t is TrainModel) ? t.no : '${t.no}';
      if (id > 0 && seen.add(id)) {
        list.add(DropdownOption(value: id, label: no.isNotEmpty ? no : 'TS-$id'));
      }
    }
    if (selectedTrainSet > 0 && seen.add(selectedTrainSet)) {
      list.add(DropdownOption(value: selectedTrainSet, label: 'TS-$selectedTrainSet'));
    }
    return list;
  }

  static List<DropdownOption> buildStatusOptions(List<dynamic> statuses, int selectedStatus) {
    final seen = <int>{0};
    final list = <DropdownOption>[
      const DropdownOption(value: 0, label: 'Select Status'),
    ];
    for (final s in statuses) {
      final id = (s is StatusModel) ? s.id : (int.tryParse('${s.id}') ?? 0);
      final name = (s is StatusModel) ? s.name : '${s.name}';
      if (id > 0 && seen.add(id)) {
        list.add(DropdownOption(value: id, label: name.isNotEmpty ? name : 'Status $id'));
      }
    }
    if (selectedStatus > 0 && seen.add(selectedStatus)) {
      list.add(DropdownOption(value: selectedStatus, label: 'Status $selectedStatus'));
    }
    return list;
  }

  static List<DropdownOption> buildPurposeOptions(List<dynamic> purposes, int selectedPurpose) {
    final seen = <int>{0};
    final list = <DropdownOption>[
      const DropdownOption(value: 0, label: 'Select Purpose'),
    ];
    for (final p in purposes) {
      final id = (p is MaintenancePurposeModel) ? p.id : (int.tryParse('${p.id}') ?? 0);
      final name = (p is MaintenancePurposeModel) ? p.name : '${p.name}';
      if (id > 0 && seen.add(id)) {
        list.add(DropdownOption(value: id, label: name.isNotEmpty ? name : 'Purpose $id'));
      }
    }
    if (selectedPurpose > 0 && seen.add(selectedPurpose)) {
      list.add(DropdownOption(value: selectedPurpose, label: 'Purpose $selectedPurpose'));
    }
    return list;
  }

  static List<String> buildBayOptions(String depot, MaintenanceBayProvider bayProvider) {
    if (depot.isEmpty || depot == 'Select Depot') {
      return const [];
    }
    final markers = (depot.toUpperCase() == 'MIYAPUR') ? WebsiteBayMarkers.miyapur : WebsiteBayMarkers.uppal;
    final options = <String>[];
    for (final id in markers.map((m) => m.id)) {
      if (!options.contains(id)) options.add(id);
    }
    for (final s in bayProvider.maintenanceBays.map((b) => b.slotName).where((s) => s.isNotEmpty)) {
      if (!options.contains(s)) options.add(s);
    }
    return options;
  }

  static Future<BayDetailParsed?> fetchParsedBayDetails(
    int mbId,
    MaintenanceBayProvider bayProvider,
  ) async {
    final detail = await fetchBayDetails(mbId, bayProvider);
    if (detail == null) return null;

    final rawAllocs = detail['allocations'] ?? detail['Allocations'] ?? detail['mbaAllocations'] ?? [];
    final allocList = (rawAllocs is List) ? rawAllocs.whereType<Map<String, dynamic>>().toList() : <Map<String, dynamic>>[];

    final rawTs = detail['mb_train_set'] ?? detail['mbTrainSet'] ?? detail['trainSet'] ?? 0;
    final tsVal = int.tryParse('$rawTs') ?? 0;

    int? statusVal;
    int? purposeVal;
    DateTime? inDate;
    DateTime? outDate;
    bool? isOut;
    String? rem;

    if (tsVal > 0) {
      statusVal = int.tryParse('${detail['mb_status'] ?? detail['status'] ?? 0}');
      purposeVal = int.tryParse('${detail['mb_purpose'] ?? detail['purpose'] ?? 0}');
      final rawIn = detail['mb_inward'] ?? detail['fromDate'] ?? '';
      if (rawIn.toString().isNotEmpty) inDate = DateTime.tryParse(rawIn.toString());
      final rawOut = detail['mb_outward'] ?? detail['toDate'] ?? '';
      if (rawOut.toString().isNotEmpty) outDate = DateTime.tryParse(rawOut.toString());
      final rawIsOut = detail['isOutward'] ?? detail['mb_isOutward'];
      if (rawIsOut != null) isOut = rawIsOut == true || rawIsOut == 'true' || rawIsOut == 1;
      final rawRem = detail['mb_remark'] ?? detail['remarks'] ?? '';
      if (rawRem.toString().isNotEmpty) rem = rawRem.toString();
    }

    return BayDetailParsed(
      allocations: allocList,
      trainSet: tsVal > 0 ? tsVal : null,
      status: statusVal,
      purpose: purposeVal,
      inward: inDate,
      outward: outDate,
      isOutward: isOut,
      remarks: rem,
    );
  }

  static Future<Map<String, dynamic>?> fetchBayDetails(
    int mbId,
    MaintenanceBayProvider bayProvider,
  ) async {
    try {
      final data = await bayProvider.repository.getMaintenanceBayById(mbId);
      final dynamic resObj = data.containsKey('response') ? data['response'] : data;
      if (resObj is Map<String, dynamic>) {
        return resObj['maintenanceBay'] is Map<String, dynamic>
            ? resObj['maintenanceBay'] as Map<String, dynamic>
            : (resObj['data'] is Map<String, dynamic> ? resObj['data'] as Map<String, dynamic> : resObj);
      } else if (resObj is List && resObj.isNotEmpty && resObj.first is Map<String, dynamic>) {
        return resObj.first as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error fetching bay details: $e');
    }
    return null;
  }

  static Future<bool> saveAllocation({
    required MaintenanceBayProvider bayProvider,
    required ActiveTrainsProvider activeProvider,
    required String depot,
    required String track,
    required int mbId,
    required int slotId,
    required int trainSetId,
    required int statusId,
    required int purposeId,
    required DateTime fromDate,
    required DateTime? toDate,
    required String remarks,
    required bool isOutward,
    required bool hasExistingData,
    required int userId,
    required List<DropdownOption> trainSetOptions,
    required List<DropdownOption> statusOptions,
    required List<DropdownOption> purposeOptions,
  }) async {
    final depotUpper = depot.toUpperCase();
    final depotId = depotIds[depotUpper] ?? (depotUpper == 'UPPAL' ? 633 : 9373);
    final inwardDate = formatToLocalIso(fromDate);
    final outwardDate = (hasExistingData && toDate != null) ? formatToLocalIso(toDate) : '';

    final success = await bayProvider.saveMaintenanceBay(
      mbId: mbId,
      mbDepot: depotId,
      mbSlot: slotId,
      mbTrainSet: trainSetId,
      mbStatus: statusId,
      mbPurpose: purposeId,
      mbInward: inwardDate,
      mbOutward: outwardDate,
      mbRemark: remarks.trim(),
      isOutward: hasExistingData ? isOutward : false,
      userId: userId,
    );

    if (success) {
      final trainOpt = trainSetOptions.where((o) => o.value == trainSetId);
      final tsName = trainOpt.isNotEmpty ? trainOpt.first.label : 'TS-$trainSetId';
      final statusOpt = statusOptions.where((o) => o.value == statusId);
      final stName = statusOpt.isNotEmpty ? statusOpt.first.label : '';
      final purposeOpt = purposeOptions.where((o) => o.value == purposeId);
      final prName = purposeOpt.isNotEmpty ? purposeOpt.first.label : '';

      bayProvider.setOrUpdateBayAllocation(
        markerOrSlotName: track,
        depotId: depotId,
        slot: slotId,
        trainSetId: trainSetId,
        trainSetName: tsName,
        statusId: statusId,
        statusName: stName,
        purposeId: purposeId,
        purposeName: prName,
        inward: inwardDate,
        outward: outwardDate,
        remark: remarks.trim(),
        isOutward: hasExistingData ? isOutward : false,
        id: mbId,
      );

      await bayProvider.fetchMaintenanceBay(depotId);

      activeProvider.assignTrain(
        TrainAssignment(
          depotName: depot,
          sectionName: track,
          trackNumber: track,
          trackId: track,
          trainNo: tsName,
          maintenancePurpose: prName,
          status: stName,
          remarks: remarks.trim(),
        ),
      );
    }

    return success;
  }
}

class BayDetailParsed {
  final List<Map<String, dynamic>> allocations;
  final int? trainSet;
  final int? status;
  final int? purpose;
  final DateTime? inward;
  final DateTime? outward;
  final bool? isOutward;
  final String? remarks;

  const BayDetailParsed({
    required this.allocations,
    this.trainSet,
    this.status,
    this.purpose,
    this.inward,
    this.outward,
    this.isOutward,
    this.remarks,
  });
}
