import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'store/listing_store.dart';
import 'constants/theme.dart';
import 'models/listing.dart';
import 'models/order_record.dart';
import 'services/update_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/shell/main_shell.dart';
import 'screens/product/product_detail_screen.dart';
import 'screens/product/category_detail_screen.dart';
import 'screens/product/my_listings_screen.dart';
import 'screens/product/listing_form_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/checkout/delivery_address_screen.dart';
import 'screens/checkout/order_confirmation_screen.dart';
import 'screens/profile/seller_profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/payment_methods_screen.dart';
import 'screens/profile/saved_items_screen.dart';
import 'screens/settings/chat_thread_screen.dart';
import 'screens/settings/help_support_screen.dart';
import 'screens/settings/about_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'widgets/update_prompt.dart';

class RetroTechApp extends StatefulWidget {
  const RetroTechApp({super.key, required this.store});

  final ListingStore store;

  @override
  State<RetroTechApp> createState() => _RetroTechAppState();
}

class _RetroTechAppState extends State<RetroTechApp> {
  late final Future<void> _loadFuture = widget.store.load();
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    if (kReleaseMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForUpdatesAfterLaunch();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        return MaterialApp(
          title: 'RetroTech',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          navigatorKey: _navigatorKey,
          initialRoute: '/login',
          onGenerateRoute: _route,
        );
      },
    );
  }

  Route<dynamic> _route(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case '/register':
        page = RegistrationScreen(store: widget.store);
        break;
      case '/main':
        page = MainShell(
          store: widget.store,
          initialIndex: settings.arguments as int? ?? 0,
        );
        break;
      case '/product':
        page = ProductDetailScreen(
          store: widget.store,
          listing: settings.arguments as Listing?,
        );
        break;
      case '/category':
        page = CategoryDetailScreen(
          store: widget.store,
          category: settings.arguments as String? ?? 'Audio',
        );
        break;
      case '/my-listings':
        page = MyListingsScreen(store: widget.store);
        break;
      case '/create-listing':
        page = ListingFormScreen(store: widget.store);
        break;
      case '/edit-listing':
        page = ListingFormScreen(
          store: widget.store,
          listing: settings.arguments as Listing?,
        );
        break;
      case '/delete-dialog':
        page = DeleteConfirmationScreen(store: widget.store);
        break;
      case '/checkout':
        page = CheckoutScreen(
          store: widget.store,
          listing: settings.arguments as Listing?,
        );
        break;
      case '/delivery-address':
        page = DeliveryAddressScreen(store: widget.store);
        break;
      case '/order-confirmed':
        final argument = settings.arguments;
        page = OrderConfirmationScreen(
          store: widget.store,
          order: argument is OrderRecord ? argument : null,
        );
        break;
      case '/orders':
        page = OrdersScreen(store: widget.store);
        break;
      case '/order-detail':
        final argument = settings.arguments;
        page = OrderDetailScreen(
          store: widget.store,
          order: argument is OrderRecord ? argument : null,
          orderId: argument is String ? argument : null,
        );
        break;
      case '/seller':
        page = SellerProfileScreen(
          store: widget.store,
          sellerName: settings.arguments as String?,
        );
        break;
      case '/settings':
        page = SettingsScreen(store: widget.store);
        break;
      case '/edit-profile':
        page = EditProfileScreen(store: widget.store);
        break;
      case '/payment-methods':
        page = PaymentMethodsScreen(store: widget.store);
        break;
      case '/saved-items':
        page = SavedItemsScreen(store: widget.store);
        break;
      case '/chat':
        final argument = settings.arguments;
        page = ChatThreadScreen(
          listing: argument is Listing ? argument : null,
          sellerName: argument is String ? argument : null,
        );
        break;
      case '/help':
        page = HelpSupportScreen();
        break;
      case '/about':
        page = AboutScreen();
        break;
      case '/login':
      default:
        page = LoginScreen(store: widget.store);
    }
    return _pageRoute(settings, page);
  }

  Route<dynamic> _pageRoute(RouteSettings settings, Widget page) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final slide = Tween(
          begin: Offset(0.045, 0),
          end: Offset.zero,
        ).animate(curved);
        final scale = Tween(begin: 0.985, end: 1.0).animate(curved);
        final outgoingSlide = Tween(begin: Offset.zero, end: Offset(-0.025, 0))
            .animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: Curves.easeOutCubic,
              ),
            );
        return SlideTransition(
          position: outgoingSlide,
          child: FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: slide,
              child: ScaleTransition(scale: scale, child: child),
            ),
          ),
        );
      },
    );
  }

  Future<void> _checkForUpdatesAfterLaunch() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final context = _navigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    await checkForAppUpdate(
      context,
      service: const UpdateService(),
      userInitiated: false,
    );
  }
}
