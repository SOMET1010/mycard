/// Service pour la collaboration en temps réel sur les thèmes
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mycard/features/events/page_event_theme_preview.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum CollaborationRole {
  owner, // Propriétaire du thème
  editor, // Éditeur avec droits de modification
  viewer, // Spectateur uniquement
  commenter, // Peut commenter mais pas modifier
}

class CollaborationSession {
  const CollaborationSession({
    required this.sessionId,
    required this.themeId,
    required this.ownerName,
    required this.createdAt,
    this.expiresAt,
    this.collaborators = const [],
    required this.userRole,
    required this.isActive,
  });

  factory CollaborationSession.fromJson(Map<String, dynamic> json) =>
      CollaborationSession(
        sessionId: json['sessionId'],
        themeId: json['themeId'],
        ownerName: json['ownerName'],
        createdAt: DateTime.parse(json['createdAt']),
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'])
            : null,
        collaborators: (json['collaborators'] as List)
            .map((c) => Collaborator.fromJson(c))
            .toList(),
        userRole: CollaborationRole.values.firstWhere(
          (r) => r.name == json['userRole'],
          orElse: () => CollaborationRole.viewer,
        ),
        isActive: json['isActive'] ?? true,
      );
  final String sessionId;
  final String themeId;
  final String ownerName;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final List<Collaborator> collaborators;
  final CollaborationRole userRole;
  final bool isActive;

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'themeId': themeId,
    'ownerName': ownerName,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'collaborators': collaborators.map((c) => c.toJson()).toList(),
    'userRole': userRole.name,
    'isActive': isActive,
  };
}

class Collaborator {
  const Collaborator({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarColor,
    required this.isOnline,
    required this.lastSeen,
  });

  factory Collaborator.fromJson(Map<String, dynamic> json) => Collaborator(
    id: json['id'],
    name: json['name'],
    role: CollaborationRole.values.firstWhere(
      (r) => r.name == json['role'],
      orElse: () => CollaborationRole.viewer,
    ),
    avatarColor: Color(json['avatarColor']),
    isOnline: json['isOnline'] ?? false,
    lastSeen: DateTime.parse(json['lastSeen']),
  );
  final String id;
  final String name;
  final CollaborationRole role;
  final Color avatarColor;
  final bool isOnline;
  final DateTime lastSeen;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role.name,
    'avatarColor': avatarColor.value,
    'isOnline': isOnline,
    'lastSeen': lastSeen.toIso8601String(),
  };
}

class ThemeChange {
  const ThemeChange({
    required this.userId,
    required this.userName,
    required this.timestamp,
    required this.changeType,
    required this.oldValue,
    required this.newValue,
    this.description,
  });

  factory ThemeChange.fromJson(Map<String, dynamic> json) => ThemeChange(
    userId: json['userId'],
    userName: json['userName'],
    timestamp: DateTime.parse(json['timestamp']),
    changeType: json['changeType'],
    oldValue: json['oldValue'],
    newValue: json['newValue'],
    description: json['description'],
  );
  final String userId;
  final String userName;
  final DateTime timestamp;
  final String changeType;
  final Map<String, dynamic> oldValue;
  final Map<String, dynamic> newValue;
  final String? description;

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'timestamp': timestamp.toIso8601String(),
    'changeType': changeType,
    'oldValue': oldValue,
    'newValue': newValue,
    'description': description,
  };
}

class CollaborationMessage {
  const CollaborationMessage({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.timestamp,
    required this.type,
  });

  factory CollaborationMessage.fromJson(Map<String, dynamic> json) =>
      CollaborationMessage(
        id: json['id'],
        userId: json['userId'],
        userName: json['userName'],
        content: json['content'],
        timestamp: DateTime.parse(json['timestamp']),
        type: MessageType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => MessageType.text,
        ),
      );
  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime timestamp;
  final MessageType type;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'type': type.name,
  };
}

enum MessageType { text, themeChange, userJoin, userLeave, system }

class CollaborativeThemeService {
  static WebSocketChannel? _channel;
  static CollaborationSession? _currentSession;
  static final StreamController<ThemeChange> _themeChangeController =
      StreamController.broadcast();
  static final StreamController<CollaborationMessage> _messageController =
      StreamController.broadcast();
  static final StreamController<List<Collaborator>> _collaboratorController =
      StreamController.broadcast();

  static Stream<ThemeChange> get themeChanges => _themeChangeController.stream;
  static Stream<CollaborationMessage> get messages => _messageController.stream;
  static Stream<List<Collaborator>> get collaborators =>
      _collaboratorController.stream;

