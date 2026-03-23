import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:criterium/providers/student_provider.dart';
import 'package:criterium/providers/app_provider.dart';
import 'package:criterium/theme/app_theme.dart';

class NewAssignmentScreen extends StatefulWidget {
  const NewAssignmentScreen({super.key});

  @override
  State<NewAssignmentScreen> createState() => _NewAssignmentScreenState();
}

class _NewAssignmentScreenState extends State<NewAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _membersController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _techController = TextEditingController();

  String _selectedClass = 'Seleccionar...';
  List<String> _technologies = [];
  List<PlatformFile> _evidenceFiles = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        final provider = context.read<AppProvider>();
        if (provider.availableCategories.isEmpty) {
          provider.fetchAppData();
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _membersController.dispose();
    _descController.dispose();
    _techController.dispose();
    super.dispose();
  }

  void _addTechnology() {
    final text = _techController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _technologies.add(text);
        _techController.clear();
      });
    }
  }

  Future<void> _pickEvidenceFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,      
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _evidenceFiles.addAll(result.files);
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedClass == 'Seleccionar...') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una categoría'), backgroundColor: Colors.red),
      );
      return;
    }

    final studentProv = context.read<StudentProvider>();

    bool success = await studentProv.submitAssignment(
      _titleController.text.trim(),
      _selectedClass,
      _descController.text.trim(),
      _membersController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      _technologies,
      files: _evidenceFiles,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Proyecto subido y publicado exitosamente'), backgroundColor: Color(0xFF2ECC71)),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Error al subir el proyecto. Verifica la terminal.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildLabel(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.grey[300] : AppTheme.navyBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : AppTheme.navyBlue;
    final studentProv = context.watch<StudentProvider>();
    final appProv = context.watch<AppProvider>();

    // Prepare dropdown items for categories
    List<String> categoryItems = ['Seleccionar...'];
    categoryItems.addAll(appProv.availableCategories.map((e) => e['name'].toString()));

    // Make sure selected class is in the list, otherwise reset
    if (!categoryItems.contains(_selectedClass)) {
      _selectedClass = 'Seleccionar...';
    }

    return Scaffold(
      backgroundColor: cardColor,
      appBar: AppBar(
        title: Text('Subir Proyecto', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FILA 1: Título y Categoría
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Título del Proyecto'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _titleController,
                          validator: (value) => value == null || value.trim().isEmpty ? 'Requerido' : null,
                          decoration: InputDecoration(
                            hintText: 'Ej. App VR',
                            filled: true,
                            fillColor: isDark ? const Color(0xFF334155) : Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Categoría'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF334155) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedClass,
                              isExpanded: true,
                              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                              items: categoryItems.map((cat) {
                                return DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat, maxLines: 1, overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedClass = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // FILA 2: Integrantes
              _buildLabel('Integrantes (separados por comas)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _membersController,
                validator: (value) => value == null || value.trim().isEmpty ? 'Requerido' : null,
                decoration: InputDecoration(
                  hintText: 'Juan Pérez, María Gómez...',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF334155) : Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),

              // FILA 3: Descripción
              _buildLabel('Descripción Completa'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 6,
                autocorrect: true,
                validator: (value) => value == null || value.trim().isEmpty ? 'Requerido' : null,
                decoration: InputDecoration(
                  hintText: 'Describe la finalidad de tu proyecto, justificación e impacto comercial...',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF334155) : Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),

              // FILA 4: Tecnologías
              _buildLabel('Tecnologías Utilizadas'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _techController,
                      onFieldSubmitted: (_) => _addTechnology(),
                      decoration: InputDecoration(
                        hintText: 'Ej. Unity, Flutter...',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF334155) : Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _addTechnology,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.electricBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Añadir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              if (_technologies.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _technologies.map((tech) {
                    return Chip(
                      label: Text(tech, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      backgroundColor: AppTheme.navyBlue,
                      deleteIconColor: Colors.white,
                      onDeleted: () {
                         setState(() {
                           _technologies.remove(tech);
                         });
                      },
                    );
                  }).toList(),
                )
              ],
              const SizedBox(height: 32),

              // FILA 5: Añadir Evidencia (Boton Gigante)
              _buildLabel('Añadir Múltiples Evidencias (Videos, Imágenes, PDFs)'),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickEvidenceFiles,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.indigo[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.electricBlue.withOpacity(0.5),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_upload_outlined, size: 50, color: AppTheme.electricBlue),
                      const SizedBox(height: 12),
                      Text('Toca para explorar archivos', style: TextStyle(fontSize: 16, color: isDark ? Colors.white : AppTheme.navyBlue, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Soporta .mp4, .jpg, .png, .pdf', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Lista de Evidencias Seleccionadas
              if (_evidenceFiles.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _evidenceFiles.length,
                  itemBuilder: (context, index) {
                    final file = _evidenceFiles[index];
                    final ext = file.extension?.toLowerCase() ?? '';
                    
                    IconData iconData = Icons.insert_drive_file;
                    Color iconColor = Colors.grey;
                    
                    if (['jpg', 'png', 'jpeg', 'webp'].contains(ext)) {
                      iconData = Icons.image;
                      iconColor = Colors.blue;
                    } else if (['mp4', 'mov', 'avi'].contains(ext)) {
                      iconData = Icons.video_library;
                      iconColor = Colors.purple;
                    } else if (ext == 'pdf') {
                      iconData = Icons.picture_as_pdf;
                      iconColor = Colors.red;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(iconData, color: iconColor),
                        ),
                        title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _evidenceFiles.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              
              const SizedBox(height: 40),

              // BOTÓN ENVIAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: studentProv.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.navyBlue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: studentProv.isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Publicar Proyecto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}