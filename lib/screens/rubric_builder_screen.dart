import 'package:flutter/material.dart';
import 'package:criterium/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:criterium/providers/teacher_provider.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:criterium/widgets/embedded_video_player.dart';

class RubricBuilderScreen extends StatefulWidget {
  final String title;
  final String description;
  final String dueDate;
  final String className;
  final List<dynamic> fileUrls;
  final List<dynamic>? members;
  final List<dynamic>? technologies;

  const RubricBuilderScreen({
    super.key,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.className,
    required this.fileUrls,
    this.members,
    this.technologies,
  });

  @override
  State<RubricBuilderScreen> createState() => _RubricBuilderScreenState();
}

class _RubricBuilderScreenState extends State<RubricBuilderScreen> {
  bool _isLoading = false;
  String _verdict = '';
  final TextEditingController _feedbackCtrl = TextEditingController();

  void _enviarEvaluacion() async {
    if (_verdict.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar un veredicto comercial.'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final feedbackText = _feedbackCtrl.text.trim();
    if (feedbackText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escribe un feedback.'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _isLoading = true);

    int finalGrade = 80;
    if (_verdict == 'vendible') finalGrade = 100;
    if (_verdict == 'noviable') finalGrade = 60;

    context.read<TeacherProvider>().evaluateProject(widget.title, finalGrade);

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Evaluación enviada'), backgroundColor: Color(0xFF2ECC71), behavior: SnackBarBehavior.floating),
    );
    Navigator.pop(context);
  }

  Widget _buildVerdictOption(String title, String icon, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _verdict == value;

    return GestureDetector(
      onTap: () => setState(() => _verdict = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Theme.of(context).cardColor,
          border: Border.all(color: isSelected ? color : (isDark ? Colors.grey[700]! : Colors.grey[300]!), width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? color : (isDark ? Colors.white : AppTheme.navyBlue)))),
            if (isSelected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : AppTheme.navyBlue;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: textColor), onPressed: () => Navigator.pop(context)),
        title: Text('Evaluar Proyecto', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: cardColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PROYECTO A EVALUAR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text(widget.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 4),
                  Text(widget.className, style: const TextStyle(fontSize: 14, color: AppTheme.electricBlue, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  
                  if (widget.members != null && widget.members!.isNotEmpty) ...[
                    const Text('Integrantes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      widget.members!.join(', '),
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (widget.technologies != null && widget.technologies!.isNotEmpty) ...[
                    const Text('Tecnologías Usadas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.technologies!.map((tech) => Chip(
                        label: Text(tech.toString(), style: TextStyle(fontSize: 12, color: textColor)),
                        backgroundColor: AppTheme.electricBlue.withOpacity(0.1),
                        side: BorderSide.none,
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : Colors.indigo[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.grey[700]! : AppTheme.navyBlue.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.description_outlined, color: AppTheme.electricBlue, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Descripción del Proyecto',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppTheme.navyBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: isDark ? Colors.grey[300] : Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Evidencia del Proyecto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 12),
                  
                  if (widget.fileUrls.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: widget.fileUrls.length,
                      itemBuilder: (context, index) {
                        return _buildRealVideoFile(context, widget.fileUrls[index].toString(), index + 1);
                      },
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: isDark ? const Color(0xFF334155) : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                      child: const Text('El alumno no adjuntó ningún video o archivo.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                    ),

                  const SizedBox(height: 32),

                  Text('Veredicto Comercial', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 16),
                  _buildVerdictOption('Altamente Vendible', '💎', 'vendible', const Color(0xFF2ECC71)),
                  _buildVerdictOption('Requiere Mejoras', '⚠️', 'mejoras', const Color(0xFFF39C12)),
                  _buildVerdictOption('No Viable', '❌', 'noviable', const Color(0xFFE74C3C)),

                  const SizedBox(height: 24),
                  Text('Feedback Técnico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _feedbackCtrl,
                    maxLines: 4,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Escribe tus recomendaciones...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF334155) : Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: cardColor, boxShadow: [BoxShadow(color: isDark ? Colors.transparent : Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))]),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _enviarEvaluacion,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.navyBlue, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Confirmar Evaluación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFile(BuildContext context, String url) async {
    final ext = url.split('.').last.toLowerCase();
    
    if (['mp4', 'mov', 'avi'].contains(ext)) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => FullScreenVideoPlayer(videoUrl: url, title: 'Video de Evidencia')));
    } else if (['jpg', 'png', 'jpeg', 'webp'].contains(ext)) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Scaffold(backgroundColor: Colors.black, appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)), body: Center(child: InteractiveViewer(child: Image.network(url))))));
    } else {
      final Uri fileUri = Uri.parse(url);
      if (await canLaunchUrl(fileUri)) {
        await launchUrl(fileUri, mode: LaunchMode.externalApplication);
      }
    }
  }

  Widget _buildRealVideoFile(BuildContext context, String url, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ext = url.split('.').last.toLowerCase();
    
    if (['jpg', 'png', 'jpeg', 'webp'].contains(ext)) {
      return GestureDetector(
        onTap: () => _openFile(context, url),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(url, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image)),
        ),
      );
    }
    
    IconData fileIcon = Icons.insert_drive_file;
    Color iconColor = Colors.grey;
    String fileTypeTxt = 'Archivo adjunto';
    
    if (['mp4', 'mov', 'avi'].contains(ext)) {
      fileIcon = Icons.play_circle_fill;
      iconColor = const Color(0xFF8B5CF6);
      fileTypeTxt = 'Ver Video';
    } else if (ext == 'pdf') {
      fileIcon = Icons.picture_as_pdf;
      iconColor = Colors.red;
      fileTypeTxt = 'Abrir PDF';
    }

    return GestureDetector(
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(fileIcon, color: iconColor, size: 36),
            ),
            const SizedBox(height: 12),
            Text('Evidencia $index', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F172A))),
            const SizedBox(height: 4),
            Text(fileTypeTxt, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}