class StatusModel {
  final int id;
  final String name;

  StatusModel({required this.id, required this.name});

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    final rawId =
        json['lookup_id'] ??
        json['lookupId'] ??
        json['lookupvalue_id'] ??
        json['lookupValueId'] ??
        json['status_id'] ??
        json['statusId'] ??
        json['StatusId'] ??
        json['id'] ??
        0;
    final rawName =
        json['lookup_value'] ??
        json['lookupValue'] ??
        json['lookupvalue_name'] ??
        json['lookupValueName'] ??
        json['status_name'] ??
        json['statusName'] ??
        json['StatusName'] ??
        json['name'] ??
        json['Name'] ??
        json['label'] ??
        json['value'] ??
        '';

    return StatusModel(
      id: rawId is num ? rawId.toInt() : int.tryParse(rawId.toString()) ?? 0,
      name: rawName.toString(),
    );
  }
}
