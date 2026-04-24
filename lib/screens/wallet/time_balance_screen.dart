import 'package:app/core/func/date_time.dart';
import 'package:app/core/providers/user_provider.dart';
import 'package:app/core/theme/vibranium_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum TimeCategory { normal, vip, master }

enum TimePaymentMethod { applePay, card, voucher, cash }

class _TimePackage {
  const _TimePackage({
    required this.id,
    required this.category,
    required this.hours,
    required this.priceJod,
  });

  final String id;
  final TimeCategory category;
  final int hours;
  final double priceJod;
}

class _CartLine {
  const _CartLine({required this.pkg, required this.qty});
  final _TimePackage pkg;
  final int qty;
}

class TimeBalanceScreen extends StatefulWidget {
  const TimeBalanceScreen({super.key});

  @override
  State<TimeBalanceScreen> createState() => _TimeBalanceScreenState();
}

class _TimeBalanceScreenState extends State<TimeBalanceScreen> {
  static const _packages = <_TimePackage>[
    _TimePackage(
      id: 'n1',
      category: TimeCategory.normal,
      hours: 1,
      priceJod: 1.50,
    ),
    _TimePackage(
      id: 'n2',
      category: TimeCategory.normal,
      hours: 2,
      priceJod: 2,
    ),
    _TimePackage(
      id: 'n5',
      category: TimeCategory.normal,
      hours: 4,
      priceJod: 3,
    ),
    _TimePackage(
      id: 'n6',
      category: TimeCategory.normal,
      hours: 6,
      priceJod: 4,
    ),
    _TimePackage(
      id: 'n10',
      category: TimeCategory.normal,
      hours: 10,
      priceJod: 5,
    ),
    _TimePackage(
      id: 'n22',
      category: TimeCategory.normal,
      hours: 22,
      priceJod: 10,
    ),
    _TimePackage(
      id: 'n45',
      category: TimeCategory.normal,
      hours: 45,
      priceJod: 20,
    ),
    _TimePackage(id: 'v2', category: TimeCategory.vip, hours: 2, priceJod: 3),
    _TimePackage(id: 'v4', category: TimeCategory.vip, hours: 4, priceJod: 4),
    _TimePackage(id: 'v7', category: TimeCategory.vip, hours: 7, priceJod: 5),
    _TimePackage(
      id: 'v15',
      category: TimeCategory.vip,
      hours: 15,
      priceJod: 10,
    ),
    _TimePackage(
      id: 'v32',
      category: TimeCategory.vip,
      hours: 32,
      priceJod: 20,
    ),
    _TimePackage(
      id: 'm2',
      category: TimeCategory.master,
      hours: 1,
      priceJod: 2,
    ),
    _TimePackage(
      id: 'm3',
      category: TimeCategory.master,
      hours: 3,
      priceJod: 5,
    ),
    _TimePackage(
      id: 'm8',
      category: TimeCategory.master,
      hours: 8,
      priceJod: 10,
    ),
    _TimePackage(
      id: 'm10',
      category: TimeCategory.master,
      hours: 20,
      priceJod: 20,
    ),
  ];

  TimeCategory _selectedCategory = TimeCategory.normal;
  final Map<String, _CartLine> _cart = {};

  String _catLabel(TimeCategory c) {
    switch (c) {
      case TimeCategory.normal:
        return 'Normal';
      case TimeCategory.vip:
        return 'VIP';
      case TimeCategory.master:
        return 'Master';
    }
  }

  void _addToCart(_TimePackage pkg) {
    setState(() {
      final line = _cart[pkg.id];
      if (line == null) {
        _cart[pkg.id] = _CartLine(pkg: pkg, qty: 1);
      } else {
        _cart[pkg.id] = _CartLine(pkg: pkg, qty: line.qty + 1);
      }
    });
  }

  int get _cartCount => _cart.values.fold(0, (p, e) => p + e.qty);
  int currectPress = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final colorScheme = theme.colorScheme;
    final shown = _packages
        .where((p) => p.category == _selectedCategory)
        .toList();

