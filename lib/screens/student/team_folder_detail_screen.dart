import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:criterium/providers/student_provider.dart';
import 'package:criterium/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:criterium/widgets/embedded_video_player.dart';

class TeamFolderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> projectData;
  final String folderName;
  final int filesCount;

  const TeamFolderDetailScreen({
    super.key,
    required this.projectData,
    required this.folderName,
    required this.filesCount,
  });

  @override
  State<TeamFolderDetailScreen> createState() => _TeamFolderDetailScreenState();
}

class _TeamFolderDetailScreenState extends State<TeamFolderDetailScreen> {
  bool _isUploading = false;

  Future<void> _addMoreEvidence() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'mp4', 'mov', 'pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => _isUploading = true);

      String assignmentId = widget.projectData['id']?.toString() ?? widget.projectData['_id']?.toString() ?? '';
      
      if (assignmentId.isNotEmpty) {
        bool success = await context.read<StudentProvider>().addEvidenceToProject(assignmentId, result.files.first);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Archivos añadidos exitosamente'), backgroundColor: Color(0xFF2ECC71)),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Error al subir archivos'), backgroundColor: Colors.red),
          );
        }
      }

      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _confirmDeleteEvidence(String url) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Evidencia'),
        content: const Text('¿Estás seguro de eliminar esta evidencia?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      setState(() => _isUploading = true);
      String assignmentId = widget.projectData['id']?.toString() ?? widget.projectData['_id']?.toString() ?? '';
      bool success = await context.read<StudentProvider>().deleteEvidenceFile(assignmentId, url);
      
      if (mounted) {
        setState(() => _isUploading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Archivo eliminado'), backgroundColor: Color(0xFF2ECC71)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Error al eliminar'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _showEditModal(BuildContext context, Map<String, dynamic> project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditProjectForm(project: project),
    );
  }

  void _openFile(BuildContext context, String url) async {
    final ext = url.split('.').last.toLowerCase();
    
    if (['mp4', 'mov', 'avi'].contains(ext)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenVideoPlayer(videoUrl: url, title: 'Video de Evidencia'),
        ),
      );
    } else if (['jpg', 'png', 'jpeg', 'webp'].contains(ext)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
            body: Center(child: InteractiveViewer(child: Image.network(url))),
          ),
        ),
      );
    } else {
      final Uri fileUri = Uri.parse(url);
      if (await canLaunchUrl(fileUri)) {
        await launchUrl(fileUri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProv = context.watch<StudentProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.navyBlue;

    // Buscar el proyecto actualizado desde el provider
    String assignmentId = widget.projectData['id']?.toString() ?? widget.projectData['_id']?.toString() ?? '';
    final updatedProject = studentProv.assignments.firstWhere(
      (a) => (a['id']?.toString() ?? a['_id']?.toString() ?? '') == assignmentId,
      orElse: () => widget.projectData,
    );
    
    final List<String> fileUrls = List<String>.from(updatedProject['fileUrls'] ?? []);
    final List<String> members = List<String>.from(updatedProject['members'] ?? []);
    final List<String> technologies = List<String>.from(updatedProject['technologies'] ?? []);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.folderName, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: textColor),
            onPressed: () => _showEditModal(context, updatedProject),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.transparent : Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.electricBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.description, color: AppTheme.electricBlue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            updatedProject['subject'] ?? 'General',
                            style: const TextStyle(color: AppTheme.electricBlue, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            updatedProject['status'] ?? 'Pendiente',
                            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (members.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Integrantes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    members.join(', '),
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
                  ),
                ],
                if (technologies.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Tecnologías Usadas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: technologies.map((tech) => Chip(
                      label: Text(tech, style: TextStyle(fontSize: 12, color: textColor)),
                      backgroundColor: AppTheme.electricBlue.withOpacity(0.1),
                      side: BorderSide.none,
                    )).toList(),
                  ),
                ],
                if (updatedProject['description'] != null && updatedProject['description'].toString().isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    updatedProject['description'],
                    style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14, height: 1.5),
                  ),
                ],
              ],
            ),
          ),
          
          if (fileUrls.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                        Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('Carpeta vacía', style: TextStyle(color: Colors.grey[500], fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Añade evidencia usando el botón flotante.', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: fileUrls.length,
                    itemBuilder: (context, index) {
                      final url = fileUrls[index];
                      final ext = url.split('.').last.toLowerCase();
                      
                      Widget itemWidget;
                      if (['jpg', 'png', 'jpeg', 'webp'].contains(ext)) {
                        itemWidget = GestureDetector(
                          onTap: () => _openFile(context, url),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(url, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image)),
                          ),
                        );
                      } else {
                        IconData fileIcon = Icons.insert_drive_file;
                        Color iconColor = Colors.grey;
                        
                        if (['mp4', 'mov', 'avi'].contains(ext)) {
                          fileIcon = Icons.play_circle_fill;
                          iconColor = Colors.purple;
                        } else if (ext == 'pdf') {
                          fileIcon = Icons.picture_as_pdf;
                          iconColor = Colors.red;
                        }

                        itemWidget = GestureDetector(
                          onTap: () => _openFile(context, url),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF334155) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[300]!),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(fileIcon, color: iconColor, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  'Archivo ${index + 1}',
                                  style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Stack(
                        children: [
                          Positioned.fill(child: itemWidget),
                          Positioned(
                            top: -4,
                            right: -4,
                            child: IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.delete, color: Colors.red, size: 20),
                              ),
                              onPressed: () => _confirmDeleteEvidence(url),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
            const SizedBox(height: 100.0),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _addMoreEvidence,
        backgroundColor: AppTheme.navyBlue,
        icon: _isUploading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.add_photo_alternate, color: Colors.white),
        label: Text(
          _isUploading ? 'Subiendo...' : 'Añadir más evidencia',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _EditProjectForm extends StatefulWidget {
  final Map<String, dynamic> project;
  const _EditProjectForm({required this.project});

  @override
  State<_EditProjectForm> createState() => _EditProjectFormState();
}

class _EditProjectFormState extends State<_EditProjectForm> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _membersCtrl;
  late TextEditingController _techsCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.project['name'] ?? widget.project['title'] ?? '');
    _descCtrl = TextEditingController(text: widget.project['description'] ?? '');
    
    final members = List<String>.from(widget.project['members'] ?? []);
    _membersCtrl = TextEditingController(text: members.join(', '));
    
    final techs = List<String>.from(widget.project['technologies'] ?? []);
    _techsCtrl = TextEditingController(text: techs.join(', '));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _membersCtrl.dispose();
    _techsCtrl.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    setState(() => _isSaving = true);
    
    final updatedData = {
      'title': _titleCtrl.text.trim(),
      'name': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'members': _membersCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      'technologies': _techsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
    };

    String assignmentId = widget.project['id']?.toString() ?? widget.project['_id']?.toString() ?? '';
    
    final success = await context.read<StudentProvider>().updateAssignmentDetails(assignmentId, updatedData);
    
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Cambios guardados'), backgroundColor: Color(0xFF2ECC71)));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Error al guardar'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Container(
      padding: EdgeInsets.only(
        top: 24, left: 24, right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Editar Proyecto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 20),
            
            _buildTextField('Título', _titleCtrl, isDark),
            const SizedBox(height: 16),
            _buildTextField('Descripción', _descCtrl, isDark, maxLines: 3),
            const SizedBox(height: 16),
            _buildTextField('Integrantes (separados por coma)', _membersCtrl, isDark),
            const SizedBox(height: 16),
            _buildTextField('Tecnologías (separadas por coma)', _techsCtrl, isDark),
            
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.navyBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: _isSaving 
                   ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                   : const Text('Guardar Cambios', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isDark, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[700])),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? const Color(0xFF334155) : Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
