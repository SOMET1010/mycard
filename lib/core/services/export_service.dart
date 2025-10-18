/// Service pour l'export des cartes de visite
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  /// Exporte une carte en PNG
  static Future<void> exportAsPNG({
    required ScreenshotController screenshotController,
    required String fileName,
    required BuildContext context,
  }) async {
    try {
      final image = await screenshotController.capture();
      if (image == null) throw Exception('Impossible de capturer l\'image');

      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/$fileName.png');
      await file.writeAsBytes(image);

      final xFile = XFile(file.path, name: '$fileName.png');
      await Share.shareXFiles([xFile], subject: 'Carte de visite - $fileName');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'export PNG: $e')),
        );
      }
    }
  }

  /// Exporte une carte en PDF
  static Future<void> exportAsPDF({
    required ScreenshotController screenshotController,
    required String fileName,
    required BuildContext context,
  }) async {
    try {
      final image = await screenshotController.capture();
      if (image == null) throw Exception('Impossible de capturer l\'image');

      final pdf = pw.Document();
      final pdfImage = pw.MemoryImage(image);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => pw.Center(child: pw.Image(pdfImage)),
        ),
      );

      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/$fileName.pdf');
      await file.writeAsBytes(await pdf.save());

      final xFile = XFile(file.path, name: '$fileName.pdf');
      await Share.shareXFiles([xFile], subject: 'Carte de visite - $fileName');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'export PDF: $e')),
        );
      }
    }
  }

  /// Exporte une carte en JPG
  static Future<void> exportAsJPG({
    required ScreenshotController screenshotController,
    required String fileName,
    required BuildContext context,
    int quality = 90,
  }) async {
    try {
      final image = await screenshotController.capture();
      if (image == null) throw Exception('Impossible de capturer l\'image');

      // Convert PNG to JPG using image package
      final decodedImage = img.decodeImage(image);
      if (decodedImage == null)
        throw Exception('Impossible de décoder l\'image');

      final jpgImage = img.encodeJpg(decodedImage, quality: quality);

      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/$fileName.jpg');
      await file.writeAsBytes(jpgImage);

      final xFile = XFile(file.path, name: '$fileName.jpg');
      await Share.shareXFiles([xFile], subject: 'Carte de visite - $fileName');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'export JPG: $e')),
        );
      }
    }
  }

  /// Exporte une vCard
  static Future<void> exportVCard({
    required String vCardContent,
    required String fileName,
    required BuildContext context,
  }) async {
    try {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/$fileName.vcf');
      await file.writeAsString(vCardContent);

      final xFile = XFile(file.path, name: '$fileName.vcf');
      await Share.shareXFiles([xFile], subject: 'Contact - $fileName');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'export vCard: $e')),
        );
      }
    }
  }

  /// Génère un nom de fichier pour l'export
  static String generateFileName({
    required String name,
    required String format,
  }) {
    final sanitized = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    return '${sanitized}_card.$format';
  }

  /// Sauvegarde une image sans partage (pour les tests)
  static Future<String> saveImageWithoutShare({
    required Uint8List imageBytes,
    required String fileName,
    required String format,
  }) async {
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/$fileName.$format');
    await file.writeAsBytes(imageBytes);
    return file.path;
  }

  /// Crée un PDF sans partage (pour les tests)
  static Future<String> createPdfWithoutShare({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    final pdf = pw.Document();
    final pdfImage = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Center(child: pw.Image(pdfImage)),
      ),
    );

    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/$fileName.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }
}
