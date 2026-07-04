import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/listing_repository.dart';
import '../models/delivery_address.dart';
import '../models/listing.dart';
import '../models/order_record.dart';
import '../models/payment_method.dart';
import '../models/user_profile.dart';
import '../services/demo_auth_service.dart';

class ListingStore extends ChangeNotifier {
  ListingStore({ListingRepository? repository})
    : _repository = repository ?? ListingRepository();

  final ListingRepository _repository;
  final List<Listing> _listings = [];
  final Set<String> _savedItemIds = {};
  final List<OrderRecord> _orders = [];
  final Set<String> _followedSellers = {};
  UserProfile _profile = UserProfile.defaults;
  DeliveryAddress _deliveryAddress = DeliveryAddress.defaults;
  DemoAuthProvider? _demoAuthProvider;
  String _selectedPaymentMethodId = PaymentMethodOption.visa.id;
  bool _notifications = true;
  bool _privacy = true;
  bool _loaded = false;

  static const _selectedPaymentKey = 'selected_payment_method';
  static const _deliveryAddressKey = 'delivery_address';
  static const _notificationsKey = 'settings_notifications';
  static const _privacyKey = 'settings_privacy';

  List<Listing> get listings => List.unmodifiable(_listings);
  List<Listing> get savedListings => _listings
      .where((listing) => _savedItemIds.contains(listing.id))
      .toList(growable: false);
  List<OrderRecord> get orders => List.unmodifiable(_orders);
  UserProfile get profile => _profile;
  DeliveryAddress get selectedDeliveryAddress => _deliveryAddress;
  DemoAuthProvider? get demoAuthProvider => _demoAuthProvider;
  bool get isDemoAuthenticated => _demoAuthProvider != null;
  PaymentMethodOption get selectedPaymentMethod =>
      PaymentMethodOption.byId(_selectedPaymentMethodId);
  bool get notifications => _notifications;
  bool get privacy => _privacy;
  bool get loaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final listings = await _repository.load();
    final profile = await _repository.loadProfile();
    final savedItemIds = await _repository.loadSavedItemIds();
    final orders = await _repository.loadOrders();
    final followedSellers = await _repository.loadFollowedSellers();
    _listings
      ..clear()
      ..addAll(listings);
    _profile = profile;
    _savedItemIds
      ..clear()
      ..addAll(savedItemIds);
    _orders
      ..clear()
      ..addAll(orders);
    _followedSellers
      ..clear()
      ..addAll(followedSellers);
    _selectedPaymentMethodId =
        prefs.getString(_selectedPaymentKey) ?? PaymentMethodOption.visa.id;
    final savedAddress = prefs.getString(_deliveryAddressKey);
    if (savedAddress == null) {
      _deliveryAddress = DeliveryAddress.defaults;
    } else {
      final address = DeliveryAddress.decode(savedAddress);
      if (address.isLegacySeedAddress) {
        _deliveryAddress = DeliveryAddress.defaults;
        await prefs.remove(_deliveryAddressKey);
      } else {
        _deliveryAddress = address;
      }
    }
    _demoAuthProvider = DemoAuthService.providerFromValue(
      prefs.getString(DemoAuthService.providerKey),
    );
    _notifications = prefs.getBool(_notificationsKey) ?? true;
    _privacy = prefs.getBool(_privacyKey) ?? true;
    _loaded = true;
    notifyListeners();
  }

  Listing? byId(String id) {
    for (final listing in _listings) {
      if (listing.id == id) return listing;
    }
    return null;
  }

  List<Listing> byCategory(String category) {
    return _listings
        .where(
          (listing) => listing.category.toLowerCase() == category.toLowerCase(),
        )
        .toList();
  }

  List<Listing> bySeller(String seller) {
    return _listings
        .where(
          (listing) => listing.seller.toLowerCase() == seller.toLowerCase(),
        )
        .toList(growable: false);
  }

  Listing? firstBySeller(String seller) {
    final matches = bySeller(seller);
    return matches.isEmpty ? null : matches.first;
  }

  OrderRecord? orderById(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  bool isSaved(String listingId) => _savedItemIds.contains(listingId);

  bool isFollowing(String seller) => _followedSellers.contains(seller);

  Future<void> add(Listing listing) async {
    await _repository.add(listing);
    _listings.insert(0, listing);
    notifyListeners();
  }

  Future<void> update(Listing listing) async {
    final index = _listings.indexWhere((item) => item.id == listing.id);
    if (index == -1) return;
    await _repository.update(listing);
    _listings[index] = listing;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    _listings.removeWhere((item) => item.id == id);
    _savedItemIds.remove(id);
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _repository.saveProfile(profile);
    _profile = profile;
    notifyListeners();
  }

  Future<void> signInWithDemoProvider(DemoAuthProvider provider) async {
    final profile = provider.profile;
    await DemoAuthService.saveProvider(provider);
    await _repository.saveProfile(profile);
    _demoAuthProvider = provider;
    _profile = profile;
    notifyListeners();
  }

  Future<void> signOut() async {
    await DemoAuthService.clearProvider();
    _demoAuthProvider = null;
    notifyListeners();
  }

  Future<void> toggleSaved(String listingId) async {
    final saved = !_savedItemIds.contains(listingId);
    await _repository.setSaved(listingId, saved);
    if (saved) {
      _savedItemIds.add(listingId);
    } else {
      _savedItemIds.remove(listingId);
    }
    notifyListeners();
  }

  Future<OrderRecord> createOrder(Listing listing) async {
    final now = DateTime.now();
    final order = OrderRecord(
      id: 'RT${now.millisecondsSinceEpoch}',
      listingId: listing.id,
      listingTitle: listing.shortTitle,
      seller: listing.seller,
      imageAsset: listing.imageAsset,
      itemPrice: listing.price,
      shipping: 35,
      protectionFee: 0,
      paymentMethodId: selectedPaymentMethod.id,
      paymentMethodTitle: selectedPaymentMethod.title,
      status: 'Paid',
      createdAt: now,
    );
    await _repository.addOrder(order);
    _orders.insert(0, order);
    notifyListeners();
    return order;
  }

  Future<void> selectPaymentMethod(String methodId) async {
    _selectedPaymentMethodId = PaymentMethodOption.byId(methodId).id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedPaymentKey, _selectedPaymentMethodId);
    notifyListeners();
  }

  Future<void> saveDeliveryAddress(DeliveryAddress address) async {
    _deliveryAddress = address;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deliveryAddressKey, address.encode());
    notifyListeners();
  }

  Future<void> setNotifications(bool value) async {
    _notifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
    notifyListeners();
  }

  Future<void> setPrivacy(bool value) async {
    _privacy = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_privacyKey, value);
    notifyListeners();
  }

  Future<void> toggleFollow(String seller) async {
    final following = !_followedSellers.contains(seller);
    await _repository.setFollowing(seller, following);
    if (following) {
      _followedSellers.add(seller);
    } else {
      _followedSellers.remove(seller);
    }
    notifyListeners();
  }
}
