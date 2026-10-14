import 'package:flutter/material.dart';

/// Filter bar for maintenance bay allocation history
class HistoryFilterBar extends StatelessWidget {
  final String depot;
  final String slot;
  final String trainSet;
  final String dateFrom;
  final String dateTo;
  final List<MapEntry<String, String>> sortedSlotEntries;
  final Map<String, String> trainMap;
  final bool loadingHistory;
  final ValueChanged<String> onDepotChanged;
  final ValueChanged<String?> onSlotChanged;
  final ValueChanged<String?> onTrainChanged;
  final VoidCallback onPickDateFrom;
  final VoidCallback onPickDateTo;
  final VoidCallback onSearch;

  const HistoryFilterBar({
    super.key,
    required this.depot,
    required this.slot,
    required this.trainSet,
    required this.dateFrom,
    required this.dateTo,
    required this.sortedSlotEntries,
    required this.trainMap,
    required this.loadingHistory,
    required this.onDepotChanged,
    required this.onSlotChanged,
    required this.onTrainChanged,
    required this.onPickDateFrom,
    required this.onPickDateTo,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final slotMatches = sortedSlotEntries.any((e) => e.key == slot);
    final trainMatches = trainMap.containsKey(trainSet);

    final normalizedDepot = (depot == '9373' || depot == '633')
        ? depot
        : (depot.toUpperCase().contains('MIYAPUR') ? '9373' : '633');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                key: ValueKey('depot_$normalizedDepot'),
                value: normalizedDepot,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Depot',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: '633',
                    child: Text('UPPAL'),
                  ),
                  DropdownMenuItem(
                    value: '9373',
                    child: Text('MIYAPUR'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) onDepotChanged(value);
                },
              ),
            ),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String>(
                key: ValueKey('bay_${depot}_${sortedSlotEntries.length}_$slot'),
                value: slotMatches ? slot : '',
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Bay',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('All'),
                  ),
                  ...sortedSlotEntries
                      .where((entry) => entry.key.isNotEmpty)
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                ],
                onChanged: onSlotChanged,
              ),
            ),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String>(
                key: ValueKey('train_${trainMap.length}_$trainSet'),
                value: trainMatches ? trainSet : '',
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Trainset',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('All'),
                  ),
                  ...trainMap.entries
                      .where((entry) => entry.key.isNotEmpty)
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                ],
                onChanged: onTrainChanged,
              ),
            ),
            OutlinedButton.icon(
              onPressed: onPickDateFrom,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                dateFrom.isEmpty ? 'Date From' : dateFrom,
              ),
            ),
            OutlinedButton.icon(
              onPressed: onPickDateTo,
              icon: const Icon(Icons.calendar_today),
              label: Text(dateTo.isEmpty ? 'Date To' : dateTo),
            ),
            FilledButton.icon(
              onPressed: loadingHistory ? null : onSearch,
              icon: loadingHistory
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.search),
              label: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data table for displaying history records
class HistoryDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> records;

  const HistoryDataTable({super.key, required this.records});

  String _value(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      final value = row[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Bay')),
            DataColumn(label: Text('Trainset')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Purpose')),
            DataColumn(label: Text('Allocated On')),
            DataColumn(label: Text('Remarks')),
          ],
          rows: records.map((row) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    _value(row, [
                      'mbh_slot_name',
                      'mbaSlotName',
                      'slotName',
                      'mbSlotName',
                    ]),
                  ),
                ),
                DataCell(
                  Text(
                    _value(row, [
                      'mbh_train_set_name',
                      'mbaTrainSetName',
                      'trainSetName',
                    ]),
                  ),
                ),
                DataCell(
                  Text(
                    _value(row, [
                      'mbh_status_name',
                      'mbaStatusName',
                      'statusName',
                    ]),
                  ),
                ),
                DataCell(
                  Text(
                    _value(row, [
                      'mbh_purpose_name',
                      'mbaPurposeName',
                      'purposeName',
                    ]),
                  ),
                ),
                DataCell(
                  Text(
                    _value(row, [
                      'mbh_inward',
                      'created_on',
                      'mbaAllocatedOn',
                    ]),
                  ),
                ),
                DataCell(
                  Text(
                    _value(row, [
                      'mbh_remarks',
                      'mbaRemarks',
                      'remarks',
                    ]),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