    return Scaffold(
      backgroundColor: VibraniumColors.black,
      appBar: AppBar(
        backgroundColor: VibraniumColors.black,
        surfaceTintColor: Colors.transparent,
        title: const Text('Time balance'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: VibraniumColors.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Remaining time',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatDuration(user!.timeRemaining),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Column(
                  children: [
                    for (var pass in userProvider.userTime)
                      Text(
                        "${pass.title} ~ ${formatDuration((pass.totalTimeSeconds - pass.usedTimeSeconds).toInt())} Time remaining",
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Time category',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TimeCategory.values.map((c) {
              final selected = c == _selectedCategory;
              return ChoiceChip(
                label: Text(_catLabel(c)),
                selected: selected,
                onSelected: (_) => setState(() => _selectedCategory = c),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          Text(
            'Time prices',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ...shown.map((pkg) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: VibraniumColors.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  title: Text('${pkg.hours} hours'),
                  subtitle: Text('${_catLabel(pkg.category)} package'),
                  trailing: TextButton(
                    onPressed: () {},
                    child: Text('${pkg.priceJod.toStringAsFixed(2)} JOD'),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: _cartCount > 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) =>
                            _TimeCartScreen(cart: _cart.values.toList()),
                      ),
                    );
                  },
                  child: Text('View cart ($_cartCount)'),
                ),
              ),
            )
          : null,
    );
  }
}

class _TimeCartScreen extends StatelessWidget {
  const _TimeCartScreen({required this.cart});
  final List<_CartLine> cart;

  @override
  Widget build(BuildContext context) {
    final total = cart.fold<double>(
      0,
      (sum, e) => sum + (e.pkg.priceJod * e.qty),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        children: [
          ...cart.map(
            (line) => ListTile(
              title: Text('${line.pkg.hours}h package'),
              subtitle: Text('Qty: ${line.qty}'),
              trailing: Text(
                '${(line.pkg.priceJod * line.qty).toStringAsFixed(2)} JOD',
              ),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Total'),
            trailing: Text('${total.toStringAsFixed(2)} JOD'),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: FilledButton(
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => _TimeCheckoutScreen(totalJod: total),
                ),
              );
            },
            child: const Text('Checkout'),
          ),
        ),
      ),
    );
  }
}

class _TimeCheckoutScreen extends StatefulWidget {
  const _TimeCheckoutScreen({required this.totalJod});
  final double totalJod;

  @override
  State<_TimeCheckoutScreen> createState() => _TimeCheckoutScreenState();
}

class _TimeCheckoutScreenState extends State<_TimeCheckoutScreen> {
  TimePaymentMethod _method = TimePaymentMethod.applePay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        children: [
          ListTile(
            title: const Text('Apple Pay'),
            leading: Radio<TimePaymentMethod>(
              value: TimePaymentMethod.applePay,
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v!),
            ),
          ),
          ListTile(
            title: const Text('Card'),
            leading: Radio<TimePaymentMethod>(
              value: TimePaymentMethod.card,
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v!),
            ),
          ),
          ListTile(
            title: const Text('Voucher'),
            leading: Radio<TimePaymentMethod>(
              value: TimePaymentMethod.voucher,
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v!),
            ),
          ),
          ListTile(
            title: const Text('Cash (walk-ins only)'),
            subtitle: const Text('Disabled in the app'),
            enabled: false,
            leading: Radio<TimePaymentMethod>(
              value: TimePaymentMethod.cash,
              groupValue: _method,
              onChanged: null,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: FilledButton(
            onPressed: () async {
              final userProvider = context.read<UserProvider>();

              await userProvider.addTime(prizeOld: null).then((c) async {
                if (!c) {
                  return;
                }
                await showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Success'),
                    content: Text(
                      'Payment completed: ${widget.totalJod.toStringAsFixed(2)} JOD',
                    ),
                    actions: [
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              });
              if (!context.mounted) return;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text('Pay ${widget.totalJod.toStringAsFixed(2)} JOD'),
          ),
        ),
      ),
    );
  }
}
