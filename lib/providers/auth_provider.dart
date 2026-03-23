import 'package:flutter/material.dart';
import 'package:criterium/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password, bool isTeacher) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simula petición de red
      await Future.delayed(const Duration(seconds: 2));

      if (isTeacher) {
        _currentUser = UserModel(
          id: 't-12345',
          name: 'Mentor Alex Rivera',
          email: email,
          role: 'teacher',
          avatar: 'https://i.pravatar.cc/150?img=11',
          institution: 'Comité Evaluador de Proyectos',
          bio: 'Inversor y evaluador de proyectos tecnológicos.',
          phone: '+52 555 123 4567',
        );
      } else {
        _currentUser = UserModel(
          id: 's-67890',
          name: 'Ana López',
          email: email,
          role: 'student',
          avatar: 'https://i.pravatar.cc/150?img=5',
          institution: 'Estudio Indie',
          bio: 'Desarrollador de videojuegos indie.',
          phone: '+52 555 987 6543',
        );
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setBool('is_teacher', isTeacher);
      await prefs.setBool('is_logged_in', true);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error de conexión. Verifica tu acceso a internet.';
      debugPrint('Error en el Provider: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('is_logged_in')) return false;

    final email = prefs.getString('user_email') ?? '';
    final isTeacher = prefs.getBool('is_teacher') ?? false;

    // Ejecutar login silencioso con los datos guardados
    return await login(email, "password_placeholder", isTeacher);
  }

  void updateUser({
    required String name,
    required String bio,
    required String phone,
    String? avatar,
  }) {
    if (_currentUser != null) {
      // Creamos una copia del usuario actual pero con los datos nuevos
      _currentUser = UserModel(
        id: _currentUser!.id,
        name: name,
        email: _currentUser!.email,
        role: _currentUser!.role,
        avatar: avatar ?? _currentUser!.avatar,
        institution: _currentUser!.institution,
        bio: bio, // <-- ACTUALIZADO
        phone: phone, // <-- ACTUALIZADO
      );
      notifyListeners();
    }
  }
}