  static Future<CollaborationSession> createCollaborationSession({
    required String themeId,
    required String userName,
    required EventThemeCustomization initialTheme,
    Duration expiresAfter = const Duration(hours: 24),
    int maxCollaborators = 10,
  }) async {
    try {
      // Simuler la création d'une session (remplacer par un vrai appel API)
      final sessionId = _generateSessionId();

      final session = CollaborationSession(
        sessionId: sessionId,
        themeId: themeId,
        ownerName: userName,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(expiresAfter),
        userRole: CollaborationRole.owner,
        isActive: true,
      );

      _currentSession = session;

      // Envoyer le thème initial
      _broadcastThemeChange(
        userId: 'system',
        userName: 'System',
        changeType: 'theme_created',
        oldValue: {},
        newValue: initialTheme.toJson(),
        description: 'Session de collaboration créée',
      );

      return session;
    } catch (e) {
      throw Exception('Échec de la création de la session: $e');
    }
  }

  static Future<CollaborationSession> joinCollaborationSession({
    required String sessionId,
    required String userName,
  }) async {
    try {
      // Simuler la jonction à une session (remplacer par un vrai appel API)
      final session = CollaborationSession(
        sessionId: sessionId,
        themeId: 'demo_theme',
        ownerName: 'Demo Owner',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        userRole: CollaborationRole.editor,
        isActive: true,
      );

      _currentSession = session;

      // Annoncer l'arrivée de l'utilisateur
      _broadcastMessage(
        userId: session.sessionId,
        userName: userName,
        content: '$userName a rejoint la session',
        type: MessageType.userJoin,
      );

      return session;
    } catch (e) {
      throw Exception('Échec de la jonction à la session: $e');
    }
  }

  static void leaveCollaborationSession() {
    if (_currentSession != null) {
      _broadcastMessage(
        userId: _currentSession!.sessionId,
        userName: 'Current User',
        content: 'Utilisateur déconnecté',
        type: MessageType.userLeave,
      );

      _currentSession = null;
      _channel?.sink.close();
      _channel = null;
    }
  }

  static void broadcastThemeChange({
    required String changeType,
    required Map<String, dynamic> oldValue,
    required Map<String, dynamic> newValue,
    String? description,
  }) {
    if (_currentSession == null) return;

    _broadcastThemeChange(
      userId: _currentSession!.sessionId,
      userName: 'Current User',
      changeType: changeType,
      oldValue: oldValue,
      newValue: newValue,
      description: description,
    );
  }

  static void sendMessage({
    required String content,
    MessageType type = MessageType.text,
  }) {
    if (_currentSession == null) return;

    _broadcastMessage(
      userId: _currentSession!.sessionId,
      userName: 'Current User',
      content: content,
      type: type,
    );
  }

  static void inviteCollaborator({
    required String email,
    required CollaborationRole role,
  }) {
    if (_currentSession == null) return;

    // Simuler l'envoi d'une invitation
    _broadcastMessage(
      userId: 'system',
      userName: 'System',
      content: 'Invitation envoyée à $email',
      type: MessageType.system,
    );
  }

  static void updateCollaboratorRole({
    required String collaboratorId,
    required CollaborationRole newRole,
  }) {
    if (_currentSession == null ||
        _currentSession!.userRole != CollaborationRole.owner) {
      return;
    }

    _broadcastMessage(
      userId: 'system',
      userName: 'System',
      content: 'Rôle du collaborateur mis à jour',
      type: MessageType.system,
    );
  }

  static List<ThemeChange> getRecentChanges({int limit = 50}) {
    // Retourner les changements récents depuis le stockage local
    return [];
  }

  static Future<List<EventThemeCustomization>> getThemeVersions() async {
    // Récupérer les versions précédentes du thème
    return [];
  }

  static Future<EventThemeCustomization> revertToVersion({
    required String versionId,
  }) async {
    // Revenir à une version précédente
    throw UnimplementedError('Revert to version not implemented yet');
  }

  static bool canEditTheme() =>
      _currentSession?.userRole == CollaborationRole.owner ||
      _currentSession?.userRole == CollaborationRole.editor;

  static bool canManageCollaborators() =>
      _currentSession?.userRole == CollaborationRole.owner;

  static CollaborationSession? get currentSession => _currentSession;

  // Méthodes privées

