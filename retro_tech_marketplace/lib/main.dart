// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(RetroTechApp(store: ListingStore()));
}

class RetroTechApp extends StatefulWidget {
  const RetroTechApp({super.key, required this.store});

  final ListingStore store;

  @override
  State<RetroTechApp> createState() => _RetroTechAppState();
}

class _RetroTechAppState extends State<RetroTechApp> {
  late final Future<void> _loadFuture = widget.store.load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        return MaterialApp(
          title: 'RetroTech',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
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
        page = CheckoutScreen(listing: settings.arguments as Listing?);
        break;
      case '/order-confirmed':
        page = OrderConfirmationScreen(listing: settings.arguments as Listing?);
        break;
      case '/seller':
        page = SellerProfileScreen(store: widget.store);
        break;
      case '/settings':
        page = SettingsScreen();
        break;
      case '/edit-profile':
        page = EditProfileScreen();
        break;
      case '/payment-methods':
        page = PaymentMethodsScreen();
        break;
      case '/chat':
        page = ChatThreadScreen(listing: settings.arguments as Listing?);
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
}

class AppTheme {
  static const blue = Color(0xFF0878FF);
  static const red = Color(0xFFFF101E);
  static const green = Color(0xFF10BF55);
  static const violet = Color(0xFF7A4DFF);
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF657085);
  static const line = Color(0xFFDCE5F0);
  static const glass = Color(0xAFFFFFFF);
  static const white = Color(0xFFFFFFFF);
  static const bg = Color(0xFFF7FAFF);
  static const detailBg = Color(0xFFF5F5F5);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: blue,
        primary: blue,
        secondary: red,
        surface: bg,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      inputDecorationTheme: InputDecorationTheme(border: InputBorder.none),
    );
  }

  static TextStyle get hero => TextStyle(
    fontSize: 51,
    height: 0.98,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    color: blue,
  );

  static TextStyle get h1 => TextStyle(
    fontSize: 32,
    height: 1.04,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    color: ink,
  );

  static TextStyle get h2 => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: ink,
  );

  static TextStyle get body => TextStyle(
    fontSize: 14,
    height: 1.42,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: muted,
  );

  static TextStyle get label => TextStyle(
    fontSize: 11,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: blue,
  );
}

class Listing {
  const Listing({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.price,
    required this.condition,
    required this.description,
    required this.storage,
    required this.battery,
    required this.connector,
    required this.imageAsset,
    required this.status,
    required this.views,
    this.seller = 'RetroTech Collector',
    this.rating = 4.9,
    this.reviews = 128,
  });

  final String id;
  final String title;
  final String subtitle;
  final String category;
  final double price;
  final String condition;
  final String description;
  final String storage;
  final String battery;
  final String connector;
  final String imageAsset;
  final String status;
  final int views;
  final String seller;
  final double rating;
  final int reviews;

  String get priceLabel => 'RM ${price.toStringAsFixed(2)}';
  String get shortTitle => subtitle.isEmpty ? title : '$title\n$subtitle';

  Listing copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? category,
    double? price,
    String? condition,
    String? description,
    String? storage,
    String? battery,
    String? connector,
    String? imageAsset,
    String? status,
    int? views,
    String? seller,
    double? rating,
    int? reviews,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      price: price ?? this.price,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      storage: storage ?? this.storage,
      battery: battery ?? this.battery,
      connector: connector ?? this.connector,
      imageAsset: imageAsset ?? this.imageAsset,
      status: status ?? this.status,
      views: views ?? this.views,
      seller: seller ?? this.seller,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
    );
  }

  Map<String, Object?> toMap({int? sortOrder}) {
    final map = <String, Object?>{
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'price': price,
      'condition': condition,
      'description': description,
      'storage': storage,
      'battery': battery,
      'connector': connector,
      'imageAsset': imageAsset,
      'status': status,
      'views': views,
      'seller': seller,
      'rating': rating,
      'reviews': reviews,
    };
    if (sortOrder != null) {
      map['sortOrder'] = sortOrder;
    }
    return map;
  }

  factory Listing.fromMap(Map<String, Object?> map) {
    return Listing(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String? ?? '',
      category: map['category'] as String? ?? 'Audio',
      price: (map['price'] as num).toDouble(),
      condition: map['condition'] as String? ?? 'Used - Excellent',
      description: map['description'] as String? ?? '',
      storage: map['storage'] as String? ?? '40GB',
      battery: map['battery'] as String? ?? '14h',
      connector: map['connector'] as String? ?? '30-Pin',
      imageAsset: map['imageAsset'] as String? ?? Assets.ipod,
      status: map['status'] as String? ?? 'Published',
      views: map['views'] as int? ?? 0,
      seller: map['seller'] as String? ?? 'RetroTech Collector',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.9,
      reviews: map['reviews'] as int? ?? 128,
    );
  }
}

class ListingStore extends ChangeNotifier {
  static const _databaseName = 'retro_tech_marketplace.db';
  static const _databaseVersion = 1;
  static const _tableName = 'listings';

  final List<Listing> _listings = [];
  bool _loaded = false;
  Database? _database;

  List<Listing> get listings => List.unmodifiable(_listings);
  bool get loaded => _loaded;

