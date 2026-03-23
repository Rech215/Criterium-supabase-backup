import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:criterium/screens/success_screen.dart';
import 'package:criterium/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:criterium/providers/app_provider.dart';

class EvaluationScreen extends StatefulWidget {
  const EvaluationScreen({super.key});

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AppProvider>().fetchAppData());
  }

  @override
  Widget build(BuildContext context) {
    final appProv = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : AppTheme.navyBlue;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Evaluación de Equipo',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                Text(
                  'Evalúa a tu equipo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Evalúa la contribución técnica y compromiso de los miembros del equipo.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),

                if (appProv.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (appProv.errorMessage != null)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Icon(
                          Icons.wifi_off_rounded,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          appProv.errorMessage!,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<AppProvider>().fetchAppData(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                else if (appProv.evaluationTeam.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Colors.green[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Ya evaluaste a todo tu equipo.',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...appProv.evaluationTeam
                      .asMap()
                      .entries
                      .map((entry) => _buildMemberCard(entry.key, entry.value))
                      .toList(),
              ],
            ),
          ),

          // Botón fijo en la parte inferior
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Theme.of(context).cardColor : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.transparent
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2E86DE),
                    Color(0xFF2EC4B6),
                  ], // Azul a Turquesa
                ),
              ),
              child: ElevatedButton(
                onPressed: _isLoading || appProv.evaluationTeam.isEmpty
                    ? null
                    : () async {
                        setState(() => _isLoading = true);

                        // Mutamos el estado global
                        await context
                            .read<AppProvider>()
                            .submitTeamEvaluation();

                        if (!mounted) return;

                        // Navegamos a la pantalla de éxito
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SuccessScreen(),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Enviar Evaluación',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.send, color: Colors.white, size: 20),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(int index, Map<String, dynamic> member) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDark ? Colors.white : AppTheme.navyBlue;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del miembro
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: CachedNetworkImageProvider(member['avatar']),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: textColor,
                    ),
                  ),
                  Text(
                    member['role'],
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E86DE), // Azul claro
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Caja de Comentarios / Feedback
          Text(
            'FEEDBACK Y RECOMENDACIONES',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 3,
            style: TextStyle(color: textColor, fontSize: 14),
            decoration: InputDecoration(
              hintText:
                  'Ej: Te recomiendo usar Firebase para la base de datos y optimizar tus consultas...',
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? Colors.transparent : Colors.grey[200]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? Colors.transparent : Colors.grey[200]!,
                ),
              ),
            ),
            onChanged: (text) {
              context.read<AppProvider>().updateEvaluation(
                index,
                'comments',
                text,
              );
            },
          ),

          const SizedBox(height: 24),

          // Feedback Rápido
          Text(
            'FEEDBACK RÁPIDO',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip(
                context,
                'Liderazgo',
                Icons.check_circle,
                Colors.blue,
                index,
                member['selectedChips'],
              ),
              _buildChip(
                context,
                'Puntualidad',
                Icons.access_time_filled,
                Colors.green,
                index,
                member['selectedChips'],
              ),
              _buildChip(
                context,
                'Falta de comunicación',
                Icons.error_outline,
                Colors.red,
                index,
                member['selectedChips'],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSection(
    BuildContext context,
    String label,
    double value,
    Function(double) onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color activeColor = const Color(0xFF2EC4B6); // Turquesa por defecto
    if (value < 70) activeColor = Colors.grey;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.navyBlue,
                fontSize: 14,
              ),
            ),
            Text(
              '${value.toInt()}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: activeColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            activeTrackColor: const Color(0xFF2EC4B6),
            inactiveTrackColor: isDark
                ? const Color(0xFF334155)
                : Colors.grey[200],
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 12,
              elevation: 4,
            ),
            overlayColor: const Color(0xFF2EC4B6).withOpacity(0.1),
          ),
          child: Slider(value: value, min: 0, max: 100, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    int memberIndex,
    List<dynamic> selectedList,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isSelected = selectedList.contains(label);

    // Logica visual especifica para "Falta de comunicación" (rojo claro fondo, rojo texto)
    Color backgroundColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF1F3F5);
    Color textColor = isDark ? Colors.grey[300]! : Colors.grey[600]!;
    Color iconColor = Colors.transparent; // oculto si no seleccionado

    if (isSelected) {
      if (color == Colors.red) {
        backgroundColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFD32F2F);
        iconColor = const Color(0xFFD32F2F);
      } else {
        backgroundColor = const Color(
          0xFFE3F2FD,
        ); // Azul muy claro para los positivos
        if (label == 'Puntualidad') backgroundColor = const Color(0xFFE8F5E9);

        textColor = const Color(0xFF1976D2);
        if (label == 'Puntualidad') textColor = const Color(0xFF388E3C);

        iconColor = textColor;
      }
    }

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected && label == 'Liderazgo') ...[
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
          ],
          if (isSelected && label == 'Puntualidad') ...[
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
          ],
          if (isSelected && label == 'Falta de comunicación') ...[
            const Text(
              '!',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ), // Signo exclamacion
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        final currentList = List<dynamic>.from(selectedList);
        if (selected) {
          currentList.add(label);
        } else {
          currentList.remove(label);
        }
        context.read<AppProvider>().updateEvaluation(
          memberIndex,
          'selectedChips',
          currentList,
        );
      },
      backgroundColor: const Color(0xFFF8F9FA),
      selectedColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.transparent),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
