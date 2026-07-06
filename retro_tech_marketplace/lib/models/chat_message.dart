class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.sellerName,
    required this.text,
    required this.mine,
    required this.createdAt,
    this.listingId,
    this.imagePath,
  });

  final String id;
  final String conversationId;
  final String sellerName;
  final String text;
  final bool mine;
  final DateTime createdAt;
  final String? listingId;
  final String? imagePath;

  String get timeLabel {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    if (difference.inMinutes < 1) return 'Now';
    if (difference.inHours < 1) return '${difference.inMinutes}m';
    if (difference.inDays < 1) return '${difference.inHours}h';
    if (difference.inDays == 1) return 'Yesterday';
    return '${difference.inDays}d';
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'sellerName': sellerName,
      'listingId': listingId,
      'text': text,
      'mine': mine ? 1 : 0,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, Object?> map) {
    return ChatMessage(
      id: map['id'] as String,
      conversationId: map['conversationId'] as String,
      sellerName: map['sellerName'] as String,
      listingId: map['listingId'] as String?,
      text: map['text'] as String,
      mine: (map['mine'] as int? ?? 0) == 1,
      imagePath: map['imagePath'] as String?,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class ChatConversationState {
  const ChatConversationState({
    required this.conversationId,
    required this.sellerName,
    required this.blocked,
    required this.reported,
    required this.updatedAt,
    this.listingId,
  });

  final String conversationId;
  final String sellerName;
  final bool blocked;
  final bool reported;
  final DateTime updatedAt;
  final String? listingId;

  ChatConversationState copyWith({
    String? sellerName,
    bool? blocked,
    bool? reported,
    DateTime? updatedAt,
    String? listingId,
  }) {
    return ChatConversationState(
      conversationId: conversationId,
      sellerName: sellerName ?? this.sellerName,
      blocked: blocked ?? this.blocked,
      reported: reported ?? this.reported,
      updatedAt: updatedAt ?? this.updatedAt,
      listingId: listingId ?? this.listingId,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'conversationId': conversationId,
      'sellerName': sellerName,
      'listingId': listingId,
      'blocked': blocked ? 1 : 0,
      'reported': reported ? 1 : 0,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ChatConversationState.fromMap(Map<String, Object?> map) {
    return ChatConversationState(
      conversationId: map['conversationId'] as String,
      sellerName: map['sellerName'] as String,
      listingId: map['listingId'] as String?,
      blocked: (map['blocked'] as int? ?? 0) == 1,
      reported: (map['reported'] as int? ?? 0) == 1,
      updatedAt:
          DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
