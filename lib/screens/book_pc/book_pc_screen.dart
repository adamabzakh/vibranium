import 'dart:convert';

import 'package:app/core/models/pc.dart';
import 'package:app/core/providers/pc_provider.dart';
import 'package:app/core/providers/user_provider.dart';
import 'package:app/core/theme/vibranium_theme.dart';
import 'package:app/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Categories (UI metadata only — IDs must match what PcProvider resolves)
// ---------------------------------------------------------------------------

class PcCategory {
  const PcCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.accent,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color accent;
}

const List<PcCategory> kPcCategories = [
  PcCategory(
    id: 'normal',
    name: 'Normal',
    description: 'Standard gaming floor',
    icon: Icons.computer_rounded,
    accent: Color(0xFF22D3EE),
  ),
  PcCategory(
    id: 'stage',
    name: 'Stage',
    description: 'Stream & showcase row',
    icon: Icons.videocam_rounded,
    accent: Color(0xFF64B5F6),
  ),
  PcCategory(
    id: 'vip',
    name: 'VIP',
    description: 'Premium rigs & space',
    icon: Icons.star_rounded,
    accent: Color(0xFFA855F7),
  ),
  PcCategory(
    id: 'master_vip',
    name: 'Master VIP',
    description: 'Top-tier private stations',
    icon: Icons.diamond_rounded,
    accent: Color(0xFFFFD54F),
  ),
];

// ---------------------------------------------------------------------------
// Booking persistence
// ---------------------------------------------------------------------------

const _kCurrentBookedPcKey = 'current_booked_pc_v1';

Future<void> saveCurrentBookedPc({
  required String pcId,
  required String categoryId,
  String? areaId,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _kCurrentBookedPcKey,
    jsonEncode({
      'pcId': pcId,
      'categoryId': categoryId,
      'areaId': areaId,
      'bookedAt': DateTime.now().toIso8601String(),
    }),
  );
}

Future<Map<String, String>?> loadCurrentBookedPc() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_kCurrentBookedPcKey);
  if (raw == null || raw.isEmpty) return null;
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  final pcId = (decoded['pcId'] ?? '').toString();
  if (pcId.isEmpty) return null;
  return {
    'pcId': pcId,
    'categoryId': (decoded['categoryId'] ?? '').toString(),
    'areaId': (decoded['areaId'] ?? '').toString(),
    'bookedAt': (decoded['bookedAt'] ?? '').toString(),
  };
}

// ---------------------------------------------------------------------------
// Root screen — category picker
// ---------------------------------------------------------------------------

class BookPcScreen extends StatefulWidget {
  const BookPcScreen({super.key});

  @override
  State<BookPcScreen> createState() => _BookPcScreenState();
}

