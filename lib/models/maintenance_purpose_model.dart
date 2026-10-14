class MaintenancePurposeModel {
  final int id;
  final String name;

  MaintenancePurposeModel({required this.id, required this.name});

  factory MaintenancePurposeModel.fromJson(Map<String, dynamic> json) {
    final rawId =
        json['schedule_id'] ??
        json['scheduleId'] ??
        json['ScheduleId'] ??
        json['schedule_type_id'] ??
        json['scheduleTypeId'] ??
        json['purposeId'] ??
        json['PurposeId'] ??
        json['purpose_id'] ??
        json['lookupvalue_id'] ??
        json['lookup_id'] ??
        json['id'] ??
        0;
    final rawName =
        json['schedule_name'] ??
        json['scheduleName'] ??
        json['ScheduleName'] ??
        json['schedule_code'] ??
        json['scheduleCode'] ??
        json['ScheduleCode'] ??
        json['scheduleType'] ??
        json['purposeName'] ??
        json['PurposeName'] ??
        json['purpose_name'] ??
        json['name'] ??
        json['Name'] ??
        json['lookup_value'] ??
        '';

    return MaintenancePurposeModel(
      id: rawId is num ? rawId.toInt() : int.tryParse(rawId.toString()) ?? 0,
      name: rawName.toString(),
    );
  }
}
