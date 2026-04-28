import 'package:app/core/providers/queue_provider.dart';
import 'package:app/core/providers/user_provider.dart';
import 'package:app/core/routing/vibranium_route.dart';
import 'package:app/screens/book_pc/book_pc_screen.dart';
import 'package:app/screens/waiting_list/dash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class WaitingListScreen extends StatefulWidget {
  const WaitingListScreen({super.key});

  @override
  State<WaitingListScreen> createState() => _WaitingListScreenState();
}

class _WaitingListScreenState extends State<WaitingListScreen> {
  Set<String> selectedLanes = {};
  Timer? _timer;

  // Vibranium UI Colors
  final Color bgDark = const Color(0xFF000000);
  final Color cardDark = const Color(0xFF14141A);
  final Color accentCyan = Colors.white;
  final Color accentMagenta = const Color(0xFFFF00FF);
  final Color accentGreen = const Color(0xFF00FF88);

  @override
  void initState() {
    super.initState();
    _refresh();
    // Auto-refresh every 20 seconds to sync with the Matchmaker
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _refresh() async {
    final waitingList = context.read<QueueProvider>();
    final user = context.read<UserProvider>().user;

    await waitingList.getWaitingListActiv();

    if (waitingList.isActiveList) {
      if (user != null) {
        context.read<QueueProvider>().updateQueueStats(user.uuid);
      }
    }
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final qp = context.watch<QueueProvider>();
    final up = context.watch<UserProvider>();
    bool inQueue = qp.bestPosition != null;
    final allWaitingUsers = qp.fullWaitingList;

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 66,
        actions: [
          (inQueue)
              ? Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        qp.exitWaitingList(up.user!.uuid);
                      },
                      icon: Icon(Icons.exit_to_app, color: Colors.red),
                    ),
                    Text(
                      "EXIT",
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                )
              : Container(),
        ],
        title: Text(
          "Waiting list",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: (qp.isLoading)
          ? Center(child: CircularProgressIndicator())
          : (qp.isActiveList)
          ? SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // --- BIG COUNTER SECTION ---
                  Center(
                    child: Column(
                      children: [
                        Text(
                          inQueue
                              ? "${qp.bestPosition?['in_front']}"
                              : "${selectedLanes.length}",
                          style: TextStyle(
                            fontSize: 100,
                            height: 1,
                            fontWeight: FontWeight.w500,
                            color: inQueue ? accentCyan : Colors.white10,
                            shadows: inQueue
                                ? [
                                    Shadow(
                                      blurRadius: 25,
                                      color: accentCyan.withOpacity(0.6),
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                        Text(
                          inQueue ? "PEOPLE IN FRONT" : "TYPES SELECTED",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  // --- SELECTION VIEW (User not in queue) ---
                  if (!inQueue) ...[
                    Text(
                      "SELECT PC TYPES",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(height: 3, width: 60, color: Colors.white),
                    const SizedBox(height: 25),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 2.2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: ['normal', 'stage', 'vip', 'master'].map((id) {
                        bool sel = selectedLanes.contains(id);
                        return InkWell(
                          onTap: () => setState(
                            () => sel
                                ? selectedLanes.remove(id)
                                : selectedLanes.add(id),
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: sel
                                  ? accentCyan.withOpacity(0.1)
                                  : cardDark,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: sel ? accentCyan : Colors.white10,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                id.toUpperCase(),
                                style: TextStyle(
                                  color: sel ? accentCyan : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    VibraniumCategoryStatus(),
                    const SizedBox(height: 20),

                    Center(
                      child: TextButton.icon(
                        onPressed: () => setState(
                          () => selectedLanes = {
                            'normal',
                            'stage',
                            'vip',
                            'master',
                          },
                        ),
                        icon: Icon(Icons.bolt, color: accentCyan, size: 18),
                        label: Text(
                          "SELECT ANY AVAILABLE PC",
                          style: TextStyle(
                            color: accentCyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentMagenta,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 10,
                        ),
                        onPressed: selectedLanes.isEmpty || qp.isLoading
                            ? null
                            : () async {
                                String lanesCsv = selectedLanes.join(',');

                                bool success = await qp.joinWaitingList(
                                  up.user!.uuid,
                                  up.user!.username,
                                  lanesCsv,
                                );
                                if (success)
                                  setState(() => selectedLanes.clear());
                              },
                        child: qp.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "JOIN WAITING LIST",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 30),
                  ]
                  // --- LIVE DASHBOARD VIEW (User is in queue) ---
                  else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "LIVE WAITING LIST",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 4,
                              width: 40,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        Text(
                          "${allWaitingUsers.length} TOTAL",
                          style: const TextStyle(
                            color: Colors.white24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allWaitingUsers.length,
                      itemBuilder: (context, index) {
                        final person = allWaitingUsers[index];
                        bool isMe = person['user_uuid'] == up.user!.uuid;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardDark,
                            borderRadius: BorderRadius.circular(15),
                            border: Border(
                              left: BorderSide(
                                color: isMe
                                    ? accentGreen
                                    : accentMagenta.withOpacity(0.2),
                                width: 8,
                              ),
                            ),
                            boxShadow: isMe
                                ? [
                                    BoxShadow(
                                      color: accentGreen.withOpacity(0.1),
                                      blurRadius: 15,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              Text(
                                "${index + 1}",
                                style: TextStyle(
                                  color: isMe ? accentGreen : Colors.white12,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      person['username']
                                          .toString()
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: isMe
                                            ? Colors.white
                                            : Colors.white70,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      person['queue_type']
                                          .toString()
                                          .replaceAll(',', ' • ')
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: isMe
                                            ? accentGreen.withOpacity(0.7)
                                            : Colors.white24,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isMe)
                                Icon(Icons.stars, color: accentGreen, size: 24),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 60),
                ],
              ),
            )
          : Center(
              child: Container(
                padding: const EdgeInsets.all(40),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  // Matching: background: rgba(16, 10, 28, 0.6);
                  color: const Color(0xFF100A1C).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(28),
                  // Matching: border: 1px solid rgba(142, 73, 230, 0.22);
                  border: Border.all(
                    color: const Color(0xFF8E49E6).withOpacity(0.22),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Matching: h1 { color: #2fd5ff; ... }
                    const Text(
                      'WAITING LIST OFFLINE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF2FD5FF),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Matching: p { color: #9f90bb; ... }
                    const Text(
                      'Waiting list is only Available when the venue is full , you can book one of our free pcs',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF9F90BB),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          vibraniumPageRoute(BookPcScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8E49E6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Book Pc'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