class _BookPcScreenState extends State<BookPcScreen> {
  Future<void> _handleCategoryTap(PcCategory category) async {
    String? areaId;
    if (category.id == 'normal') {
      areaId = await _showNormalAreaDialog();
      if (!mounted || areaId == null) return;
    } else {
      areaId = category.id;
    }
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _PcCanvasScreen(category: category, areaId: areaId),
      ),
    );
  }

  Future<String?> _showNormalAreaDialog() => showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Choose normal area'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.looks_one_rounded),
            title: const Text('Area 1'),
            onTap: () => Navigator.of(ctx).pop('area1'),
          ),
          ListTile(
            leading: const Icon(Icons.looks_two_rounded),
            title: const Text('Area 2'),
            onTap: () => Navigator.of(ctx).pop('area2'),
          ),
          ListTile(
            leading: const Icon(Icons.looks_3_rounded),
            title: const Text('Area 3'),
            onTap: () => Navigator.of(ctx).pop('area3'),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: VibraniumColors.black,
      appBar: AppBar(
        backgroundColor: VibraniumColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Book PC',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const SizedBox(height: 20),
          ...kPcCategories.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: VibraniumColors.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () => _handleCategoryTap(c),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: c.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(c.icon, color: c.accent, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                c.description,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
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

// ---------------------------------------------------------------------------
// Canvas screen — floor plan with live PC dots from PcProvider
// ---------------------------------------------------------------------------

class _PcCanvasScreen extends StatefulWidget {
  const _PcCanvasScreen({required this.category, this.areaId});

  final PcCategory category;
  final String? areaId;

  @override
  State<_PcCanvasScreen> createState() => _PcCanvasScreenState();
}

class _PcCanvasScreenState extends State<_PcCanvasScreen> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();

    final userProvider = context.read<PcProvider>();
    // Always re-fetch fresh data when this screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await userProvider.getAllPCServerSide(widget.areaId ?? "area1");
    });
  }

  void _toggleStation(GgMachine pc) {
    if (pc.state != "ReadyForUser") return;
    setState(() {
      _selectedId = pc.uuid == _selectedId ? null : pc.uuid;
    });
  }

  Future<void> _lockSelectedPc() async {
    final selectedId = _selectedId;
    if (selectedId == null) return;

    final userProvider = context.read<UserProvider>();
    final pcProvider = context.read<PcProvider>();

    setState(() {
      print("Start Loading");
      print(userProvider.isLoading);
      userProvider.initLoading("_lockSelectedPc");
      print(userProvider.isLoading);
    });

    await userProvider.lockPC(selectedId).then((value) {
      if (!value) return;
    });

    final pcName = pcProvider.pcs
        .firstWhere((element) => element.uuid == selectedId)
        .name;

    await saveCurrentBookedPc(
      pcId: pcName ?? "",
      categoryId: widget.category.id,
      areaId: widget.areaId,
    );

    userProvider.initLoading("_lockSelectedPc");
    print("finish Loading");
    setState(() => _selectedId = null);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Booking confirmed'),
        content: Text('$pcName locked successfully.'),
        actions: [
          FilledButton(
            onPressed: () async {
              await userProvider.getCurrectLoggedingPC(pcProvider);
              Navigator.pushAndRemoveUntil(
                ctx,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (_) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cat = widget.category;

    final pcProvider = context.watch<PcProvider>();

    final stations = pcProvider.currentSelectedPcs;

    return Scaffold(
      backgroundColor: VibraniumColors.black,
      appBar: AppBar(
        backgroundColor: VibraniumColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(_buildTitle()),
      ),
      body: _buildBody(theme, colorScheme, cat, stations, pcProvider),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // -------------------------------------------------------------------------
  // Body
  // -------------------------------------------------------------------------

  Widget _buildBody(
    ThemeData theme,
    ColorScheme colorScheme,
    PcCategory cat,
    List<GgMachine> stations,
    PcProvider pcProvider,
  ) {
    // Show error if fetch failed and we have nothing to show.
    if (!pcProvider.isLoading &&
        pcProvider.errorMessage != null &&
        stations.isEmpty) {
      return _ErrorState(
        message: pcProvider.errorMessage!,
        onRetry: () => context.read<PcProvider>().getAllPCServerSide(
          widget.areaId ?? "area_1",
        ),
      );
    }

    if (pcProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (stations.isEmpty) {
      return Center(
        child: Text(
          'No stations available in this area.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildLegend(colorScheme, cat),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _FloorPlanCanvas(
              stations: stations,
              categoryAccent: cat.accent,
              selectedId: _selectedId,
              onToggle: _toggleStation,
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  Widget _buildLegend(ColorScheme colorScheme, PcCategory cat) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          _LegendDot(color: Colors.red, label: 'Taken'),
          const SizedBox(width: 14),
          _LegendDot(color: cat.accent, label: 'Selected'),
          const SizedBox(width: 14),
          _LegendDot(
            color: const Color.fromARGB(255, 70, 70, 70),
            label: 'Walk-in only',
          ),
          const SizedBox(width: 14),
          _LegendDot(color: Colors.green, label: 'Free'),
        ],
      ),
    );
  }

  Widget? _buildBottomBar() {
    final userProvider = context.watch<UserProvider>();
    if (_selectedId == null) return null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: FilledButton(
          onPressed: (userProvider.isLoading) ? null : _lockSelectedPc,
          child: (userProvider.isLoading)
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 1,
                  ),
                )
              : const Text('Book PC'),
        ),
      ),
    );
  }

  String _buildTitle() {
    final base = widget.category.name;
    if (widget.category.id != 'normal' || widget.areaId == null) return base;
    return '$base · ${widget.areaId!.replaceAll('_', ' ').toUpperCase()}';
  }
}

// ---------------------------------------------------------------------------
// Floor plan canvas
// ---------------------------------------------------------------------------

class _FloorPlanCanvas extends StatelessWidget {
  const _FloorPlanCanvas({
    required this.stations,
    required this.categoryAccent,
    required this.selectedId,
    required this.onToggle,
  });

  final List<GgMachine> stations;
  final Color categoryAccent;
  final String? selectedId;
  final void Function(GgMachine) onToggle;

  static const double _dotSize = 36;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 1.0,
            maxScale: 4.0,
            boundaryMargin: EdgeInsets.zero,
            child: SizedBox(
              width: w,
              height: h,
              child: Stack(
                clipBehavior: Clip.none,
                children: stations.map((pc) {
                  final cx = ((pc.postion!.dx / 100) * w - _dotSize / 2);
                  final cy = ((pc.postion!.dy / 100) * h - _dotSize / 2);
                  final isSelected = selectedId == pc.uuid;

                  return Positioned(
                    left: cx,
                    top: cy,
                    width: _dotSize,
                    height: _dotSize,
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: _StationDot(
                        label: pc.name ?? "",
                        accent: categoryAccent,
                        off: pc.state!.toLowerCase() == "off",
                        occupied: pc.state != "ReadyForUser",
                        selected: isSelected,
                        onTap: (pc.state != "ReadyForUser")
                            ? null
                            : () => onToggle(pc),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Station dot widget
// ---------------------------------------------------------------------------

class _StationDot extends StatelessWidget {
  const _StationDot({
    required this.label,
    required this.accent,
    required this.occupied,
    required this.off,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color accent;
  final bool occupied;
  final bool off;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color bg;
    final Color border;

    if (occupied) {
      if (off) {
        bg = const Color.fromARGB(255, 70, 70, 70);
        border = const Color.fromARGB(255, 70, 70, 70);
      } else {
        bg = Colors.red;
        border = Colors.red;
      }
    } else if (selected) {
      bg = accent.withValues(alpha: 0.4);
      border = accent;
    } else {
      bg = Colors.green;
      border = Colors.green;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Tooltip(
          message: label,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border, width: selected ? 2 : 1),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label.replaceAll(RegExp(r'[^0-9]'), ''),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 9,
                      height: 1.1,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Legend dot
// ---------------------------------------------------------------------------

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text('Failed to load stations', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
