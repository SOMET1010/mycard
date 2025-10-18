import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadArea extends StatefulWidget {

  const UploadArea({super.key, this.initialPath, this.onSelected});
  final String? initialPath;
  final Future<void> Function(String path)? onSelected;

  @override
  State<UploadArea> createState() => _UploadAreaState();
}

class _UploadAreaState extends State<UploadArea> {
  String? _path;

  @override
  void initState() {
    super.initState();
    _path = widget.initialPath;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _path = file.path);
      if (widget.onSelected != null) {
        await widget.onSelected!(file.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.primary.withOpacity(0.5);
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1, style: BorderStyle.solid),
        ),
        child: _path == null
            ? _buildPlaceholder(context)
            : Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_path!),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _path!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                ],
              ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_outlined, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          'Tap to upload a logo or photo',
          style: TextStyle(color: Colors.grey[700]),
        ),
        Text(
          'PNG, JPG, SVG up to 5MB',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
      ],
    );
}

