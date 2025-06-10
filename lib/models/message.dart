class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json, {String? id}) => Message(
        id: id ?? json['id'] ?? '',
        chatId: json['chatId'] ?? '',
        senderId: json['senderId'] ?? '',
        content: json['content'] ?? '',
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
            : DateTime.now(),
      );

  factory Message.fromFirestore(Map<String, dynamic> json, String id) {
    return Message.fromJson(json, id: id);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chatId': chatId,
        'senderId': senderId,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  Map<String, dynamic> toFirestore() => toJson();
}
