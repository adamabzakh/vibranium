import 'dart:convert';
import 'dart:ui';
import 'package:app/core/api/config.dart';
import 'package:app/core/providers/user_provider.dart';
import 'package:app/core/theme/vibranium_theme.dart';
import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class MenuItemModel {
  final String name;
  final String imageUrl;
  final String category;
  final double price;

  MenuItemModel({
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.price,
  });

  factory MenuItemModel.fromApi(Map<String, dynamic> json) {
    return MenuItemModel(
      name: json['Name'] ?? '',
      imageUrl: json['IconUrl'] ?? '',
      category: _categoryMap[json['CategoryUuid']] ?? 'Unknown',
      price: (json['Price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

const Map<String, String> _categoryMap = {
  'e04f31dd-41df-44fa-9746-17946df6f2ed': 'Beverages',
  '208c3947-0899-4e8f-93a7-d6dc971b0af0': 'Pizza',
  '481422b7-e39f-43e9-a4e9-0c307aa9f0d6': 'Chocolate',
  '671ec85e-5c21-4954-8e8d-1a14c64058c8': 'Sandwiches',
  '2c6504fb-d9a9-4d49-b455-ab08269d8524': 'Smoothies',
  '2b025961-52a3-4ac6-8c51-bb47efcdeb29': 'Juice',
  'c2432d17-c65b-4c68-8f66-0b0a741bb66f': 'Burgers',
  'fa670139-e44a-4ef2-9e2d-60f274469811': 'Mojito',
  'e25fd62b-ecc1-4aeb-a82b-10e7331e7038': 'Cold Drinks',
  '7b8f7fac-36db-455e-8902-3076df50a23f': 'Hot Drinks',
  'ac22ea63-338a-4122-8e13-29b15a03a8c6': 'Starter',
  'f53f2f14-1566-4c95-9364-dc4dbba470e7': 'Pasta',
  '4f2ffcdb-cca9-4b95-8cc6-1d3dbdc6f234': 'Chips',
  '202d83fe-9794-4848-bf7b-24ff9986b0f5': 'Ice Cream',
};

class StunningMenuScreen extends StatefulWidget {
  const StunningMenuScreen({super.key});

  @override
  State<StunningMenuScreen> createState() => _StunningMenuScreenState();
}

class _StunningMenuScreenState extends State<StunningMenuScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;
  List<MenuItemModel> _allItems = [];
  List<MenuItemModel> _filteredItems = [];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _fetchItems(userProvider.user?.uuid);
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchItems(String? uuid) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.apiBaseUrl}/pos/products/get-all?UserUuid=$uuid',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentJWT',
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to load items: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final products = data['Products'] as List<dynamic>? ?? [];

      final items = products
          .map((e) => MenuItemModel.fromApi(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _allItems = items;
        _filteredItems = items;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    final result = _allItems.where((item) {
      final matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;

      final matchesSearch =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();

    setState(() {
      _filteredItems = result;
    });
  }

  List<String> get _categories {
    final set = {'All', ..._allItems.map((e) => e.category)};
    return set.toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: VibraniumColors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              VibraniumColors.black,
              VibraniumColors.surface,
              VibraniumColors.surfaceContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Vibranium Menu',
              style: theme.textTheme.titleLarge?.copyWith(
                color: VibraniumColors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () => _fetchItems(userProvider.user?.uuid),
            color: VibraniumColors.cyan,
            backgroundColor: VibraniumColors.surfaceContainer,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildSearchBar()),
                if (_isLoading)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const _LoadingCard(),
                        childCount: 6,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.72,
                          ),
                    ),
                  )
                else if (_error != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ErrorView(
                      error: _error!,
                      onRetry: () => _fetchItems(userProvider.user?.uuid),
                    ),
                  )
                else if (_allItems.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyView(),
                  )
                else ...[
                  SliverToBoxAdapter(child: _buildCategoryBar()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          const Spacer(),
                          Text(
                            '${_filteredItems.length} items',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: VibraniumColors.onSurfaceMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_filteredItems.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _NoSearchResultsView(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = _filteredItems[index];
                          return _MenuCard(item: item);
                        }, childCount: _filteredItems.length),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.72,
                            ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: VibraniumColors.surfaceContainer.withOpacity(0.92),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: VibraniumColors.outline),
            ),
            child: TextField(
              controller: _searchController,

              style: const TextStyle(color: VibraniumColors.white),
              decoration: const InputDecoration(
                icon: Icon(Icons.search_rounded, color: VibraniumColors.cyan),
                hintText: 'Search menu items...',
                hintStyle: TextStyle(color: VibraniumColors.onSurfaceMuted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBar() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final selected = category == _selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = category);
              _applyFilters();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: selected
                    ? const LinearGradient(
                        colors: [
                          VibraniumColors.purpleDeep,
                          VibraniumColors.purple,
                        ],
                      )
                    : null,
                color: selected ? null : VibraniumColors.surfaceContainer,
                border: Border.all(
                  color: selected
                      ? VibraniumColors.cyan.withOpacity(0.55)
                      : VibraniumColors.outline,
                ),
                boxShadow: selected
                    ? const [
                        BoxShadow(
                          color: Color(0x4422D3EE),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: VibraniumColors.white,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final MenuItemModel item;

  const _MenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: VibraniumColors.surfaceContainer,
        border: Border.all(color: VibraniumColors.outline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: VibraniumColors.surface),
                  Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: VibraniumColors.surface,
                      child: const Icon(
                        Icons.image_not_supported_rounded,
                        color: VibraniumColors.onSurfaceMuted,
                        size: 38,
                      ),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: VibraniumColors.surface,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: VibraniumColors.cyan,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: VibraniumColors.black.withOpacity(0.72),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: VibraniumColors.outline),
                      ),
                      child: Text(
                        '${item.price.toStringAsFixed(2)} JOD',
                        style: const TextStyle(
                          color: VibraniumColors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: VibraniumColors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: VibraniumColors.purple.withOpacity(0.16),
                        border: Border.all(
                          color: VibraniumColors.purple.withOpacity(0.30),
                        ),
                      ),
                      child: Text(
                        item.category,
                        style: const TextStyle(
                          color: VibraniumColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: VibraniumColors.surfaceContainer,
        border: Border.all(color: VibraniumColors.outline),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: VibraniumColors.onSurfaceMuted,
              size: 54,
            ),
            const SizedBox(height: 14),
            const Text(
              'Something went wrong',
              style: TextStyle(
                color: VibraniumColors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: VibraniumColors.onSurfaceMuted),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: VibraniumColors.purple,
                foregroundColor: VibraniumColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No items found',
        style: TextStyle(
          color: VibraniumColors.onSurfaceMuted,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NoSearchResultsView extends StatelessWidget {
  const _NoSearchResultsView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No items match your search or filter.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: VibraniumColors.onSurfaceMuted,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
