class OrderRecord {
  const OrderRecord({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.seller,
    required this.imageAsset,
    required this.itemPrice,
    required this.shipping,
    required this.protectionFee,
    required this.paymentMethodId,
    required this.paymentMethodTitle,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String listingId;
  final String listingTitle;
  final String seller;
  final String imageAsset;
  final double itemPrice;
  final double shipping;
  final double protectionFee;
  final String paymentMethodId;
  final String paymentMethodTitle;
  final String status;
  final DateTime createdAt;

  double get total => itemPrice + shipping + protectionFee;
  String get totalLabel => 'RM ${total.toStringAsFixed(2)}';

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'listingId': listingId,
      'listingTitle': listingTitle,
      'seller': seller,
      'imageAsset': imageAsset,
      'itemPrice': itemPrice,
      'shipping': shipping,
      'protectionFee': protectionFee,
      'paymentMethodId': paymentMethodId,
      'paymentMethodTitle': paymentMethodTitle,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OrderRecord.fromMap(Map<String, Object?> map) {
    return OrderRecord(
      id: map['id'] as String,
      listingId: map['listingId'] as String,
      listingTitle: map['listingTitle'] as String,
      seller: map['seller'] as String,
      imageAsset: map['imageAsset'] as String,
      itemPrice: (map['itemPrice'] as num).toDouble(),
      shipping: (map['shipping'] as num).toDouble(),
      protectionFee: (map['protectionFee'] as num).toDouble(),
      paymentMethodId: map['paymentMethodId'] as String,
      paymentMethodTitle: map['paymentMethodTitle'] as String,
      status: map['status'] as String? ?? 'Placed',
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
