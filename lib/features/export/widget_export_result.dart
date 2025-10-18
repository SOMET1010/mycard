/// Widget pour afficher le résultat d'un export
library;

import 'package:flutter/material.dart';
import 'package:mycard/data/models/business_card.dart';

class ExportResultPage extends StatelessWidget {
  const ExportResultPage({
    super.key,
    required this.format,
    required this.success,
    required this.card,
  });
  final String format;
  final bool success;
  final BusinessCard card;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Résultat de l\'export'),
      automaticallyImplyLeading: false,
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône de résultat
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: success ? Colors.green[100] : Colors.red[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                success ? Icons.check_circle : Icons.error,
                size: 40,
                color: success ? Colors.green : Colors.red,
              ),
            ),

            const SizedBox(height: 24),

            // Message
            Text(
              success ? 'Export réussi !' : 'Échec de l\'export',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(
              success
                  ? 'Votre carte a été exportée au format ${format.toUpperCase()}'
                  : 'Une erreur est survenue lors de l\'export',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Détails de l'export
            if (success) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Détails',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Format', format.toUpperCase()),
                    _buildDetailRow('Carte', card.fullName),
                    _buildDetailRow('Date', _formatDate(DateTime.now())),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Retour'),
                  ),
                ),
                if (success) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Partager le fichier
                      },
                      child: const Text('Partager'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildDetailRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Text(
          '$label :',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, style: TextStyle(color: Colors.grey[600])),
        ),
      ],
    ),
  );

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
