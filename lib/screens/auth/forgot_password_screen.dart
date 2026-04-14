import 'package:app/core/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Builds a display like `a**********v@gmail.com` — first local char, ten stars, last local char, @domain.
String maskEmailOrUsername(String input) {
  final raw = input.trim();
  if (raw.isEmpty) return '•**********•@••••••••';

  final at = raw.indexOf('@');
  if (at > 0 && at < raw.length - 1) {
    final local = raw.substring(0, at);
    final domain = raw.substring(at + 1);
    if (local.length == 1) {
      return '${local[0]}**********@$domain';
    }
    return '${local[0]}**********${local[local.length - 1]}@$domain';
  }

  // Username only — same mask pattern with a hidden domain placeholder.
  if (raw.length == 1) {
    return '${raw[0]}**********@••••••••';
  }
  return '${raw[0]}**********${raw[raw.length - 1]}@••••••••';
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactController = TextEditingController();

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  static bool _looksLikeEmail(String value) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim());
  }

  Future<void> _onSendResetLink() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final userProvider = context.read<UserProvider>();

    await userProvider.resetPassword(_contactController.text).then((email) {
      if (email.isEmpty) {
        return;
      } else {
        final masked = maskEmailOrUsername(email);

        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            final theme = Theme.of(ctx);
            return AlertDialog(
              title: const Text('Check your email'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'We sent a password reset link to:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    masked,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              actions: [
                FilledButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Forgot password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Reset your password',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the email address or username for your account. '
                  'We will send you a link to reset your password.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _contactController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [
                    AutofillHints.email,
                    AutofillHints.username,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Email or username',
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                  ),
                  onFieldSubmitted: (_) => _onSendResetLink(),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) {
                      return 'Enter your email or username';
                    }
                    if (v.contains('@')) {
                      if (!_looksLikeEmail(v)) {
                        return 'Enter a valid email';
                      }
                    } else {
                      if (v.length < 3) {
                        return 'At least 3 characters';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _onSendResetLink,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Send reset link'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
