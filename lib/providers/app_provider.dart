import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _notifications = [];
  Map<String, List<Map<String, dynamic>>> _chatSessions = {};
  List<Map<String, dynamic>> _evaluationTeam = [];

  List<Map<String, String>> _availableCategories = [];
  List<Map<String, String>> get availableCategories => _availableCategories;

  // INTERRUPTOR DE BACKEND:
  // true = Usa datos de prueba (App funcional sin servidor)
  // false = Usa peticiones http reales al servidor
  final bool _useMockData = true;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get notifications => _notifications;
  List<Map<String, dynamic>> get evaluationTeam => _evaluationTeam;

  List<Map<String, dynamic>> getChatFor(String studentName) {
    if (!_chatSessions.containsKey(studentName)) {
      _chatSessions[studentName] = [
        {
          'text':
              'Hola, este es el inicio de tu conversación con $studentName. ¡Escribe un mensaje para empezar la mentoría!',
          'isMe': false,
          'time': 'Ahora',
        },
      ];
    }
    return _chatSessions[studentName]!;
  }

  Future<void> fetchAppData() async {
    _isLoading = true;
    _errorMessage = null; // Limpiar errores previos
    notifyListeners();

    try {
      if (_useMockData) {
        // ==========================================
        // 🛑 MODO OFFLINE: DATOS DE PRUEBA (MOCKS)
        // ==========================================
        await Future.delayed(const Duration(seconds: 1));

        _availableCategories = [
          {'id': '1', 'name': 'VR/AR', 'icon': '🥽'},
          {'id': '2', 'name': 'E-commerce', 'icon': '🛒'},
          {'id': '3', 'name': 'IA/Machine Learning', 'icon': '🤖'},
          {'id': '4', 'name': 'App Móvil', 'icon': '📱'},
          {'id': '5', 'name': 'SaaS B2B', 'icon': '🏢'},
          {'id': '6', 'name': 'Juego Indie', 'icon': '🎮'},
        ];

        _notifications = [
          {
            'type': 'urgent',
            'title': 'Feedback Prioritario',
            'body':
                'Tienes un nuevo feedback crítico de tu mentor sobre el Pitch Deck.',
            'time': 'Hace 15 min',
            'read': false,
            'icon': Icons.warning_amber_rounded,
            'color': const Color(0xFFE74C3C),
          },
          {
            'type': 'academic',
            'title': 'Veredicto de Proyecto',
            'body':
                'El MVP de tu E-Commerce fue marcado como "Altamente Vendible".',
            'time': 'Hace 1h',
            'read': false,
            'icon': Icons.diamond,
            'color': const Color(0xFFF39C12),
          },
          {
            'type': 'academic',
            'title': 'Nueva Build enviada',
            'body':
                'Sofía subió una nueva versión de su juego indie para revisión.',
            'time': 'Hace 2h',
            'read': false,
            'icon': Icons.new_releases,
            'color': const Color(0xFF2EC4B6),
          },
          {
            'type': 'system',
            'title': 'Cierre de ciclo de Incubación',
            'body':
                'El sistema cerrará evaluaciones el domingo de 2:00 a 5:00 AM.',
            'time': 'Hace 4h',
            'read': true,
            'icon': Icons.build_circle_outlined,
            'color': const Color(0xFF3B82F6),
          },
        ];

        _chatSessions = {
          // Puedes poner el nombre de algún alumno de tu lista de TeacherProvider para probar
          'Ana García Martínez': [
            {
              'text':
                  'Hola, revisé tu avance del MVP. ¿Podemos agendar mentoría?',
              'isMe': true,
              'time': '10:30 AM',
            },
            {
              'text':
                  'Hola, tuve un contratiempo con el internet. Claro, ya subí la nueva build con las correcciones.',
              'isMe': false,
              'time': '10:32 AM',
            },
            {
              'text':
                  'No te preocupes, pero trata de entregarla antes de las 6 PM.',
              'isMe': true,
              'time': '10:33 AM',
            },
          ],
        };

        _evaluationTeam = [
          {
            'name': 'Andrea Ruiz',
            'role': 'BACKEND DEVELOPER',
            'avatar': 'https://i.pravatar.cc/100?img=5',
            'responsibility': 85.0,
            'technical': 92.0,
            'selectedChips': ['Liderazgo'],
          },
          {
            'name': 'Carlos Sosa',
            'role': 'DISEÑO DE NIVELES',
            'avatar': 'https://i.pravatar.cc/100?img=11',
            'responsibility': 60.0,
            'technical': 75.0,
            'selectedChips': ['Falta de comunicación'],
          },
          {
            'name': 'Elena Méndez',
            'role': 'MARKETING',
            'avatar': 'https://i.pravatar.cc/100?img=9',
            'responsibility': 100.0,
            'technical': 88.0,
            'selectedChips': ['Puntualidad'],
          },
        ];
      } else {
        // ==========================================
        // 🟢 MODO PRODUCCIÓN: CONEXIÓN REAL AL API
        // ==========================================
        final baseUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:5074/api';
        final response = await http.get(Uri.parse('$baseUrl/App/Data'));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          // TODO: Mapear la respuesta JSON
        } else {
          throw Exception('Error del servidor: ${response.statusCode}');
        }
      }
    } catch (e) {
      _errorMessage = 'Error de conexión. Verifica tu acceso a internet.';
      debugPrint('Error en el Provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i]['read'] = true;
    }
    notifyListeners();
  }

  void sendMessage(String studentName, String text, String time) {
    if (!_chatSessions.containsKey(studentName)) {
      _chatSessions[studentName] = [];
    }
    _chatSessions[studentName]!.add({'text': text, 'isMe': true, 'time': time});
    notifyListeners();
  }

  void updateEvaluation(int index, String key, dynamic value) {
    _evaluationTeam[index][key] = value;
    notifyListeners();
  }

  Future<void> submitTeamEvaluation() async {
    _isLoading = true;
    notifyListeners();

    // Simulamos el envío de datos al servidor
    await Future.delayed(const Duration(seconds: 2));

    // Limpiamos la lista para simular que ya no hay compañeros por evaluar
    _evaluationTeam.clear();
    _isLoading = false;
    notifyListeners();
  }

  void clearChat(String studentName) {
    _chatSessions[studentName] = [];
    notifyListeners();
  }

  void clearData() {
    _notifications.clear();
    _chatSessions.clear();
    _evaluationTeam.clear();
    _availableCategories.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
