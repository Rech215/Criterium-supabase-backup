import 'dart:io';
import 'package:flutter/material.dart';
import 'package:criterium/screens/generic_info_screen.dart';
import 'package:criterium/screens/login_screen.dart';
import 'package:criterium/screens/edit_profile_screen.dart';
import 'package:criterium/screens/submissions_screen.dart';
import 'package:criterium/screens/teacher/teacher_classes_screen.dart';
import 'package:criterium/screens/teacher/student_directory_screen.dart';
import 'package:criterium/screens/student/attendance_screen.dart';
import 'package:criterium/screens/student/assignment_history_screen.dart';
import 'package:criterium/screens/student/grades_summary_screen.dart';
import 'package:criterium/theme/app_theme.dart';
import 'package:criterium/main.dart';
import 'package:provider/provider.dart';
import 'package:criterium/providers/auth_provider.dart';
import 'package:criterium/providers/teacher_provider.dart';
import 'package:criterium/providers/student_provider.dart';
import 'package:criterium/providers/dashboard_provider.dart';
import 'package:criterium/providers/app_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  final bool isTeacher;
  const ProfileScreen({super.key, this.isTeacher = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _openEditProfile(BuildContext context, user) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          currentName: user.name,
          currentBio: user.bio,
          currentPhone: user.phone,
          email: user.email,
          role: user.role == 'teacher'
              ? 'Evaluador / Mentor'
              : 'Desarrollador / Creador',
          currentAvatar: user.avatar,
        ),
      ),
    );

    if (result != null && context.mounted) {
      context.read<AuthProvider>().updateUser(
        name: result['name'] ?? user.name,
        bio: result['bio'] ?? '',
        phone: result['phone'] ?? '',
        avatar: result['avatar'],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Perfil actualizado exitosamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : AppTheme.navyBlue;

    final teacherProv = context.watch<TeacherProvider>();
    final studentProv = context.watch<StudentProvider>();

    // Cálculos para el Mentor
    final String catCount = teacherProv.classes.length.toString();
    final String pendingCount = teacherProv.submissions
        .where(
          (s) =>
              s['status'] == 'Pendiente' ||
              s['status'] == 'Sin Entregar' ||
              s['status'] == 'Tardía',
        )
        .length
        .toString();
    final String creatorsCount = teacherProv.students.length.toString();

    // Cálculos para el Creador
    final String viabilidad = studentProv.subjects.isEmpty
        ? '0.0'
        : (studentProv.subjects
                      .map((s) => (s['grade'] as num).toDouble())
                      .reduce((a, b) => a + b) /
                  studentProv.subjects.length)
              .toStringAsFixed(1);
    final String entregasCount = studentProv.assignments.length.toString();
    // Contamos los días de sesiones exitosas o con retardo (1 y 2 en el mapa) o el total
    final String sesionesCount = studentProv.attendanceRecords.length
        .toString();

    return Scaffold(
      backgroundColor: cardColor,
      appBar: AppBar(
        title: Text(
          'Perfil',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: cardColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: textColor),
            onPressed: () => _openEditProfile(context, user),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar y Datos
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: user.avatar.startsWith('http')
                        ? CachedNetworkImageProvider(user.avatar)
                              as ImageProvider
                        : FileImage(File(user.avatar)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.navyBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: cardColor, width: 2),
                  ),
                  child: Icon(
                    widget.isTeacher
                        ? Icons.verified_user
                        : Icons.rocket_launch,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.role == 'teacher'
                  ? 'Mentor / Evaluador'
                  : 'Creador / Desarrollador',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              user.institution,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),

            const SizedBox(height: 32),

            // Estadísticas dinámicas según rol
            Row(
              children: widget.isTeacher
                  ? [
                      _buildStatItem(
                        context,
                        'CATEGORÍAS',
                        catCount,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TeacherClassesScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildStatItem(
                        context,
                        'PENDIENTES',
                        pendingCount,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SubmissionsScreen(
                                className: 'Todas',
                                isTeacher: true,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildStatItem(
                        context,
                        'CREADORES',
                        creatorsCount,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StudentDirectoryScreen(),
                            ),
                          );
                        },
                      ),
                    ]
                  : [
                      _buildStatItem(
                        context,
                        'VIABILIDAD',
                        viabilidad,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GradesSummaryScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildStatItem(
                        context,
                        'ENTREGAS',
                        entregasCount,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AssignmentHistoryScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildStatItem(
                        context,
                        'SESIONES',
                        sesionesCount,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AttendanceScreen(),
                            ),
                          );
                        },
                      ),
                    ],
            ),

            const SizedBox(height: 32),

            // Configuración
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Configuración de cuenta',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Modo Oscuro ──
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (_, currentMode, __) {
                final isDarkOn = currentMode == ThemeMode.dark;
                return Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.grey[200]!,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.transparent
                            : Colors.grey.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SwitchListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDarkOn ? Icons.dark_mode : Icons.light_mode,
                        color: textColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Modo Oscuro',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                    value: isDarkOn,
                    activeColor: const Color(0xFF2EC4B6),
                    onChanged: (value) {
                      themeNotifier.value = value
                          ? ThemeMode.dark
                          : ThemeMode.light;
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildSettingItem(
              context,
              Icons.notifications,
              'Notificaciones',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GenericInfoScreen(
                      icon: Icons.notifications,
                      title: 'Configurar Notificaciones',
                      content:
                          'Aquí podrás gestionar tus preferencias de alertas.\n\n'
                          '• Correos electrónicos: Activado\n'
                          '• Notificaciones Push: Activado\n'
                          '• Alertas de tareas: Activado',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSettingItem(
              context,
              Icons.lock,
              'Privacidad y Seguridad',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GenericInfoScreen(
                      icon: Icons.lock,
                      title: 'Privacidad',
                      content:
                          'En Criterium nos tomamos tu privacidad en serio. '
                          'Tus datos están encriptados de extremo a extremo y '
                          'solo son visibles para tu programa de incubación según '
                          'las políticas de confidencialidad.',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSettingItem(
              context,
              Icons.help,
              'Ayuda y Soporte',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GenericInfoScreen(
                      icon: Icons.help_outline,
                      title: 'Centro de Ayuda',
                      content:
                          '¿Necesitas asistencia?\n\n'
                          'Contacta al soporte técnico de la incubadora o '
                          'escríbenos a soporte@criterium.app.\n\n'
                          'Versión de la App: 2.4.0 (Build 2023)',
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'LEGAL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingItem(
              context,
              Icons.description,
              'Términos de servicio',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GenericInfoScreen(
                      icon: Icons.description,
                      title: 'Términos Legales',
                      content:
                          'El uso de esta aplicación está sujeto a las '
                          'normativas de conducta de la incubadora. El usuario '
                          'se compromete a realizar evaluaciones objetivas y '
                          'respetuosas.\n\n'
                          'Criterium se reserva el derecho de modificar estos '
                          'términos en cualquier momento. El uso continuado de '
                          'la aplicación implica la aceptación de los mismos.\n\n'
                          '© 2023 Criterium. Todos los derechos reservados.',
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Cerrar Sesión
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  // Limpiar la memoria de todos los Providers
                  context.read<TeacherProvider>().clearData();
                  context.read<StudentProvider>().clearData();
                  context.read<DashboardProvider>().clearData();
                  context.read<AppProvider>().clearData();
                  context.read<AuthProvider>().logout();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: isDark
                      ? Colors.red.withOpacity(0.15)
                      : const Color(0xFFFFEBEE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Criterium v2.4.0',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.navyBlue;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textColor.withOpacity(0.7),
                  letterSpacing: 1.0,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : AppTheme.navyBlue;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: textColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 16,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDark ? Colors.grey[500] : Colors.grey[400],
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
