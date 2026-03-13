import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_shell.dart';
import 'screens/user_shell.dart';

void main() {
  runApp(const RiverFlowApp());
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
