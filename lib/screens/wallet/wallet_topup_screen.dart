import 'package:flutter/material.dart';

enum WalletPayMethod { applePay, card }

class WalletTopupScreen extends StatefulWidget {
  const WalletTopupScreen({super.key});

  @override
  State<WalletTopupScreen> createState() => _WalletTopupScreenState();
}

class _WalletTopupScreenState extends State<WalletTopupScreen> {
  String _amountRaw = '';

  void _tapKey(String key) {
    setState(() {
      if (key == '⌫') {
        if (_amountRaw.isNotEmpty) {
          _amountRaw = _amountRaw.substring(0, _amountRaw.length - 1);
        }
      } else if (key == '.') {
        if (!_amountRaw.contains('.')) _amountRaw += '.';
      } else {
        _amountRaw += key;
      }
    });
  }

  double get _amount => double.tryParse(_amountRaw) ?? 0;

  @override
  Widget build(BuildContext context) {
    final keys = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      '.', '0', '⌫',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Add balance')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Enter amount'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Text(
                '${_amountRaw.isEmpty ? '0' : _amountRaw} JOD',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: keys.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.5,
                ),
                itemBuilder: (context, i) {
                  final k = keys[i];
                  return FilledButton(
                    onPressed: () => _tapKey(k),
                    child: Text(k, style: const TextStyle(fontSize: 20)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: FilledButton(
            onPressed: _amount <= 0
                ? null
                : () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) => _WalletCheckoutScreen(amount: _amount),
                      ),
                    );
                  },
            child: const Text('Continue'),
          ),
        ),
      ),
    );
  }
}

class _WalletCheckoutScreen extends StatefulWidget {
  const _WalletCheckoutScreen({required this.amount});
  final double amount;

  @override
  State<_WalletCheckoutScreen> createState() => _WalletCheckoutScreenState();
}

class _WalletCheckoutScreenState extends State<_WalletCheckoutScreen> {
  WalletPayMethod _method = WalletPayMethod.applePay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top-up checkout')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        children: [
          ListTile(
            title: const Text('Apple Pay'),
            leading: Radio<WalletPayMethod>(
              value: WalletPayMethod.applePay,
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v!),
            ),
          ),
          ListTile(
            title: const Text('Card'),
            leading: Radio<WalletPayMethod>(
              value: WalletPayMethod.card,
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v!),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: FilledButton(
            onPressed: () async {
              await showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Top-up successful'),
                  content: Text(
                    '${widget.amount.toStringAsFixed(2)} JOD added to wallet.',
                  ),
                  actions: [
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
              if (!context.mounted) return;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text('Pay ${widget.amount.toStringAsFixed(2)} JOD'),
          ),
        ),
      ),
    );
  }
}

