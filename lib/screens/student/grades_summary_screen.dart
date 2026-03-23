import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:criterium/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:criterium/providers/student_provider.dart';

class GradesSummaryScreen extends StatefulWidget {
  const GradesSummaryScreen({super.key});

  @override
  State<GradesSummaryScreen> createState() => _GradesSummaryScreenState();
}

class _GradesSummaryScreenState extends State<GradesSummaryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<StudentProvider>().fetchStudentData());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();

    if (provider.errorMessage != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Resumen de Viabilidad Comercial',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppTheme.navyBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppTheme.navyBlue,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                provider.errorMessage!,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    context.read<StudentProvider>().fetchStudentData(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.isLoading || provider.subjects.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Resumen de Viabilidad Comercial',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppTheme.navyBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppTheme.navyBlue,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Calcular promedio
    final double average = provider.subjects.isEmpty
        ? 0
        : provider.subjects
                  .map((s) => (s['grade'] as num).toDouble())
                  .reduce((a, b) => a + b) /
              provider.subjects.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Resumen de Viabilidad Comercial',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : AppTheme.navyBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : AppTheme.navyBlue,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tarjeta Maestra — Promedio General ──
            Builder(
              builder: (context) {
                final now = DateTime.now();
                final batch = now.month <= 6 ? 'Ene-Jun' : 'Jul-Dic';

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.navyBlue.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Gráfico circular
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CustomPaint(
                          painter: _CircularGradePainter(average / 10),
                          child: Center(
                            child: Text(
                              average.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Puntaje de Viabilidad',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Batch de Incubación $batch ${now.year}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white38,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2ECC71).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.trending_up,
                                    color: Color(0xFF2ECC71),
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Excelente',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2ECC71),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // ── Lista de Materias ──
            const Text(
              'Evaluación por Categoría',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.navyBlue,
              ),
            ),
            const SizedBox(height: 14),

            ...List.generate(provider.subjects.length, (index) {
              final subject = provider.subjects[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSubjectCard(context, subject),
              );
            }),

            const SizedBox(height: 16),

            // ── Habilidades Blandas ──
            const Text(
              'Habilidades Blandas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.navyBlue,
              ),
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.transparent
                        : Colors.grey.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: List.generate(provider.softSkills.length, (index) {
                  final skill = provider.softSkills[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < provider.softSkills.length - 1 ? 16 : 0,
                    ),
                    child: _buildSoftSkillRow(
                      context,
                      skill['name'],
                      skill['stars'],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Subject Card ──
  Widget _buildSubjectCard(BuildContext context, Map<String, dynamic> subject) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.navyBlue;
    final double grade = subject['grade'];
    final double progress = grade / 10;

    // Color basado en calificación
    Color gradeColor;
    if (grade >= 9.5) {
      gradeColor = const Color(0xFF2ECC71);
    } else if (grade >= 8.0) {
      gradeColor = const Color(0xFF3B82F6);
    } else if (grade >= 7.0) {
      gradeColor = const Color(0xFFF39C12);
    } else {
      gradeColor = const Color(0xFFE74C3C);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.grey.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.navyBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(subject['icon'], color: AppTheme.navyBlue, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject['name'],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subject['teacher'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 8),
                // Barra de progreso
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? const Color(0xFF334155)
                        : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            grade.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: gradeColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Soft Skill Row ──
  Widget _buildSoftSkillRow(BuildContext context, String name, int stars) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : AppTheme.navyBlue,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return Icon(
              index < stars ? Icons.star_rounded : Icons.star_outline_rounded,
              color: index < stars ? const Color(0xFFF59E0B) : Colors.grey[300],
              size: 22,
            );
          }),
        ),
      ],
    );
  }
}

// ── Custom Painter para el gráfico circular ──
class _CircularGradePainter extends CustomPainter {
  final double progress; // 0.0 a 1.0

  _CircularGradePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Fondo del arco
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Arco de progreso
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [Color(0xFF2ECC71), Color(0xFF3B82F6)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularGradePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
