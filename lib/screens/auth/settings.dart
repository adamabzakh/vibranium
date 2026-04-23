import 'package:app/core/providers/user_provider.dart';
import 'package:app/core/routing/vibranium_route.dart';
import 'package:app/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  Future<String> getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSectionHeader("Account"),
          _buildListTile(Icons.logout, "Logout", Colors.white, () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Logout'),
                content: Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      SharedPreferences.getInstance().then((c) => c.clear());
                      Navigator.of(context).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        vibraniumPageRoute(const LoginScreen()),
                        (route) => false,
                      );
                    },
                    child: Text('Logout'),
                  ),
                ],
              ),
            );
          }),
          _buildSectionHeader("Support & Feedback"),
          _buildListTile(
            Icons.support_agent,
            "Contact Support",
            Colors.white,
            () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Contact Support'),
                  content: Text(
                    'Please contact support at support@vibraniumjobooking.com or call +962 79 138 0808',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => launchUrl(
                        Uri.parse('mailto:support@vibraniumjobooking.com'),
                      ),
                      child: Text('Open Email'),
                    ),
                    TextButton(
                      onPressed: () =>
                          launchUrl(Uri.parse('tel:+962791380808')),
                      child: Text('Call Support'),
                    ),
                  ],
                ),
              );
            },
          ),
          _buildListTile(
            Icons.lightbulb_outline,
            "Feature Request",
            Colors.white,
            () {
              launchUrl(Uri.parse('https://forms.gle/P2hAhHxaovsSG8878'));
            },
          ),

          _buildSectionHeader("App Info"),
          FutureBuilder(
            future: getAppVersion(),
            builder: (context, asyncSnapshot) {
              return ListTile(
                title: Text(
                  "App Version",
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  asyncSnapshot.data ?? '',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
          ),

          const Divider(color: Color(0xFF30363D), height: 40),

          // DANGER ZONE (Crucial for Apple Review)
          _buildSectionHeader("Danger Zone"),
          _buildListTile(
            Icons.delete_forever,
            "Delete Account",
            Colors.redAccent,
            () {
              _showDeleteConfirmation(context, userProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Color(0xFF58A6FF),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildListTile(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    UserProvider userProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF161B22),
        title: Text("Delete Account?", style: TextStyle(color: Colors.white)),
        content: Text(
          "This action is permanent and will delete all your gaming data and credits. No backup after this action.",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final deleteCon = TextEditingController();
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Last step before delete'),
                    content: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Type : delete ${userProvider.user!.username}",
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: deleteCon,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () async {
                          if (deleteCon.text !=
                              "delete ${userProvider.user!.username}") {
                            print("no match");
                            return;
                          }
                          await userProvider.deleteAcc();

                          SharedPreferences.getInstance().then(
                            (c) => c.clear(),
                          );
                          Navigator.of(context).pop();
                          Navigator.of(context).pushAndRemoveUntil(
                            vibraniumPageRoute(const LoginScreen()),
                            (route) => false,
                          );
                        },
                        child: Text("Delete"),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text("Delete"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
