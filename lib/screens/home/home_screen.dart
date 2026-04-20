import 'package:app/core/func/date_time.dart';
import 'package:app/core/models/session.dart';
import 'package:app/core/models/user_rank.dart';
import 'package:app/core/providers/pc_provider.dart';
import 'package:app/core/providers/queue_provider.dart';
import 'package:app/core/providers/user_provider.dart';
import 'package:app/core/routing/vibranium_route.dart';
import 'package:app/core/theme/vibranium_theme.dart';
import 'package:app/screens/auth/login_screen.dart';
import 'package:app/screens/book_pc/book_pc_screen.dart';
import 'package:app/screens/events/events_screen.dart';
import 'package:app/screens/home/meal_barcode.dart';
import 'package:app/screens/home/rank.dart';
import 'package:app/screens/lounge/lounge_screen.dart';
import 'package:app/screens/points/points_screen.dart';
import 'package:app/screens/tournaments/tournaments_screen.dart';
import 'package:app/screens/waiting_list/waiting_list.dart';
import 'package:app/screens/wallet/time_balance_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kLogoAsset = 'assets/branding/vibranium_logo.png';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setState(() {
      isLoading = true;
    });
    final userProvider = context.read<UserProvider>();
    final pcProvider = context.read<PcProvider>();
    final queueProvider = context.read<QueueProvider>();

    await userProvider.getUserSessions();

    await pcProvider.fetchMachines();

    userProvider.setUser(
      await userProvider.getUserByUuid(userProvider.user!.uuid),
    );

    await userProvider.getCurrectLoggedingPC(pcProvider);
    await queueProvider.updateQueueStats(userProvider.user!.uuid);

    await pcProvider.fetchConsoles();
    print("Collection status : ${userProvider.user!.rank.hasCollected}");
    await userProvider.getUserRank();
    await userProvider.updateUserRank(isUpdatingCollection: false);
    await userProvider.registerUser();

    if (kDebugMode) {
      print("Collection status : ${userProvider.user!.rank.hasCollected}");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final userProvider = context.watch<UserProvider>();
    final pcProvider = context.watch<PcProvider>();
    final queueProvider = context.watch<QueueProvider>();

    final user = userProvider.user;

    return Scaffold(
      drawer: const _VibraniumDrawer(),
      body: Builder(
        builder: (scaffoldContext) {
          return RefreshIndicator(
            onRefresh: () async {
              init();
            },

            child: (isLoading)
                ? Center(child: CircularProgressIndicator(strokeWidth: 2))
                : CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        elevation: 0,
                        backgroundColor: VibraniumColors.black,
                        surfaceTintColor: Colors.transparent,
                        leading: IconButton(
                          tooltip: 'Menu',
                          icon: Icon(
                            Icons.menu_rounded,
                            color: colorScheme.onSurface,
                          ),
                          onPressed: () {
                            Scaffold.of(scaffoldContext).openDrawer();
                          },
                        ),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Material(
                              color: VibraniumColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(999),
                              child: InkWell(
                                onTap: () => Navigator.of(context).push<void>(
                                  vibraniumPageRoute(const PointsScreen()),
                                ),
                                borderRadius: BorderRadius.circular(999),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.stars_rounded,
                                        size: 18,
                                        color: colorScheme.tertiary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        (user!.pointsBalance ?? 0)
                                            .toStringAsFixed(0),
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'vibs',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                          child: Column(
                            children: [
                              Image.asset(
                                _kLogoAsset,
                                height: 168,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.shield_outlined,
                                  color: colorScheme.primary,
                                  size: 96,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Welcome back, ${userProvider.user!.firstName}',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),

                              Text(
                                'Vibranium E-Sports',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: [
                                  _StatusChip(
                                    icon: Icons.dns_rounded,
                                    label:
                                        '${pcProvider.pcs.where((pc) => pc.state!.toLowerCase() == "readyforuser" || pc.state!.toLowerCase() == "off").length} / ${pcProvider.pcs.length} PCs free',
                                    color: colorScheme.tertiary,
                                  ),
                                  _StatusChip(
                                    icon: Icons.sports_esports_rounded,
                                    label:
                                        '${pcProvider.consoles.where((console) => console['Users'].isEmpty && console['Guests'].isEmpty).length} / ${pcProvider.consoles.length} PS5 free',
                                    color: colorScheme.primary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (userProvider.currentBookedPc != null)
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          sliver: SliverToBoxAdapter(
                            child: FutureBuilder<Map<String, String>?>(
                              future: loadCurrentBookedPc(),
                              builder: (context, snapshot) {
                                final current = snapshot.data;
                                if (current == null ||
                                    (current['pcId'] ?? '').isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return _CurrentBookedPcCard(current: current);
                              },
                            ),
                          ),
                        ),

                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              rankCard(userProvider.user!.rank),
                              if (userProvider.user!.rank.rank.toUpperCase() ==
                                      "VIBE: ETERNAL" &&
                                  userProvider.user!.rank.remainMeals > 0)
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.grey[900]!,
                                        Colors.black,
                                        Colors.black,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF00E5FF,
                                        ).withOpacity(0.2),
                                        blurRadius: 25,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                    border: Border.all(
                                      color: const Color(
                                        0xFF00E5FF,
                                      ).withOpacity(0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                      horizontal: 28,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Eternal Member Special Benefits",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.purple,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          "Remaining Meals: ${userProvider.user!.rank.remainMeals}",
                                        ),
                                        SizedBox(height: 10),
                                        ElevatedButton(
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(9),
                                              ),
                                            ),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                  Colors.purple,
                                                ),
                                          ),
                                          onPressed:
                                              userProvider
                                                      .user!
                                                      .rank
                                                      .remainMeals >
                                                  0
                                              ? () async {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                          "Redeem Free Meal",
                                                        ),
                                                        content: Text(
                                                          "Are you sure you want to redeem one of your free meals? You have ${userProvider.user!.rank.remainMeals} remaining.\nYou have to be at the Vibe Lounge counter to redeem, Other wise you will lose the meal without getting the reward.",
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                  context,
                                                                ).pop(),
                                                            child: Text(
                                                              "Cancel",
                                                            ),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed:
                                                                (userProvider
                                                                    .isLoading)
                                                                ? null
                                                                : () async {
                                                                    await userProvider
                                                                        .redeemFreeMeal(
                                                                          context,
                                                                        );
                                                                    Navigator.of(
                                                                      context,
                                                                    ).pop();
                                                                    await Navigator.of(
                                                                          context,
                                                                        )
                                                                        .push<
                                                                          void
                                                                        >(
                                                                          vibraniumPageRoute(
                                                                            MemberBarCodeScreen(
                                                                              userRank: userProvider.user!.rank.rank,
                                                                              userUuid: userProvider.user!.uuid,
                                                                            ),
                                                                          ),
                                                                        )
                                                                        .then(
                                                                          (
                                                                            _,
                                                                          ) => setState(
                                                                            () {
                                                                              init();
                                                                            },
                                                                          ),
                                                                        );
                                                                  },
                                                            child: Text(
                                                              "Redeem",
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              : null,
                                          child: Text(
                                            "Redeem Free Meal",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),

                        sliver: SliverToBoxAdapter(
                          child: Text(
                            'Your balances',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            children: [
                              Expanded(
                                child: _BalanceCard(
                                  label: 'Time balance',
                                  value: formatDuration(user.timeRemaining),
                                  hint:
                                      'Last seen ${formatLastSeen(user.lastSeen ?? DateTime.now())}',
                                  icon: Icons.timer_outlined,
                                  accent: colorScheme.tertiary,
                                  onTap: () => Navigator.of(context).push<void>(
                                    vibraniumPageRoute(
                                      const TimeBalanceScreen(),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _BalanceCard(
                                  label: 'Waiting List',
                                  value: queueProvider.fullWaitingList.length
                                      .toString(),
                                  suffix: 'total in-line',
                                  hint: 'Add your self to queue',
                                  icon: Icons.format_list_numbered_rounded,
                                  accent: colorScheme.primary,
                                  onTap: () => Navigator.of(context).push<void>(
                                    vibraniumPageRoute(
                                      const WaitingListScreen(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            'Quick actions',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _ActionCard(
                              icon: Icons.computer_rounded,
                              title: 'Book PC',
                              subtitle: 'Pick station & time slot',
                              onTap: () => Navigator.of(context).push<void>(
                                vibraniumPageRoute(const BookPcScreen()),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _ActionCard(
                              icon: Icons.access_time,
                              title: 'Add your self to Waiting list',
                              subtitle:
                                  'Add your self to the waiting list queue',
                              onTap: () => Navigator.of(context).push<void>(
                                vibraniumPageRoute(const WaitingListScreen()),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _ActionCard(
                              icon: Icons.weekend_outlined,
                              title: 'Vibranium Lounge',
                              subtitle: 'Vibranium Cafe & Restaurant',
                              onTap: () => Navigator.of(context).push<void>(
                                vibraniumPageRoute(const StunningMenuScreen()),
                              ),
                            ),
                          ]),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Last Sessions',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).push<void>(
                                      vibraniumPageRoute(
                                        SessionsScreen(
                                          sessions: userProvider.userSesstions,
                                        ),
                                      ),
                                    ),
                                child: const Text('See all'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final e = userProvider.userSesstions[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    index ==
                                        userProvider.userSesstions.length - 1
                                    ? 0
                                    : 10,
                              ),
                              child: _EventTile(event: e),
                            );
                          }, childCount: userProvider.userSesstions.length),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 28)),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget rankCard(UserRank rank) {
    final UserProvider userProvider = context.read<UserProvider>();
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RanksSliderScreen()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
        child: Stack(
          children: [
            VibraniumVisaCard(
              totalSpent: rank.totalSpent,
              userName:
                  "${userProvider.user!.firstName} ${userProvider.user!.lastName} (${userProvider.user!.username})",
            ),
            (rank.totalSpent <= 50)
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    width: double.infinity,
                    height: 230,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_rounded, color: Colors.black, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'Your rank is locked',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: Text(
                            'Raise your monthly spending to minimum 50 JOD to unlock your Loyality Pass \n\nCurrent monthly spending: ${rank.totalSpent.toStringAsFixed(2)} JOD',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class VibraniumVisaCard extends StatefulWidget {
  double totalSpent;
  final String userName;

  VibraniumVisaCard({
    super.key,
    required this.totalSpent,
    required this.userName,
  });

  @override
  State<VibraniumVisaCard> createState() => _VibraniumVisaCardState();
}

class _VibraniumVisaCardState extends State<VibraniumVisaCard> {
  @override
  Widget build(BuildContext context) {
    String rankName = "";
    Color themeColor = const Color(0xFFCD7F32); // default bronze-like
    double progress = 0.0;
    double nextGoal = 50.0;

    final userProvider = context.read<UserProvider>();

    if (widget.totalSpent >= 250) {
      rankName = "VIBE: ETERNAL";
      themeColor = const Color(0xFF00E5FF); // Electric Blue
      progress = 1.0;
      nextGoal = 250.0;
    } else if (widget.totalSpent >= 150) {
      rankName = "OBSIDIAN";
      themeColor = const Color(0xFF673AB7); // Purple
      progress = (widget.totalSpent - 150) / 50;
      nextGoal = 200.0;
    } else if (widget.totalSpent >= 100) {
      rankName = "Cobalt";
      themeColor = const Color(0xFF3F51B5); // Blue
      progress = (widget.totalSpent - 100) / 50;
      nextGoal = 150.0;
    } else if (widget.totalSpent >= 50) {
      rankName = "Unranked";
      themeColor = const Color(0xFFC0C0C0);
      progress = (widget.totalSpent - 50) / 50;
      nextGoal = 100.0;
    } else {
      rankName = "None";
      themeColor = const Color(0xFFCD7F32);
      progress = widget.totalSpent / 50;
      nextGoal = 50.0;
    }

    // keep progress safe
    progress = progress.clamp(0.0, 1.0);

    final imagePath =
        "assets/branding/${rankName.toLowerCase().replaceAll(" ", "_").replaceAll(":", "")}.png";

    return Container(
      width: double.infinity,
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[900]!, Colors.black, Colors.black],
        ),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.2),
            blurRadius: 25,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: themeColor.withOpacity(0.4), width: 1),
      ),
      child: ClipRRect(
        // Ensures progress bar stays inside rounded corners
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // --- RANK IMAGE PLACEHOLDER ---
            (rankName == "None")
                ? Container()
                : Positioned(
                    right: 20,
                    top: 40,
                    child: Opacity(
                      opacity: 0.4,
                      child: Image.asset(
                        imagePath, // Pass your rank icon here
                        width: 140,
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

            // --- CARD CONTENT ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "VIBRANIUM",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rankName.toUpperCase(),
                        style: TextStyle(
                          color: themeColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        "EXCLUSIVE LOYALTY PASS",
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      (widget.totalSpent >= 200)
                          ? Container()
                          : Text(
                              "${nextGoal - widget.totalSpent} JD TO NEXT LEVEL",
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                    ],
                  ),

                  (userProvider.user!.rank.hasCollected == "false" &&
                          userProvider.user!.rank.rank != "Unranked")
                      ? ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              userProvider.initLoad();
                            });
                            await userProvider.addTime(
                              prizeOld: int.parse(
                                userProvider.user!.rank.reward,
                              ),
                            );
                            await userProvider.updateUserRank(
                              isUpdatingCollection: true,
                            );
                            userProvider.setUser(
                              await userProvider.getUserByUuid(
                                userProvider.user!.uuid,
                              ),
                            );
                            await userProvider.getUserRank();
                            setState(() {
                              userProvider.initLoad();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: Text(
                            'Collect ${userProvider.user!.rank.reward} Hours reward',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),

            // --- PROGRESS LINE (BOTTOM PINNED) ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 6,
                width: double.infinity,
                color: Colors.white.withOpacity(0.05),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeColor,
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withOpacity(0.8),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentBookedPcCard extends StatelessWidget {
  const _CurrentBookedPcCard({required this.current});
  final Map<String, String> current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = context.watch<UserProvider>();
    final colorScheme = theme.colorScheme;
    final pcId = current['pcId'] ?? '';
    final category = (current['categoryId'] ?? '').replaceAll('_', ' ');
    final areaRaw = current['areaId'] ?? '';
    final area = areaRaw.isEmpty
        ? ''
        : areaRaw.replaceAll('_', ' ').toUpperCase();
    return Material(
      color: VibraniumColors.surfaceContainer,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Logout from PC'),
              content: Text('Are you sure you want to logout from PC?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),

                FilledButton(
                  onPressed: () async {
                    final success = await userProvider.logoutUserFromPc();
                    if (success) {
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to logout from PC'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text('Logout'),
                ),
              ],
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.computer_rounded, color: colorScheme.error),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Currently logged in',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pcId,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${area.isEmpty ? category : '$category · $area'} . tap to logout',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VibraniumDrawer extends StatelessWidget {
  const _VibraniumDrawer();

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Drawer(
      backgroundColor: VibraniumColors.black,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Material(
              color: VibraniumColors.surfaceContainer,
              child: SizedBox(
                height: 240,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        _kLogoAsset,
                        height: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.shield_outlined,
                          color: colorScheme.primary,
                          size: 48,
                        ),
                      ),
                      Text(
                        user!.username.toUpperCase(),
                        maxLines: 1,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user!.firstName + " " + user.lastName,
                        maxLines: 1,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 4),
                      Text(
                        "Phone : ${user.phone}",
                        maxLines: 1,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Email : ${user.email}",
                        maxLines: 1,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _DrawerTile(
              icon: Icons.home_rounded,
              iconColor: colorScheme.primary,
              title: 'Home',
              onTap: () => Navigator.of(context).pop(),
            ),
            _DrawerTile(
              icon: Icons.computer_rounded,
              iconColor: colorScheme.primary,
              title: 'Book PC',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push<void>(vibraniumPageRoute(const BookPcScreen()));
              },
            ),
            _DrawerTile(
              icon: Icons.format_list_numbered,
              iconColor: colorScheme.secondary,
              title: 'Wait list & Queues',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push<void>(vibraniumPageRoute(const WaitingListScreen()));
              },
            ),
            _DrawerTile(
              icon: Icons.stars_rounded,
              iconColor: colorScheme.tertiary,
              title: 'Points & rewards',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push<void>(vibraniumPageRoute(const PointsScreen()));
              },
            ),
            _DrawerTile(
              icon: Icons.weekend_rounded,
              iconColor: const Color(0xFF81C784),
              title: 'Vibranium Lounge',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push<void>(vibraniumPageRoute(const StunningMenuScreen()));
              },
            ),
            _DrawerTile(
              icon: Icons.emoji_events_outlined,
              iconColor: const Color(0xFFFFB74D),
              title: 'Tournaments',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push<void>(vibraniumPageRoute(const TournamentsScreen()));
              },
            ),

            _DrawerTile(
              icon: Icons.logout_rounded,
              iconColor: colorScheme.error,
              title: 'Log out',
              onTap: () {
                SharedPreferences.getInstance().then((c) => c.clear());
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  vibraniumPageRoute(const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );

    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
      child: child,
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.hint,
    required this.onTap,
    this.suffix,
  });
  final String label;
  final String value;

  final String? suffix;
  final String hint;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Material(
      color: VibraniumColors.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: accent),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (suffix != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      suffix!,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                hint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Material(
      color: VibraniumColors.surfaceContainer,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
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
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});
  final GgSession event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Material(
      color: VibraniumColors.surfaceContainer,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.primaryColor.withAlpha(14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.computer, color: theme.primaryColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pc session",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "From ${DateFormat("yyyy/mm/dd hh:mm").format(event.addedAt)} - to ${DateFormat("yyyy/mm/dd hh:mm").format(event.endDateTime!)}",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatLastSeen(event.endDateTime!),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
