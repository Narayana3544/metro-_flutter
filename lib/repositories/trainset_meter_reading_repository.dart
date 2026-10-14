import 'package:flutter/foundation.dart';
import '../models/trainset_meter_reading_model.dart';
import '../services/api_service.dart';

class TrainsetMeterReadingRepository {
  final ApiService _apiService;

  TrainsetMeterReadingRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<TrainsetMeterReadingPage> getTrainsetMeterReadings({
    required String date,
    required int pageNo,
    required int pageSize,
    required int pagination,
    required String token,
    required String userSession,
    required String roleId,
  }) async {
    try {
      return await _apiService.getTrainsetMeterReadings(
        date: date,
        pageNo: pageNo,
        pageSize: pageSize,
        pagination: pagination,
        token: token,
        userSession: userSession,
        roleId: roleId,
      );
    } catch (e) {
      if (kIsWeb || e.toString().contains('Failed to fetch') || e.toString().contains('405')) {
        debugPrint('[Web CORS Fallback] assetregister blocked ($e). Using mock meter readings for Web development.');
        return _buildFallbackWebMeterReadings(pageNo, pageSize);
      }
      rethrow;
    }
  }

  TrainsetMeterReadingPage _buildFallbackWebMeterReadings(int pageNo, int pageSize) {
    const total = 57;
    final startIndex = (pageNo - 1) * pageSize;
    final endIndex = (startIndex + pageSize) > total ? total : (startIndex + pageSize);

    final items = <TrainsetMeterReadingModel>[];
    for (int i = startIndex + 1; i <= endIndex; i++) {
      final tsNo = 'TS${i.toString().padLeft(3, '0')}';
      items.add(
        TrainsetMeterReadingModel(
          assetId: 170 + i,
          assetNo: tsNo,
          assetLocation: i % 2 == 0 ? 633 : 9373,
          locationCode: i % 2 == 0 ? 'UPL' : 'MYP',
          locationName: i % 2 == 0 ? 'Uppal Depot' : 'Miyapur Depot',
          previousDate: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          previousDateReading: '${120000 + i * 340}',
          todayReading: '${120250 + i * 340}',
        ),
      );
    }

    return TrainsetMeterReadingPage(
      items: items,
      totalRows: total,
      pageNo: pageNo,
    );
  }
}
