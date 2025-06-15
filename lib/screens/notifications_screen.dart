import 'package:flutter/material.dart';
import 'package:proyecto/services/notification_service.dart';
import '../models/notification.dart' as model;
import '../widgets/custom_image_spinner.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Stream<List<model.AppNotification>> _notificationsStream;

  @override
  void initState() {
    super.initState();
    _notificationsStream = NotificationService.getUserNotificationsStream();
  }

  Future<void> _deleteNotification(String id) async {
    await NotificationService.deleteNotification(id);
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
        shape: const Border(
          bottom: BorderSide(color: Colors.transparent, width: 0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<model.AppNotification>>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomImageSpinner(size: 40));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar notificaciones'));
          }
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return const Center(child: Text('No tienes notificaciones.'));
          }
          return RefreshIndicator(
            onRefresh: () async {},
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return Dismissible(
                  key: Key(n.id),
                  direction: DismissDirection.horizontal, // Permite ambos lados
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) async {
                    await _deleteNotification(n.id);
                  },
                  child: Card(
                    color: n.read ? Colors.grey[100] : const Color(0xFFFFF3E0),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(
                        n.read
                            ? Icons.notifications_none
                            : Icons.notifications_active,
                        color: n.read ? Colors.grey : const Color(0xFF5C3D2E),
                      ),
                      title: Text(n.title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
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
                          // Eliminado: opción de marcar como leída
                        ],
                      ),
                      // Eliminado onTap: ahora no hace nada al hacer click
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    int hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    String ampm = date.hour < 12 ? 'a.m.' : 'p.m.';
    String hourMinute = '$hour:${date.minute.toString().padLeft(2, '0')} $ampm';
    if (now.difference(date).inDays == 0) {
      return 'Hoy, $hourMinute';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} $hourMinute';
    }
  }
}
