import 'package:flutter/material.dart';
import 'package:criterium/screens/login_screen.dart';
import 'package:criterium/theme/app_theme.dart';
import 'package:criterium/widgets/criterium_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : AppTheme.navyBlue;
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            const CriteriumLogo(size: 120),
            const SizedBox(height: 20),
            Text(
              'Criterium',
              style: Theme.of(
                context,
              ).textTheme.displayLarge?.copyWith(color: textColor),
            ),
            Text(
              'PROJECT INCUBATOR',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                letterSpacing: 2.0,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 100),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: textColor,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sincronizando proyectos...',
              style: TextStyle(color: textColor),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 40.0),
              child: Column(
                children: [
                  Text(
                    'DESIGNED FOR MENTORS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'v 2.4.0',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
