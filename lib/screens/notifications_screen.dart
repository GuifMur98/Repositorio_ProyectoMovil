import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _notifications = [
    // Simulación de notificaciones en memoria
    AppNotification(
      id: '1',
      userId: 'user1',
      title: '¡Bienvenido!',
      body: 'Gracias por unirte a la app.',
      date: DateTime.now().subtract(const Duration(hours: 1)),
      read: false,
    ),
    AppNotification(
      id: '2',
      userId: 'user1',
      title: 'Compra realizada',
      body: 'Tu compra fue exitosa.',
      date: DateTime.now().subtract(const Duration(days: 1)),
      read: true,
    ),
    // Agrega más notificaciones simuladas si lo deseas
  ];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Simulación: los datos ya están cargados en memoria
    _isLoading = false;
  }

  Future<void> _fetchNotifications() async {
    // Simulación: los datos ya están en memoria
    setState(() {
      _isLoading = false;
      _error = null;
    });
  }

  Future<void> _markAsRead(String id) async {
    setState(() {
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        _notifications[idx] = _notifications[idx].copyWith(read: true);
      }
    });
  }

  Future<void> _deleteNotification(String id) async {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5C3D2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _notifications.isEmpty
                  ? const Center(child: Text('No tienes notificaciones.'))
                  : RefreshIndicator(
                      onRefresh: _fetchNotifications,
                      child: ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final n = _notifications[index];
                          return Card(
                            color: n.read
                                ? Colors.grey[100]
                                : const Color(0xFFFFF3E0),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: Icon(
                                n.read
                                    ? Icons.notifications_none
                                    : Icons.notifications_active,
                                color: n.read
                                    ? Colors.grey
                                    : const Color(0xFF5C3D2E),
                              ),
                              title: Text(n.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(n.body),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(n.date),
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!n.read)
                                    IconButton(
                                      icon: const Icon(Icons.mark_email_read,
                                          color: Colors.green),
                                      tooltip: 'Marcar como leída',
                                      onPressed: () => _markAsRead(n.id),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    tooltip: 'Eliminar',
                                    onPressed: () => _deleteNotification(n.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (now.difference(date).inDays == 0) {
      return 'Hoy, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }
}

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime date;
  final bool read;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.date,
    required this.read,
  });

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      userId: userId,
      title: title,
      body: body,
      date: date,
      read: read ?? this.read,
    );
  }
}