  Future<Database> get _db async {
    final existing = _database;
    if (existing != null) return existing;

    final databasePath = await getDatabasesPath();
    final database = await openDatabase(
      p.join(databasePath, _databaseName),
      version: _databaseVersion,
      onCreate: _createDatabase,
    );
    _database = database;
    return database;
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        condition TEXT NOT NULL,
        description TEXT NOT NULL,
        storage TEXT NOT NULL,
        battery TEXT NOT NULL,
        connector TEXT NOT NULL,
        imageAsset TEXT NOT NULL,
        status TEXT NOT NULL,
        views INTEGER NOT NULL,
        seller TEXT NOT NULL,
        rating REAL NOT NULL,
        reviews INTEGER NOT NULL,
        sortOrder INTEGER NOT NULL
      )
    ''');

    final batch = db.batch();
    for (var index = 0; index < seedListings.length; index += 1) {
      batch.insert(_tableName, seedListings[index].toMap(sortOrder: index));
    }
    await batch.commit(noResult: true);
  }

  Future<void> load() async {
    if (_loaded) return;
    final db = await _db;
    final rows = await db.query(_tableName, orderBy: 'sortOrder ASC');
    _listings
      ..clear()
      ..addAll(rows.map(Listing.fromMap));
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

  Future<void> add(Listing listing) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.rawUpdate('UPDATE $_tableName SET sortOrder = sortOrder + 1');
      await txn.insert(_tableName, listing.toMap(sortOrder: 0));
    });
    _listings.insert(0, listing);
    notifyListeners();
  }

  Future<void> update(Listing listing) async {
    final index = _listings.indexWhere((item) => item.id == listing.id);
    if (index == -1) return;
    final db = await _db;
    await db.update(
      _tableName,
      listing.toMap(),
      where: 'id = ?',
      whereArgs: [listing.id],
    );
    _listings[index] = listing;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    _listings.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}

class Assets {
  static const background = 'assets/images/aero-background.png';
  static const detailBackground = 'assets/images/detail-background.png';
  static const loginBackground = 'assets/images/login-background.png';
  static const logoMark = 'assets/images/retro-tech-mark.png';
  static const homeAvatar = 'assets/images/home-avatar.png';
  static const googleIcon = 'assets/images/google-logo-transparent.png';
  static const appleIcon = 'assets/images/apple-logo-transparent.png';
  static const facebookIcon = 'assets/images/facebook-logo-transparent.png';
  static const latestNewsThumbnail = 'assets/images/latest-news-thumbnail.png';
  static const v60 = 'assets/images/motorola-v60.png';
  static const ipodFront = 'assets/images/ipod-classic-front.png';
  static const discmanHome = 'assets/images/sony-discman-home.png';
  static const avatarSilhouette = 'assets/images/avatar-silhouette.png';
  static const ipod = 'assets/images/ipod-side.png';
  static const ipodBack = 'assets/images/ipod-back.png';
  static const walkman = 'assets/images/sony-walkman.png';
  static const minidisc = 'assets/images/minidisc.png';
  static const gameboy = 'assets/images/gameboy.png';
  static const camera = 'assets/images/compact-camera.png';
  static const imac = 'assets/images/imac-g3.png';
  static const palm = 'assets/images/palmpilot.png';
  static const watch = 'assets/images/clear-watch.png';
  static const glassButterfly = 'assets/images/glass-butterfly.png';
  static const avatarVintage = 'assets/images/avatar-vintageaudio.png';
  static const avatarPalm = 'assets/images/avatar-palmpilot.png';
  static const avatarPixel = 'assets/images/avatar-pixelcam.png';
}

final seedListings = <Listing>[
  Listing(
    id: 'motorola-v60',
    title: 'Motorola',
    subtitle: 'V60',
    category: 'Phones',
    price: 1299,
    condition: 'Legendary flip.\nTimeless design.',
    description:
        'A collector-grade Motorola V60 with iconic Y2K flip-phone attitude.',
    storage: 'SIM',
    battery: '9h',
    connector: 'Mini USB',
    imageAsset: Assets.v60,
    status: 'FEATURED',
    views: 248,
    seller: 'RetroTech Collector',
  ),
  Listing(
    id: 'ipod-classic',
    title: 'iPod Classic',
    subtitle: '4th Generation',
    category: 'Audio',
    price: 1599,
    condition: 'Used - Excellent',
    description:
        'The iconic iPod Classic 4th Gen with 40GB storage. Perfect working condition.',
    storage: '40GB',
    battery: '14h',
    connector: '30-Pin',
    imageAsset: Assets.ipodFront,
    status: 'TRENDING',
    views: 376,
  ),
  Listing(
    id: 'sony-discman',
    title: 'Sony',
    subtitle: 'Discman',
    category: 'Audio',
    price: 999,
    condition: 'Portable CD classic.',
    description: 'A transparent Discman-style player for late-Y2K audio fans.',
    storage: 'CD',
    battery: '12h',
    connector: '3.5mm',
    imageAsset: Assets.discmanHome,
    status: 'NEW ARRIVAL',
    views: 152,
    seller: 'VintageAudioCo',
  ),
  Listing(
    id: 'walkman',
    title: 'Sony Walkman',
    subtitle: 'Cassette',
    category: 'Audio',
    price: 899,
    condition: 'Collector Grade',
    description:
        'Fully tested Walkman with clean transparent body and strong playback.',
    storage: 'Tape',
    battery: 'AA',
    connector: '3.5mm',
    imageAsset: Assets.walkman,
    status: 'Available',
    views: 228,
    seller: 'VintageAudioCo',
    rating: 4.8,
    reviews: 96,
  ),
  Listing(
    id: 'minidisc',
    title: 'MiniDisc Player',
    subtitle: 'Portable',
    category: 'Audio',
    price: 749,
    condition: 'Fully Working',
    description:
        'Compact MiniDisc player with crisp buttons and rare Y2K finish.',
    storage: 'MD',
    battery: '10h',
    connector: 'Line In',
    imageAsset: Assets.minidisc,
    status: 'Published',
    views: 182,
    seller: 'PixelCam Studio',
    rating: 4.7,
    reviews: 74,
  ),
  Listing(
    id: 'gameboy',
    title: 'GameBoy Color',
    subtitle: 'Clear Shell',
    category: 'Gaming',
    price: 899,
    condition: 'Active',
    description:
        'Clear GameBoy Color with clean screen and responsive buttons.',
    storage: 'Cart',
    battery: 'AA',
    connector: 'Link',
    imageAsset: Assets.gameboy,
    status: 'Published',
    views: 194,
  ),
  Listing(
    id: 'camera',
    title: 'Compact Camera',
    subtitle: 'Transparent',
    category: 'Cameras',
    price: 699,
    condition: 'New Arrival',
    description: 'Crystal compact camera for Frutiger Aero collectors.',
    storage: 'SD',
    battery: '8h',
    connector: 'USB',
    imageAsset: Assets.camera,
    status: 'Published',
    views: 119,
  ),
  Listing(
    id: 'imac',
    title: 'iMac G3',
    subtitle: 'Blueberry',
    category: 'Computing',
    price: 2499,
    condition: 'Display Piece',
    description: 'Blue translucent iMac G3 for desk display and retro setups.',
    storage: '6GB',
    battery: 'AC',
    connector: 'USB',
    imageAsset: Assets.imac,
    status: 'Draft',
    views: 88,
  ),
  Listing(
    id: 'palm',
    title: 'PalmPilot',
    subtitle: 'PDA',
    category: 'Phones',
    price: 529,
    condition: 'Working',
    description: 'Classic PalmPilot with stylus and clean monochrome screen.',
    storage: '8MB',
    battery: 'AAA',
    connector: 'Serial',
    imageAsset: Assets.palm,
    status: 'Published',
    views: 137,
    seller: 'PalmPilotFan',
  ),
];

void popOrMain(BuildContext context) {
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.pop();
    return;
  }
  navigator.pushReplacementNamed('/main');
}

String _listingHeroTag(Listing listing) => 'listing-image-${listing.id}';

String _categoryHeroTag(String category) => 'category-image-$category';

String _categoryAssetFor(String category) {
  return switch (category.toLowerCase()) {
    'phones' => Assets.v60,
    'audio' => Assets.discmanHome,
    'gaming' => Assets.gameboy,
    'cameras' => Assets.camera,
    'computing' => Assets.imac,
    'wearables' => Assets.watch,
    _ => Assets.discmanHome,
  };
}

class _OpenMotionContainer extends StatelessWidget {
  const _OpenMotionContainer({
    required this.openPage,
    required this.closedBuilder,
    required this.radius,
    this.routeSettings,
  });

  final Widget openPage;
  final Widget Function(VoidCallback openContainer) closedBuilder;
  final double radius;
  final RouteSettings? routeSettings;

  @override
  Widget build(BuildContext context) {
    return OpenContainer<void>(
      tappable: false,
      transitionDuration: const Duration(milliseconds: 520),
      transitionType: ContainerTransitionType.fadeThrough,
      closedColor: Colors.transparent,
      middleColor: Colors.white.withValues(alpha: 0.52),
      openColor: AppTheme.bg,
      closedElevation: 0,
      openElevation: 0,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      openShape: const RoundedRectangleBorder(),
      routeSettings: routeSettings,
      closedBuilder: (context, openContainer) => closedBuilder(openContainer),
      openBuilder: (context, closeContainer) => openPage,
    );
  }
}

class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    super.key,
    required this.child,
    this.bottomNavigationBar,
    this.includeSafeArea = true,
    this.backgroundAsset = Assets.background,
    this.backgroundOverlay = true,
    this.background,
  });

  final Widget child;
  final Widget? bottomNavigationBar;
  final bool includeSafeArea;
  final String backgroundAsset;
  final bool backgroundOverlay;
  final Widget? background;

  @override
  Widget build(BuildContext context) {
    final content = includeSafeArea
        ? SafeArea(bottom: false, child: child)
        : child;
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth > 480
              ? 440.0
              : constraints.maxWidth;
          return Center(
            child: SizedBox(
              width: width,
              height: constraints.maxHeight,
              child: Stack(
                children: [
                  background ??
                      AeroBackground(
                        asset: backgroundAsset,
                        includeOverlay: backgroundOverlay,
                      ),
                  content,
                  if (bottomNavigationBar != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: bottomNavigationBar!,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AeroBackground extends StatelessWidget {
  const AeroBackground({
    super.key,
    this.asset = Assets.background,
    this.includeOverlay = true,
  });

  final String asset;
  final bool includeOverlay;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          asset,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          filterQuality: FilterQuality.high,
        ),
        if (includeOverlay) ...[
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withValues(alpha: 0.24),
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.02),
                ],
                stops: const [0, 0.42, 1],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.46,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0),
                      Colors.white.withValues(alpha: 0.12),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class DetailAeroBackground extends StatelessWidget {
  const DetailAeroBackground({super.key, this.asset = Assets.detailBackground});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final heroHeight = (constraints.maxHeight * 0.5)
            .clamp(448.0, 478.0)
            .toDouble();
        final imageWidth = constraints.maxWidth * 1.1364;
        final imageHeight = heroHeight * 1.8578;
        return Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppTheme.detailBg),
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              height: heroHeight,
              child: ClipRect(
                child: Stack(
                  children: [
                    Positioned(
                      left: constraints.maxWidth - imageWidth,
                      top: 0,
                      width: imageWidth,
                      height: imageHeight,
                      child: Image.asset(
                        asset,
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppTheme.detailBg,
                              AppTheme.detailBg.withValues(alpha: 0.45),
                              AppTheme.detailBg.withValues(alpha: 0),
                            ],
                            stops: const [0, 0.1, 0.24],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius = 30,
    this.opacity = 0.54,
    this.blur = 24,
    this.borderOpacity = 0.72,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double opacity;
  final double blur;
  final double borderOpacity;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final glassBlur = blur < 72 ? 72.0 : blur;
    final glassSheen = opacity.clamp(0.08, 0.22).toDouble();
    final glassBorderOpacity = borderOpacity.clamp(0.86, 0.96).toDouble();
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: glassSheen * 1.55),
            offset: Offset(-2, -2),
            blurRadius: 12,
          ),
          BoxShadow(
            color: Color(0xFF1A2942).withValues(alpha: 0.1),
            offset: Offset(0, 18),
            blurRadius: 28,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: glassBlur, sigmaY: glassBlur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: Colors.transparent,
              border: Border.all(
                color: Colors.white.withValues(alpha: glassBorderOpacity),
                width: 1.1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _ResponsiveMetrics {
  const _ResponsiveMetrics({
    required this.width,
    required this.height,
    required this.pagePadding,
    required this.topGap,
    required this.gutter,
    required this.bottomNavHeight,
    required this.cardRadius,
  });

  final double width;
  final double height;
  final double pagePadding;
  final double topGap;
  final double gutter;
  final double bottomNavHeight;
  final double cardRadius;

  factory _ResponsiveMetrics.of(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final shellWidth = mediaSize.width > 480 ? 440.0 : mediaSize.width;
    final compactWidth = shellWidth < 360;
    final compactHeight = mediaSize.height < 740;
    final compact = compactWidth || compactHeight;
    return _ResponsiveMetrics(
      width: shellWidth,
      height: mediaSize.height,
      pagePadding: compactWidth ? 16 : 22,
      topGap: compactHeight ? 12 : 18,
      gutter: compactWidth ? 12 : 16,
      bottomNavHeight: compact ? 74 : 82,
      cardRadius: compact ? 24 : 30,
    );
  }

  bool get compact => width < 360 || height < 740;

  EdgeInsets get pageInsets =>
      EdgeInsets.fromLTRB(pagePadding, topGap, pagePadding, 28);

  EdgeInsets get pageInsetsWithNav => EdgeInsets.fromLTRB(
    pagePadding,
    topGap,
    pagePadding,
    bottomNavHeight + 40,
  );

  double get homeCardHeight =>
      (height * (compact ? 0.255 : 0.25)).clamp(176.0, 218.0).toDouble();

  double get listingActionCardHeight =>
      (height * 0.225).clamp(170.0, 198.0).toDouble();

  double get detailImageHeight =>
      (height * (compact ? 0.34 : 0.39)).clamp(230.0, 350.0).toDouble();

  int get categoryColumns => width >= 410 ? 3 : 2;

  double scaled(double value, {double min = 0, double? max}) {
    final scaledValue = value * (width / 390);
    return scaledValue.clamp(min, max ?? value * 1.12).toDouble();
  }
}

class _LiquidPressable extends StatefulWidget {
  const _LiquidPressable({
    required this.child,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.glowColor = AppTheme.blue,
    this.active = false,
    this.pressedScale = 0.975,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadiusGeometry borderRadius;
  final Color glowColor;
  final bool active;
  final double pressedScale;

  @override
  State<_LiquidPressable> createState() => _LiquidPressableState();
}

class _LiquidPressableState extends State<_LiquidPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final glowing = enabled && (_pressed || widget.active);
    final overlayOpacity = _pressed ? 0.9 : (widget.active ? 0.55 : 0.0);
    final borderRadius = widget.borderRadius;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        child: AnimatedScale(
          scale: _pressed ? widget.pressedScale : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              boxShadow: glowing
                  ? [
                      BoxShadow(
                        color: widget.glowColor.withValues(
                          alpha: _pressed ? 0.34 : 0.2,
                        ),
                        blurRadius: _pressed ? 26 : 18,
                        spreadRadius: _pressed ? 1.5 : 0,
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(
                          alpha: _pressed ? 0.46 : 0.22,
                        ),
                        offset: const Offset(-2, -2),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                widget.child,
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOutCubic,
                      opacity: overlayOpacity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: borderRadius,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.82),
                            width: 1.3,
                          ),
                          gradient: RadialGradient(
                            center: Alignment.topLeft,
                            radius: 1.15,
                            colors: [
                              Colors.white.withValues(alpha: 0.42),
                              widget.glowColor.withValues(alpha: 0.16),
                              Colors.transparent,
                            ],
                            stops: const [0, 0.42, 1],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LiquidButton extends StatelessWidget {
  const LiquidButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 58,
    this.color = AppTheme.red,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final hasIcon = icon != null;
    final compact = height < 54;
    final iconSize = height - (compact ? 16 : 14);

    return _LiquidPressable(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(999),
      glowColor: color,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.92), color],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.34),
              offset: Offset(0, 10),
              blurRadius: 24,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.white.withValues(alpha: 0.28),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final rawMaxLabelWidth = hasIcon
                      ? constraints.maxWidth -
                            2 * (8 + iconSize + (compact ? 8 : 10))
                      : constraints.maxWidth - 44;
                  final maxLabelWidth = rawMaxLabelWidth
                      .clamp(24.0, constraints.maxWidth)
                      .toDouble();

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxLabelWidth),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: compact ? 14 : 17,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (hasIcon)
              Positioned(
                right: 8,
                child: Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.78),
                      width: 1.2,
                    ),
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: compact ? 18 : 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CircleGlassButton extends StatelessWidget {
  const CircleGlassButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color = AppTheme.ink,
    this.size = 46,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: _LiquidPressable(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(size / 2),
        glowColor: color,
        child: GlassCard(
          width: size,
          height: size,
          radius: size / 2,
          padding: EdgeInsets.zero,
          opacity: 0.62,
          child: Icon(icon, color: color, size: size * 0.45),
        ),
      ),
    );
  }
}

class CircleGlassImageButton extends StatelessWidget {
  const CircleGlassImageButton({
    super.key,
    required this.asset,
    this.onTap,
    this.size = 46,
  });

  final String asset;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _LiquidPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      glowColor: AppTheme.blue,
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => CircleGlassButton(
          icon: Icons.person_rounded,
          color: AppTheme.muted,
          size: size,
        ),
      ),
    );
  }
}

class SolidCircleButton extends StatelessWidget {
  const SolidCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 56,
    this.color = AppTheme.red,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: _LiquidPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        glowColor: color,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.92), color],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                offset: Offset(0, 10),
                blurRadius: 22,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: size * 0.42),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton({this.size = 42});

  final double size;

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  bool _favorite = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: _LiquidPressable(
        onTap: () => setState(() => _favorite = !_favorite),
        borderRadius: BorderRadius.circular(widget.size / 2),
        glowColor: AppTheme.red,
        active: _favorite,
        pressedScale: 0.94,
        child: GlassCard(
          width: widget.size,
          height: widget.size,
          radius: widget.size / 2,
          padding: EdgeInsets.zero,
          opacity: _favorite ? 0.72 : 0.62,
          child: Icon(
            _favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: AppTheme.red,
            size: widget.size * 0.45,
          ),
        ),
      ),
    );
  }
}

class _HomeListingCard extends StatelessWidget {
  const _HomeListingCard({required this.listing, this.onTap, this.heroTag});

  final Listing listing;
  final VoidCallback? onTap;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final metrics = _ResponsiveMetrics.of(context);
    final isMotorola = listing.id == 'motorola-v60';
    final isIpod = listing.id == 'ipod-classic';
    final bodyCopy = isMotorola
        ? 'Legendary flip.\nTimeless design.'
        : isIpod
        ? '1,000 songs.\nZero skips.'
        : 'Portable audio.\nCrystal shell.';
    final imageWidth = isMotorola
        ? 176.0
        : isIpod
        ? 150.0
        : 167.0;
    final imageHeight = isMotorola
        ? 264.0
        : isIpod
        ? 225.0
        : 115.0;
    return Container(
      margin: EdgeInsets.only(bottom: metrics.gutter + 2),
      child: _LiquidPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(metrics.cardRadius),
        glowColor: AppTheme.red,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardHeight = metrics.homeCardHeight;
            final compact = constraints.maxWidth < 340;
            final buttonSize = compact ? 32.0 : 36.0;
            return GlassCard(
              padding: EdgeInsets.fromLTRB(
                compact ? 16 : 20,
                compact ? 14 : 16,
                compact ? 12 : 14,
                compact ? 14 : 18,
              ),
              radius: metrics.cardRadius,
              opacity: 0.22,
              blur: 42,
              borderOpacity: 0.9,
              child: SizedBox(
                height: cardHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: compact ? 5 : 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing.status,
                            style: AppTheme.label.copyWith(fontSize: 12),
                          ),
                          SizedBox(height: compact ? 7 : 9),
                          Text.rich(
                            TextSpan(
                              style: AppTheme.h2.copyWith(
                                fontSize: compact ? 20 : 23,
                                height: 1.05,
                              ),
                              children: [
                                TextSpan(
                                  text: isMotorola
                                      ? 'Motorola\n'
                                      : '${listing.title}\n',
                                ),
                                TextSpan(
                                  text: isIpod ? '4th Gen ' : listing.subtitle,
                                ),
                                _accentSquare(size: 8),
                              ],
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: compact ? 10 : 13),
                          Text(
                            bodyCopy,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.body.copyWith(
                              fontSize: compact ? 12 : 13,
                              height: 1.28,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            listing.priceLabel,
                            style: TextStyle(
                              color: AppTheme.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: compact ? 4 : 6),
                    Expanded(
                      flex: compact ? 5 : 6,
                      child: Column(
                        children: [
                          Expanded(
                            child: Transform.scale(
                              scale: compact ? 1.12 : 1.16,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: ProductImage(
                                  asset: listing.imageAsset,
                                  width: imageWidth,
                                  height: imageHeight,
                                  heroTag: heroTag,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: compact ? 4 : 6),
                          const _Dots(),
                        ],
                      ),
                    ),
                    SizedBox(width: compact ? 4 : 6),
                    SizedBox(
                      width: buttonSize,
                      child: Column(
                        children: [
                          _FavoriteButton(size: buttonSize),
                          SizedBox(height: compact ? 7 : 9),
                          CircleGlassButton(
                            icon: Icons.shopping_cart_outlined,
                            color: AppTheme.blue,
                            size: buttonSize,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class GlassStatCard extends StatelessWidget {
  const GlassStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.color = AppTheme.blue,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.symmetric(vertical: 9),
      radius: 20,
      child: Column(
        children: [
          Icon(icon, color: color, size: 17),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.ink),
          ),
          Text(label, style: AppTheme.body.copyWith(fontSize: 9)),
        ],
      ),
    );
  }
}

class GlassListSection extends StatelessWidget {
  const GlassListSection({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );
  }
}

class GlassListRow extends StatelessWidget {
  const GlassListRow({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.badge,
    this.onTap,
    this.iconColor = AppTheme.blue,
    this.badgeColor = AppTheme.blue,
    this.dense = false,
  });

  final IconData icon;
  final String title;
  final String? value;
  final String? badge;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color badgeColor;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        dense: dense,
        minVerticalPadding: dense ? 4 : null,
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w800)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            else if (value != null)
              Text(value!, style: AppTheme.body.copyWith(fontSize: 12)),
            Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
          ],
        ),
      ),
    );
  }
}

class GlassInput extends StatefulWidget {
  const GlassInput({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final int maxLines;

  @override
  State<GlassInput> createState() => _GlassInputState();
}

class _GlassInputState extends State<GlassInput> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscure;
  }

  @override
  void didUpdateWidget(covariant GlassInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscure != widget.obscure) {
      _obscured = widget.obscure;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      padding: EdgeInsets.symmetric(
        horizontal: 18,
        vertical: widget.maxLines > 1 ? 6 : 0,
      ),
      opacity: 0.46,
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: _obscured,
        maxLines: widget.maxLines,
        style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink),
        decoration: InputDecoration(
          icon: Icon(widget.icon, color: AppTheme.blue, size: 18),
          hintText: widget.hint,
          hintStyle: AppTheme.body.copyWith(
            color: AppTheme.muted.withValues(alpha: 0.78),
          ),
          suffixIcon: widget.obscure
              ? IconButton(
                  onPressed: () => setState(() => _obscured = !_obscured),
                  icon: Icon(
                    _obscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppTheme.muted,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(Size(24, 28)),
                  splashRadius: 18,
                )
              : null,
          suffixIconConstraints: widget.obscure
              ? BoxConstraints.tight(Size(24, 32))
              : null,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 88});

  final double size;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: size,
      height: size,
      radius: size * 0.25,
      padding: EdgeInsets.all(size * 0.06),
      opacity: 0.46,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.2),
        child: Image.asset(
          Assets.logoMark,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.devices_rounded, color: AppTheme.blue),
        ),
      ),
    );
  }
}

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.asset,
    this.width = 124,
    this.height = 124,
    this.fit = BoxFit.contain,
    this.heroTag,
  });

  final String asset;
  final double width;
  final double height;
  final BoxFit fit;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.devices_rounded, size: width * 0.56),
    );
    final tag = heroTag;
    if (tag == null) return image;
    return Hero(
      tag: tag,
      transitionOnUserGestures: true,
      createRectTween: (begin, end) =>
          MaterialRectArcTween(begin: begin, end: end),
      flightShuttleBuilder:
          (context, animation, direction, fromHeroContext, toHeroContext) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
              reverseCurve: Curves.easeInOutCubic,
            );
            final child = direction == HeroFlightDirection.push
                ? toHeroContext.widget
                : fromHeroContext.widget;
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween(begin: 0.96, end: 1.0).animate(curved),
                child: child,
              ),
            );
          },
      child: image,
    );
  }
}

InlineSpan _accentSquare({required double size, double gap = 5}) {
  return WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: Padding(
      padding: EdgeInsets.only(left: gap),
      child: _AccentSquare(size: size),
    ),
  );
}

class _AccentSquare extends StatelessWidget {
  const _AccentSquare({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const ColoredBox(color: AppTheme.red),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.store});

  final ListingStore store;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _remember = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _ResponsiveMetrics.of(context);
    final horizontalPadding = metrics.compact ? 32.0 : 40.0;
    return GlassScaffold(
      backgroundAsset: Assets.loginBackground,
      backgroundOverlay: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          metrics.compact ? 58 : 64,
          horizontalPadding,
          28,
        ),
        children: [
          Center(child: LogoMark(size: metrics.compact ? 110 : 120)),
          SizedBox(height: metrics.compact ? 56 : 64),
          Center(
            child: RichText(
              text: TextSpan(
                style: AppTheme.h1.copyWith(fontSize: 32),
                children: [
                  TextSpan(
                    text: 'Welcome ',
                    style: TextStyle(color: AppTheme.blue),
                  ),
                  TextSpan(
                    text: 'Back',
                    style: TextStyle(color: AppTheme.red),
                  ),
                  _accentSquare(size: 8),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Log in to continue your journey.',
            textAlign: TextAlign.center,
            style: AppTheme.body,
          ),
          SizedBox(height: 34),
          GlassInput(
            controller: _email,
            hint: 'Username or Email',
            icon: Icons.person_outline_rounded,
          ),
          SizedBox(height: 14),
          GlassInput(
            controller: _password,
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            obscure: true,
          ),
          SizedBox(height: 18),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _remember = !_remember),
                child: GlassCard(
                  width: 34,
                  height: 34,
                  radius: 17,
                  padding: EdgeInsets.zero,
                  child: Icon(
                    _remember ? Icons.check_rounded : Icons.circle_outlined,
                    color: AppTheme.red,
                    size: 18,
                  ),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Remember me',
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.body,
                ),
              ),
              Text(
                'Forgot password?',
                overflow: TextOverflow.ellipsis,
                style: AppTheme.label.copyWith(
                  color: AppTheme.blue,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          SizedBox(height: 28),
          LiquidButton(
            label: 'Log In',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => Navigator.pushReplacementNamed(context, '/main'),
          ),
          SizedBox(height: 40),
          Center(child: _SocialLoginCluster()),
          SizedBox(height: 46),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: AppTheme.body.copyWith(fontSize: 12),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/register'),
                child: Text('Sign Up', style: AppTheme.label),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialLoginCluster extends StatelessWidget {
  const _SocialLoginCluster();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final clusterWidth = constraints.maxWidth
            .clamp(256.0, 360.0)
            .toDouble();
        final gap = clusterWidth < 300 ? 10.0 : 12.0;
        final buttonWidth = ((clusterWidth - gap * 2) / 3)
            .clamp(78.0, 108.0)
            .toDouble();
        final buttonHeight = (buttonWidth * 0.62).clamp(54.0, 66.0).toDouble();
        final iconScale = buttonHeight / 52.0;

        return SizedBox(
          width: clusterWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Color(0x61BFC7D6)),
                      child: SizedBox(height: 1),
                    ),
                  ),
                  SizedBox(
                    width: 126,
                    child: Text(
                      'Or continue with',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Color(0x61BFC7D6)),
                      child: SizedBox(height: 1),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 26),
              Row(
                children: [
                  _SocialButton(
                    semanticLabel: 'Continue with Google',
                    asset: Assets.googleIcon,
                    width: buttonWidth,
                    height: buttonHeight,
                    iconWidth: 28 * iconScale,
                    iconHeight: 28 * iconScale,
                  ),
                  SizedBox(width: gap),
                  _SocialButton(
                    semanticLabel: 'Continue with Apple',
                    asset: Assets.appleIcon,
                    width: buttonWidth,
                    height: buttonHeight,
                    iconWidth: 29 * iconScale,
                    iconHeight: 34 * iconScale,
                  ),
                  SizedBox(width: gap),
                  _SocialButton(
                    semanticLabel: 'Continue with Facebook',
                    asset: Assets.facebookIcon,
                    width: buttonWidth,
                    height: buttonHeight,
                    iconWidth: 35 * iconScale,
                    iconHeight: 34 * iconScale,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.asset,
    required this.semanticLabel,
    required this.width,
    required this.height,
    required this.iconWidth,
    required this.iconHeight,
  });

  final String asset;
  final String semanticLabel;
  final double width;
  final double height;
  final double iconWidth;
  final double iconHeight;

  @override
  Widget build(BuildContext context) {
    final radius = height * 0.38;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: _LiquidPressable(
        onTap: () {},
        borderRadius: BorderRadius.circular(radius),
        glowColor: AppTheme.blue,
        pressedScale: 0.96,
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.54),
                    borderRadius: BorderRadius.circular(radius),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF1A2942).withValues(alpha: 0.13),
                        offset: Offset(0, 12),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(radius),
                        color: Colors.white.withValues(alpha: 0.54),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.72),
                          width: 1,
                        ),
                      ),
                      child: Image.asset(
                        asset,
                        width: iconWidth,
                        height: iconHeight,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key, required this.store});

  final ListingStore store;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _agree = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      backgroundAsset: Assets.loginBackground,
      backgroundOverlay: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(52, 64, 52, 28),
        children: [
          Align(alignment: Alignment.center, child: LogoMark(size: 100)),
          SizedBox(height: 44),
          RichText(
            text: TextSpan(
              style: AppTheme.h1.copyWith(fontSize: 32),
              children: [
                TextSpan(text: 'Create your\n'),
                TextSpan(
                  text: 'Retro ',
                  style: TextStyle(color: AppTheme.blue),
                ),
                TextSpan(
                  text: 'Tech',
                  style: TextStyle(color: AppTheme.red),
                ),
                TextSpan(text: '\naccount'),
              ],
            ),
          ),
          SizedBox(height: 24),
          GlassInput(
            controller: _name,
            hint: 'Full Name',
            icon: Icons.person_outline_rounded,
          ),
          SizedBox(height: 12),
          GlassInput(
            controller: _email,
            hint: 'Email Address',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 12),
          GlassInput(
            controller: _password,
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            obscure: true,
          ),
          SizedBox(height: 12),
          GlassInput(
            controller: _confirm,
            hint: 'Confirm Password',
            icon: Icons.lock_outline_rounded,
            obscure: true,
          ),
          SizedBox(height: 18),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _agree = !_agree),
                child: Icon(
                  _agree ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: AppTheme.red,
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppTheme.body.copyWith(fontSize: 12),
                    children: [
                      TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms & Privacy Policy',
                        style: TextStyle(
                          color: AppTheme.blue,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 26),
          LiquidButton(
            label: 'Create Account',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => Navigator.pushReplacementNamed(context, '/main'),
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: AppTheme.body.copyWith(fontSize: 12),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text('Log In', style: AppTheme.label),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.store, this.initialIndex = 0});

  final ListingStore store;
  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = _shellIndexFor(widget.initialIndex);
  late final List<Widget> _pages = [
    HomeScreen(store: widget.store),
    CategoriesScreen(store: widget.store),
    InboxScreen(inShell: true),
    AccountProfileScreen(store: widget.store),
  ];

  int _shellIndexFor(int navIndex) {
    if (navIndex == 2) return 0;
    return navIndex > 2 ? navIndex - 1 : navIndex;
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      bottomNavigationBar: GlassBottomNav(
        currentIndex: _index,
        onTap: (index) {
          if (index == 2) {
            Navigator.pushNamed(context, '/create-listing');
            return;
          }
          setState(() => _index = index > 2 ? index - 1 : index);
        },
      ),
      child: SizedBox.expand(
        child: Stack(
          children: [
            for (var pageIndex = 0; pageIndex < _pages.length; pageIndex++)
              _AnimatedShellPage(
                active: pageIndex == _index,
                currentIndex: _index,
                pageIndex: pageIndex,
                child: _pages[pageIndex],
              ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedShellPage extends StatelessWidget {
  const _AnimatedShellPage({
    required this.active,
    required this.currentIndex,
    required this.pageIndex,
    required this.child,
  });

  final bool active;
  final int currentIndex;
  final int pageIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final hiddenOffset = pageIndex < currentIndex
        ? const Offset(-0.045, 0)
        : const Offset(0.045, 0);

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !active,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          opacity: active ? 1 : 0,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            offset: active ? Offset.zero : hiddenOffset,
            child: HeroMode(
              enabled: active,
              child: TickerMode(enabled: active, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final activeRealIndex = currentIndex >= 2 ? currentIndex + 1 : currentIndex;
    final metrics = _ResponsiveMetrics.of(context);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final barHeight = metrics.compact ? 62.0 : 66.0;
    final addLift = metrics.compact ? 10.0 : 12.0;
    final addSize = metrics.compact ? 60.0 : 64.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        metrics.pagePadding,
        0,
        metrics.pagePadding,
        bottomInset + 8,
      ),
      child: SizedBox(
        height: barHeight + addLift,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GlassCard(
                height: barHeight,
                radius: 32,
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                opacity: 0.62,
                child: Row(
                  children: [
                    Expanded(
                      child: _NavItem(
                        Icons.home_rounded,
                        'Home',
                        activeRealIndex == 0,
                        () => onTap(0),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        Icons.grid_view_rounded,
                        'Categories',
                        activeRealIndex == 1,
                        () => onTap(1),
                      ),
                    ),
                    const Expanded(child: SizedBox.expand()),
                    Expanded(
                      child: _NavItem(
                        Icons.chat_bubble_outline_rounded,
                        'Inbox',
                        activeRealIndex == 3,
                        () => onTap(3),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        Icons.person_outline_rounded,
                        'Profile',
                        activeRealIndex == 4,
                        () => onTap(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: _LiquidPressable(
                  onTap: () => onTap(2),
                  borderRadius: BorderRadius.circular(addSize / 2),
                  glowColor: AppTheme.red,
                  pressedScale: 0.94,
                  child: GlassCard(
                    width: addSize,
                    height: addSize,
                    radius: addSize / 2,
                    padding: EdgeInsets.zero,
                    opacity: 0.68,
                    child: Icon(
                      Icons.add_rounded,
                      color: AppTheme.red,
                      size: metrics.compact ? 34 : 36,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem(this.icon, this.label, this.active, this.onTap);

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final compact = _ResponsiveMetrics.of(context).compact;
    return _LiquidPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      glowColor: AppTheme.red,
      pressedScale: 0.94,
      child: SizedBox.expand(
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: compact ? 54 : 60,
              height: 48,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: active ? AppTheme.red : AppTheme.ink,
                    size: compact ? 20 : 21,
                  ),
                  SizedBox(height: compact ? 4 : 5),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compact ? 9 : 10,
                      fontWeight: FontWeight.w800,
                      color: active ? AppTheme.red : AppTheme.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.store});

  final ListingStore store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final metrics = _ResponsiveMetrics.of(context);
        return ListView(
          padding: metrics.pageInsetsWithNav,
          children: [
            Row(
              children: [
                CircleGlassImageButton(
                  asset: Assets.homeAvatar,
                  onTap: () => Navigator.pushNamed(context, '/seller'),
                ),
                SizedBox(width: metrics.compact ? 12 : 18),
                Expanded(
                  child: GlassCard(
                    height: 48,
                    radius: 26,
                    padding: EdgeInsets.all(5),
                    child: _HomeSegmentControl(
                      value: _segment,
                      onChanged: (value) {
                        if (_segment == value) return;
                        setState(() => _segment = value);
                      },
                    ),
                  ),
                ),
                SizedBox(width: metrics.compact ? 12 : 18),
                CircleGlassButton(icon: Icons.search_rounded),
              ],
            ),
            SizedBox(height: metrics.compact ? 20 : 28),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                reverseDuration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final fromRight = (child.key as ValueKey<int>).value == 1;
                  final offset = Tween<Offset>(
                    begin: Offset(fromRight ? 0.055 : -0.055, 0),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_segment),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _segment == 0
                        ? _marketContent(context)
                        : _communityContent(context),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _marketContent(BuildContext context) {
    final listings = widget.store.listings;
    return [
      RichText(
        text: TextSpan(
          style: AppTheme.hero,
          children: [
            TextSpan(text: 'Rediscover\n'),
            TextSpan(
              text: 'Iconic',
              style: TextStyle(color: AppTheme.red),
            ),
            _accentSquare(size: 13, gap: 7),
          ],
        ),
      ),
      SizedBox(height: 12),
      Text(
        'Buy, sell, and collect authentic\nY2K electronics.',
        style: AppTheme.body.copyWith(fontSize: 18),
      ),
      SizedBox(height: 22),
      Row(
        children: [
          SolidCircleButton(
            icon: Icons.north_east_rounded,
            onTap: () =>
                Navigator.pushNamed(context, '/category', arguments: 'Audio'),
          ),
          SizedBox(width: 14),
          Text(
            'Explore\nCollection',
            style: AppTheme.h2.copyWith(fontSize: 16),
          ),
        ],
      ),
      SizedBox(height: 22),
      ...listings.take(3).map((listing) {
        return ListingCard(
          listing: listing,
          large: true,
          openStore: widget.store,
          onTap: () =>
              Navigator.pushNamed(context, '/product', arguments: listing),
        );
      }),
    ];
  }

  List<Widget> _communityContent(BuildContext context) {
    return [
      Text('Community', style: AppTheme.hero.copyWith(fontSize: 44)),
      SizedBox(height: 10),
      Text(
        'Collectors, restorers, and transparent tech fans share finds here.',
        style: AppTheme.body,
      ),
      SizedBox(height: 22),
      _CommunityPostCard(
        user: 'VintageAudioCo',
        time: '18m',
        text: 'I can include the original earbuds for the Walkman bundle.',
        asset: Assets.avatarVintage,
      ),
      _CommunityPostCard(
        user: 'PalmPilotFan',
        time: '1h',
        text:
            'Battery holds charge well. Ask for more photos before buying rare PDAs.',
        asset: Assets.avatarPalm,
      ),
      _CommunityPostCard(
        user: 'PixelCam Studio',
        time: 'Yesterday',
        text:
            'Transparent tech photographs best against high-key white backgrounds.',
        asset: Assets.avatarPixel,
      ),
    ];
  }
}

class _HomeSegmentControl extends StatelessWidget {
  const _HomeSegmentControl({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            alignment: value == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white.withValues(alpha: 0.82),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.red.withValues(alpha: 0.14),
                      offset: Offset(0, 7),
                      blurRadius: 15,
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.54),
                      offset: Offset(-2, -2),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Row(
          children: [
            _SegmentPill('Market', value == 0, () => onChanged(0)),
            _SegmentPill('Community', value == 1, () => onChanged(1)),
          ],
        ),
      ],
    );
  }
}

class _SegmentPill extends StatelessWidget {
  const _SegmentPill(this.label, this.active, this.onTap);

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _LiquidPressable(
        onTap: onTap,
        active: active,
        borderRadius: BorderRadius.circular(24),
        glowColor: AppTheme.red,
        pressedScale: 0.96,
        child: AnimatedDefaultTextStyle(
          duration: Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: active ? AppTheme.red : AppTheme.muted,
          ),
          child: Center(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
    );
  }
}

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.openStore,
    this.large = false,
  });

  final Listing listing;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ListingStore? openStore;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final metrics = _ResponsiveMetrics.of(context);
    final hasActions = onEdit != null || onDelete != null;
    final heroTag = _listingHeroTag(listing);

    Widget buildCard(VoidCallback? tap) {
      if (!hasActions) {
        return _HomeListingCard(listing: listing, onTap: tap, heroTag: heroTag);
      }
      final imageWidth = 172.0;
      final imageHeight = 184.0;
      final detailsColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(listing.status.toUpperCase(), style: AppTheme.label),
          SizedBox(height: 8),
          Text(
            listing.shortTitle,
            style: AppTheme.h2.copyWith(fontSize: large ? 25 : 19),
          ),
          SizedBox(height: 8),
          Text(listing.condition, style: AppTheme.body),
          SizedBox(height: 18),
          Text(
            listing.priceLabel,
            style: TextStyle(
              color: AppTheme.red,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          if (!large) ...[
            SizedBox(height: 4),
            Text(
              '${listing.views} views',
              style: AppTheme.body.copyWith(fontSize: 11),
            ),
          ],
        ],
      );

      return _LiquidPressable(
        onTap: tap,
        borderRadius: BorderRadius.circular(metrics.cardRadius),
        glowColor: AppTheme.blue,
        child: GlassCard(
          margin: EdgeInsets.only(bottom: metrics.gutter + 2),
          padding: EdgeInsets.fromLTRB(20, 16, 14, 18),
          radius: metrics.cardRadius,
          opacity: 0.22,
          blur: 42,
          borderOpacity: 0.9,
          child: SizedBox(
            height: metrics.listingActionCardHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: metrics.compact ? 5 : 4, child: detailsColumn),
                SizedBox(width: metrics.compact ? 4 : 6),
                Expanded(
                  flex: metrics.compact ? 5 : 6,
                  child: Transform.scale(
                    scale: metrics.compact ? 1.1 : 1.14,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: ProductImage(
                        asset: listing.imageAsset,
                        width: imageWidth,
                        height: imageHeight,
                        heroTag: heroTag,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: metrics.compact ? 4 : 6),
                SizedBox(
                  width: 38,
                  child: Column(
                    children: [
                      CircleGlassButton(
                        icon: Icons.edit_rounded,
                        color: AppTheme.blue,
                        size: 38,
                        onTap: onEdit,
                      ),
                      SizedBox(height: 10),
                      CircleGlassButton(
                        icon: Icons.delete_outline_rounded,
                        color: AppTheme.red,
                        size: 38,
                        onTap: onDelete,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final store = openStore;
    if (store == null) return buildCard(onTap);

    return _OpenMotionContainer(
      radius: metrics.cardRadius,
      routeSettings: RouteSettings(name: '/product', arguments: listing),
      openPage: ProductDetailScreen(store: store, listing: listing),
      closedBuilder: buildCard,
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.store, this.listing});

  final ListingStore store;
  final Listing? listing;

  @override
  Widget build(BuildContext context) {
    final fallbackItem = seedListings.firstWhere(
      (item) => item.id == 'ipod-classic',
    );
    final item =
        listing ??
        store.byId('ipod-classic') ??
        (store.listings.isNotEmpty ? store.listings.first : fallbackItem);
    return GlassScaffold(
      includeSafeArea: false,
      background: const DetailAeroBackground(),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final metrics = _ResponsiveMetrics.of(context);
            final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
            return Stack(
              children: [
                ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    metrics.pagePadding,
                    metrics.topGap,
                    metrics.pagePadding,
                    104 + bottomPadding,
                  ),
                  children: [
                    Row(
                      children: [
                        CircleGlassButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          size: 44,
                          onTap: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        CircleGlassButton(
                          icon: Icons.ios_share_rounded,
                          size: 44,
                        ),
                        SizedBox(width: metrics.compact ? 10 : 14),
                        const _FavoriteButton(size: 44),
                      ],
                    ),
                    SizedBox(height: metrics.compact ? 14 : 22),
                    Center(
                      child: SizedBox(
                        height: metrics.detailImageHeight,
                        width: constraints.maxWidth - metrics.pagePadding * 2,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: ProductImage(
                            asset: item.imageAsset,
                            width: 316,
                            height: 413,
                            heroTag: _listingHeroTag(item),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: metrics.compact ? 8 : 14),
                    const Center(child: _Dots()),
                    SizedBox(height: metrics.compact ? 14 : 20),
                    _ProductDetailPanel(item: item),
                  ],
                ),
                Positioned(
                  left: metrics.pagePadding + 10,
                  right: metrics.pagePadding + 10,
                  bottom: 10 + bottomPadding,
                  child: LiquidButton(
                    label: 'Contact Seller',
                    icon: Icons.chat_bubble_outline_rounded,
                    height: metrics.compact ? 54 : 60,
                    onPressed: () =>
                        Navigator.pushNamed(context, '/chat', arguments: item),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProductDetailPanel extends StatelessWidget {
  const _ProductDetailPanel({required this.item});

  final Listing item;

  @override
  Widget build(BuildContext context) {
    final metrics = _ResponsiveMetrics.of(context);
    return GlassCard(
      padding: EdgeInsets.all(metrics.compact ? 18 : 22),
      radius: metrics.cardRadius,
      opacity: 0.42,
      blur: 30,
      borderOpacity: 0.82,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('FEATURED', style: AppTheme.label),
              const Spacer(),
              Text(
                item.priceLabel,
                style: AppTheme.label.copyWith(
                  color: AppTheme.red,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: metrics.compact ? 14 : 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppTheme.h1.copyWith(
                      fontSize: metrics.compact ? 22 : 25,
                      height: 1.08,
                    ),
                    children: [
                      TextSpan(text: '${item.title}\n'),
                      TextSpan(
                        text: item.subtitle,
                        style: TextStyle(color: AppTheme.red),
                      ),
                      _accentSquare(size: 8),
                    ],
                  ),
                ),
              ),
              SizedBox(width: metrics.gutter),
              CircleGlassButton(
                icon: Icons.shopping_cart_outlined,
                color: AppTheme.blue,
                size: metrics.compact ? 42 : 46,
              ),
            ],
          ),
          SizedBox(height: metrics.compact ? 14 : 18),
          Text(
            item.description,
            style: AppTheme.body.copyWith(fontSize: 12, height: 1.5),
          ),
          SizedBox(height: metrics.compact ? 16 : 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 360 ? 2 : 4;
              const spacing = 10.0;
              final chipWidth =
                  (constraints.maxWidth - (columns - 1) * spacing) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  SizedBox(
                    width: chipWidth,
                    child: _SpecChip(
                      Icons.sd_storage_rounded,
                      item.storage,
                      'Storage',
                    ),
                  ),
                  SizedBox(
                    width: chipWidth,
                    child: _SpecChip(
                      Icons.battery_full_rounded,
                      item.battery,
                      'Battery Life',
                    ),
                  ),
                  SizedBox(
                    width: chipWidth,
                    child: _SpecChip(Icons.music_note_rounded, '10K+', 'Songs'),
                  ),
                  SizedBox(
                    width: chipWidth,
                    child: _SpecChip(
                      Icons.settings_input_component_rounded,
                      item.connector,
                      'Connector',
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: metrics.compact ? 18 : 22),
          Divider(height: 1, color: AppTheme.line),
          SizedBox(height: metrics.compact ? 16 : 18),
          Text('Seller', style: AppTheme.h2.copyWith(fontSize: 15)),
          SizedBox(height: metrics.compact ? 10 : 12),
          Row(
            children: [
              LogoMark(size: 43),
              SizedBox(width: metrics.gutter),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.seller,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.h2.copyWith(fontSize: 14),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${item.rating} ★  (${item.reviews})',
                      style: AppTheme.label.copyWith(fontSize: 13),
                    ),
                    Text(
                      'Active today',
                      style: AppTheme.body.copyWith(fontSize: 11, height: 1.1),
                    ),
                  ],
                ),
              ),
              CircleGlassButton(
                icon: Icons.more_horiz_rounded,
                size: 42,
                onTap: () => Navigator.pushNamed(context, '/seller'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return Container(
          width: index == 0 ? 20 : 8,
          height: 5,
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: index == 0 ? AppTheme.red : AppTheme.line,
          ),
        );
      }),
    );
  }
}

class _SpecChip extends StatelessWidget {
  const _SpecChip(this.icon, this.value, this.label);

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: GlassCard(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        radius: 16,
        opacity: 0.5,
        blur: 12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: AppTheme.ink),
            SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: AppTheme.body.copyWith(fontSize: 8, height: 1.1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key, required this.store});

  final ListingStore store;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final metrics = _ResponsiveMetrics.of(context);
    final categories = [
      _CategoryData(
        'Phones',
        '128 items',
        Icons.phone_iphone_rounded,
        Assets.v60,
      ),
      _CategoryData(
        'Audio',
        '84 items',
        Icons.headphones_rounded,
        Assets.discmanHome,
      ),
      _CategoryData(
        'Gaming',
        '156 items',
        Icons.videogame_asset_rounded,
        Assets.gameboy,
      ),
      _CategoryData(
        'Cameras',
        '92 items',
        Icons.camera_alt_rounded,
        Assets.camera,
      ),
      _CategoryData(
        'Computing',
        '73 items',
        Icons.desktop_mac_rounded,
        Assets.imac,
      ),
      _CategoryData('Wearables', '64 items', Icons.watch_rounded, Assets.watch),
    ];
    final visibleCategories = _query.trim().isEmpty
        ? categories
        : categories
              .where(
                (category) =>
                    category.name.toLowerCase().contains(
                      _query.trim().toLowerCase(),
                    ) ||
                    category.count.toLowerCase().contains(
                      _query.trim().toLowerCase(),
                    ),
              )
              .toList();
    return ListView(
      padding: metrics.pageInsetsWithNav,
      children: [
        Row(
          children: [
            CircleGlassButton(
              icon: Icons.search_rounded,
              size: metrics.compact ? 42 : 46,
            ),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Categories', style: AppTheme.h2),
                ),
              ),
            ),
            CircleGlassButton(
              icon: Icons.tune_rounded,
              size: metrics.compact ? 42 : 46,
            ),
          ],
        ),
        SizedBox(height: 18),
        GlassCard(
          height: 48,
          radius: 24,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: TextField(
            key: const ValueKey('category-search-field'),
            onChanged: (value) => setState(() => _query = value),
            style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink),
            decoration: InputDecoration(
              icon: Icon(Icons.search_rounded, color: AppTheme.muted, size: 18),
              hintText: 'Search retro devices',
              hintStyle: AppTheme.body,
              border: InputBorder.none,
            ),
          ),
        ),
        SizedBox(height: 22),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleCategories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: metrics.categoryColumns,
            childAspectRatio: metrics.categoryColumns == 3 ? 0.86 : 1.06,
            crossAxisSpacing: metrics.gutter,
            mainAxisSpacing: metrics.gutter,
          ),
          itemBuilder: (context, index) {
            final category = visibleCategories[index];
            return _OpenMotionContainer(
              radius: metrics.cardRadius,
              routeSettings: RouteSettings(
                name: '/category',
                arguments: category.name,
              ),
              openPage: CategoryDetailScreen(
                store: widget.store,
                category: category.name,
              ),
              closedBuilder: (openContainer) => _LiquidPressable(
                onTap: openContainer,
                borderRadius: BorderRadius.circular(metrics.cardRadius),
                glowColor: AppTheme.blue,
                child: GlassCard(
                  padding: EdgeInsets.all(metrics.compact ? 8 : 10),
                  radius: metrics.cardRadius,
                  opacity: 0.24,
                  blur: 38,
                  borderOpacity: 0.88,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: ProductImage(
                                  asset: category.asset,
                                  width: 152,
                                  height: 122,
                                  heroTag: _categoryHeroTag(category.name),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: metrics.compact ? 4 : 6),
                          Text(
                            category.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.label.copyWith(color: AppTheme.red),
                          ),
                          SizedBox(height: 4),
                          Text(
                            category.count,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.body.copyWith(fontSize: 11),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CategoryData {
  const _CategoryData(this.name, this.count, this.icon, this.asset);

  final String name;
  final String count;
  final IconData icon;
  final String asset;
}

class CategoryDetailScreen extends StatelessWidget {
  const CategoryDetailScreen({
    super.key,
    required this.store,
    required this.category,
  });

  final ListingStore store;
  final String category;

  @override
  Widget build(BuildContext context) {
    final metrics = _ResponsiveMetrics.of(context);
    return GlassScaffold(
      bottomNavigationBar: GlassBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) {
            Navigator.pop(context);
            return;
          }
          if (index == 2) {
            Navigator.pushNamed(context, '/create-listing');
            return;
          }
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/main',
            (route) => false,
            arguments: index,
          );
        },
      ),
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final items = store.byCategory(category).isEmpty
              ? store.listings
              : store.byCategory(category);
          return ListView(
            padding: EdgeInsets.fromLTRB(22, 18, 22, 118),
            children: [
              Row(
                children: [
                  CircleGlassButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  Spacer(),
                  Text(category, style: AppTheme.h2),
                  Spacer(),
                  CircleGlassButton(icon: Icons.tune_rounded),
                ],
              ),
              SizedBox(height: 22),
              GlassCard(
                height: 126,
                radius: metrics.cardRadius,
                padding: EdgeInsets.fromLTRB(18, 12, 18, 12),
                opacity: 0.22,
                blur: 42,
                borderOpacity: 0.9,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$category Collection',
                        style: AppTheme.h2.copyWith(fontSize: 18),
                      ),
                    ),
                    SizedBox(width: metrics.gutter),
                    ProductImage(
                      asset: _categoryAssetFor(category),
                      width: 120,
                      height: 100,
                      heroTag: _categoryHeroTag(category),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18),
              Row(
                children: [
                  _FilterPill('All', true),
                  _FilterPill('iPod', false),
                  _FilterPill('Walkman', false),
                  _FilterPill('Speakers', false),
                ],
              ),
              SizedBox(height: 22),
              ...items.map(
                (listing) => ListingCard(
                  listing: listing,
                  openStore: store,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/product',
                    arguments: listing,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill(this.label, this.active);

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: _LiquidPressable(
        onTap: () {},
        active: active,
        borderRadius: BorderRadius.circular(999),
        glowColor: active ? AppTheme.red : AppTheme.blue,
        pressedScale: 0.95,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: active ? AppTheme.red : Colors.white.withValues(alpha: 0.58),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : AppTheme.muted,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}

class AccountProfileScreen extends StatelessWidget {
  const AccountProfileScreen({super.key, required this.store});

  final ListingStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return ListView(
          padding: EdgeInsets.fromLTRB(22, 18, 22, 118),
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CircleGlassButton(
                icon: Icons.settings_rounded,
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
            ),
            SizedBox(height: 2),
            Center(child: LogoMark(size: 94)),
            SizedBox(height: 12),
            Center(
              child: Text(
                'Retro Tech',
                style: AppTheme.h1.copyWith(fontSize: 26),
              ),
            ),
            Center(
              child: Text(
                '@retrotech',
                style: AppTheme.body.copyWith(fontSize: 14),
              ),
            ),
            SizedBox(height: 4),
            Center(
              child: Text('Collect rare. Live timeless.', style: AppTheme.body),
            ),
            SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
                child: Text('Edit Profile', style: AppTheme.label),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                _ProfileStat(
                  '${store.listings.length}',
                  'Listings',
                  Icons.article_outlined,
                ),
                _ProfileStat(
                  '342',
                  'Saved',
                  Icons.favorite_rounded,
                  color: AppTheme.red,
                ),
                _ProfileStat('1.2K', 'Followers', Icons.groups_rounded),
                _ProfileStat('98%', 'Rating', Icons.star_rounded),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Marketplace Dashboard',
              style: AppTheme.h2.copyWith(fontSize: 16),
            ),
            SizedBox(height: 10),
            GlassListSection(
              children: [
                _ProfileRow(
                  'My Listings',
                  '${store.listings.length}',
                  Icons.sell_outlined,
                  () => Navigator.pushNamed(context, '/my-listings'),
                ),
                _ProfileRow(
                  'Orders',
                  '8',
                  Icons.inventory_2_outlined,
                  () => Navigator.pushNamed(
                    context,
                    '/checkout',
                    arguments: store.listings.first,
                  ),
                ),
                _ProfileRow(
                  'Saved Items',
                  '342',
                  Icons.favorite_border_rounded,
                  null,
                ),
                _ProfileRow(
                  'Messages',
                  '8',
                  Icons.chat_bubble_outline_rounded,
                  () => Navigator.pushNamed(context, '/chat'),
                ),
              ],
            ),
            SizedBox(height: 14),
            Text('Recent Activity', style: AppTheme.h2.copyWith(fontSize: 16)),
            SizedBox(height: 12),
            _ActivityTile(
              'iPod Classic 4th Gen',
              'Listing updated',
              '2h ago',
              Assets.ipodFront,
            ),
            _ActivityTile('Motorola V60', 'Saved item', '1d ago', Assets.v60),
          ],
        );
      },
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat(
    this.value,
    this.label,
    this.icon, {
    this.color = AppTheme.blue,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassStatCard(
        value: value,
        label: label,
        icon: icon,
        color: color,
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow(this.title, this.badge, this.icon, this.onTap);

  final String title;
  final String badge;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassListRow(
      icon: icon,
      title: title,
      badge: badge,
      onTap: onTap,
      dense: true,
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile(this.title, this.subtitle, this.time, this.asset);

  final String title;
  final String subtitle;
  final String time;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(10),
      radius: 20,
      child: Row(
        children: [
          ProductImage(asset: asset, width: 42, height: 42),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w900)),
                Text(subtitle, style: AppTheme.body.copyWith(fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: AppTheme.body.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key});

  final _displayName = TextEditingController(text: 'Retro Tech');
  final _username = TextEditingController(text: '@retrotech');
  final _email = TextEditingController(text: 'retro@tech.market');
  final _bio = TextEditingController(text: 'Collect rare. Live timeless.');
  final _location = TextEditingController(text: 'Kuala Lumpur');
  final _seller = TextEditingController(text: 'RetroTech Collector');
  final _contact = TextEditingController(text: 'In-app message');

  @override
  Widget build(BuildContext context) {
    return _FormShell(
      title: 'Edit Profile',
      action: 'Save Profile',
      onSave: () => Navigator.pop(context),
      children: [
        Center(child: LogoMark(size: 110)),
        SizedBox(height: 20),
        GlassInput(
          controller: _displayName,
          hint: 'Display Name',
          icon: Icons.person_outline_rounded,
        ),
        SizedBox(height: 12),
        GlassInput(
          controller: _username,
          hint: 'Username',
          icon: Icons.alternate_email_rounded,
        ),
        SizedBox(height: 12),
        GlassInput(
          controller: _email,
          hint: 'Email',
          icon: Icons.email_outlined,
        ),
        SizedBox(height: 12),
        GlassInput(
          controller: _bio,
          hint: 'Bio',
          icon: Icons.edit_outlined,
          maxLines: 2,
        ),
        SizedBox(height: 12),
        GlassInput(
          controller: _location,
          hint: 'Location',
          icon: Icons.location_on_outlined,
        ),
        SizedBox(height: 24),
        Text('Marketplace Identity', style: AppTheme.h2.copyWith(fontSize: 16)),
        SizedBox(height: 12),
        GlassInput(
          controller: _seller,
          hint: 'Seller Name',
          icon: Icons.storefront_outlined,
        ),
        SizedBox(height: 12),
        GlassInput(
          controller: _contact,
          hint: 'Preferred Contact',
          icon: Icons.chat_bubble_outline_rounded,
        ),
      ],
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool privacy = true;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      child: ListView(
        padding: EdgeInsets.fromLTRB(22, 18, 22, 32),
        children: [
          _TopBar(
            title: 'Settings',
            trailing: Icons.info_outline_rounded,
            onTrailingTap: () => Navigator.pushNamed(context, '/about'),
          ),
          SizedBox(height: 22),
          GlassCard(
            padding: EdgeInsets.all(18),
            child: Row(
              children: [
                LogoMark(size: 58),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Retro Tech',
                        style: AppTheme.h2.copyWith(fontSize: 16),
                      ),
                      Text(
                        '@retrotech',
                        style: AppTheme.body.copyWith(fontSize: 12),
                      ),
                      Text(
                        'Manage your marketplace preferences',
                        style: AppTheme.body.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18),
          GlassListSection(
            children: [
              _SettingsRow(
                Icons.person_outline_rounded,
                'Account',
                onTap: () => Navigator.pushNamed(context, '/edit-profile'),
              ),
              _SettingsSwitch(
                Icons.notifications_outlined,
                'Notifications',
                notifications,
                (v) => setState(() => notifications = v),
              ),
              _SettingsSwitch(
                Icons.lock_outline_rounded,
                'Privacy',
                privacy,
                (v) => setState(() => privacy = v),
              ),
              _SettingsRow(
                Icons.language_rounded,
                'Language',
                value: 'English',
              ),
              _SettingsRow(Icons.paid_outlined, 'Currency', value: 'MYR'),
              _SettingsRow(
                Icons.brush_outlined,
                'Theme',
                value: 'Liquid Glass',
              ),
              _SettingsRow(
                Icons.shield_outlined,
                'Help Center',
                onTap: () => Navigator.pushNamed(context, '/help'),
              ),
            ],
          ),
          SizedBox(height: 28),
          GlassCard(
            radius: 24,
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: Icon(Icons.logout_rounded, color: AppTheme.red),
              title: Text(
                'Log Out',
                style: TextStyle(
                  color: AppTheme.red,
                  fontWeight: FontWeight.w900,
                ),
              ),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow(this.icon, this.label, {this.value, this.onTap});

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassListRow(icon: icon, title: label, value: value, onTap: onTap);
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch(this.icon, this.label, this.value, this.onChanged);

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppTheme.blue,
      secondary: Icon(icon, color: AppTheme.blue),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      child: ListView(
        padding: EdgeInsets.fromLTRB(22, 18, 22, 28),
        children: [
          _TopBar(title: 'Payment Methods'),
          SizedBox(height: 20),
          GlassCard(
            radius: 24,
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded, color: AppTheme.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Protected checkout for verified listings',
                    style: AppTheme.body,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18),
          _PaymentTile('VISA', 'Visa ending 2048', 'Default', AppTheme.blue),
          _PaymentTile('Pay', 'Apple Pay', 'Available', AppTheme.ink),
          _PaymentTile(
            'TnG',
            "Touch 'n Go eWallet",
            'Available',
            AppTheme.blue,
          ),
          _PaymentTile('Bank', 'Online Banking', 'Available', AppTheme.green),
          SizedBox(height: 12),
          GlassCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: Icon(Icons.add_rounded, color: AppTheme.blue),
              title: Text('Add New Payment Method', style: AppTheme.label),
              trailing: Icon(Icons.chevron_right_rounded),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'All payments are encrypted and secure. Eligible purchases are covered by RetroTech Buyer Protection.',
            textAlign: TextAlign.center,
            style: AppTheme.body.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile(this.logo, this.title, this.status, this.color);

  final String logo;
  final String title;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              logo,
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text(
                  status,
                  style: AppTheme.label.copyWith(
                    color: status == 'Default' ? AppTheme.red : AppTheme.blue,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.radio_button_unchecked_rounded, color: AppTheme.muted),
        ],
      ),
    );
  }
}

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key, required this.store});

  final ListingStore store;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: store,
            builder: (context, _) {
              return ListView(
                padding: EdgeInsets.fromLTRB(22, 18, 22, 104),
                children: [
                  _TopBar(
                    title: 'My Listings',
                    trailing: Icons.filter_alt_outlined,
                  ),
                  SizedBox(height: 18),
                  Row(
                    children: [
                      _ListingCounter(
                        '${store.listings.where((e) => e.status == 'Published').length}',
                        'Published',
                      ),
                      _ListingCounter(
                        '${store.listings.where((e) => e.status == 'Draft').length}',
                        'Drafts',
                      ),
                      _ListingCounter('5', 'Sold'),
                    ],
                  ),
                  SizedBox(height: 18),
                  Row(
                    children: [
                      _FilterPill('Published', true),
                      _FilterPill('Drafts', false),
                      _FilterPill('Sold', false),
                    ],
                  ),
                  SizedBox(height: 18),
                  ...store.listings.map(
                    (listing) => ListingCard(
                      listing: listing,
                      openStore: store,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/product',
                        arguments: listing,
                      ),
                      onEdit: () => Navigator.pushNamed(
                        context,
                        '/edit-listing',
                        arguments: listing,
                      ),
                      onDelete: () =>
                          showDeleteListingDialog(context, store, listing),
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            right: 24,
            bottom: 26,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/create-listing'),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.red,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.red.withValues(alpha: 0.32),
                      offset: Offset(0, 10),
                      blurRadius: 22,
                    ),
                  ],
                ),
                child: Icon(Icons.add_rounded, color: Colors.white, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingCounter extends StatelessWidget {
  const _ListingCounter(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        margin: EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(vertical: 12),
        radius: 20,
        child: Column(
          children: [
            Text(
              value,
              style: AppTheme.h2.copyWith(fontSize: 16, color: AppTheme.blue),
            ),
            Text(label, style: AppTheme.body.copyWith(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class DeleteConfirmationScreen extends StatelessWidget {
  const DeleteConfirmationScreen({super.key, required this.store});

  final ListingStore store;

  @override
  Widget build(BuildContext context) {
    final listing = store.listings.isEmpty
        ? seedListings.first
        : store.listings.first;
    return GlassScaffold(
      child: Stack(
        children: [
          IgnorePointer(
            child: AnimatedBuilder(
              animation: store,
              builder: (context, _) {
                return ListView(
                  padding: EdgeInsets.fromLTRB(22, 18, 22, 34),
                  children: [
                    _TopBar(
                      title: 'My Listings',
                      trailing: Icons.filter_alt_outlined,
                    ),
                    SizedBox(height: 18),
                    Row(
                      children: [
                        _ListingCounter('12', 'Published'),
                        _ListingCounter('3', 'Drafts'),
                        _ListingCounter('5', 'Sold'),
                      ],
                    ),
                    SizedBox(height: 18),
                    ListingCard(listing: listing, openStore: store),
                    ListingCard(listing: seedListings[1], openStore: store),
                  ],
                );
              },
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(color: Colors.white.withValues(alpha: 0.42)),
          ),
          Center(
            child: GlassCard(
              width: 300,
              radius: 28,
              padding: EdgeInsets.fromLTRB(22, 26, 22, 18),
              opacity: 0.82,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.red,
                    size: 34,
                  ),
                  SizedBox(height: 12),
                  Text('Delete Listing?', style: AppTheme.h2),
                  SizedBox(height: 8),
                  Text(
                    'This action cannot be undone.\nYour listing will be removed from RetroTech.',
                    textAlign: TextAlign.center,
                    style: AppTheme.body.copyWith(fontSize: 12),
                  ),
                  SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: AppTheme.body.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.red,
                            foregroundColor: Colors.white,
                            shape: StadiumBorder(),
                          ),
                          onPressed: () async {
                            await store.delete(listing.id);
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showDeleteListingDialog(
  BuildContext context,
  ListingStore store,
  Listing listing,
) async {
  await showDialog<void>(
    context: context,
    barrierColor: Colors.white.withValues(alpha: 0.42),
    builder: (dialogContext) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: AlertDialog(
          backgroundColor: Colors.white.withValues(alpha: 0.82),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Column(
            children: [
              Icon(Icons.delete_outline_rounded, color: AppTheme.red, size: 34),
              SizedBox(height: 12),
              Text(
                'Delete Listing?',
                textAlign: TextAlign.center,
                style: AppTheme.h2,
              ),
            ],
          ),
          content: Text(
            'This action cannot be undone.\nYour listing will be removed from RetroTech.',
            textAlign: TextAlign.center,
            style: AppTheme.body,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: AppTheme.body.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.red,
                foregroundColor: Colors.white,
                shape: StadiumBorder(),
              ),
              onPressed: () async {
                await store.delete(listing.id);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: Text('Delete'),
            ),
          ],
        ),
      );
    },
  );
}

class ListingFormScreen extends StatefulWidget {
  const ListingFormScreen({super.key, required this.store, this.listing});

  final ListingStore store;
  final Listing? listing;

  @override
  State<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends State<ListingFormScreen> {
  late final TextEditingController _title;
  late final TextEditingController _category;
  late final TextEditingController _price;
  late final TextEditingController _condition;
  late final TextEditingController _description;
  late final TextEditingController _storage;
  late final TextEditingController _battery;
  late final TextEditingController _connector;
  late String _asset;

  bool get isEditing => widget.listing != null;

  @override
  void initState() {
    super.initState();
    final listing = widget.listing;
    _title = TextEditingController(text: listing?.title ?? '');
    _category = TextEditingController(
      text: listing?.category ?? 'Music Players',
    );
    _price = TextEditingController(
      text: listing?.price.toStringAsFixed(2) ?? '',
    );
    _condition = TextEditingController(
      text: listing?.condition ?? 'Used - Excellent',
    );
    _description = TextEditingController(text: listing?.description ?? '');
    _storage = TextEditingController(text: listing?.storage ?? '');
    _battery = TextEditingController(text: listing?.battery ?? '');
    _connector = TextEditingController(text: listing?.connector ?? '');
    _asset = listing?.imageAsset ?? Assets.gameboy;
  }

  @override
  void dispose() {
    _title.dispose();
    _category.dispose();
    _price.dispose();
    _condition.dispose();
    _description.dispose();
    _storage.dispose();
    _battery.dispose();
    _connector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormShell(
      title: isEditing ? 'Edit Listing' : 'Create Listing',
      action: isEditing ? 'Save Changes' : 'Publish Listing',
      onSave: _save,
      dangerAction: isEditing ? 'Delete Listing' : null,
      onDanger: isEditing
          ? () =>
                showDeleteListingDialog(
                  context,
                  widget.store,
                  widget.listing!,
                ).then((_) {
                  if (context.mounted) Navigator.pop(context);
                })
          : null,
      children: [
        GestureDetector(
          onTap: _cycleAsset,
          child: GlassCard(
            height: isEditing ? 124 : 136,
            radius: 26,
            padding: EdgeInsets.all(12),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isEditing)
                    ProductImage(asset: _asset, width: 94, height: 68)
                  else
                    Icon(
                      Icons.add_a_photo_outlined,
                      color: AppTheme.muted,
                      size: 34,
                    ),
                  SizedBox(height: 6),
                  Text(
                    isEditing ? 'Tap to change photo' : 'Add product photos',
                    style: AppTheme.body.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        GlassInput(
          controller: _title,
          hint: 'Product Title',
          icon: Icons.sell_outlined,
        ),
        SizedBox(height: 10),
        GlassInput(
          controller: _category,
          hint: 'Category',
          icon: Icons.category_outlined,
        ),
        SizedBox(height: 10),
        GlassInput(
          controller: _price,
          hint: 'Price RM',
          icon: Icons.paid_outlined,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 10),
        GlassInput(
          controller: _condition,
          hint: 'Condition',
          icon: Icons.verified_outlined,
        ),
        SizedBox(height: 10),
        GlassInput(
          controller: _description,
          hint: 'Description',
          icon: Icons.notes_rounded,
          maxLines: 3,
        ),
        SizedBox(height: 10),
        GlassInput(
          controller: _storage,
          hint: 'Storage',
          icon: Icons.sd_storage_outlined,
        ),
        SizedBox(height: 10),
        GlassInput(
          controller: _battery,
          hint: 'Battery Life',
          icon: Icons.battery_5_bar_outlined,
        ),
        SizedBox(height: 10),
        GlassInput(
          controller: _connector,
          hint: 'Connector',
          icon: Icons.cable_outlined,
        ),
      ],
    );
  }

  void _cycleAsset() {
    final assets = [
      Assets.gameboy,
      Assets.ipod,
      Assets.walkman,
      Assets.camera,
      Assets.minidisc,
      Assets.palm,
      Assets.imac,
      Assets.watch,
    ];
    final current = assets.indexOf(_asset);
    setState(() => _asset = assets[(current + 1) % assets.length]);
  }

  Future<void> _save() async {
    final parsedPrice = double.tryParse(_price.text.trim()) ?? 0;
    final title = _title.text.trim().isEmpty
        ? 'Untitled Device'
        : _title.text.trim();
    final listing = Listing(
      id:
          widget.listing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      subtitle: widget.listing?.subtitle ?? '',
      category: _category.text.trim().isEmpty ? 'Audio' : _category.text.trim(),
      price: parsedPrice,
      condition: _condition.text.trim().isEmpty
          ? 'Used - Excellent'
          : _condition.text.trim(),
      description: _description.text.trim().isEmpty
          ? 'Collector-ready retro device.'
          : _description.text.trim(),
      storage: _storage.text.trim().isEmpty ? '40GB' : _storage.text.trim(),
      battery: _battery.text.trim().isEmpty ? '14h' : _battery.text.trim(),
      connector: _connector.text.trim().isEmpty
          ? '30-Pin'
          : _connector.text.trim(),
      imageAsset: _asset,
      status: 'Published',
      views: widget.listing?.views ?? 0,
    );
    if (isEditing) {
      await widget.store.update(listing);
    } else {
      await widget.store.add(listing);
    }
    if (mounted) Navigator.pop(context);
  }
}

class _FormShell extends StatelessWidget {
  const _FormShell({
    required this.title,
    required this.action,
    required this.onSave,
    required this.children,
    this.dangerAction,
    this.onDanger,
  });

  final String title;
  final String action;
  final VoidCallback onSave;
  final List<Widget> children;
  final String? dangerAction;
  final VoidCallback? onDanger;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(
              22,
              18,
              22,
              dangerAction == null ? 104 : 136,
            ),
            children: [
              _TopBar(
                title: title,
                trailing: title.contains('Edit')
                    ? Icons.visibility_outlined
                    : null,
              ),
              SizedBox(height: 22),
              ...children,
            ],
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: dangerAction == null ? 22 : 54,
            child: LiquidButton(
              label: action,
              icon: Icons.check_circle_outline_rounded,
              onPressed: onSave,
            ),
          ),
          if (dangerAction != null)
            Positioned(
              left: 22,
              right: 22,
              bottom: 12,
              child: TextButton(
                onPressed: onDanger,
                child: Text(
                  dangerAction!,
                  style: AppTheme.label.copyWith(color: AppTheme.red),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key, this.listing});

  final Listing? listing;

  @override
  Widget build(BuildContext context) {
    final item = listing ?? seedListings.first;
    final total = item.price + 35 + 15;
    return GlassScaffold(
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(22, 18, 22, 104),
            children: [
              _TopBar(title: 'Checkout'),
              SizedBox(height: 18),
              GlassCard(
                child: Row(
                  children: [
                    ProductImage(asset: item.imageAsset, width: 78, height: 78),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.shortTitle,
                            style: AppTheme.h2.copyWith(fontSize: 16),
                          ),
                          Text(
                            'Seller: ${item.seller}',
                            style: AppTheme.body.copyWith(fontSize: 12),
                          ),
                          Text(
                            item.priceLabel,
                            style: AppTheme.label.copyWith(color: AppTheme.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14),
              _CheckoutTile(
                Icons.location_on_outlined,
                'Delivery Address',
                'Liu Zhenyu\nNo. 18, Jalan Bukit Indah\nKuala Lumpur, Malaysia',
              ),
              _CheckoutTile(
                Icons.credit_card_outlined,
                'Payment Method',
                'Visa ending 2048   Default',
                onTap: () => Navigator.pushNamed(context, '/payment-methods'),
              ),
              _CheckoutTile(
                Icons.shield_outlined,
                'Buyer Protection',
                'Secure payment and verified listing coverage included.',
              ),
              SizedBox(height: 16),
              Text('Order Summary', style: AppTheme.h2.copyWith(fontSize: 16)),
              SizedBox(height: 10),
              GlassCard(
                child: Column(
                  children: [
                    _MoneyRow('Item Price', item.price),
                    _MoneyRow('Shipping', 35),
                    _MoneyRow('Protection Fee', 15),
                    Divider(color: AppTheme.line),
                    _MoneyRow('Total', total, strong: true),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: 22,
            child: LiquidButton(
              label: 'Pay Securely',
              icon: Icons.lock_outline_rounded,
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                '/order-confirmed',
                arguments: item,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutTile extends StatelessWidget {
  const _CheckoutTile(this.icon, this.title, this.body, {this.onTap});

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.blue),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w900)),
                  Text(body, style: AppTheme.body.copyWith(fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
          ],
        ),
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow(this.label, this.amount, {this.strong = false});

  final String label;
  final double amount;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: strong ? AppTheme.h2.copyWith(fontSize: 16) : AppTheme.body,
          ),
          Spacer(),
          Text(
            'RM ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: strong ? AppTheme.blue : AppTheme.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key, this.listing});

  final Listing? listing;

  @override
  Widget build(BuildContext context) {
    final item = listing ?? seedListings.first;
    return GlassScaffold(
      child: ListView(
        padding: EdgeInsets.fromLTRB(22, 30, 22, 30),
        children: [
          Center(child: Text('RetroTech', style: AppTheme.h2)),
          SizedBox(height: 54),
          Center(
            child: GlassCard(
              width: 112,
              height: 112,
              radius: 56,
              padding: EdgeInsets.zero,
              child: Icon(Icons.done_rounded, color: AppTheme.red, size: 58),
            ),
          ),
          SizedBox(height: 28),
          Center(child: Text('Order Confirmed', style: AppTheme.h1)),
          SizedBox(height: 24),
          GlassCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.shortTitle,
                        style: AppTheme.h2.copyWith(fontSize: 17),
                      ),
                      SizedBox(height: 8),
                      Text('Order #RT2048', style: AppTheme.label),
                      Text(
                        'Paid',
                        style: AppTheme.label.copyWith(color: AppTheme.green),
                      ),
                      Text(
                        item.priceLabel,
                        style: AppTheme.h2.copyWith(
                          fontSize: 16,
                          color: AppTheme.blue,
                        ),
                      ),
                      Text(
                        'Seller: ${item.seller}',
                        style: AppTheme.body.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ProductImage(asset: item.imageAsset, width: 72, height: 72),
              ],
            ),
          ),
          SizedBox(height: 22),
          Row(
            children: [
              _ProgressChip('Paid', Icons.done_rounded, true),
              _ProgressChip(
                'Seller Notified',
                Icons.notifications_rounded,
                true,
              ),
              _ProgressChip('Preparing', Icons.inventory_2_outlined, false),
            ],
          ),
          SizedBox(height: 30),
          LiquidButton(
            label: 'Track Order',
            icon: Icons.my_location_rounded,
            onPressed: () {},
          ),
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/main',
              (route) => false,
            ),
            child: Text('Back to Home', style: AppTheme.label),
          ),
        ],
      ),
    );
  }
}

class _ProgressChip extends StatelessWidget {
  const _ProgressChip(this.label, this.icon, this.done);

  final String label;
  final IconData icon;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(vertical: 12),
        radius: 20,
        child: Column(
          children: [
            Icon(icon, color: done ? AppTheme.blue : AppTheme.muted),
            SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.body.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class SellerProfileScreen extends StatelessWidget {
  const SellerProfileScreen({super.key, required this.store});

  final ListingStore store;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      child: ListView(
        padding: EdgeInsets.fromLTRB(22, 18, 22, 30),
        children: [
          _TopBar(title: 'Seller Profile', trailing: Icons.ios_share_rounded),
          SizedBox(height: 24),
          Center(child: LogoMark(size: 112)),
          SizedBox(height: 18),
          Center(
            child: Text(
              'RetroTech Collector',
              style: AppTheme.h1.copyWith(fontSize: 26),
            ),
          ),
          Center(
            child: Text('4.9 star  |  Verified Seller', style: AppTheme.label),
          ),
          SizedBox(height: 6),
          Center(
            child: Text('Transparent tech specialist', style: AppTheme.body),
          ),
          SizedBox(height: 22),
          Row(
            children: [
              _ProfileStat('128', 'Sold', Icons.shopping_bag_outlined),
              _ProfileStat(
                '98%',
                'Positive',
                Icons.favorite_rounded,
                color: AppTheme.green,
              ),
              _ProfileStat('2h', 'Reply', Icons.chat_outlined),
            ],
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: LiquidButton(
                  label: 'Message Seller',
                  height: 48,
                  onPressed: () => Navigator.pushNamed(context, '/chat'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: GlassCard(
                  height: 48,
                  radius: 999,
                  padding: EdgeInsets.zero,
                  child: Center(child: Text('Follow', style: AppTheme.label)),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Text('Active Listings', style: AppTheme.h2.copyWith(fontSize: 17)),
          SizedBox(height: 12),
          ...store.listings
              .take(4)
              .map(
                (listing) => ListingCard(
                  listing: listing,
                  openStore: store,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/product',
                    arguments: listing,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key, this.inShell = false});

  final bool inShell;

  @override
  Widget build(BuildContext context) {
    final content = ListView(
      padding: EdgeInsets.fromLTRB(22, 18, 22, inShell ? 118 : 30),
      children: [
        Row(
          children: [
            CircleGlassButton(icon: Icons.search_rounded),
            Spacer(),
            Text('Inbox', style: AppTheme.h2),
            Spacer(),
            CircleGlassButton(icon: Icons.tune_rounded),
          ],
        ),
        SizedBox(height: 18),
        Row(
          children: [
            _FilterPill('Messages', true),
            _FilterPill('Orders', false),
            _FilterPill('Support', false),
          ],
        ),
        SizedBox(height: 18),
        _MessageTile(
          'RetroTech Collector',
          'The iPod is fully tested and ready to ship.',
          '2m',
          '2',
          Assets.ipod,
        ),
        _MessageTile(
          'VintageAudioCo',
          'I can include the original earbuds for you.',
          '18m',
          '1',
          Assets.avatarVintage,
        ),
        _MessageTile(
          'PalmPilotFan',
          'Battery holds charge well. Let me know if you want more photos.',
          '1h',
          '3',
          Assets.avatarPalm,
        ),
        _MessageTile(
          'PixelCam Studio',
          'Price is firm, but shipping is free.',
          'Yesterday',
          '',
          Assets.avatarPixel,
        ),
      ],
    );
    return inShell ? content : GlassScaffold(child: content);
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile(
    this.name,
    this.message,
    this.time,
    this.badge,
    this.asset,
  );

  final String name;
  final String message;
  final String time;
  final String badge;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return _LiquidPressable(
      onTap: () => Navigator.pushNamed(context, '/chat'),
      borderRadius: BorderRadius.circular(30),
      glowColor: AppTheme.blue,
      child: GlassCard(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            ClipOval(child: ProductImage(asset: asset, width: 48, height: 48)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontWeight: FontWeight.w900)),
                  SizedBox(height: 4),
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.body.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Column(
              children: [
                Text(time, style: AppTheme.body.copyWith(fontSize: 10)),
                if (badge.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    padding: EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppTheme.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChatThreadScreen extends StatefulWidget {
  const ChatThreadScreen({super.key, this.listing});

  final Listing? listing;

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final List<_ChatLine> _messages = _initialMessages;

  Listing get _item => widget.listing ?? seedListings.first;

  List<_ChatLine> get _initialMessages {
    final item = _item;
    return [
      _ChatLine(
        'Hi! Thanks for your interest in the ${item.title}.',
        false,
        '2:14 PM',
      ),
      _ChatLine(
        "It's in excellent condition. The front and back are clean.",
        false,
        '2:15 PM',
      ),
      _ChatLine(
        'Thanks! Can you confirm storage capacity and battery?',
        true,
        '2:16 PM',
      ),
      _ChatLine(
        "Sure! It is the ${item.storage} model and battery holds charge well.",
        false,
        '2:17 PM',
      ),
      _ChatLine(
        'Perfect, please do. Also, do you ship to Kuala Lumpur?',
        true,
        '2:18 PM',
      ),
      _ChatLine(
        'Yes, shipping is RM15 via Pos Laju and usually takes 2-3 working days.',
        false,
        '2:18 PM',
      ),
      _ChatLine(
        "Great! I'll take it. Please let me know your preferred payment method.",
        true,
        '2:19 PM',
      ),
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatLine(text, true, 'Now'));
      _messageController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    final metrics = _ResponsiveMetrics.of(context);
    return GlassScaffold(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              metrics.pagePadding,
              metrics.topGap,
              metrics.pagePadding,
              0,
            ),
            child: Row(
              children: [
                CircleGlassButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.seller,
                        style: AppTheme.h2.copyWith(fontSize: 16),
                      ),
                      Text(
                        'Active today',
                        style: AppTheme.body.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                CircleGlassButton(icon: Icons.more_horiz_rounded),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              metrics.pagePadding,
              14,
              metrics.pagePadding,
              10,
            ),
            child: GlassCard(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  ProductImage(asset: item.imageAsset, width: 54, height: 54),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.shortTitle,
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          item.priceLabel,
                          style: AppTheme.label.copyWith(color: AppTheme.red),
                        ),
                        Text('View Listing', style: AppTheme.label),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(
                metrics.pagePadding,
                8,
                metrics.pagePadding,
                8,
              ),
              children: [
                Center(
                  child: Text(
                    'Today 2:14 PM',
                    style: AppTheme.body.copyWith(fontSize: 11),
                  ),
                ),
                SizedBox(height: 12),
                ..._messages.map((message) => _ChatBubble(message)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              metrics.pagePadding,
              6,
              metrics.pagePadding,
              18 + MediaQuery.viewPaddingOf(context).bottom,
            ),
            child: GlassCard(
              radius: 999,
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.image_outlined, color: AppTheme.muted),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      key: const ValueKey('chat-message-field'),
                      controller: _messageController,
                      onSubmitted: (_) => _sendMessage(),
                      minLines: 1,
                      maxLines: 3,
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Message seller',
                        hintStyle: AppTheme.body,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  CircleGlassButton(
                    icon: Icons.send_rounded,
                    color: AppTheme.red,
                    size: 42,
                    onTap: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatLine {
  const _ChatLine(this.text, this.mine, this.time);

  final String text;
  final bool mine;
  final String time;
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble(this.line);

  final _ChatLine line;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: line.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.74,
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: line.mine
                ? AppTheme.red
                : Colors.white.withValues(alpha: 0.72),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.text,
                style: TextStyle(
                  color: line.mine ? Colors.white : AppTheme.ink,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 5),
              Text(
                line.time,
                style: TextStyle(
                  color: line.mine
                      ? Colors.white.withValues(alpha: 0.78)
                      : AppTheme.muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = _ResponsiveMetrics.of(context);
    return GlassScaffold(
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(
              metrics.pagePadding,
              metrics.topGap,
              metrics.pagePadding,
              104,
            ),
            children: [
              Row(
                children: [
                  CircleGlassButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  Spacer(),
                  CircleGlassButton(
                    icon: Icons.headset_mic_outlined,
                    color: AppTheme.blue,
                  ),
                ],
              ),
              SizedBox(height: 22),
              Text('How can we help?', style: AppTheme.h1),
              SizedBox(height: 18),
              GlassCard(
                height: 46,
                radius: 23,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: AppTheme.muted, size: 18),
                    SizedBox(width: 10),
                    Text('Search help topics', style: AppTheme.body),
                  ],
                ),
              ),
              SizedBox(height: 18),
              Wrap(
                runSpacing: 8,
                children: [
                  _FilterPill('Orders', true),
                  _FilterPill('Selling', false),
                  _FilterPill('Payments', false),
                  _FilterPill('Safety', false),
                ],
              ),
              SizedBox(height: 18),
              _FaqTile(
                'How do I contact a seller?',
                'Message sellers securely from any product page.',
              ),
              _FaqTile(
                'How do I create a listing?',
                'Add product details, photos, and price in minutes.',
              ),
              _FaqTile(
                'How are payments protected?',
                'Protected checkout helps keep transactions safe.',
              ),
              _FaqTile(
                'How do I report a fake item?',
                'Flag suspicious listings and our team will review them.',
              ),
            ],
          ),
          Positioned(
            left: metrics.pagePadding,
            right: metrics.pagePadding,
            bottom: 22,
            child: LiquidButton(
              label: 'Start Live Chat',
              icon: Icons.chat_bubble_rounded,
              onPressed: () => Navigator.pushNamed(context, '/chat'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile(this.title, this.body);

  final String title;
  final String body;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return _LiquidPressable(
      onTap: () => setState(() => _expanded = !_expanded),
      active: _expanded,
      borderRadius: BorderRadius.circular(22),
      glowColor: AppTheme.blue,
      child: GlassCard(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        radius: 22,
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.help_outline_rounded, color: AppTheme.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.muted,
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10, left: 36),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(widget.body, style: AppTheme.body),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = _ResponsiveMetrics.of(context);
    return GlassScaffold(
      includeSafeArea: false,
      background: const _AboutBackground(),
      child: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            metrics.pagePadding,
            metrics.topGap,
            metrics.pagePadding,
            30 + MediaQuery.viewPaddingOf(context).bottom,
          ),
          children: [
            Row(
              children: [
                _AboutIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => popOrMain(context),
                ),
                const Spacer(),
                const _AboutIconButton(icon: Icons.ios_share_rounded),
              ],
            ),
            SizedBox(height: metrics.compact ? 28 : 42),
            LayoutBuilder(
              builder: (context, constraints) {
                final showInlineArt = constraints.maxWidth >= 340;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _AboutHeroCopy(compact: metrics.compact)),
                    if (showInlineArt) ...[
                      SizedBox(width: metrics.gutter),
                      SizedBox(
                        width: constraints.maxWidth * 0.5,
                        height: metrics.compact ? 168 : 210,
                        child: Transform.rotate(
                          angle: 0.06981317007977318,
                          child: Image.asset(
                            Assets.glassButterfly,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            if (metrics.width < 340) ...[
              SizedBox(height: metrics.gutter),
              SizedBox(
                height: 190,
                child: Image.asset(
                  Assets.glassButterfly,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ],
            SizedBox(height: metrics.compact ? 30 : 42),
            Row(
              children: const [
                _SmallDash(_aboutRed),
                SizedBox(width: 10),
                _SmallDash(_aboutBlue),
              ],
            ),
            SizedBox(height: metrics.compact ? 28 : 38),
            Text.rich(
              TextSpan(
                style: _AboutText.body,
                children: [
                  TextSpan(
                    text: 'RetroTech',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        ' is the go-to marketplace for collectors and enthusiasts of ',
                  ),
                  TextSpan(
                    text: 'Y2K',
                    style: TextStyle(
                      color: _aboutRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: ' electronics. From '),
                  TextSpan(
                    text: 'classic',
                    style: TextStyle(
                      color: _aboutBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text:
                        ' devices to rare finds, we bring the best of the past to your future.',
                  ),
                ],
              ),
            ),
            SizedBox(height: metrics.compact ? 28 : 42),
            Row(
              children: [
                _AboutIconButton(
                  icon: Icons.arrow_forward_rounded,
                  color: _aboutRed,
                  size: 42,
                  iconSize: 22,
                ),
                SizedBox(width: metrics.gutter),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Learn more about our ',
                          style: _AboutText.ctaCopy,
                        ),
                        TextSpan(text: 'mission', style: _AboutText.ctaLink),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: metrics.compact ? 32 : 44),
            Text('WHAT WE STAND FOR', style: _AboutText.section),
            SizedBox(height: metrics.gutter),
            LayoutBuilder(
              builder: (context, constraints) {
                final gap = metrics.compact ? 8.0 : 10.0;
                final cardWidth = ((constraints.maxWidth - gap * 2) / 3)
                    .clamp(88.0, 116.0)
                    .toDouble();
                return Row(
                  children: [
                    _ValueCard(
                      Icons.favorite_rounded,
                      'Trust & Safety',
                      'Secure payments\nand verified\nsellers.',
                      _aboutRed,
                      width: cardWidth,
                      iconTop: 4,
                      titleLeft: 20,
                      titleTop: 43,
                      copyTop: 63,
                      iconSize: 18,
                    ),
                    SizedBox(width: gap),
                    _ValueCard(
                      Icons.groups_rounded,
                      'Community First',
                      'Connect with\ncollectors who\nshare your passion.',
                      _aboutBlue,
                      width: cardWidth,
                      iconTop: 5,
                      titleLeft: 11,
                      titleTop: 44,
                      copyTop: 65,
                      iconSize: 16,
                    ),
                    SizedBox(width: gap),
                    _ValueCard(
                      Icons.eco_rounded,
                      'Sustainability',
                      'Give vintage\ntech a second\nlife together.',
                      _aboutGreen,
                      width: cardWidth,
                      iconTop: 6,
                      titleLeft: 23,
                      titleTop: 47,
                      copyTop: 65,
                      iconSize: 16,
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: metrics.compact ? 32 : 44),
            Text('BY THE NUMBERS', style: _AboutText.section),
            SizedBox(height: metrics.gutter),
            LayoutBuilder(
              builder: (context, constraints) {
                final gap = metrics.compact ? 6.0 : 8.0;
                final numberWidth = ((constraints.maxWidth - gap * 3) / 4)
                    .clamp(64.0, 90.0)
                    .toDouble();
                return Row(
                  children: [
                    _Number(
                      '10K+',
                      'Happy Buyers',
                      _aboutRed,
                      width: numberWidth,
                    ),
                    SizedBox(width: gap),
                    _Number(
                      '5K+',
                      'Verified Sellers',
                      _aboutBlue,
                      width: numberWidth,
                    ),
                    SizedBox(width: gap),
                    _Number(
                      '50K+',
                      'Products Sold',
                      _aboutGreen,
                      width: numberWidth,
                    ),
                    SizedBox(width: gap),
                    _Number(
                      '100+',
                      'Countries',
                      _aboutViolet,
                      width: numberWidth,
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: metrics.compact ? 28 : 36),
            const _AboutNewsCard(),
          ],
        ),
      ),
    );
  }
}

class _AboutHeroCopy extends StatelessWidget {
  const _AboutHeroCopy({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final heroStyle = _AboutText.hero.copyWith(fontSize: compact ? 26 : 28);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ABOUT US', style: _AboutText.eyebrow),
        SizedBox(height: compact ? 18 : 22),
        Text('More than', style: heroStyle),
        RichText(
          text: TextSpan(
            style: heroStyle,
            children: [
              const TextSpan(text: 'a '),
              const TextSpan(
                text: 'Marketplace',
                style: TextStyle(color: _aboutRed),
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 2),
                  child: SizedBox(
                    width: 8,
                    height: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: _aboutRed),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: compact ? 16 : 20),
        Text(
          'A community built on trust, passion, and nostalgia.',
          style: _AboutText.subcopy.copyWith(fontSize: compact ? 16 : 17),
        ),
      ],
    );
  }
}

const _aboutInk = Color(0xFF080A0F);
const _aboutMuted = Color(0xFF5C637A);
const _aboutEyebrow = Color(0xFF4791DB);
const _aboutBlue = Color(0xFF0573FF);
const _aboutRed = Color(0xFFFF080F);
const _aboutGreen = Color(0xFF0DB238);
const _aboutViolet = Color(0xFF7338F2);

class _AboutText {
  static const baseFont = 'Inter';

  static const eyebrow = TextStyle(
    fontFamily: baseFont,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: _aboutEyebrow,
  );

  static const hero = TextStyle(
    fontFamily: baseFont,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: _aboutInk,
  );

  static const subcopy = TextStyle(
    fontFamily: baseFont,
    fontSize: 17,
    height: 24 / 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: _aboutMuted,
  );

  static const body = TextStyle(
    fontFamily: baseFont,
    fontSize: 17,
    height: 25 / 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: _aboutInk,
  );

  static const ctaCopy = TextStyle(
    fontFamily: baseFont,
    fontSize: 12,
    height: 15 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: _aboutMuted,
  );

  static const ctaLink = TextStyle(
    fontFamily: baseFont,
    fontSize: 12,
    height: 15 / 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: _aboutBlue,
  );

  static const section = TextStyle(
    fontFamily: baseFont,
    fontSize: 10,
    height: 13 / 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: _aboutEyebrow,
  );

  static const valueTitle = TextStyle(
    fontFamily: baseFont,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const valueCopy = TextStyle(
    fontFamily: baseFont,
    fontSize: 9,
    height: 12 / 9,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: _aboutMuted,
  );

  static const metric = TextStyle(
    fontFamily: baseFont,
    fontSize: 22,
    height: 26 / 22,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const metricLabel = TextStyle(
    fontFamily: baseFont,
    fontSize: 9,
    height: 11 / 9,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: _aboutMuted,
  );

  static const newsEyebrow = TextStyle(
    fontFamily: baseFont,
    fontSize: 9,
    height: 11 / 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: _aboutBlue,
  );

  static const newsTitle = TextStyle(
    fontFamily: baseFont,
    fontSize: 11,
    height: 13 / 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: _aboutInk,
  );

  static const newsCopy = TextStyle(
    fontFamily: baseFont,
    fontSize: 9,
    height: 11 / 9,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: _aboutMuted,
  );
}

class _AboutBackground extends StatelessWidget {
  const _AboutBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Image.asset(
        Assets.background,
        fit: BoxFit.cover,
        alignment: Alignment.topLeft,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _AboutGlassSurface extends StatelessWidget {
  const _AboutGlassSurface({
    required this.child,
    required this.width,
    required this.height,
    required this.radius,
    this.opacity = 0.66,
  });

  final Widget child;
  final double width;
  final double height;
  final double radius;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final glassSheen = opacity.clamp(0.08, 0.22).toDouble();
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: glassSheen * 1.45),
            offset: Offset(-2, -2),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Color(0xFF1A2942).withValues(alpha: 0.1),
            offset: Offset(0, 16),
            blurRadius: 24,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 72, sigmaY: 72),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.94),
                width: 1.1,
              ),
              borderRadius: BorderRadius.circular(radius),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _AboutIconButton extends StatelessWidget {
  const _AboutIconButton({
    required this.icon,
    this.color = _aboutInk,
    this.onTap,
    this.size = 44,
    this.iconSize,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: _LiquidPressable(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(size / 2),
        glowColor: color,
        child: _AboutGlassSurface(
          width: size,
          height: size,
          radius: size / 2,
          child: Icon(icon, color: color, size: iconSize ?? size * 0.54),
        ),
      ),
    );
  }
}

class _SmallDash extends StatelessWidget {
  const _SmallDash(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard(
    this.icon,
    this.title,
    this.text,
    this.color, {
    required this.width,
    required this.iconTop,
    required this.titleLeft,
    required this.titleTop,
    required this.copyTop,
    required this.iconSize,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color color;
  final double width;
  final double iconTop;
  final double titleLeft;
  final double titleTop;
  final double copyTop;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final height = (112 * (width / 116)).clamp(92.0, 112.0).toDouble();
    return _LiquidPressable(
      onTap: () {},
      borderRadius: BorderRadius.circular(18),
      glowColor: color,
      child: _AboutGlassSurface(
        width: width,
        height: height,
        radius: 18 * (width / 116).clamp(0.82, 1),
        opacity: 0.52,
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 116,
              height: 112,
              child: Stack(
                children: [
                  Positioned(
                    left: 40,
                    top: iconTop,
                    child: _AboutGlassSurface(
                      width: 34,
                      height: 34,
                      radius: 17,
                      child: Icon(icon, color: color, size: iconSize),
                    ),
                  ),
                  Positioned(
                    left: titleLeft,
                    top: titleTop,
                    width: 92,
                    child: Text(
                      title,
                      style: _AboutText.valueTitle.copyWith(color: color),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: copyTop,
                    width: 92,
                    child: Text(
                      text,
                      style: _AboutText.valueCopy,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Number extends StatelessWidget {
  const _Number(this.value, this.label, this.color, {required this.width});

  final String value;
  final String label;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 43,
      child: FittedBox(
        alignment: Alignment.centerLeft,
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 90,
          height: 43,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                width: 80,
                child: Text(
                  value,
                  style: _AboutText.metric.copyWith(color: color),
                ),
              ),
              Positioned(
                left: 0,
                top: 28,
                width: 90,
                child: Text(label, style: _AboutText.metricLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutNewsCard extends StatelessWidget {
  const _AboutNewsCard();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;
        return _LiquidPressable(
          onTap: () {},
          borderRadius: BorderRadius.circular(30),
          glowColor: _aboutRed,
          child: _AboutGlassSurface(
            width: constraints.maxWidth,
            height: compact ? 78 : 64,
            radius: 30,
            opacity: 0.58,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(31),
                  child: Image.asset(
                    Assets.latestNewsThumbnail,
                    width: compact ? 76 : 93,
                    height: compact ? 78 : 64,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) => ProductImage(
                      asset: Assets.gameboy,
                      width: compact ? 76 : 93,
                      height: compact ? 78 : 64,
                    ),
                  ),
                ),
                SizedBox(width: compact ? 12 : 18),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LATEST NEWS', style: _AboutText.newsEyebrow),
                      SizedBox(height: compact ? 3 : 4),
                      Text(
                        'New Arrivals: Transparent Tech',
                        style: _AboutText.newsTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: compact ? 2 : 3),
                      Text(
                        'Explore rare transparent gadgets',
                        style: _AboutText.newsCopy,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: compact ? 8 : 12),
                  child: _AboutIconButton(
                    icon: Icons.arrow_forward_rounded,
                    color: _aboutRed,
                    size: 38,
                    iconSize: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({
    required this.user,
    required this.time,
    required this.text,
    required this.asset,
  });

  final String user;
  final String time;
  final String text;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return _LiquidPressable(
      onTap: () {},
      borderRadius: BorderRadius.circular(30),
      glowColor: AppTheme.blue,
      child: GlassCard(
        margin: EdgeInsets.only(bottom: 14),
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipOval(child: ProductImage(asset: asset, width: 44, height: 44)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(time, style: AppTheme.body.copyWith(fontSize: 10)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    text,
                    style: AppTheme.body.copyWith(color: AppTheme.ink),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        color: AppTheme.red,
                        size: 17,
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: AppTheme.blue,
                        size: 17,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, this.trailing, this.onTrailingTap});

  final String title;
  final IconData? trailing;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleGlassButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTheme.h2.copyWith(fontSize: 18),
          ),
        ),
        CircleGlassButton(
          icon: trailing ?? Icons.more_horiz_rounded,
          onTap: onTrailingTap,
        ),
      ],
    );
  }
}
