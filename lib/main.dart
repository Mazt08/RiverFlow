import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:river_flow/firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_shell.dart';
import 'screens/user_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RiverFlowBootstrapApp());
}

class RiverFlowBootstrapApp extends StatefulWidget {
  const RiverFlowBootstrapApp({super.key});

  @override
  State<RiverFlowBootstrapApp> createState() => _RiverFlowBootstrapAppState();
}

class _RiverFlowBootstrapAppState extends State<RiverFlowBootstrapApp> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeFirebase();
  }

  Future<void> _initializeFirebase() {
    final options = DefaultFirebaseOptions.currentPlatform;
    if (_hasPlaceholderFirebaseConfig(options)) {
      throw StateError(
        'Firebase configuration contains placeholder values. Run "flutterfire configure" and update platform config files.',
      );
    }

    return Firebase.initializeApp(
      options: options,
    ).timeout(const Duration(seconds: 20));
  }

  bool _hasPlaceholderFirebaseConfig(FirebaseOptions options) {
    final values = <String>[
      options.apiKey,
      options.appId,
      options.messagingSenderId,
      options.projectId,
      options.databaseURL ?? '',
      options.storageBucket ?? '',
      options.authDomain ?? '',
      options.iosBundleId ?? '',
    ];

    for (final value in values) {
      final normalized = value.trim().toLowerCase();
      if (normalized.isEmpty) {
        continue;
      }
      if (normalized.contains('example') ||
          normalized.contains('your_') ||
          normalized.contains('replace_me')) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Unable to initialize app services.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Please check network/Firebase config and try again.',
                        textAlign: TextAlign.center,
                      ),
                      if (snapshot.error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            _initFuture = _initializeFirebase();
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return const RiverFlowApp();
      },
    );
  }
}

class RiverFlowApp extends StatelessWidget {
  const RiverFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0C3B7A); // Deep Blue
    const secondary = Color(0xFF119DA4); // Aqua / Teal

    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(primary: primary, secondary: secondary);

    return MaterialApp(
      title: 'RiverFlow Sentinel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.surface,
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.zero,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: scheme.surface,
          surfaceTintColor: scheme.surfaceTint,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          elevation: 0,
          backgroundColor: scheme.surface,
          indicatorColor: scheme.secondaryContainer,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: scheme.surface,
          indicatorColor: scheme.secondaryContainer,
          selectedIconTheme: IconThemeData(color: scheme.onSecondaryContainer),
          selectedLabelTextStyle: TextStyle(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/admin': (context) => const AdminShellScreen(),
        '/user': (context) => const UserShellScreen(),
      },
    );
  }
}
