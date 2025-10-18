/// Widget de sélection de couleur
library;
import 'package:flutter/material.dart';

class ColorPickerField extends StatelessWidget {

  const ColorPickerField({
    super.key,
    required this.label,
    required this.selectedColor,
    required this.onColorChanged,
    this.helperText,
  });
  final String label;
  final Color selectedColor;
  final Function(Color) onColorChanged;
  final String? helperText;

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            InkWell(
              onTap: () => _showColorPicker(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selectedColor,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.colorize,
                  color: _getContrastColor(selectedColor),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              helperText!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner une couleur'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: _buildColorGrid(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorGrid() {
    final colors = [
      Colors.black,
      Colors.white,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.cyan,
      Colors.amber,
      Colors.indigo,
      Colors.teal,
      Colors.lime,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.redAccent,
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.yellowAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.pinkAccent,
      Colors.cyanAccent,
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final color = colors[index];
        return InkWell(
          onTap: () {
            onColorChanged(color);
            Navigator.of(context).pop();
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: color == selectedColor ? Colors.blue : Colors.grey[300]!,
                width: color == selectedColor ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}