import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/map_data.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/map/section_buttons.dart';
import '../../widgets/map/depot_map.dart';
import '../../widgets/common/custom_header.dart';
import '../../widgets/map/bay_allocation_table.dart';
import '../../providers/maintenance_bay_provider.dart';
import '../../providers/train_provider.dart';
import '../../providers/login_provider.dart';

class DashboardScreen extends StatefulWidget {
  final void Function(String depot)? onNavigateToHistory;

  const DashboardScreen({super.key, this.onNavigateToHistory});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedDepot = 'Select Depot';
  String selectedSection = '';

  void _showViewTableDialog(BuildContext context, MaintenanceBayProvider bayProvider) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950, maxHeight: 700),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  "${selectedDepot.toUpperCase()} – Live Allocations Table",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: BayAllocationTable(
                  title: "${selectedDepot.toUpperCase()} All Bays",
                  badge: "${bayProvider.maintenanceBays.length} slots",
                  depotName: selectedDepot,
                  sectionName: selectedSection,
                  tracks: MapData.getTracks(selectedDepot, selectedSection),
                  allocations: bayProvider.maintenanceBays,
                  isLoading: bayProvider.isLoading,
                  error: bayProvider.error,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bayProvider = context.watch<MaintenanceBayProvider>();

    final isDepotSelected = selectedDepot != 'Select Depot';

    // Filter allocations if a section is active
    final displayAllocations = selectedSection.isNotEmpty
        ? bayProvider.maintenanceBays.where((b) {
            final slotUpper = b.slotName.toUpperCase();
            final secUpper = selectedSection.toUpperCase();
            return slotUpper.contains(secUpper);
          }).toList()
        : bayProvider.maintenanceBays;

    return ColoredBox(
      color: colors.surface,
      child: Column(
        children: [
          const CustomHeader(
            title: "Maintenance Bay Dashboard",
            subtitle: "Depot Allocation Overview",
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  /// DEPOT SELECTOR & ACTION BUTTONS
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 620;

                      final depotDropdown = CustomDropdown(
                        key: ValueKey(selectedDepot),
                        label: 'Depot',
                        selectedValue: selectedDepot,
                        options: const ['Select Depot', 'Miyapur', 'Uppal'],
                        onChanged: (value) {
                          setState(() {
                            selectedDepot = value;
                            selectedSection = ''; // Default to full layout view!

                            if (value != 'Select Depot') {
                              final depotId = value == 'Uppal' ? 633 : 9373;
                              context
                                  .read<MaintenanceBayProvider>()
                                  .fetchMaintenanceBay(depotId);

                              final loginData = context.read<LoginProvider>().loginData;
                              final roleId = context.read<LoginProvider>().selectedRoleId ??
                                  loginData?.roleIds.split(',').first.trim() ??
                                  '1';

                              context.read<TrainProvider>().fetchTrainSets(
                                    token: loginData?.token,
                                    userSession: loginData?.encodedUserSession,
                                    roleId: roleId,
                                  );
                            }
                          });
                        },
                      );

                      final actionButtons = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isDepotSelected) ...[
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () =>
                                  _showViewTableDialog(context, bayProvider),
                              icon: const Icon(Icons.table_chart, size: 18),
                              label: const Text("View Table"),
                            ),
                            const SizedBox(width: 8),
                          ],
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () {
                              widget.onNavigateToHistory?.call(selectedDepot);
                            },
                            icon: const Icon(Icons.history, size: 18),
                            label: const Text('History'),
                          ),
                        ],
                      );

                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            depotDropdown,
                            const SizedBox(height: 10),
                            actionButtons,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: depotDropdown),
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: actionButtons,
                          ),
                        ],
                      );
                    },
                  ),

                  /// SECTION BUTTONS (NxAMS Line Summary Cards)
                  if (isDepotSelected) ...[
                    const SizedBox(height: 8),
                    SectionButtons(
                      depot: selectedDepot,
                      sections: MapData.depotSections[selectedDepot] ?? [],
                      selectedSection: selectedSection,
                      colors: MapData.sectionColors[selectedDepot] ?? {},
                      onSectionSelected: (section) {
                        setState(() {
                          selectedSection = section;
                        });
                      },
                    ),
                  ],

                  const SizedBox(height: 14),

                  /// DEPOT MAP (Full CAD Layout with Overlays)
                  DepotMap(
                    depot: selectedDepot == 'Select Depot' ? '' : selectedDepot,
                    selectedSection: selectedSection,
                    onResetZoom: () {
                      setState(() {
                        selectedSection = '';
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  /// LIVE ALLOCATION TABLE BELOW MAP
                  if (isDepotSelected)
                    BayAllocationTable(
                      title: selectedSection.isNotEmpty
                          ? "$selectedSection Allocation"
                          : "${selectedDepot.toUpperCase()} Live Allocations",
                      badge: "${displayAllocations.length} slots",
                      depotName: selectedDepot,
                      sectionName: selectedSection,
                      tracks: MapData.getTracks(selectedDepot, selectedSection),
                      allocations: displayAllocations,
                      isLoading: bayProvider.isLoading,
                      error: bayProvider.error,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
