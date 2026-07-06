class CommunityReplyRecord {
  const CommunityReplyRecord({
    required this.id,
    required this.postId,
    required this.user,
    required this.handle,
    required this.time,
    required this.text,
    required this.asset,
    required this.createdAt,
  });

  final String id;
  final String postId;
  final String user;
  final String handle;
  final String time;
  final String text;
  final String asset;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'postId': postId,
      'user': user,
      'handle': handle,
      'timeLabel': time,
      'text': text,
      'asset': asset,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CommunityReplyRecord.fromMap(Map<String, Object?> map) {
    return CommunityReplyRecord(
      id: map['id'] as String,
      postId: map['postId'] as String,
      user: map['user'] as String,
      handle: map['handle'] as String,
      time: map['timeLabel'] as String,
      text: map['text'] as String,
      asset: map['asset'] as String,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
