import 'package:flutter/material.dart';
import 'package:criterium/screens/splash_screen.dart';
import 'package:criterium/screens/login_screen.dart';
import 'package:criterium/screens/dashboard_screen.dart';
import 'package:criterium/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:criterium/providers/auth_provider.dart';
import 'package:criterium/providers/teacher_provider.dart';
import 'package:criterium/providers/student_provider.dart';
import 'package:criterium/providers/dashboard_provider.dart';
import 'package:criterium/providers/app_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Archivo principal revisado y listo para produccióngit add .

/// Global notifier controlado desde el Switch de perfil.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Leer preferencia guardada
  final prefs = await SharedPreferences.getInstance();
  final isDarkSaved = prefs.getBool('isDarkMode') ?? false;
  themeNotifier.value = isDarkSaved ? ThemeMode.dark : ThemeMode.light;

  // Guardar cada vez que el usuario cambia el tema
  themeNotifier.addListener(() {
    prefs.setBool('isDarkMode', themeNotifier.value == ThemeMode.dark);
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        // 1. Nombramos explícitamente este contexto que YA vive dentro del MultiProvider
        builder: (contextBelowProvider, mode, __) {
          return MaterialApp(
            title: 'Criterium',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            home: FutureBuilder(
              future: Provider.of<AuthProvider>(
                contextBelowProvider, // 2. Usamos el contexto interno aquí
                listen: false,
              ).tryAutoLogin(),
              // 3. Nombramos el contexto del builder para evitar choques
              builder: (futureContext, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                }
                if (snapshot.data == true) {
                  final isTeacher =
                      Provider.of<AuthProvider>(
                        futureContext, // 4. Usamos el contexto del FutureBuilder aquí
                        listen: false,
                      ).currentUser?.role ==
                      'teacher';
                  return DashboardScreen(isTeacher: isTeacher);
                }
                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
