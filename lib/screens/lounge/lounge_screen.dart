import 'package:app/core/theme/vibranium_theme.dart';
import 'package:flutter/material.dart';

enum LoungePayMethod { applePay, card, voucher, cash }

class LoungeMenuItem {
  const LoungeMenuItem({
    required this.name,
    required this.priceJod,
    required this.imageUrl,
  });

  final String name;
  final double priceJod;
  final String imageUrl;
}

class LoungeCartLine {
  const LoungeCartLine({required this.item, required this.qty});

  final LoungeMenuItem item;
  final int qty;
}

class LoungeScreen extends StatefulWidget {
  const LoungeScreen({super.key});

  @override
  State<LoungeScreen> createState() => _LoungeScreenState();
}

class _LoungeScreenState extends State<LoungeScreen> {
  final Map<String, LoungeCartLine> _cart = {};

  void _addToCart(LoungeMenuItem item) {
    setState(() {
      final line = _cart[item.name];
      if (line == null) {
        _cart[item.name] = LoungeCartLine(item: item, qty: 1);
      } else {
        _cart[item.name] = LoungeCartLine(item: item, qty: line.qty + 1);
      }
    });
  }

  int get _cartCount => _cart.values.fold(0, (p, e) => p + e.qty);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: VibraniumColors.black,
        appBar: AppBar(
          backgroundColor: VibraniumColors.black,
          surfaceTintColor: Colors.transparent,
          title: const Text('Vibranium Lounge'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Cold'),
              Tab(text: 'Hot'),
              Tab(text: 'Food'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _MenuTab(
              onAddToCart: _addToCart,
              imageAsset: 'assets/lounge/drinks.png',
              title: 'Cold drinks',
              sections: const [
                _MenuSectionData('Juice', <LoungeMenuItem>[
                  LoungeMenuItem(
                    name: 'Strawberry',
                    priceJod: 2.00,
                    imageUrl:
                        'https://images.unsplash.com/photo-1647275485937-e82fb6a7b977?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8c3RyYXdiZXJyeSUyMGp1aWNlJTIwcHJvZHVjdHxlbnwwfHwwfHx8MA%3D%3D',
                  ),
                  LoungeMenuItem(
                    name: 'Lemon & Mint',
                    priceJod: 2.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?lemon,mint,drink',
                  ),
                  LoungeMenuItem(
                    name: 'Orange Juice',
                    priceJod: 2.50,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?orange,juice',
                  ),
                ]),
                _MenuSectionData('Mojito', <LoungeMenuItem>[
                  LoungeMenuItem(
                    name: 'Vibe Mojito',
                    priceJod: 2.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?mojito,cocktail',
                  ),
                  LoungeMenuItem(
                    name: 'Blue Curacav',
                    priceJod: 2.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?blue,cocktail,drink',
                  ),
                  LoungeMenuItem(
                    name: 'Blueberry',
                    priceJod: 2.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?blueberry,drink',
                  ),
                  LoungeMenuItem(
                    name: 'Green Apple',
                    priceJod: 2.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?green,apple,juice',
                  ),
                  LoungeMenuItem(
                    name: 'Bubble Gum',
                    priceJod: 2.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?milkshake,colorful',
                  ),
                  LoungeMenuItem(
                    name: 'Passion Fruit',
                    priceJod: 2.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?passionfruit,juice',
                  ),
                ]),
                _MenuSectionData('Smoothies', <LoungeMenuItem>[
                  LoungeMenuItem(
                    name: 'Blue Curacau',
                    priceJod: 2.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?blue,smoothie',
                  ),
                  LoungeMenuItem(
                    name: 'Orange Passion',
                    priceJod: 2.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?orange,smoothie',
                  ),
                  LoungeMenuItem(
                    name: 'Strawberry',
                    priceJod: 2.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?strawberry,smoothie',
                  ),
                  LoungeMenuItem(
                    name: 'Blue Raspberry',
                    priceJod: 2.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?raspberry,smoothie',
                  ),
                  LoungeMenuItem(
                    name: 'Pineapple',
                    priceJod: 2.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?pineapple,smoothie',
                  ),
                ]),
                _MenuSectionData('Shakes', <LoungeMenuItem>[
                  LoungeMenuItem(
                    name: 'Banana Milk',
                    priceJod: 2.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?banana,milkshake',
                  ),
                  LoungeMenuItem(
                    name: 'Strawberry Milk',
                    priceJod: 2.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?strawberry,milkshake',
                  ),
                ]),
              ],
            ),
            _MenuTab(
              onAddToCart: _addToCart,
              imageAsset: 'assets/lounge/coffee.png',
              title: 'Hot & coffee',
              sections: const [
                _MenuSectionData('Iced Coffee', <LoungeMenuItem>[
                  LoungeMenuItem(
                    name: 'Iced Cappuccino',
                    priceJod: 2.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?iced,cappuccino',
                  ),
                  LoungeMenuItem(
                    name: 'Iced Latte',
                    priceJod: 2.00,
                    imageUrl: 'https://source.unsplash.com/400x300/?iced,latte',
                  ),
                  LoungeMenuItem(
                    name: 'Iced Spanish',
                    priceJod: 2.50,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?spanish,latte',
                  ),
                  LoungeMenuItem(
                    name: 'Iced American',
                    priceJod: 2.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?iced,americano',
                  ),
                ]),
                _MenuSectionData('Frappe', <LoungeMenuItem>[
                  LoungeMenuItem(
                    name: 'Caramel Frappe',
                    priceJod: 2.50,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?caramel,frappe',
                  ),
                  LoungeMenuItem(
                    name: 'Vanilla Frappe',
                    priceJod: 2.50,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?vanilla,frappe',
                  ),
                  LoungeMenuItem(
                    name: 'Chocolate Frappe',
                    priceJod: 2.50,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?chocolate,frappe',
                  ),
                ]),
                _MenuSectionData('Hot Coffee', <LoungeMenuItem>[
                  LoungeMenuItem(
                    name: 'Cappuccino',
                    priceJod: 1.00,
                    imageUrl: 'https://source.unsplash.com/400x300/?cappuccino',
                  ),
                  LoungeMenuItem(
                    name: 'Latte',
                    priceJod: 1.00,
                    imageUrl: 'https://source.unsplash.com/400x300/?latte',
                  ),
                  LoungeMenuItem(
                    name: 'Latte Macchiato',
                    priceJod: 1.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?latte,macchiato',
                  ),
                  LoungeMenuItem(
                    name: 'Hot Chocolate',
                    priceJod: 0.75,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?hot,chocolate',
                  ),
                  LoungeMenuItem(
                    name: 'Espresso Shot',
                    priceJod: 1.00,
                    imageUrl: 'https://source.unsplash.com/400x300/?espresso',
                  ),
                  LoungeMenuItem(
                    name: 'Turkish Coffee',
                    priceJod: 0.50,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?turkish,coffee',
                  ),
                  LoungeMenuItem(
                    name: 'Lipton Tea',
                    priceJod: 0.60,
                    imageUrl: 'https://source.unsplash.com/400x300/?tea,cup',
                  ),
                  LoungeMenuItem(
                    name: 'Nescafe 3 in 1',
                    priceJod: 1.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?instant,coffee',
                  ),
                ]),
              ],
            ),
            _MenuTab(
              onAddToCart: _addToCart,
              imageAsset: 'assets/lounge/food.png',
              title: 'Food',
              sections: const [
                _MenuSectionData('Burger', <LoungeMenuItem>[
                  LoungeMenuItem(
                    name: 'BBQ Chicken Burger',
                    priceJod: 4.25,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?bbq,chicken,burger',
                  ),
                  LoungeMenuItem(
                    name: 'Classic Beef Burger',
                    priceJod: 4.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?beef,burger',
                  ),
                  LoungeMenuItem(
                    name: 'Swiss Beef Burger',
                    priceJod: 4.25,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?burger,swiss,cheese',
                  ),
                  LoungeMenuItem(
                    name: 'Smashed Burger',
                    priceJod: 4.25,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?smashed,burger',
                  ),
                ]),
                _MenuSectionData('Sandwich', <LoungeMenuItem>[
                  LoungeMenuItem(
                    name: 'Chicken Shawerma',
                    priceJod: 3.00,
                    imageUrl: 'https://source.unsplash.com/400x300/?shawarma',
                  ),
                  LoungeMenuItem(
                    name: 'Chicken Quesadilla',
                    priceJod: 3.50,
                    imageUrl: 'https://source.unsplash.com/400x300/?quesadilla',
                  ),
                  LoungeMenuItem(
                    name: 'Chicken Fajita',
                    priceJod: 3.00,
                    imageUrl: 'https://source.unsplash.com/400x300/?fajita',
                  ),
                  LoungeMenuItem(
                    name: 'Chicken Alfredo',
                    priceJod: 3.50,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?chicken,alfredo',
                  ),
                  LoungeMenuItem(
                    name: 'Zinger',
                    priceJod: 3.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?crispy,chicken,sandwich',
                  ),
                  LoungeMenuItem(
                    name: 'Vibe Hotdog',
                    priceJod: 3.00,
                    imageUrl: 'https://source.unsplash.com/400x300/?hotdog',
                  ),
                ]),
                _MenuSectionData('Pizza', <LoungeMenuItem>[
                  LoungeMenuItem(
                    name: 'BBQ Pizza',
                    priceJod: 6.00,
                    imageUrl: 'https://source.unsplash.com/400x300/?bbq,pizza',
                  ),
                  LoungeMenuItem(
                    name: 'Margherita',
                    priceJod: 5.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?margherita,pizza',
                  ),
                  LoungeMenuItem(
                    name: 'Ranch Pizza',
                    priceJod: 6.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?ranch,pizza',
                  ),
                  LoungeMenuItem(
                    name: 'Pepperoni',
                    priceJod: 5.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?pepperoni,pizza',
                  ),
                  LoungeMenuItem(
                    name: 'Alfredo Pizza',
                    priceJod: 6.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?alfredo,pizza',
                  ),
                ]),
                _MenuSectionData('Pasta', <LoungeMenuItem>[
                  LoungeMenuItem(
                    name: 'Fettuccine Alfredo',
                    priceJod: 5.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?fettuccine,alfredo',
                  ),
                  LoungeMenuItem(
                    name: 'Penne Arabiatta',
                    priceJod: 4.50,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?penne,arrabbiata',
                  ),
                  LoungeMenuItem(
                    name: 'Bolognese',
                    priceJod: 5.50,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?bolognese,pasta',
                  ),
                  LoungeMenuItem(
                    name: 'Mac & Cheese',
                    priceJod: 5.25,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?mac,and,cheese',
                  ),
                ]),
                _MenuSectionData('Appetizer', <LoungeMenuItem>[
                  LoungeMenuItem(
                    name: 'Chicken Tenders (3pcs)',
                    priceJod: 3.25,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?chicken,tenders',
                  ),
                  LoungeMenuItem(
                    name: 'French Fries',
                    priceJod: 1.20,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?french,fries',
                  ),
                  LoungeMenuItem(
                    name: 'Caesar Chicken Salad',
                    priceJod: 4.00,
                    imageUrl:
                        'https://source.unsplash.com/400x300/?caesar,salad',
                  ),
                ]),
              ],
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: _cartCount == 0
                ? OutlinedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: Text('Back', style: theme.textTheme.titleSmall),
                  )
                : FilledButton(
                    onPressed: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) =>
                              _LoungeCartScreen(cart: _cart.values.toList()),
                        ),
                      );
                    },
                    child: Text('View cart ($_cartCount)'),
                  ),
          ),
        ),
      ),
    );
  }
}

