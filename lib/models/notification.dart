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

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['_id'] ?? '',
        userId: json['userId'] ?? '',
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
        read: json['read'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'userId': userId,
        'title': title,
        'body': body,
        'date': date.toIso8601String(),
        'read': read,
      };
}
