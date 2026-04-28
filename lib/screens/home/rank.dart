import 'dart:ui';
import 'package:app/core/providers/user_provider.dart';
import 'package:app/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RankInfo {
  final String name;
  final String description;
  final String image;
  final double minSpend;
  final List<Color> cardColors;
  final Color accentColor;

  const RankInfo({
    required this.name,
    required this.description,
    required this.image,
    required this.minSpend,
    required this.cardColors,
    required this.accentColor,
  });
}

class RanksSliderScreen extends StatefulWidget {
  const RanksSliderScreen({super.key});

  @override
  State<RanksSliderScreen> createState() => _RanksSliderScreenState();
}

class _RanksSliderScreenState extends State<RanksSliderScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  final List<RankInfo> ranks = const [
    RankInfo(
      name: "Unranked",
      description: "Entry to vibranium rank\nMin spend 50 JOD.",
      image: "assets/branding/vibranium_logo.png",
      minSpend: 50,
      accentColor: Colors.white70,
      cardColors: [Color(0xFF1A1A1A), Color(0xFF000000)],
    ),
    RankInfo(
      name: "Cobalt",
      description: "5 hours free weekly\nMin spend 100 JOD.",
      image: "assets/branding/cobalt.png",
      minSpend: 100,
      accentColor: Color(0xFF2FD5FF),
      cardColors: [Color(0xFF0A192F), Color(0xFF00050A)],
    ),
    RankInfo(
      name: "Obsidian",
      description: "7 hours free weekly\nMin spend 150 JOD.",
      image: "assets/branding/obsidian.png",
      minSpend: 150,
      accentColor: Color(0xFFA061FF),
      cardColors: [Color(0xFF140A20), Color(0xFF05010A)],
    ),
    RankInfo(
      name: "VIBE Eternal",
      description: "10 hours & 2 free meals\nMin spend 250 JOD.",
      image: "assets/branding/vibe_eternal.png",
      minSpend: 250,
      accentColor: Color(0xFFFFD700),
      cardColors: [Color(0xFF201A0A), Color(0xFF0A0801)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final currentRank = userProvider.user!.rank;
    final totalSpent = currentRank.totalSpent;

    return Scaffold(
      backgroundColor: const Color(0xFF020205),
      appBar: AppBar(
        title: const Text(
          "LOYALTY PASSES",
          style: TextStyle(
            letterSpacing: 3,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Current Status Card (VibraniumVisaCard)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Hero(
                tag: "rank",
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(24),
                  child: Material(
                    child: VibraniumVisaCard(
                      totalSpent: userProvider.user!.rank.totalSpent,
                      userName:
                          "${userProvider.user!.firstName} ${userProvider.user!.lastName} (${userProvider.user!.username})",
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Tier Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "AVAILABLE TIERS",
                  style: TextStyle(
                    color: Colors.white30,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // The Carousel
            SizedBox(
              height: 260, // Classic card height ratio
              child: PageView.builder(
                controller: _pageController,
                itemCount: ranks.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final rank = ranks[index];
                  final isLocked = totalSpent < rank.minSpend;
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _currentPage == index ? 1.0 : 0.5,
                    child: _buildPremiumMembershipCard(
                      rank,
                      isLocked,
                      totalSpent,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),
            _buildPageIndicator(),
            const SizedBox(height: 40),
            _buildFooterNotes(),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumMembershipCard(
    RankInfo rank,
    bool isLocked,
    double currentSpend,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: rank.cardColors,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: isLocked ? Colors.black : rank.accentColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle Tech Pattern Overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Icon(
                Icons.military_tech_outlined,
                size: 200,
                color: rank.accentColor,
              ),
            ),
          ),

          // Diagonal Sheen (The Metalic Look)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: const Alignment(0.5, 0.5),
                  colors: [Colors.white.withOpacity(0.05), Colors.transparent],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "VIBRANIUM",
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    if (isLocked)
                      const Icon(
                        Icons.lock_outline,
                        color: Colors.white24,
                        size: 16,
                      )
                    else
                      Icon(Icons.verified, color: rank.accentColor, size: 18),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rank.name.toUpperCase(),
                            style: TextStyle(
                              color: isLocked
                                  ? Colors.white54
                                  : rank.accentColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            rank.description,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Image.asset(
                      rank.image,
                      height: 80,
                      width: 80,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Progress or Spend requirement
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isLocked
                          ? "REQUIRES ${rank.minSpend} JOD"
                          : "RANK UNLOCKED",
                      style: TextStyle(
                        color: isLocked ? Colors.white24 : rank.accentColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    if (isLocked)
                      Text(
                        "${(currentSpend / rank.minSpend * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(
                          color: Colors.white24,
                          fontSize: 9,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(ranks.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 4,
          width: _currentPage == index ? 20 : 4,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? const Color(0xFF2FD5FF)
                : Colors.white10,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  Widget _buildFooterNotes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PROGRAM DETAILS",
            style: TextStyle(
              color: Color(0xFF2FD5FF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          _noteItem("Tier rewards are issued weekly until the ACT resets."),
          _noteItem(
            "Access granted to Master, VIP, Stage, and Normal stations.",
          ),
          _noteItem("Spendings are calculated based on monthly activities."),
          _noteItem("The ranking system resets on the 1st of every month."),
        ],
      ),
    );
  }

  Widget _noteItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        "• $text",
        style: const TextStyle(
          color: Colors.white30,
          fontSize: 12,
          height: 1.4,
        ),
      ),
    );
  }
}