  static void _broadcastThemeChange({
    required String userId,
    required String userName,
    required String changeType,
    required Map<String, dynamic> oldValue,
    required Map<String, dynamic> newValue,
    String? description,
  }) {
    final change = ThemeChange(
      userId: userId,
      userName: userName,
      timestamp: DateTime.now(),
      changeType: changeType,
      oldValue: oldValue,
      newValue: newValue,
      description: description,
    );

    _themeChangeController.add(change);

    // Envoyer via WebSocket si connecté
    if (_channel != null) {
      _channel!.sink.add(
        jsonEncode({'type': 'theme_change', 'data': change.toJson()}),
      );
    }
  }

  static void _broadcastMessage({
    required String userId,
    required String userName,
    required String content,
    required MessageType type,
  }) {
    final message = CollaborationMessage(
      id: _generateMessageId(),
      userId: userId,
      userName: userName,
      content: content,
      timestamp: DateTime.now(),
      type: type,
    );

    _messageController.add(message);

    // Envoyer via WebSocket si connecté
    if (_channel != null) {
      _channel!.sink.add(
        jsonEncode({'type': 'message', 'data': message.toJson()}),
      );
    }
  }

  static String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return 'session_${timestamp}_$random';
  }

  static String _generateMessageId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return 'msg_${timestamp}_$random';
  }

  static void _simulateCollaboratorActivity() {
    // Simuler l'activité des collaborateurs pour la démo
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_currentSession != null && _currentSession!.isActive) {
        final random = DateTime.now().millisecond % 3;
        switch (random) {
          case 0:
            _broadcastMessage(
              userId: 'collaborator_1',
              userName: 'Alice',
              content: 'J\'adore ce thème !',
              type: MessageType.text,
            );
            break;
          case 1:
            _broadcastThemeChange(
              userId: 'collaborator_2',
              userName: 'Bob',
              changeType: 'color_change',
              oldValue: {'primaryColor': 'FF0000FF'},
              newValue: {'primaryColor': 'FF00FF00'},
              description: 'Couleur principale modifiée',
            );
            break;
          case 2:
            _broadcastMessage(
              userId: 'system',
              userName: 'System',
              content: 'Nouveau collaborateur : Carol',
              type: MessageType.userJoin,
            );
            break;
        }
      }
    });
  }
}

class CollaborativeThemeEditor extends StatefulWidget {
  const CollaborativeThemeEditor({
    super.key,
    required this.initialTheme,
    required this.session,
    required this.onThemeChanged,
  });

  final EventThemeCustomization initialTheme;
  final CollaborationSession session;
  final Function(EventThemeCustomization) onThemeChanged;

  @override
  State<CollaborativeThemeEditor> createState() =>
      _CollaborativeThemeEditorState();
}

