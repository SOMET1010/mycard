/// Page pour exporter une carte de visite
library;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mycard/data/models/business_card.dart';
import 'package:mycard/features/export/widget_export_result.dart';

class ExportPage extends StatefulWidget {

  const ExportPage({super.key, required this.card});
  final BusinessCard card;

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  String _selectedFormat = 'png';
  bool _includeQRCode = true;
  bool _includeVCard = false;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Exporter la carte'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aperçu de la carte
            _buildCardPreview(),
            const SizedBox(height: 24),

            // Format d'export
            _buildFormatSection(),
            const SizedBox(height: 24),

            // Options d'export
            _buildOptionsSection(),
            const SizedBox(height: 24),

            // Actions
            _buildActionsSection(),
          ],
        ),
      ),
    );

  Widget _buildCardPreview() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aperçu',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Center(
            child: Text('Aperçu de la carte'),
          ),
        ),
      ],
    );

  Widget _buildFormatSection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Format d\'export',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            _buildFormatChip('png', 'PNG'),
            _buildFormatChip('jpg', 'JPG'),
            _buildFormatChip('pdf', 'PDF'),
          ],
        ),
      ],
    );

  Widget _buildFormatChip(String format, String label) {
    final isSelected = _selectedFormat == format;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFormat = format;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsSection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Options',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          title: const Text('Inclure le code QR'),
          subtitle: const Text('Ajoute un code QR avec les informations de contact'),
          value: _includeQRCode,
          onChanged: (value) {
            setState(() {
              _includeQRCode = value ?? false;
            });
          },
        ),
        if (_selectedFormat == 'pdf')
          CheckboxListTile(
            title: const Text('Inclure la vCard'),
            subtitle: const Text('Ajoute un fichier vCard téléchargeable'),
            value: _includeVCard,
            onChanged: (value) {
              setState(() {
                _includeVCard = value ?? false;
              });
            },
          ),
      ],
    );

  Widget _buildActionsSection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isExporting ? null : _exportCard,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Exporter'),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            context.pop();
          },
          child: const Text('Annuler'),
        ),
      ],
    );

  Future<void> _exportCard() async {
    setState(() {
      _isExporting = true;
    });

    // Simuler l'export
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isExporting = false;
      });

      // Afficher le résultat
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ExportResultPage(
            format: _selectedFormat,
            success: true,
            card: widget.card,
          ),
        ),
      );
    }
  }
}
