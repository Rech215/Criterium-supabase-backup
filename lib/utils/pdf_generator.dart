import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfGenerator {
  /// Genera un reporte de calificaciones en PDF y abre el menú nativo de compartir.
  static Future<void> generateAndShareReport(
    String className, {
    required List<Map<String, dynamic>> students,
  }) async {
    // ── Colores de marca ─────────────────────────────────────────────────────
    const navyBlue = PdfColor.fromInt(0xFF0F172A);
    const turquoise = PdfColor.fromInt(0xFF2EC4B6);
    const lightGrey = PdfColor.fromInt(0xFFF1F5F9);
    const white = PdfColors.white;

    // ── Documento ────────────────────────────────────────────────────────────
    final pdf = pw.Document();
    final now = DateTime.now();
    final fechaStr =
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── Encabezado ──────────────────────────────────────────────
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: pw.BoxDecoration(
                  color: navyBlue,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'CRITERIUM',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: turquoise,
                        letterSpacing: 2,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Reporte de Viabilidad',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: white,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      className,
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey300,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              // ── Fecha ───────────────────────────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'Generado: $fechaStr',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // ── Tabla ───────────────────────────────────────────────────
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  // Encabezado de tabla
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: navyBlue),
                    children: [
                      _tableCell('Líder de Proyecto / Creador', isHeader: true),
                      _tableCell('Estado', isHeader: true),
                      _tableCell('Viabilidad', isHeader: true),
                    ],
                  ),
                  // Filas de datos
                  ...students.asMap().entries.map((entry) {
                    final i = entry.key;
                    final s = entry.value;
                    final bg = i.isEven ? lightGrey : white;
                    final gradeStr = s['grade'] != null
                        ? '${s['grade']} / 100'
                        : '—';
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(color: bg),
                      children: [
                        _tableCell(s['name'] ?? ''),
                        _tableCell(s['status'] ?? ''),
                        _tableCell(gradeStr),
                      ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 24),

              // ── Resumen ─────────────────────────────────────────────────
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: lightGrey,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _summaryItem(
                      'Total de Proyectos',
                      '${students.length}',
                      turquoise,
                    ),
                    _summaryItem(
                      'Evaluados',
                      '${students.where((s) => s['grade'] != null).length}',
                      PdfColor.fromInt(0xFF2ECC71),
                    ),
                    _summaryItem(
                      'Pendientes',
                      '${students.where((s) => s['grade'] == null).length}',
                      PdfColor.fromInt(0xFFF39C12),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // ── Pie de página ────────────────────────────────────────────
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  '© ${now.year} Criterium · Reporte generado automáticamente',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
                ),
              ),
            ],
          );
        },
      ),
    );

    // ── Guardar en directorio temporal ───────────────────────────────────────
    final tmpDir = await getTemporaryDirectory();
    final file = File('${tmpDir.path}/reporte_viabilidad_proyectos.pdf');
    await file.writeAsBytes(await pdf.save());

    // ── Compartir ────────────────────────────────────────────────────────────
    await Share.shareXFiles([
      XFile(file.path),
    ], subject: 'Reporte de Viabilidad – $className');
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.grey800,
        ),
      ),
    );
  }

  static pw.Widget _summaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      ],
    );
  }
}
