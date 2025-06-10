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

  factory AppNotification.fromJson(Map<String, dynamic> json, {String? id}) =>
      AppNotification(
        id: id ?? json['id'] ?? '',
        userId: json['userId'] ?? '',
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        date: json['date'] != null
            ? DateTime.tryParse(json['date']) ?? DateTime.now()
            : DateTime.now(),
        read: json['read'] ?? false,
      );

  factory AppNotification.fromFirestore(Map<String, dynamic> json, String id) {
    return AppNotification.fromJson(json, id: id);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
        'date': date.toIso8601String(),
        'read': read,
      };

  Map<String, dynamic> toFirestore() => toJson();
}
