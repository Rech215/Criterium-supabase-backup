import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _submissions = [];
  List<Map<String, String>> _availableClasses = [];
  bool _isLoading = false;
  String? _errorMessage;

  final bool _useMockData = false;

  List<Map<String, dynamic>> get students => _students;
  List<Map<String, dynamic>> get classes => _classes;
  List<Map<String, dynamic>> get submissions => _submissions;
  List<Map<String, String>> get availableClasses => _availableClasses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTeacherData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_useMockData) {
        // ... (datos mock omitidos) ...
      } else {
        _availableClasses = [
          {'id': '65d4f9c2a1c3000000000001', 'name': 'VR/AR', 'icon': '🥽'},
          {
            'id': '65d4f9c2a1c3000000000002',
            'name': 'E-commerce',
            'icon': '🛒',
          },
          {
            'id': '65d4f9c2a1c3000000000003',
            'name': 'IA/Machine Learning',
            'icon': '🤖',
          },
        ];
        _classes = [
          {
            'name': 'Fintech',
            'room': 'Sala A',
            'schedule': 'Lun/Mié 8:00',
            'students': '32',
            'color': '0xFF2EC4B6',
          },
          {
            'name': 'Videojuegos',
            'room': 'Hub 2',
            'schedule': 'Mar/Jue 10:00',
            'students': '28',
            'color': '0xFF3B82F6',
          },
        ];
        _students = [
          {
            'name': 'Alumno UTM',
            'id': 'PRY-2024-001',
            'category': 'General',
            'avg': '9.8',
          },
        ];

        final baseUrl = dotenv.env['API_URL'] ?? 'https://criterium-project-production.up.railway.app/api';
        final response = await http.get(Uri.parse('$baseUrl/Assignments'));

        if (response.statusCode == 200) {
          List<dynamic> apiData = jsonDecode(response.body);

          _submissions = apiData.map((item) {
            return {
              'id': item['id'],
              'name': item['title'] ?? 'Sin título',
              'avatar': 'https://i.pravatar.cc/150?img=5',
              'status': 'Pendiente',
              'time': 'Nuevo',
              'grade': null,
              'fileUrls': item['fileUrls'] ?? [],
              'fileUrl': (item['fileUrls'] != null && (item['fileUrls'] as List).isNotEmpty) ? item['fileUrls'][0] : (item['attachedFileUrl'] ?? item['fileUrl']),
              'description': item['description'] ?? 'Sin descripción proporcionada.',
              'members': item['members'] != null ? List<String>.from(item['members']) : [],
              'technologies': item['technologies'] != null ? List<String>.from(item['technologies']) : [],
            };
          }).toList();
          _submissions = _submissions.reversed.toList();
        } else {
          throw Exception('Error del servidor: ${response.statusCode}');
        }
      }
    } catch (e) {
      _errorMessage = 'Error de conexión. Verifica Pinggy.';
      debugPrint('Error en el Provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> playProjectVideo(Map<String, dynamic> project) async {
    final String? videoUrlString = project['fileUrl'];

    if (videoUrlString == null || videoUrlString.isEmpty) {
      debugPrint("⚠️ Este proyecto no tiene video adjunto.");
      return;
    }

    final Uri videoUri = Uri.parse(videoUrlString);
    try {
      if (await canLaunchUrl(videoUri)) {
        await launchUrl(
          videoUri,
          mode: LaunchMode.externalApplication,
        ); // 🔥 MODO EXTERNO PARA VIDEOS
      }
    } catch (e) {
      debugPrint("❌ Error al reproducir video: $e");
    }
  }

  Future<bool> createAssignment({
    required String title,
    required String description,
    required String dueDate,
    required String className,
    required List<Map<String, dynamic>> rubric,
  }) async {
    try {
      if (_useMockData) {
        await Future.delayed(const Duration(seconds: 2));
        return true;
      }
      final classObj = _availableClasses.firstWhere(
        (c) => c['name'] == className,
        orElse: () => {'id': '65d4f9c2a1c3000000000000'},
      );
      final baseUrl = dotenv.env['API_URL'] ?? 'https://criterium-project-production.up.railway.app/api';
      final url = Uri.parse('$baseUrl/Assignments');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": title,
          "description": description,
          "dueDate": "2026-12-31T23:59:00Z",
          "classGroupId": classObj['id'],
          "rubric": rubric
              .map((c) => {"criteriaName": c['title'], "maxPoints": c['score']})
              .toList(),
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      debugPrint("Error: $e");
      return false;
    }
  }

  void evaluateProject(String projectName, int grade) {
    final index = _submissions.indexWhere(
      (s) => projectName.contains(s['name']),
    );
    if (index != -1) {
      _submissions[index]['status'] = 'Calificado';
      _submissions[index]['grade'] = grade;
      notifyListeners();
    }
  }

  void clearData() {
    _students.clear();
    _classes.clear();
    _submissions.clear();
    _availableClasses.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
