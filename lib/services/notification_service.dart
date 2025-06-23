import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification.dart';
import 'local_notifications_service.dart';

class NotificationService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // Obtener notificaciones del usuario actual en tiempo real
  static Stream<List<AppNotification>> getUserNotificationsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Marcar una notificación como leída
  static Future<void> markAsRead(String notificationId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  // Eliminar una notificación
  static Future<void> deleteNotification(String notificationId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  // Crear una notificación para el usuario actual
  static Future<void> createNotification({
    required String title,
    required String body,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final notification = AppNotification(
      id: '',
      userId: user.uid,
      title: title,
      body: body,
      date: DateTime.now(),
      read: false,
    );
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .add(notification.toFirestore());
  }

  // Crear una notificación para un usuario específico
  static Future<void> createNotificationForUser({
    required String userId,
    required String title,
    required String body,
    String? chatId,
    String? senderId,
  }) async {
    final notificationData = AppNotification(
      id: '',
      userId: userId,
      title: title,
      body: body,
      date: DateTime.now(),
      read: false,
    ).toFirestore();
    if (chatId != null) {
      notificationData['chatId'] = chatId;
    }
    if (senderId != null) {
      notificationData['senderId'] = senderId;
    }
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add(notificationData);

    // Mostrar notificación local si el usuario actual es el destinatario
    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.uid == userId) {
      await NotificationsService().showNotification(
        title: title,
        body: body,
      );
    }
  }

  static String? getCurrentUserId() {
    final user = _auth.currentUser;
    return user?.uid;
  }
}
