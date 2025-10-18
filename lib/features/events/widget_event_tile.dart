import 'package:flutter/material.dart';
import 'package:mycard/data/models/event_overlay.dart';

class EventThemeTile extends StatelessWidget {
  const EventThemeTile({
    super.key,
    required this.event,
    required this.onActivate,
  });
  final EventOverlay event;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final accent = event.color;
    final accentLight = event.color.withValues(alpha: 0.1);

    return InkWell(
      onTap: onActivate,
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec label et icône
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accentLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(_iconFor(event.icon), color: accent, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Séparateur
              Container(
                height: 1,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(0.5),
                ),
              ),
              const SizedBox(height: 12),
              // Contenu principal
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _headlineFor(event),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _subtitleFor(event),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _headlineFor(EventOverlay e) {
    switch (e.id) {
      case 'octobre_rose':
        return 'Soutenez la sensibilisation au cancer du sein';
      case 'movember':
        return 'Soutenez la santé masculine';
      case 'noel':
        return 'Célébrez les fêtes de fin d\'année';
      case 'fete_des_meres':
        return 'Célébrez les mères';
      case 'fete_des_peres':
        return 'Célébrez les pères';
      case 'st_valentin':
        return 'Partagez l\'amour';
      case 'halloween':
        return 'Ambiance effrayante d\'Halloween';
      case 'nouvel_an':
        return 'Bonne année';
      default:
        return e.description;
    }
  }

  String _subtitleFor(EventOverlay e) {
    switch (e.id) {
      case 'octobre_rose':
        return 'Montrez votre soutien avec une carte aux tons roses.';
      case 'movember':
        return 'Sensibilisez avec une carte aux tons bleus.';
      case 'noel':
        return 'Tons chaleureux de fête pour votre carte.';
      case 'fete_des_meres':
        return 'Honorez les mères avec une carte aux tons roses.';
      case 'fete_des_peres':
        return 'Honorez les pères avec une carte bleue raffinée.';
      case 'st_valentin':
        return 'Diffusez l\'amour avec une carte aux tons rouges.';
      case 'halloween':
        return 'Effrayez avec des accents violets.';
      case 'nouvel_an':
        return 'Commencez l\'année avec des tons dorés.';
      default:
        return e.description;
    }
  }

  IconData _iconFor(String iconName) {
    switch (iconName) {
      case 'ribbon':
        return Icons.emoji_events;
      case 'tree':
        return Icons.forest;
      case 'heart':
        return Icons.favorite;
      case 'mustache':
        return Icons.face;
      case 'tie':
        return Icons.work;
      case 'pumpkin':
        return Icons.hourglass_full;
      case 'champagne':
        return Icons.celebration;
      default:
        return Icons.event;
    }
  }
}
