import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({required this.email, super.key});

  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _checking = false;
  bool _resending = false;
  String? _error;

  Future<void> _checkVerification() async {
    setState(() {
      _checking = true;
      _error = null;
    });

    try {
      final verified = await AuthService.instance
          .checkCurrentUserEmailVerified();
      if (!mounted) return;

      if (!verified) {
        setState(() {
          _checking = false;
          _error =
              'Email not verified yet. Open your inbox and tap the verification link.';
        });
        return;
      }

      await AuthService.instance.signOut();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _error = 'Unable to verify status right now. Please try again.';
      });
    }
  }

  Future<void> _resendVerification() async {
    setState(() {
      _resending = true;
      _error = null;
    });

    try {
      await AuthService.instance.sendVerificationForCurrentUser();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verification email sent. Check inbox and spam folder.',
          ),
        ),
      );
    } on AuthServiceException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Unable to resend verification email right now.');
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  Future<void> _cancelAndBackToLogin() async {
    await AuthService.instance.signOut();
    if (!mounted) return;
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.mark_email_read_outlined, size: 36),
                      const SizedBox(height: 12),
                      const Text(
                        'Verify your email before login',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'We sent a verification link to ${widget.email}. Open your email and tap the link to activate your account.',
                      ),
                      const SizedBox(height: 16),
                      if (_error != null)
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _checking ? null : _checkVerification,
                          child: _checking
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("I've Verified My Email"),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _resending ? null : _resendVerification,
                          child: _resending
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Resend Verification Email'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _cancelAndBackToLogin,
                        child: const Text('Back to Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
