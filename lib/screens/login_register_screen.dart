import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'verify_email_screen.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  bool _loginLoading = false;
  bool _registerLoading = false;
  bool _resendLoading = false;
  String? _loginError;
  String? _loginErrorCode;
  String? _registerError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      setState(() {
        _loginError = null;
        _loginErrorCode = null;
        _registerError = null;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin({
    required String email,
    required String password,
  }) async {
    setState(() {
      _loginLoading = true;
      _loginError = null;
      _loginErrorCode = null;
    });

    try {
      final user = await AuthService.instance.signIn(
        email: email,
        password: password,
      );

      if (!mounted || user == null) return;

      final route = user.role == UserRole.admin ? '/admin' : '/user';
      Navigator.pushReplacementNamed(context, route);
    } on AuthServiceException catch (error) {
      if (!mounted) return;
      setState(() {
        _loginError = error.message;
        _loginErrorCode = error.code;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loginError = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _loginLoading = false);
      }
    }
  }

  Future<void> _handleResendVerification({
    required String email,
    required String password,
  }) async {
    setState(() => _resendLoading = true);

    try {
      await AuthService.instance.resendVerificationEmail(
        email: email,
        password: password,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verification email sent. Please check your inbox/spam.',
          ),
        ),
      );
    } on AuthServiceException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to resend verification email right now.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _resendLoading = false);
    }
  }

  Future<void> _handleRegister({
    required String name,
    required String email,
    required String password,
  }) async {
    setState(() {
      _registerLoading = true;
      _registerError = null;
    });

    try {
      await AuthService.instance.register(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;
      final verified = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: email)),
      );

      if (!mounted) return;
      _tabController.animateTo(0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            verified == true
                ? 'Email verified. You can now login.'
                : 'Registration complete. Please verify your email before logging in.',
          ),
        ),
      );
    } on AuthServiceException catch (error) {
      if (!mounted) return;
      setState(() => _registerError = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _registerError = 'Registration failed. Please try again later.',
      );
    } finally {
      if (mounted) {
        setState(() => _registerLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 90,
                              child: Image.asset('assets/images/logo.png'),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'RiverFlow Sentinel',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TabBar(
                              controller: _tabController,
                              tabs: const [
                                Tab(text: 'LOGIN'),
                                Tab(text: 'REGISTER'),
                              ],
                            ),
                            const SizedBox(height: 20),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: _tabController.index == 0
                                  ? LoginForm(
                                      key: const ValueKey('login-form'),
                                      onSubmit: _handleLogin,
                                      isLoading: _loginLoading,
                                      errorText: _loginError,
                                      showResendVerification:
                                          _loginErrorCode ==
                                          'email-not-verified',
                                      resendLoading: _resendLoading,
                                      onResendVerification:
                                          _handleResendVerification,
                                    )
                                  : RegisterForm(
                                      key: const ValueKey('register-form'),
                                      onSubmit: _handleRegister,
                                      isLoading: _registerLoading,
                                      errorText: _registerError,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
