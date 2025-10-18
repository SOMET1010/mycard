/// Service pour la gestion des fichiers et images
library;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Prend une photo depuis la caméra
  static Future<File?> pickImageFromCamera() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur lors de la prise de photo: $e');
      return null;
    }
  }

  /// Sélectionne une image depuis la galerie
  static Future<File?> pickImageFromGallery() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur lors de la sélection d\'image: $e');
      return null;
    }
  }

  /// Sauvegarde une image dans le répertoire de l'application
  static Future<String?> saveImage(File image, String fileName) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cardDir = Directory('${appDir.path}/mycard');

      if (!await cardDir.exists()) {
        await cardDir.create(recursive: true);
      }

      final finalPath = '${cardDir.path}/$fileName';
      await image.copy(finalPath);

      return finalPath;
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde de l\'image: $e');
      return null;
    }
  }

  /// Supprime un fichier
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de la suppression du fichier: $e');
      return false;
    }
  }

  /// Vérifie si un fichier existe
  static Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      debugPrint('Erreur lors de la vérification du fichier: $e');
      return false;
    }
  }

  /// Crée un nom de fichier unique
  static String generateUniqueFileName(String baseName, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().millisecond;
    return '${baseName}_${timestamp}_$random.$extension';
  }

  /// Obtient la taille d'un fichier
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur lors de l\'obtention de la taille du fichier: $e');
      return 0;
    }
  }

  /// Formatte la taille du fichier pour l'affichage
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Nettoie les fichiers temporaires
  static Future<void> cleanupTempFiles() async {
    try {
      final tempDir = Directory.systemTemp;
      if (await tempDir.exists()) {
        final files = await tempDir.list().where((entity) => entity is File).cast<File>().toList();

        for (final file in files) {
          if (file.path.contains('mycard') || file.path.contains('screenshot')) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Erreur lors du nettoyage des fichiers temporaires: $e');
    }
  }
}