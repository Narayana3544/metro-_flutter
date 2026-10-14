import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/wheel_measurement_model.dart';
import '../../providers/login_provider.dart';
import '../../providers/train_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/common/custom_header.dart';
import '../../widgets/wheel_measurements/wheel_history_widgets.dart';

class WheelMeasurementHistoryScreen extends StatefulWidget {
  const WheelMeasurementHistoryScreen({super.key});

  @override
  State<WheelMeasurementHistoryScreen> createState() =>
      _WheelMeasurementHistoryScreenState();
}

class _WheelMeasurementHistoryScreenState
    extends State<WheelMeasurementHistoryScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String _selectedTrainSet = '0';
  List<WheelMeasurementListItem> _records = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final login = context.read<LoginProvider>();
      final ld = login.loginData;
      final roleId = login.selectedRoleId ?? ld?.roleIds.split(',').first.trim() ?? '1';
      context.read<TrainProvider>().fetchTrainSets(
        token: ld?.token,
        userSession: ld?.encodedUserSession,
        roleId: roleId,
      );
    });
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String tsParam = '0';
      if (_selectedTrainSet != 'All Trainsets' && _selectedTrainSet != '0' && _selectedTrainSet.isNotEmpty) {
        final trainProvider = Provider.of<TrainProvider>(context, listen: false);
        final match = trainProvider.trainSets.where((t) => t.no == _selectedTrainSet);
        if (match.isNotEmpty && match.first.id > 0) {
          tsParam = match.first.id.toString();
        } else {
          tsParam = _selectedTrainSet.replaceAll(RegExp(r'[^0-9]'), '');
          if (tsParam.isEmpty) tsParam = _selectedTrainSet;
        }
      }
      final list = await _apiService.getWheelMeasurementsList(trainSet: tsParam);
      setState(() {
        _records = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load wheel measurement records: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? "Unknown error",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchRecords,
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final trainProvider = context.watch<TrainProvider>();

    final List<String> trainsets = <String>{
      'All Trainsets',
      if (trainProvider.trainSets.isNotEmpty)
        ...trainProvider.trainSets
            .map((t) => t.no.isNotEmpty ? t.no : 'TS-${t.id}')
            .where((s) => s.isNotEmpty)
      else
        for (int i = 1; i <= 57; i++) 'TS${i.toString().padLeft(3, '0')}',
    }.toList();

    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          CustomHeader(
            title: "WHEEL HISTORY",
            subtitle: "Historical Records & Profiling Data",
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: "Refresh Records",
                onPressed: _fetchRecords,
              ),
            ],
          ),
          WheelMeasurementFilterBar(
            selectedTrainSet: _selectedTrainSet,
            trainsets: trainsets,
            isDark: isDark,
            onTrainSetChanged: (val) {
              setState(() => _selectedTrainSet = val);
              _fetchRecords();
            },
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorView()
                    : _records.isEmpty
                        ? const WheelHistoryEmptyView()
                        : RefreshIndicator(
                            onRefresh: _fetchRecords,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: _records.length,
                              itemBuilder: (context, index) {
                                return WheelRecordCard(
                                  record: _records[index],
                                  isDark: isDark,
                                  onTap: () => WheelRecordDetailSheet.show(
                                    context,
                                    _records[index],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
