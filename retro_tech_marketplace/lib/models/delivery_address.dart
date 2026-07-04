import 'dart:convert';

class DeliveryAddress {
  const DeliveryAddress({
    required this.recipient,
    required this.phone,
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.postcode,
    required this.country,
    required this.note,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
  });

  final String recipient;
  final String phone;
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String postcode;
  final String country;
  final String note;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;

  static const defaults = DeliveryAddress(
    recipient: '',
    phone: '',
    line1: '',
    line2: '',
    city: '',
    state: '',
    postcode: '',
    country: '',
    note: '',
    latitude: null,
    longitude: null,
    accuracyMeters: null,
  );

  bool get isEmpty {
    return [
          recipient,
          phone,
          line1,
          line2,
          city,
          state,
          postcode,
          country,
          note,
        ].every((value) => value.trim().isEmpty) &&
        latitude == null &&
        longitude == null;
  }

  bool get isLegacySeedAddress {
    return note == 'Leave with reception if unavailable.' &&
        postcode == '50480' &&
        latitude == 3.1579 &&
        longitude == 101.7116;
  }

  List<String> get summaryLines {
    if (isEmpty) return const ['No delivery address selected'];

    final cityLine = [
      postcode,
      city,
    ].where((value) => value.trim().isNotEmpty).join(' ');
    final locationLine = [
      cityLine,
      country,
    ].where((value) => value.trim().isNotEmpty).join(', ');

    final lines = [
      recipient,
      line1,
      line2,
      locationLine,
    ].where((value) => value.trim().isNotEmpty).toList(growable: false);
    return lines.isEmpty ? const ['No delivery address selected'] : lines;
  }

  String get checkoutSummary => summaryLines.join('\n');

  Map<String, Object?> toJson() {
    return {
      'recipient': recipient,
      'phone': phone,
      'line1': line1,
      'line2': line2,
      'city': city,
      'state': state,
      'postcode': postcode,
      'country': country,
      'note': note,
      'latitude': latitude,
      'longitude': longitude,
      'accuracyMeters': accuracyMeters,
    };
  }

  String encode() => jsonEncode(toJson());

  factory DeliveryAddress.fromJson(Map<String, Object?> json) {
    return DeliveryAddress(
      recipient: json['recipient'] as String? ?? defaults.recipient,
      phone: json['phone'] as String? ?? defaults.phone,
      line1: json['line1'] as String? ?? defaults.line1,
      line2: json['line2'] as String? ?? defaults.line2,
      city: json['city'] as String? ?? defaults.city,
      state: json['state'] as String? ?? defaults.state,
      postcode: json['postcode'] as String? ?? defaults.postcode,
      country: json['country'] as String? ?? defaults.country,
      note: json['note'] as String? ?? defaults.note,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      accuracyMeters: (json['accuracyMeters'] as num?)?.toDouble(),
    );
  }

  factory DeliveryAddress.decode(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, Object?>) return defaults;
    return DeliveryAddress.fromJson(decoded);
  }
}