class _MenuTab extends StatelessWidget {
  const _MenuTab({
    required this.onAddToCart,
    required this.imageAsset,
    required this.title,
    required this.sections,
  });

  final void Function(LoungeMenuItem item) onAddToCart;
  final String imageAsset;
  final String title;
  final List<_MenuSectionData> sections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const SizedBox(height: 14),
        ...sections.map(
          (section) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: VibraniumColors.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.tertiary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...section.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.imageUrl,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 52,
                                    height: 52,
                                    color: Colors.black26,
                                    child: const Icon(
                                      Icons.image_not_supported_outlined,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(item.name)),
                              const SizedBox(width: 8),
                              Text('${item.priceJod.toStringAsFixed(2)} JOD'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuSectionData {
  const _MenuSectionData(this.title, this.items);
  final String title;
  final List<LoungeMenuItem> items;
}

class _LoungeCartScreen extends StatelessWidget {
  const _LoungeCartScreen({required this.cart});
  final List<LoungeCartLine> cart;

  @override
  Widget build(BuildContext context) {
    final total = cart.fold<double>(0, (s, e) => s + e.item.priceJod * e.qty);
    return Scaffold(
      appBar: AppBar(title: const Text('Lounge cart')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        children: [
          ...cart.map(
            (line) => ListTile(
              title: Text(line.item.name),
              subtitle: Text('Qty: ${line.qty}'),
              trailing: Text(
                '${(line.item.priceJod * line.qty).toStringAsFixed(2)} JOD',
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
                  builder: (_) => _LoungeCheckoutScreen(totalJod: total),
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

class _LoungeCheckoutScreen extends StatefulWidget {
  const _LoungeCheckoutScreen({required this.totalJod});
  final double totalJod;

  @override
  State<_LoungeCheckoutScreen> createState() => _LoungeCheckoutScreenState();
}

class _LoungeCheckoutScreenState extends State<_LoungeCheckoutScreen> {
  LoungePayMethod _method = LoungePayMethod.applePay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lounge checkout')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        children: [
          ListTile(
            title: const Text('Apple Pay'),
            leading: Radio<LoungePayMethod>(
              value: LoungePayMethod.applePay,
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v!),
            ),
          ),
          ListTile(
            title: const Text('Card'),
            leading: Radio<LoungePayMethod>(
              value: LoungePayMethod.card,
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v!),
            ),
          ),
          ListTile(
            title: const Text('Voucher'),
            leading: Radio<LoungePayMethod>(
              value: LoungePayMethod.voucher,
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v!),
            ),
          ),
          ListTile(
            title: const Text('Cash (walk-ins only)'),
            subtitle: const Text('Disabled in app ordering'),
            enabled: false,
            leading: Radio<LoungePayMethod>(
              value: LoungePayMethod.cash,
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
              await showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Order placed'),
                  content: Text(
                    'Your lounge order is confirmed.\nTotal: ${widget.totalJod.toStringAsFixed(2)} JOD',
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
            child: Text('Pay ${widget.totalJod.toStringAsFixed(2)} JOD'),
          ),
        ),
      ),
    );
  }
}
