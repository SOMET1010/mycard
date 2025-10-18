/// Page pour sélectionner un événement – design carte + création auto de carte
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mycard/data/models/event_overlay.dart';
import 'package:mycard/features/events/page_event_theme_preview.dart';
import 'package:mycard/features/events/widget_event_tile.dart';

class EventsPickerPage extends StatelessWidget {
  const EventsPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    const events = EventOverlay.predefinedEvents;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/gallery'),
        ),
        title: const Text('Thèmes d\'Événements'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Thèmes Disponibles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          final event = events[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: EventThemeTile(
              event: event,
              onActivate: () => _showEventPreview(context, event),
            ),
          );
        },
      ),
    );
  }

  void _showEventPreview(
    BuildContext context,
    EventOverlay event,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventThemePreviewPage(event: event),
      ),
    );
  }
}
