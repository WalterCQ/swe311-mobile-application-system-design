import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../constants/theme.dart';
import '../../models/delivery_address.dart';
import '../../store/listing_store.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_input.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/liquid_button.dart';
import '../../widgets/navigation.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({
    super.key,
    required this.store,
    this.closeOnSave = false,
  });

  final ListingStore store;
  final bool closeOnSave;

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _search = TextEditingController();
  late final _recipient = TextEditingController(
    text: widget.store.selectedDeliveryAddress.recipient,
  );
  late final _phone = TextEditingController(
    text: widget.store.selectedDeliveryAddress.phone,
  );
  late final _line1 = TextEditingController(
    text: widget.store.selectedDeliveryAddress.line1,
  );
  late final _line2 = TextEditingController(
    text: widget.store.selectedDeliveryAddress.line2,
  );
  late final _city = TextEditingController(
    text: widget.store.selectedDeliveryAddress.city,
  );
  late final _state = TextEditingController(
    text: widget.store.selectedDeliveryAddress.state,
  );
  late final _postcode = TextEditingController(
    text: widget.store.selectedDeliveryAddress.postcode,
  );
  late final _country = TextEditingController(
    text: widget.store.selectedDeliveryAddress.country,
  );
  late final _note = TextEditingController(
    text: widget.store.selectedDeliveryAddress.note,
  );
  LatLng? _pinnedLocation;
  double? _accuracyMeters;
  String? _locationStatus;
  bool _locating = false;

  bool _submitted = false;

  List<_AddressSuggestion> get _matches {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return _suggestions.take(2).toList(growable: false);
    return _suggestions
        .where((suggestion) => suggestion.searchText.contains(query))
        .take(3)
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    final address = widget.store.selectedDeliveryAddress;
    if (address.latitude != null && address.longitude != null) {
      _pinnedLocation = LatLng(address.latitude!, address.longitude!);
      _accuracyMeters = address.accuracyMeters;
    }
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    _recipient.dispose();
    _phone.dispose();
    _line1.dispose();
    _line2.dispose();
    _city.dispose();
    _state.dispose();
    _postcode.dispose();
    _country.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      child: Stack(
        children: [
          Form(
            key: _formKey,
            autovalidateMode: _submitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: ListView(
              padding: EdgeInsets.fromLTRB(22, 18, 22, 104),
              children: [
                TopBar(title: 'Delivery Address', showTrailing: false),
                SizedBox(height: 18),
                _LocationPanel(
                  location: _pinnedLocation,
                  accuracyMeters: _accuracyMeters,
                  status: _locationStatus,
                  locating: _locating,
                  onUseLocation: _useCurrentLocation,
                ),
                SizedBox(height: 14),
                GlassInput(
                  controller: _search,
                  label: 'Find Address',
                  helperText: 'Start with building, street, or postcode.',
                  hint: 'KLCC, 50088',
                  icon: Icons.search_rounded,
                  textInputAction: TextInputAction.search,
                ),
                SizedBox(height: 12),
                ..._matches.map(
                  (suggestion) => _AddressSuggestionTile(
                    suggestion: suggestion,
                    onTap: () => _useSuggestion(suggestion),
                  ),
                ),
                SizedBox(height: 12),
                _AddressPreview(address: _currentAddress()),
                SizedBox(height: 20),
                Text('Recipient', style: AppTheme.h2.copyWith(fontSize: 16)),
                SizedBox(height: 10),
                GlassInput(
                  controller: _recipient,
                  label: 'Full Name',
                  hint: 'Recipient name',
                  icon: Icons.person_outline_rounded,
                  requiredField: true,
                  textInputAction: TextInputAction.next,
                  validator: _required('Enter a recipient name.'),
                ),
                SizedBox(height: 12),
                GlassInput(
                  controller: _phone,
                  label: 'Phone Number',
                  hint: '+60 12-345 6789',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 20),
                Text(
                  'Address Details',
                  style: AppTheme.h2.copyWith(fontSize: 16),
                ),
                SizedBox(height: 10),
                GlassInput(
                  controller: _line1,
                  label: 'Address Line 1',
                  hint: 'Street address or building name',
                  icon: Icons.home_outlined,
                  requiredField: true,
                  textInputAction: TextInputAction.next,
                  validator: _required('Enter an address line.'),
                ),
                SizedBox(height: 12),
                GlassInput(
                  controller: _line2,
                  label: 'Address Line 2',
                  hint: 'Apartment, suite, floor',
                  icon: Icons.apartment_rounded,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GlassInput(
                        controller: _postcode,
                        label: 'Postcode',
                        hint: '50480',
                        icon: Icons.pin_drop_outlined,
                        requiredField: true,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: _required('Enter a postcode.'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: GlassInput(
                        controller: _city,
                        label: 'City',
                        hint: 'Kuala Lumpur',
                        icon: Icons.location_city_outlined,
                        requiredField: true,
                        textInputAction: TextInputAction.next,
                        validator: _required('Enter a city.'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GlassInput(
                        controller: _state,
                        label: 'State',
                        hint: 'Wilayah Persekutuan',
                        icon: Icons.map_outlined,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: GlassInput(
                        controller: _country,
                        label: 'Country',
                        hint: 'Malaysia',
                        icon: Icons.public_rounded,
                        requiredField: true,
                        textInputAction: TextInputAction.next,
                        validator: _required('Enter a country.'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                GlassInput(
                  controller: _note,
                  label: 'Delivery Note',
                  hint: 'Gate code, landmark, or drop-off note',
                  icon: Icons.sticky_note_2_outlined,
                  maxLines: 2,
                  textInputAction: TextInputAction.newline,
                ),
              ],
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: 22,
            child: LiquidButton(
              label: 'Save Address',
              icon: Icons.check_circle_outline_rounded,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }

  void _useSuggestion(_AddressSuggestion suggestion) {
    final address = suggestion.address;
    _search.text = suggestion.title;
    _line1.text = address.line1;
    _line2.text = address.line2;
    _city.text = address.city;
    _state.text = address.state;
    _postcode.text = address.postcode;
    _country.text = address.country;
    if (address.latitude != null && address.longitude != null) {
      setState(() {
        _pinnedLocation = LatLng(address.latitude!, address.longitude!);
        _accuracyMeters = address.accuracyMeters;
        _locationStatus = 'Map updated from selected address.';
      });
    }
  }

  DeliveryAddress _currentAddress() {
    return DeliveryAddress(
      recipient: _recipient.text.trim(),
      phone: _phone.text.trim(),
      line1: _line1.text.trim(),
      line2: _line2.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim(),
      postcode: _postcode.text.trim(),
      country: _country.text.trim(),
      note: _note.text.trim(),
      latitude: _pinnedLocation?.latitude,
      longitude: _pinnedLocation?.longitude,
      accuracyMeters: _accuracyMeters,
    );
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _locating = true;
      _locationStatus = 'Requesting one-time location access...';
    });
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setLocationError('Location services are off. Turn them on first.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _setLocationError('Location permission was not granted.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      setState(() {
        _pinnedLocation = LatLng(position.latitude, position.longitude);
        _accuracyMeters = position.accuracy;
        _locationStatus =
            'Pinned current location. Confirm the address details below.';
        _locating = false;
      });
    } catch (_) {
      _setLocationError('Could not get current location. Try again nearby.');
    }
  }

  void _setLocationError(String message) {
    if (!mounted) return;
    setState(() {
      _locationStatus = message;
      _locating = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    await widget.store.saveDeliveryAddress(_currentAddress());
    if (!mounted) return;
    if (widget.closeOnSave) {
      Navigator.pop(context);
      return;
    }
    Navigator.pop(context);
  }

  FormFieldValidator<String> _required(String message) {
    return (value) => value == null || value.trim().isEmpty ? message : null;
  }
}

class _AddressPreview extends StatelessWidget {
  const _AddressPreview({required this.address});

  final DeliveryAddress address;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 24,
      padding: EdgeInsets.all(14),
      opacity: 0.5,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on_outlined, color: AppTheme.blue),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Checkout Preview', style: AppTheme.label),
                SizedBox(height: 4),
                Text(
                  address.checkoutSummary,
                  style: AppTheme.body.copyWith(
                    color: AppTheme.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationPanel extends StatelessWidget {
  const _LocationPanel({
    required this.location,
    required this.accuracyMeters,
    required this.status,
    required this.locating,
    required this.onUseLocation,
  });

  final LatLng? location;
  final double? accuracyMeters;
  final String? status;
  final bool locating;
  final VoidCallback onUseLocation;

  @override
  Widget build(BuildContext context) {
    final point = location ?? const LatLng(3.1579, 101.7116);
    return GlassCard(
      radius: 26,
      padding: EdgeInsets.zero,
      opacity: 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            child: SizedBox(
              height: 128,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: location == null ? 12.0 : 15.5,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.retro_tech_marketplace',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 48,
                        height: 48,
                        child: Icon(
                          Icons.location_pin,
                          color: location == null
                              ? AppTheme.muted
                              : AppTheme.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        location == null
                            ? 'Confirm Delivery Area'
                            : 'Current Location Pinned',
                        style: AppTheme.h2.copyWith(fontSize: 16),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: locating ? null : onUseLocation,
                      icon: locating
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.my_location_rounded, size: 18),
                      label: Text(locating ? 'Locating' : 'Use current'),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  _locationCopy(),
                  style: AppTheme.body.copyWith(fontSize: 12, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _locationCopy() {
    if (status != null) return status!;
    if (location == null) {
      return 'Use the map to check the delivery area, then choose an address or fill it manually.';
    }
    final accuracy = accuracyMeters == null
        ? ''
        : ' Accuracy about ${accuracyMeters!.round()}m.';
    return 'Pinned at ${location!.latitude.toStringAsFixed(5)}, ${location!.longitude.toStringAsFixed(5)}.$accuracy';
  }
}

class _AddressSuggestionTile extends StatelessWidget {
  const _AddressSuggestionTile({required this.suggestion, required this.onTap});

  final _AddressSuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: EdgeInsets.only(bottom: 10),
      radius: 22,
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: Icon(Icons.near_me_outlined, color: AppTheme.blue),
        title: Text(
          suggestion.title,
          style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.ink),
        ),
        subtitle: Text(suggestion.subtitle, style: AppTheme.body),
        trailing: Icon(Icons.add_location_alt_outlined, color: AppTheme.muted),
      ),
    );
  }
}

class _AddressSuggestion {
  const _AddressSuggestion({
    required this.title,
    required this.subtitle,
    required this.address,
  });

  final String title;
  final String subtitle;
  final DeliveryAddress address;

  String get searchText => [
    title,
    subtitle,
    address.line1,
    address.line2,
    address.city,
    address.state,
    address.postcode,
    address.country,
  ].join(' ').toLowerCase();
}

const _suggestions = [
  _AddressSuggestion(
    title: 'KLCC, Jalan Ampang',
    subtitle: '50088 Kuala Lumpur, Malaysia',
    address: DeliveryAddress(
      recipient: '',
      phone: '',
      line1: 'Kuala Lumpur City Centre',
      line2: 'Jalan Ampang',
      city: 'Kuala Lumpur',
      state: 'Wilayah Persekutuan',
      postcode: '50088',
      country: 'Malaysia',
      note: '',
      latitude: 3.1579,
      longitude: 101.7116,
      accuracyMeters: null,
    ),
  ),
  _AddressSuggestion(
    title: 'Mid Valley Megamall',
    subtitle: '59200 Kuala Lumpur, Malaysia',
    address: DeliveryAddress(
      recipient: '',
      phone: '',
      line1: 'Mid Valley Megamall',
      line2: 'Lingkaran Syed Putra',
      city: 'Kuala Lumpur',
      state: 'Wilayah Persekutuan',
      postcode: '59200',
      country: 'Malaysia',
      note: '',
      latitude: 3.1188,
      longitude: 101.6775,
      accuracyMeters: null,
    ),
  ),
  _AddressSuggestion(
    title: 'The Exchange TRX',
    subtitle: '55188 Kuala Lumpur, Malaysia',
    address: DeliveryAddress(
      recipient: '',
      phone: '',
      line1: 'The Exchange TRX',
      line2: 'Persiaran TRX',
      city: 'Kuala Lumpur',
      state: 'Wilayah Persekutuan',
      postcode: '55188',
      country: 'Malaysia',
      note: '',
      latitude: 3.1427,
      longitude: 101.7197,
      accuracyMeters: null,
    ),
  ),
];
