import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MovieHubApp());
}

class MovieHubApp extends StatelessWidget {
  const MovieHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MovieHub',
      theme: ThemeData(
        primaryColor: const Color(0xFF00203F),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF0D3B66),
        ),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
          bodyMedium: TextStyle(color: Color(0xFFFFFFFF)),
          titleLarge: TextStyle(color: Color(0xFFFFFFFF)),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}