class _CollaborativeThemeEditorState extends State<CollaborativeThemeEditor> {
  late EventThemeCustomization _currentTheme;
  final List<CollaborationMessage> _messages = [];
  final List<ThemeChange> _changes = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentTheme = widget.initialTheme;
    _setupListeners();
  }

  void _setupListeners() {
    // Écouter les changements de thème
    CollaborativeThemeService.themeChanges.listen((change) {
      if (change.userId != widget.session.sessionId) {
        setState(() {
          _changes.insert(0, change);
          if (_changes.length > 100) {
            _changes.removeLast();
          }
        });
      }
    });

    // Écouter les messages
    CollaborativeThemeService.messages.listen((message) {
      setState(() {
        _messages.add(message);
        if (_messages.length > 200) {
          _messages.removeAt(0);
        }
      });

      // Scroll vers le bas
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_chatScrollController.hasClients) {
          _chatScrollController.animateTo(
            _chatScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Édition collaborative: ${widget.session.ownerName}'),
      actions: [
        IconButton(
          icon: const Icon(Icons.people),
          onPressed: _showCollaborators,
          tooltip: 'Collaborateurs',
        ),
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: _showHistory,
          tooltip: 'Historique des changements',
        ),
      ],
    ),
    body: Row(
      children: [
        // Panneau d'édition principal
        Expanded(flex: 2, child: _buildMainEditor()),

        // Panneau de discussion
        Expanded(flex: 1, child: _buildChatPanel()),
      ],
    ),
  );

  Widget _buildMainEditor() => Column(
    children: [
      // En-tête avec informations de session
      Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey[100],
        child: Row(
          children: [
            Icon(Icons.group, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              'Session: ${widget.session.sessionId}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(widget.session.userRole),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getRoleLabel(widget.session.userRole),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),

      // Zone d'édition (placeholder pour l'éditeur de thème existant)
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Éditeur de thème collaboratif',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              // Ici, intégrer l'éditeur de thème existant
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('Intégrer l\'éditeur de thème ici'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _buildChatPanel() => Column(
    children: [
      // En-tête du chat
      Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey[100],
        child: Row(
          children: [
            const Icon(Icons.chat),
            const SizedBox(width: 8),
            const Text('Discussion'),
            const Spacer(),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),

      // Messages
      Expanded(
        child: ListView.builder(
          controller: _chatScrollController,
          padding: const EdgeInsets.all(8),
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            final message = _messages[index];
            return _buildMessageBubble(message);
          },
        ),
      ),

      // Zone de saisie
      if (CollaborativeThemeService.canEditTheme())
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Tapez un message...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _sendMessage(_messageController.text),
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
    ],
  );

  Widget _buildMessageBubble(CollaborationMessage message) {
    final isCurrentUser = message.userId == widget.session.sessionId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isCurrentUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!isCurrentUser) ...[
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    message.userName.isNotEmpty ? message.userName[0] : '?',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentUser ? Colors.blue[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isCurrentUser)
                        Text(
                          message.userName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      Text(
                        message.content,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              if (isCurrentUser) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.blue[300],
                  child: const Text(
                    'Moi',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Padding(
            padding: EdgeInsets.only(
              left: isCurrentUser ? 0 : 32,
              right: isCurrentUser ? 32 : 0,
            ),
            child: Text(
              _formatTimestamp(message.timestamp),
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String content) {
    if (content.trim().isEmpty) return;

    CollaborativeThemeService.sendMessage(content: content);
    _messageController.clear();
  }

  void _showCollaborators() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Collaborateurs'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[300],
                child: const Text(
                  'MOI',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
              title: Text(widget.session.ownerName),
              subtitle: Text(_getRoleLabel(widget.session.userRole)),
              trailing: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const Divider(),
            const ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple,
                child: Text(
                  'A',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
              title: Text('Alice'),
              subtitle: Text('Éditeur'),
              trailing: Icon(Icons.circle, color: Colors.green, size: 8),
            ),
            const ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text(
                  'B',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
              title: Text('Bob'),
              subtitle: Text('Spectateur'),
              trailing: Icon(Icons.circle, color: Colors.grey, size: 8),
            ),
          ],
        ),
        actions: [
          if (CollaborativeThemeService.canManageCollaborators())
            TextButton(
              onPressed: _showInviteDialog,
              child: const Text('Inviter'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Historique des changements'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _changes.isEmpty
              ? const Center(child: Text('Aucun changement pour le moment'))
              : ListView.builder(
                  itemCount: _changes.length,
                  itemBuilder: (context, index) {
                    final change = _changes[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          change.userName.isNotEmpty ? change.userName[0] : '?',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      title: Text(change.description ?? change.changeType),
                      subtitle: Text(_formatTimestamp(change.timestamp)),
                      trailing: Icon(
                        _getChangeIcon(change.changeType),
                        size: 16,
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inviter un collaborateur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CollaborationRole>(
              initialValue: CollaborationRole.viewer,
              decoration: const InputDecoration(
                labelText: 'Rôle',
                border: OutlineInputBorder(),
              ),
              items: CollaborationRole.values
                  .map(
                    (role) => DropdownMenuItem(
                      value: role,
                      child: Text(_getRoleLabel(role)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              CollaborativeThemeService.inviteCollaborator(
                email: emailController.text,
                role: CollaborationRole.viewer,
              );
              Navigator.pop(context);
            },
            child: const Text('Inviter'),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(CollaborationRole role) {
    switch (role) {
      case CollaborationRole.owner:
        return Colors.purple;
      case CollaborationRole.editor:
        return Colors.blue;
      case CollaborationRole.commenter:
        return Colors.orange;
      case CollaborationRole.viewer:
        return Colors.grey;
    }
  }

  String _getRoleLabel(CollaborationRole role) {
    switch (role) {
      case CollaborationRole.owner:
        return 'Propriétaire';
      case CollaborationRole.editor:
        return 'Éditeur';
      case CollaborationRole.commenter:
        return 'Commentateur';
      case CollaborationRole.viewer:
        return 'Spectateur';
    }
  }

  IconData _getChangeIcon(String changeType) {
    switch (changeType) {
      case 'color_change':
        return Icons.palette;
      case 'font_change':
        return Icons.text_fields;
      case 'layout_change':
        return Icons.view_quilt;
      case 'theme_created':
        return Icons.create_new_folder;
      default:
        return Icons.edit;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours} h';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
