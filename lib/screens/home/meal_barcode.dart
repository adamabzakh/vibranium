import 'package:app/core/theme/vibranium_theme.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart'; // Add this

class MemberBarCodeScreen extends StatefulWidget {
  final String userUuid;
  final String userRank;

  const MemberBarCodeScreen({
    super.key,
    required this.userUuid,
    required this.userRank,
  });

  @override
  State<MemberBarCodeScreen> createState() => _MemberBarCodeScreenState();
}

class _MemberBarCodeScreenState extends State<MemberBarCodeScreen> {
  @override
  void initState() {
    super.initState();
    _enablePreventScreenshot();
  }

  @override
  void dispose() {
    _disablePreventScreenshot();
    super.dispose();
  }

  // Activates the protection
  Future<void> _enablePreventScreenshot() async {
    await ScreenProtector.preventScreenshotOn();
  }

  // Deactivates protection so other screens can take screenshots
  Future<void> _disablePreventScreenshot() async {
    await ScreenProtector.preventScreenshotOff();
  }

  @override
  Widget build(BuildContext context) {
    final isEternal = widget.userRank == 'VIBE: Eternal';
    final accentColor = isEternal
        ? VibraniumColors.purple
        : VibraniumColors.cyan;

    return Scaffold(
      backgroundColor: VibraniumColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: VibraniumColors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Vibe Lounge One-time Pass',
          style: TextStyle(
            color: VibraniumColors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Center(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.asset(
                    'assets/branding/vibranium_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: VibraniumColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: VibraniumColors.outline),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accentColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        widget.userRank.toUpperCase(),
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white, // Barcodes love white backgrounds
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: BarcodeWidget(
                        barcode: Barcode.code128(),
                        data: "15072002107",
                        color: Colors.black, // Use black bars here
                        width: double.infinity,
                        height: 120,
                        drawText: false,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Scan at Vibe Lounge front desk.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: VibraniumColors.onSurfaceMuted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.light_mode_outlined,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Turn up screen brightness for faster scanning.',
                    style: TextStyle(
                      color: VibraniumColors.onSurfaceMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Once exiting this screen, your reward will be counted as claimed even if you don\'t scan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
