import 'package:flutter/material.dart';

class RankInfo {
  final String name;
  final String description;
  final String image;

  const RankInfo({
    required this.name,
    required this.description,
    required this.image,
  });
}

class RanksSliderScreen extends StatefulWidget {
  const RanksSliderScreen({super.key});

  @override
  State<RanksSliderScreen> createState() => _RanksSliderScreenState();
}

class _RanksSliderScreenState extends State<RanksSliderScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;

  final List<RankInfo> ranks = const [
    RankInfo(
      name: "Unranked",
      description: "Entry to vibranium rank , minimum spent 50Jds per act",
      image: "assets/branding/vibranium_logo.png",
    ),
    RankInfo(
      name: "Cobalt",
      description:
          "5 hours free every week until the end of the act , minimum spent 100Jds per act",
      image: "assets/branding/cobalt.png",
    ),
    RankInfo(
      name: "Obsidian",
      description:
          "7 hours free every week until the end of the act , minimum spent 150Jds per act",
      image: "assets/branding/obsidian.png",
    ),
    RankInfo(
      name: "VIBE: Eternal",
      description:
          "10 hours free every week until the end of the act , minimum spent 200Jds per act",
      image: "assets/branding/vibe_eternal.png",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Ranks"), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: ranks.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final rank = ranks[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              rank.image,
                              height: 140,
                              width: 140,
                              fit: BoxFit.contain,
                            ),

                            const SizedBox(height: 16),
                            Text(
                              rank.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                ranks.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "* All added hours as RANK REWARD have access to all (Master, Vip, Stage, Normal)\n\n"
                "* The ACT period is ONE month\n\n"
                "* Rank resets for all player after every act\n\n"
                "* Minimum spent to enter rank is 50 JDs per act",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
