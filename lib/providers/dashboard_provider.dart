import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, String>> _stat1List = [];
  List<Map<String, String>> _stat2List = [];
  List<Map<String, String>> _stat3List = [];
  List<Map<String, String>> _feedbackList = [];
  List<Map<String, dynamic>> _activeProjects = [];

  Map<String, String> _summaryStats = {};
  Map<String, String> get summaryStats => _summaryStats;

  Map<String, String> _topCardsStats = {};
  Map<String, String> get topCardsStats => _topCardsStats;

  // Dejamos el dashboard en true para que muestre números bonitos de la escuela, 
  // pero los proyectos y videos REALES los descargarán los otros providers.
  final bool _useMockData = true;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, String>> get stat1List => _stat1List;
  List<Map<String, String>> get stat2List => _stat2List;
  List<Map<String, String>> get stat3List => _stat3List;
  List<Map<String, String>> get feedbackList => _feedbackList;
  List<Map<String, dynamic>> get activeProjects => _activeProjects;

  Future<void> fetchDashboardData(bool isTeacher) async {
    _isLoading = true;
    _errorMessage = null; 
    notifyListeners();

    try {
      if (_useMockData) {
        await Future.delayed(const Duration(seconds: 1));

        if (isTeacher) {
          _stat1List = [
            {'name': 'Ana García', 'detail': 'Viabilidad: 9.8'},
            {'name': 'Luis Mendoza', 'detail': 'Viabilidad: 9.7'},
            {'name': 'Sofía Hernández', 'detail': 'Viabilidad: 9.6'},
            {'name': 'Marco Torres', 'detail': 'Viabilidad: 9.5'},
          ];
          _stat2List = [
            {'name': 'Carlos Ruiz', 'detail': 'Viabilidad: 8.0'},
            {'name': 'María López', 'detail': 'Viabilidad: 7.8'},
            {'name': 'Jorge Vargas', 'detail': 'Viabilidad: 7.5'},
          ];
          _stat3List = [
            {'name': 'Elena Soto', 'detail': 'Riesgo Alto - Viabilidad: 6.2'},
            {'name': 'Andrés López', 'detail': 'Riesgo Crítico - Viabilidad: 5.8'},
          ];
        } else {
          _stat1List = [
            {'name': 'E-Commerce App', 'detail': 'En Progreso'},
            {'name': 'Plataforma SaaS', 'detail': 'Completada'},
            {'name': 'Juego RPG 2D', 'detail': 'Siguiente'},
          ];
          _stat2List = [
            {'name': 'Plataforma SaaS', 'detail': 'Evaluación: 9.5/10'},
          ];
          _stat3List = [
            {'name': 'E-Commerce App', 'detail': 'Fase de Pruebas'},
            {'name': 'Juego RPG 2D', 'detail': 'Diseño de Niveles'},
          ];
        }

        _summaryStats = isTeacher
            ? {
                'metric1Label': 'Viabilidad Promedio',
                'metric1Value': '8.5',
                'metric2Label': 'Tasa de Aprobación',
                'metric2Value': '92%',
                'summaryText': '154 creadores activos\n6 categorías evaluadas\n85% proyectos viables',
                'gamification1': '154 horas de mentoría',
                'gamification2': '85% de asistencia',
                'gamification3': '12 evaluaciones hoy',
              }
            : {
                'metric1Label': 'Mi Viabilidad',
                'metric1Value': '9.8',
                'metric2Label': 'Top Creadores',
                'metric2Value': '3ro',
                'summaryText': '3 proyectos activos\nFeedback positivo\nTop 3 en tu categoría',
                'gamification1': '120 hrs invertidas',
                'gamification2': '15 días de racha 🔥',
                'gamification3': '5 proyectos totales',
              };

        _topCardsStats = isTeacher
            ? {
                'stat1Val': _stat1List.length.toString(),
                'stat1Label': 'POR EVALUAR',
                'stat2Val': _stat2List.length.toString(),
                'stat2Label': 'VENDIBLES',
                'stat3Val': _stat3List.length.toString(),
                'stat3Label': 'A MEJORAR',
              }
            : {
                'stat1Val': _stat1List.length.toString(),
                'stat1Label': 'PROYECTOS',
                'stat2Val': _stat2List.length.toString(),
                'stat2Label': 'EVALUADOS',
                'stat3Val': _stat3List.length.toString(),
                'stat3Label': 'EN DESARROLLO',
              };

        _activeProjects = [
          {
            'title': 'Explorar\nProyectos',
            'subtitle': 'Base de Datos',
            'progress': 1.0,
            'status': 'CONECTADO',
            'statusColor': const Color(0xFF4CAF50), 
            'iconData': Icons.folder_special,
            'participants': 24,
            'timeLeft': 'En vivo',
            'backgroundColor': const Color(0xFFF1F5F9), 
            'isDark': false, 
          },
        ];
      }
    } catch (e) {
      _errorMessage = 'Error de conexión. Verifica tu acceso a internet.';
      debugPrint('Error en el Provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _stat1List.clear();
    _stat2List.clear();
    _stat3List.clear();
    _feedbackList.clear();
    _activeProjects.clear();
    _summaryStats.clear();
    _topCardsStats.clear();
    _errorMessage = null;
    notifyListeners();
  }
}