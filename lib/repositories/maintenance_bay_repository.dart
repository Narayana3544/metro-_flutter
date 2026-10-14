import 'package:flutter/foundation.dart';
import '../constants/website_bay_markers.dart';
import '../models/maintenance_bay_model.dart';
import '../services/api_service.dart';

class MaintenanceBayRepository {
  final ApiService api = ApiService();

  Future<List<MaintenanceBayModel>> getMaintenanceBay(int depotId) async {
    try {
      return await api.getMaintenanceBay(depotId);
    } catch (e) {
      if (kIsWeb || e.toString().contains('Failed to fetch') || e.toString().contains('405')) {
        debugPrint('[Web CORS Fallback] search-maintenancebay error ($e). Using mock bay data for Web development.');
        return _buildFallbackWebBays(depotId);
      }
      rethrow;
    }
  }

  List<MaintenanceBayModel> _buildFallbackWebBays(int depotId) {
    final markers = (depotId == 9373) ? WebsiteBayMarkers.miyapur : WebsiteBayMarkers.uppal;
    final list = <MaintenanceBayModel>[];
    for (int i = 0; i < markers.length; i++) {
      final marker = markers[i];
      final isAlloc = (i % 3 == 0);
      final trainNum = (i ~/ 3) + 1;
      final tsName = 'TS${trainNum.toString().padLeft(3, '0')}';

      list.add(
        MaintenanceBayModel(
          id: 1000 + i,
          slot: i + 1,
          slotName: marker.id,
          slotType: marker.id.contains('SBL') ? 'SBL' : (marker.id.contains('IBL') ? 'IBL' : 'MAIN'),
          trainSetId: isAlloc ? trainNum : 0,
          trainSetName: isAlloc ? tsName : '',
          statusId: isAlloc ? (i % 2 == 0 ? 1 : 2) : 0,
          statusName: isAlloc ? (i % 2 == 0 ? 'Stable' : 'In-Service') : '',
          purposeId: isAlloc ? 1 : 0,
          purposeName: isAlloc ? 'Scheduled Maintenance' : '',
          inward: isAlloc ? DateTime.now().subtract(const Duration(hours: 4)).toIso8601String() : '',
          outward: '',
          remark: isAlloc ? 'Daily Inspection Complete' : '',
          isAllocated: isAlloc,
        ),
      );
    }
    return list;
  }

  Future<Map<String, dynamic>> getMaintenanceBayById(int mbId) {
    return api.getMaintenanceBayById(mbId);
  }

  Future<Map<String, dynamic>> saveMaintenanceBay({
    required int mbId,
    required int mbDepot,
    required int mbSlot,
    required int mbTrainSet,
    required int mbStatus,
    required int mbPurpose,
    required String mbInward,
    required String mbOutward,
    required String mbRemark,
    bool isOutward = false,
    int? userId,
  }) {
    return api.saveMaintenanceBay(
      mbId: mbId,
      mbDepot: mbDepot,
      mbSlot: mbSlot,
      mbTrainSet: mbTrainSet,
      mbStatus: mbStatus,
      mbPurpose: mbPurpose,
      mbInward: mbInward,
      mbOutward: mbOutward,
      mbRemark: mbRemark,
      isOutward: isOutward,
      userId: userId,
    );
  }

  Future<Map<String, dynamic>> saveMaintenanceBayAllocation({
    required int mbaMbId,
    required int mbaDepot,
    required int mbaSlot,
    required int mbaTrainSet,
    required int mbaPurpose,
    required int mbaStatus,
    required String mbaAllocatedOn,
    required String mbaAllocatedBy,
    required String mbaRemarks,
    int? userId,
  }) {
    return api.saveMaintenanceBayAllocation(
      mbaMbId: mbaMbId,
      mbaDepot: mbaDepot,
      mbaSlot: mbaSlot,
      mbaTrainSet: mbaTrainSet,
      mbaPurpose: mbaPurpose,
      mbaStatus: mbaStatus,
      mbaAllocatedOn: mbaAllocatedOn,
      mbaAllocatedBy: mbaAllocatedBy,
      mbaRemarks: mbaRemarks,
      userId: userId,
    );
  }
}
