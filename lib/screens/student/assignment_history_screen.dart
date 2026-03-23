import 'package:flutter/material.dart';
import 'package:criterium/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:criterium/providers/student_provider.dart';
import 'package:criterium/screens/chat_screen.dart';

class AssignmentHistoryScreen extends StatefulWidget {
  const AssignmentHistoryScreen({super.key});

  @override
  State<AssignmentHistoryScreen> createState() =>
      _AssignmentHistoryScreenState();
}

class _AssignmentHistoryScreenState extends State<AssignmentHistoryScreen> {
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
  }

  List<Map<String, dynamic>> _getFilteredAssignments(
    List<Map<String, dynamic>> allAssignments,
  ) {
    if (_selectedFilter == 1) {
      return allAssignments.where((a) => a['status'] == 'graded').toList();
    } else if (_selectedFilter == 2) {
      return allAssignments
          .where((a) => a['status'] == 'pending' || a['status'] == 'late')
          .toList();
    }
    return allAssignments;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    final filtered = _getFilteredAssignments(provider.assignments);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Mis Entregables',
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
        // 🔥 MAGIA AQUÍ: Solo muestra la flecha si es seguro ir hacia atrás
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppTheme.navyBlue,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Column(
        children: [
          if (!provider.isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildMiniStat(
                    '${provider.assignments.length}',
                    'Total',
                    AppTheme.navyBlue,
                  ),
                  const SizedBox(width: 10),
                  _buildMiniStat(
                    '${provider.assignments.where((a) => a['status'] == 'graded').length}',
                    'Evaluadas',
                    const Color(0xFF2ECC71),
                  ),
                  const SizedBox(width: 10),
                  _buildMiniStat(
                    '${provider.assignments.where((a) => a['status'] == 'pending').length}',
                    'Pendientes',
                    const Color(0xFFF39C12),
                  ),
                  const SizedBox(width: 10),
                  _buildMiniStat(
                    '${provider.assignments.where((a) => a['status'] == 'late').length}',
                    'Con Retraso',
                    const Color(0xFFE74C3C),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildFilterChip('Todas', 0),
                const SizedBox(width: 8),
                _buildFilterChip('Evaluadas', 1),
                const SizedBox(width: 8),
                _buildFilterChip('Pendientes', 2),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.errorMessage!,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context
                              .read<StudentProvider>()
                              .fetchStudentData(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == filtered.length) {
                        return const SizedBox(height: 24);
                      }
                      return _buildAssignmentCard(filtered[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.transparent
                  : Colors.grey.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.navyBlue : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? AppTheme.navyBlue
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.navyBlue.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.grey[300] : Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    final String status = assignment['status'] ?? 'pending';
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (status) {
      case 'graded':
        statusColor = const Color(0xFF2ECC71);
        statusLabel = assignment['grade']?.toString() ?? '100';
        statusIcon = Icons.check_circle;
        break;
      case 'late':
        statusColor = const Color(0xFFE74C3C);
        statusLabel = 'Con Retraso';
        statusIcon = Icons.warning_amber_rounded;
        break;
      default:
        statusColor = const Color(0xFFF39C12);
        statusLabel = 'Pendiente';
        statusIcon = Icons.schedule;
    }

    return GestureDetector(
      onTap: () {
        context.read<StudentProvider>().playProjectVideo(assignment);
        
        if (assignment['fileUrl'] == null || assignment['fileUrl'].toString().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Este proyecto no tiene video adjunto.')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.transparent
                  : Colors.grey.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.navyBlue.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    (assignment['fileUrl'] != null && assignment['fileUrl'].toString().isNotEmpty) 
                        ? Icons.play_circle_fill 
                        : Icons.folder_special,
                    color: AppTheme.navyBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment['name'] ?? 'Sin título',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : AppTheme.navyBlue,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        assignment['subject'] ?? 'Proyecto Integrador',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: status == 'graded' ? 18 : 13,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assignment['date'] ?? '',
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ],
            ),
            if (status == 'graded' && assignment['feedback'] != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FFF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2ECC71).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            assignment['feedback'],
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                studentName: 'Mentor de ${assignment['subject']}',
                                studentAvatar: 'https://i.pravatar.cc/100?img=11',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.forum_outlined,
                          size: 16,
                          color: Color(0xFF2ECC71),
                        ),
                        label: const Text(
                          'Discutir con Evaluador',
                          style: TextStyle(
                            color: Color(0xFF2ECC71),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF2ECC71)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}