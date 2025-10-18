/// Widget pour afficher un événement sous forme de chip
library;

import 'package:flutter/material.dart';
import 'package:mycard/data/models/event_overlay.dart';

class EventChip extends StatelessWidget {
  const EventChip({
    super.key,
    required this.event,
    this.onTap,
    this.isSelected = false,
    this.showLabel = true,
  });
  final EventOverlay event;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showLabel;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: event.color.withOpacity(0.2),
        border: Border.all(
          color: isSelected ? event.color : event.color.withOpacity(0.5),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getEventIcon(event.icon), color: event.color, size: 16),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              event.label,
              style: TextStyle(
                color: event.color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    ),
  );

  IconData _getEventIcon(String iconName) {
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
      case 'love':
        return Icons.favorite;
      case 'pumpkin':
        return Icons.circle;
      case 'champagne':
        return Icons.celebration;
      default:
        return Icons.event;
    }
  }
}
