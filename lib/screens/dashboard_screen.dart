import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:criterium/screens/evaluation_screen.dart';
import 'package:criterium/screens/submissions_screen.dart';
import 'package:criterium/screens/new_assignment_screen.dart';
import 'package:criterium/screens/profile_screen.dart';
import 'package:criterium/screens/student/team_folders_screen.dart';
import 'package:criterium/screens/reports_screen.dart';
import 'package:criterium/screens/notifications_screen.dart';
import 'package:criterium/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:criterium/providers/dashboard_provider.dart';
import 'package:criterium/providers/auth_provider.dart';
import 'package:criterium/providers/student_provider.dart';
import 'package:criterium/providers/teacher_provider.dart';
import 'package:criterium/widgets/embedded_video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DashboardScreen extends StatefulWidget {
  final bool isTeacher;
  const DashboardScreen({super.key, this.isTeacher = false});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _fetchData();
    });
  }

  void _fetchData() {
    context.read<DashboardProvider>().fetchDashboardData(widget.isTeacher);
    if (widget.isTeacher) {
      context.read<TeacherProvider>().fetchTeacherData();
    } else {
      context.read<StudentProvider>().fetchStudentData();
    }
  }

  late List<Widget> _pages;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    _pages = [
      _buildDashboardView(), 
      widget.isTeacher
          ? const SubmissionsScreen(className: 'Todas', isTeacher: true)
          : const TeamFoldersScreen(),
      ReportsScreen(isTeacher: widget.isTeacher),
      ProfileScreen(isTeacher: widget.isTeacher),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.navyBlue,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppTheme.navyBlue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              const BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_rounded),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  widget.isTeacher ? Icons.folder_special : Icons.rocket_launch,
                ),
                label: widget.isTeacher ? 'Proyectos' : 'Mis Proyectos',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.assessment),
                label: 'Reportes',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: AppTheme.orange,
            unselectedItemColor: Colors.white.withOpacity(0.5),
            backgroundColor: AppTheme.navyBlue,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardView() {
    final dashboardProv = context.watch<DashboardProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.navyBlue;

    final authProv = context.watch<AuthProvider>();
    final user = authProv.currentUser;

    String rawName = user?.name ?? (widget.isTeacher ? 'Mentor' : 'Creador');
    String userName;

    if (rawName.contains(' ')) {
      final parts = rawName.split(' ');
      userName = '${parts[0]}\n${parts.sublist(1).join(' ')}';
    } else {
      userName = 'Hola,\n$rawName';
    }

    String userRoleSubtitle = widget.isTeacher ? 'Mentor / Evaluador' : 'Creador / Desarrollador';

    List<Map<String, dynamic>> realProjectsFromMongo = widget.isTeacher
        ? context.watch<TeacherProvider>().submissions
        : context.watch<StudentProvider>().assignments;

    if (dashboardProv.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.orange));
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ENCABEZADO Y PERFIL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DASHBOARD',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userName,
                        style: GoogleFonts.poppins(
                          color: textColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          userRoleSubtitle,
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(isTeacher: widget.isTeacher)));
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFE8EAF0),
                    child: const Icon(Icons.person, color: Colors.grey, size: 28),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 2. TARJETAS DE ESTADÍSTICAS
            Row(
              children: [
                _buildStatCard(
                  context,
                  dashboardProv.topCardsStats['stat1Val'] ?? '0',
                  dashboardProv.topCardsStats['stat1Label'] ?? (widget.isTeacher ? 'POR EVALUAR' : 'PROYECTOS'),
                  widget.isTeacher ? Icons.class_ : Icons.trending_up,
                  const Color(0xFF2EC4B6),
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  dashboardProv.topCardsStats['stat2Val'] ?? '0',
                  dashboardProv.topCardsStats['stat2Label'] ?? (widget.isTeacher ? 'VENDIBLES' : 'EVALUADOS'),
                  widget.isTeacher ? Icons.assignment_late : Icons.remove,
                  const Color(0xFFF39C12),
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  dashboardProv.topCardsStats['stat3Val'] ?? '0',
                  dashboardProv.topCardsStats['stat3Label'] ?? (widget.isTeacher ? 'A MEJORAR' : 'EN DESARROLLO'),
                  widget.isTeacher ? Icons.people : Icons.priority_high,
                  const Color(0xFFE74C3C),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 3. TÍTULO DE SECCIÓN Y BOTÓN DE SUBIR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isTeacher ? 'Proyectos Recientes' : 'Mis Proyectos Activos',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (!widget.isTeacher) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NewAssignmentScreen()),
                    );
                    if (context.mounted) {
                      _fetchData();
                    }
                  },
                  icon: const Icon(Icons.cloud_upload, color: Colors.white),
                  label: const Text(
                    'Subir Nuevo Proyecto',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.navyBlue, 
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 4. LISTA DE VIDEOS REALES (EL FEED)
            if (context.watch<TeacherProvider>().isLoading || context.watch<StudentProvider>().isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator(color: AppTheme.orange)))
            else if (realProjectsFromMongo.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text('Aún no hay proyectos en la Base de Datos.', style: TextStyle(color: Colors.grey[500])),
                ),
              )
            else
              ...realProjectsFromMongo.map((project) {
                List<String> fileUrls = List<String>.from(project['fileUrls'] ?? []);
                if (fileUrls.isEmpty && project['fileUrl'] != null && project['fileUrl'].toString().isNotEmpty) {
                  fileUrls.add(project['fileUrl']);
                }
                bool hasMedia = fileUrls.isNotEmpty;
                
                // 🔥 AQUÍ ESTÁ EL ARREGLO INFALIBLE PARA LOS IDs 🔥
                String assignmentId = project['id']?.toString() ?? project['_id']?.toString() ?? project['Id']?.toString() ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : const Color(0xFF94A3B8)).withOpacity(isDark ? 0.4 : 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasMedia)
                          _FeedMediaGallery(fileUrls: fileUrls, projectTitle: project['name'] ?? 'Proyecto')
                        else
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(
                              color: isDark ? Colors.black45 : Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 50),
                                  const SizedBox(height: 8),
                                  Text('Proyecto sin evidencia visual', style: TextStyle(color: Colors.grey[500])),
                                ],
                              ),
                            ),
                          ),
                        
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: AppTheme.orange.withOpacity(0.1),
                                    child: const Icon(Icons.folder_special, color: AppTheme.orange),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          project['name'] ?? 'Sin Título',
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'UT Metropolitana • ${project['status'] ?? 'Pendiente'}',
                                          style: TextStyle(
                                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // 🔥 BOTÓN DE BORRAR (SOLO CREADOR Y SI TIENE ID) 🔥
                                  if (!widget.isTeacher && assignmentId.isNotEmpty)
                                    PopupMenuButton<String>(
                                      icon: Icon(Icons.more_vert, color: isDark ? Colors.grey[500] : Colors.grey[700]),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          _confirmDeleteAssignment(assignmentId, project['name'] ?? 'Sin Título');
                                        }
                                      },
                                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                        PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              const Icon(Icons.delete_forever, color: Colors.redAccent, size: 20),
                                              const SizedBox(width: 10),
                                              Text('Eliminar Proyecto', style: TextStyle(color: Colors.redAccent[700], fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              
                              if (project['description'] != null && project['description'].toString().isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    project['description'],
                                    style: TextStyle(
                                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                                      fontSize: 13,
                                      height: 1.4, 
                                    ),
                                    maxLines: 3, 
                                    overflow: TextOverflow.ellipsis, 
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              
            const SizedBox(height: 100), 
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAssignment(String id, String projectName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text('¿Eliminar Proyecto?'),
          ],
        ),
        content: Text('Estás a punto de borrar permanentemente el proyecto "$projectName". Esta acción no se puede deshacer.', style: const TextStyle(fontSize: 14),),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('Cancelar', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppTheme.navyBlue),),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); 
              _deleteAssignmentAction(id); 
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Sí, Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
          ),
        ],
      ),
    );
  }

  void _deleteAssignmentAction(String id) async {
    final success = await context.read<StudentProvider>().deleteAssignment(id);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Proyecto eliminado correctamente.'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: ${context.read<StudentProvider>().errorMessage ?? "No se pudo borrar"}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 140), 
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), 
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center, 
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedMediaGallery extends StatelessWidget {
  final List<String> fileUrls;
  final String projectTitle;

  const _FeedMediaGallery({
    required this.fileUrls,
    required this.projectTitle,
  });

  Widget _buildMediaItem(String url) {
    final ext = url.split('.').last.toLowerCase();
    if (['mp4', 'mov', 'avi'].contains(ext)) {
      return EmbeddedVideoPlayer(videoUrl: url, title: projectTitle);
    } else {
      return Image.network(url, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < fileUrls.length; i++) ...[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: _buildMediaItem(fileUrls[i]),
            ),
          ),
          if (i < fileUrls.length - 1)
            const SizedBox(height: 8),
        ],
      ],
    );
  }
}