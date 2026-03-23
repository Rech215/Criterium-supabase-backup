import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:criterium/providers/auth_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentProvider with ChangeNotifier {
  List<Map<String, dynamic>> _assignments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get assignments => _assignments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider? _authProvider;

  // 🔥 VARIABLES DE RELLENO PARA QUE LAS PANTALLAS VIEJAS COMPILEN 🔥
  List<dynamic> subjects = [];
  Map<int, int> attendanceRecords = {}; 
  List<dynamic> incidentLogs = [];
  List<dynamic> softSkills = [];

  void update(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  // Cabeceras limpias (con el permiso de Ngrok para saltar la pantalla azul)
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true', 
    };
  }

  // ==========================================
  // 1. OBTENER PROYECTOS REALES (CON TRADUCTOR)
  // ==========================================
  Future<void> fetchStudentData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null) throw Exception('API_URL no configurado');

      final url = Uri.parse('$apiUrl/Assignments'); 
      final response = await http.get(url, headers: _getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // 🔥 AQUÍ ESTÁ LA MAGIA: Traducimos lo que manda C# a lo que entiende Flutter
        _assignments = data.map((item) {
          return {
            'id': item['id'],
            '_id': item['id'],
            'name': item['title'] ?? item['name'] ?? 'Sin título', 
            'subject': item['subject'] ?? 'General',
            'description': item['description'] ?? '',
            'status': item['status'] ?? 'Pendiente',
            'members': item['members'] != null ? List<String>.from(item['members']) : [],
            'technologies': item['technologies'] != null ? List<String>.from(item['technologies']) : [],
            'fileUrls': List<String>.from(item['fileUrls'] ?? []),
            'fileUrl': (item['fileUrls'] != null && (item['fileUrls'] as List).isNotEmpty) 
                ? item['fileUrls'][0] 
                : (item['attachedFileUrl'] ?? item['fileUrl'] ?? ''), 
            'time': item['time'] ?? 'Reciente',
            'createdAt': item['createdAt'] ?? DateTime.now().toIso8601String(),
          };
        }).toList();
        
        _assignments.sort((a, b) => b['createdAt'].toString().compareTo(a['createdAt'].toString()));
      } else {
        _errorMessage = 'Error al cargar: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error de red: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 2. ELIMINAR PROYECTO REAL 
  // ==========================================
  Future<bool> deleteAssignment(String assignmentId) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null) throw Exception('API_URL no configurado');

      final url = Uri.parse('$apiUrl/Assignments/$assignmentId'); 
      final response = await http.delete(url, headers: _getHeaders());

      if (response.statusCode == 200 || response.statusCode == 204) {
        _assignments.removeWhere((assignment) => assignment['id'] == assignmentId);
        notifyListeners(); 
        return true; 
      } else {
        final errorBody = json.decode(response.body);
        _errorMessage = 'No se pudo borrar: ${errorBody['message'] ?? response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de red: $e';
      notifyListeners();
      return false;
    }
  }

  // ==========================================
  // 3. SUBIR NUEVO PROYECTO (CON LLAVES DOBLES)
  // ==========================================
  Future<bool> submitAssignment(String title, String selectedClass, String description, List<String> members, List<String> technologies, {List<PlatformFile> files = const []}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null) throw Exception('API_URL no configurado');

      List<String> uploadedUrls = [];
      
      print('--- STARTING ASSIGNMENT SUBMISSION ---');
      print('Uploading ${files.length} files to Supabase...');

      final supabase = Supabase.instance.client;

      for (var file in files) {
        if (file.path != null) {
          print('Uploading file: ${file.name}');
          try {
            final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_${file.name.replaceAll(RegExp(r'\s+'), '_')}';
            await supabase.storage.from('criterium_evidence').upload(uniqueName, File(file.path!));
            final publicUrl = supabase.storage.from('criterium_evidence').getPublicUrl(uniqueName);
            uploadedUrls.add(publicUrl);
            print('Successfully uploaded: $publicUrl');
          } catch (e) {
            print('Failed to upload file to Supabase: $e');
          }
        }
      }

      print('Total uploaded files: ${uploadedUrls.length}');
      
      final url = Uri.parse('$apiUrl/Assignments');
      final requestBody = {
        "title": title,
        "name": title,
        "subject": selectedClass,
        "description": description,
        "members": members,
        "technologies": technologies,
        "status": "Pendiente",
        "fileUrls": uploadedUrls,
        "fileUrl": uploadedUrls.isNotEmpty ? uploadedUrls[0] : null,
        "time": "Reciente"
      };

      print('Creating Assignment Entry at $url');
      print('POST Body: ${json.encode(requestBody)}');
      
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: json.encode(requestBody),
      );

      print('Create Assignment status code: ${response.statusCode}');
      print('Create Assignment response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Assignment created successfully! Refreshing data...');
        await fetchStudentData(); 
        print('--- SUBMISSION COMPLETE ---');
        return true;
      } else {
        print("Error al guardar en Mongo: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error catastrófico: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 4. AÑADIR EVIDENCIA A PROYECTO EXISTENTE
  // ==========================================
  Future<bool> addEvidenceToProject(String assignmentId, dynamic newFile) async {
    if (newFile == null || newFile.path == null) return false;
    
    _isLoading = true;
    notifyListeners();

    try {
      final apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null) throw Exception('API_URL no configurado');

      List<String> uploadedUrls = [];
      final supabase = Supabase.instance.client;

      try {
        String fileName;
        try {
          fileName = newFile.name;
        } catch (_) {
          String p = newFile.path as String;
          fileName = p.contains('/') ? p.split('/').last : p.split('\\').last;
        }
        
        final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_${fileName.replaceAll(RegExp(r'\s+'), '_')}';
        
        print('Uploading file to Supabase...');
        await supabase.storage.from('criterium_evidence').upload(uniqueName, File(newFile.path));
        final publicUrl = supabase.storage.from('criterium_evidence').getPublicUrl(uniqueName);
        uploadedUrls.add(publicUrl);
        print('Successfully uploaded: $publicUrl');
      } catch (e) {
        print("Error en carga de imagen/video a Supabase: $e");
      }

      if (uploadedUrls.isEmpty) return false;

      final putUrl = Uri.parse('$apiUrl/Assignments/$assignmentId/files');
      final response = await http.put(
        putUrl,
        headers: _getHeaders(),
        body: json.encode({
          'fileUrls': uploadedUrls,
          'fileUrl': uploadedUrls.isNotEmpty ? uploadedUrls.first : null,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await fetchStudentData();
        return true;
      }
      print("Error guardando URLs en Mongo: ${response.statusCode} - ${response.body}");
      return false;
    } catch (e) {
      print("Error al añadir archivos: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 5. ELIMINAR EVIDENCIA DE UN PROYECTO
  // ==========================================
  Future<bool> deleteEvidenceFile(String assignmentId, String fileUrl) async {
    _isLoading = true;
    notifyListeners();

    try {
      final apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null) throw Exception('API_URL no configurado');

      // 1. Extraer storagePath de Supabase y eliminar archivo fisico
      final String basePath = '/public/criterium_evidence/';
      int index = fileUrl.indexOf(basePath);
      if (index != -1) {
        String storagePath = fileUrl.substring(index + basePath.length);
        final supabase = Supabase.instance.client;
        try {
          await supabase.storage.from('criterium_evidence').remove([storagePath]);
          print('Successfully deleted from storage: $storagePath');
        } catch (e) {
          print('Error eliminando de Supabase: $e');
        }
      }

      // 2. Localizar proyecto en mongo para actualizar
      final assignmentIndex = _assignments.indexWhere((a) => (a['id']?.toString() ?? a['_id']?.toString()) == assignmentId);
      if (assignmentIndex != -1) {
        // Enviar peticion GET para resguardar los miembros y descripcion del proyecto real
        final getResponse = await http.get(Uri.parse('$apiUrl/Assignments/$assignmentId'), headers: _getHeaders());
        if (getResponse.statusCode == 200) {
          final fullAssignment = json.decode(getResponse.body);
          List<String> currentUrls = List<String>.from(fullAssignment['fileUrls'] ?? []);
          
          if (currentUrls.contains(fileUrl)) {
            currentUrls.remove(fileUrl);
            fullAssignment['fileUrls'] = currentUrls;
            fullAssignment['fileUrl'] = currentUrls.isNotEmpty ? currentUrls.first : null;
            
            final putUrl = Uri.parse('$apiUrl/Assignments/$assignmentId');
            final putResponse = await http.put(putUrl, headers: _getHeaders(), body: json.encode(fullAssignment));

            if (putResponse.statusCode == 200 || putResponse.statusCode == 204) {
              await fetchStudentData();
              return true;
            } else {
              print('Error actualizando Mongo: ${putResponse.body}');
              return false;
            }
          }
          return true; // Si no estaba, consideramos exito
        }
      }
      return false;
    } catch (e) {
      print("Error al eliminar evidencia: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 6. ACTUALIZAR DETALLES DE PROYECTO
  // ==========================================
  Future<bool> updateAssignmentDetails(String assignmentId, Map<String, dynamic> updatedData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null) throw Exception('API_URL no configurado');

      // Descargar el proyecto completo para evitar pérdida de datos
      final getResponse = await http.get(Uri.parse('$apiUrl/Assignments/$assignmentId'), headers: _getHeaders());
      if (getResponse.statusCode == 200) {
        final Map<String, dynamic> fullAssignment = json.decode(getResponse.body);
        
        // Unir datos actualizados
        updatedData.forEach((key, value) {
          fullAssignment[key] = value;
        });
        
        if (updatedData.containsKey('title')) {
          fullAssignment['name'] = updatedData['title'];
        }

        final putResponse = await http.put(
          Uri.parse('$apiUrl/Assignments/$assignmentId'),
          headers: _getHeaders(),
          body: json.encode(fullAssignment)
        );

        if (putResponse.statusCode == 200 || putResponse.statusCode == 204) {
          await fetchStudentData();
          return true;
        } else {
          print("Error actualizando Mongo: ${putResponse.body}");
          return false;
        }
      }
      return false;
    } catch (e) {
      print("Error al actualizar $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {}
  void playProjectVideo(dynamic assignment) {}
}