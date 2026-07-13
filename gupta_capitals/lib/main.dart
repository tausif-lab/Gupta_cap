import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'pages/landing_page.dart';
import 'pages/user_dashboard.dart';
import 'pages/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().init();
  runApp(const GuptaCapitalsApp());
}

class GuptaCapitalsApp extends StatelessWidget {
  const GuptaCapitalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final Widget home;
    if (auth.isLoggedIn) {
      if (auth.isAdmin) {
        home = const AdminDashboard();
      } else {
        home = UserDashboard(
          userId: auth.userId ?? '',
          userName: auth.userName ?? 'User',
        );
      }
    } else {
      home = const LandingPage();
    }

    return MaterialApp(
      title: 'Gupta Capitals',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A3A5C),
          primary: const Color(0xFF1A3A5C),
          secondary: const Color(0xFFD4A843),
          surface: const Color(0xFFF7F4EF),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD0C9BC), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD0C9BC), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF1A3A5C), width: 2.0),
          ),
          labelStyle: const TextStyle(fontSize: 16, color: Color(0xFF6B6154)),
        ),
      ),
      home: home,
    );
  }
}
