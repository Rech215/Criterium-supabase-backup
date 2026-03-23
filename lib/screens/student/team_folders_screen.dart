import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:criterium/providers/student_provider.dart';
import 'package:criterium/theme/app_theme.dart';
import 'package:criterium/screens/student/team_folder_detail_screen.dart';

class TeamFoldersScreen extends StatelessWidget {
  const TeamFoldersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProv = context.watch<StudentProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.navyBlue;

    // Agrupación de proyectos por nombre
    final Map<String, List<Map<String, dynamic>>> groupedFolders = {};
    for (var assignment in studentProv.assignments) {
      final name = assignment['name'] ?? 'Proyecto sin título';
      if (!groupedFolders.containsKey(name)) {
        groupedFolders[name] = [];
      }
      groupedFolders[name]!.add(assignment);
    }

    final folderNames = groupedFolders.keys.toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Carpetas de Equipo',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
      ),
      body: studentProv.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.orange))
          : folderNames.isEmpty
              ? Center(
                  child: Text(
                    'No hay proyectos creados aún.',
                    style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 16),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: folderNames.length,
                  itemBuilder: (context, index) {
                    final folderName = folderNames[index];
                    final projects = groupedFolders[folderName]!;
                    final projectData = projects.first; 
                    final fileCount = projects.fold<int>(0, (sum, p) => sum + (p['fileUrls'] as List).length);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TeamFolderDetailScreen(
                              projectData: projectData,
                              folderName: folderName,
                              filesCount: fileCount,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.transparent : Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_shared, size: 56, color: AppTheme.orange.withOpacity(0.9)),
                            const SizedBox(height: 16),
                            Text(
                              folderName,
                              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.electricBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$fileCount archivos',
                                style: const TextStyle(fontSize: 12, color: AppTheme.electricBlue, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
