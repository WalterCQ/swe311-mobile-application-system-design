import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retro_tech_marketplace/app.dart';
import 'package:retro_tech_marketplace/constants/assets.dart';
import 'package:retro_tech_marketplace/data/listing_repository.dart';
import 'package:retro_tech_marketplace/models/chat_message.dart';
import 'package:retro_tech_marketplace/models/community_record.dart';
import 'package:retro_tech_marketplace/models/delivery_address.dart';
import 'package:retro_tech_marketplace/models/listing.dart';
import 'package:retro_tech_marketplace/models/order_record.dart';
import 'package:retro_tech_marketplace/models/user_profile.dart';
import 'package:retro_tech_marketplace/services/demo_auth_service.dart';
import 'package:retro_tech_marketplace/store/listing_store.dart';
import 'package:retro_tech_marketplace/store/seed_data.dart';
import 'package:retro_tech_marketplace/constants/theme.dart';
import 'package:retro_tech_marketplace/screens/settings/help_support_screen.dart';
import 'package:retro_tech_marketplace/screens/settings/chat_thread_screen.dart';
import 'package:retro_tech_marketplace/screens/settings/settings_screen.dart';
import 'package:retro_tech_marketplace/screens/auth/registration_screen.dart';
import 'package:retro_tech_marketplace/screens/checkout/checkout_screen.dart';
import 'package:retro_tech_marketplace/screens/checkout/delivery_address_screen.dart';
import 'package:retro_tech_marketplace/screens/checkout/order_confirmation_screen.dart';
import 'package:retro_tech_marketplace/screens/home/home_screen.dart';
import 'package:retro_tech_marketplace/screens/product/category_detail_screen.dart';
import 'package:retro_tech_marketplace/screens/product/listing_form_screen.dart';
import 'package:retro_tech_marketplace/screens/product/my_listings_screen.dart';
import 'package:retro_tech_marketplace/screens/product/product_detail_screen.dart';
import 'package:retro_tech_marketplace/screens/product/product_video_player.dart';
import 'package:retro_tech_marketplace/screens/profile/account_profile_screen.dart';
import 'package:retro_tech_marketplace/screens/profile/edit_profile_screen.dart';
import 'package:retro_tech_marketplace/screens/profile/payment_methods_screen.dart';
import 'package:retro_tech_marketplace/screens/profile/seller_profile_screen.dart';
import 'package:retro_tech_marketplace/screens/profile/saved_items_screen.dart';
import 'package:retro_tech_marketplace/services/update_service.dart';
import 'package:retro_tech_marketplace/widgets/glass_scaffold.dart';
import 'package:retro_tech_marketplace/screens/home/categories_screen.dart';
import 'package:retro_tech_marketplace/screens/shell/main_shell.dart';
import 'package:retro_tech_marketplace/screens/settings/about_screen.dart';
import 'package:retro_tech_marketplace/services/local_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, (
        MethodCall methodCall,
      ) async {
        if (methodCall.method == 'Clipboard.setData') return null;
        return null;
      });

  test('release version comparison handles tags and build suffixes', () {
    expect(compareVersionNames('v1.0.5', '1.0.4+5'), greaterThan(0));
    expect(compareVersionNames('1.0.4', 'v1.0.4+5'), 0);
    expect(compareVersionNames('v1.0.3', '1.0.4'), lessThan(0));
  });

  test('update service checks the published release repository', () {
    expect(UpdateService.repository, 'WalterCQ/SWE311-retro-tech-marketplace');
    expect(UpdateService.fallbackVersion, '1.1.6');
  });

  test('release parser selects the first APK asset download URL', () {
    final release = <String, Object?>{
      'assets': [
        {
          'name': 'release-notes.txt',
          'browser_download_url':
              'https://github.com/WalterCQ/example/releases/download/v1.1.1/release-notes.txt',
        },
        {
          'name': 'retro-tech-marketplace.apk',
          'browser_download_url':
              'https://github.com/WalterCQ/example/releases/download/v1.1.1/retro-tech-marketplace.apk',
        },
        {
          'name': 'retro-tech-marketplace-arm64.apk',
          'browser_download_url':
              'https://github.com/WalterCQ/example/releases/download/v1.1.1/retro-tech-marketplace-arm64.apk',
        },
      ],
    };

    expect(
      selectApkDownloadUrlFromRelease(release),
      'https://github.com/WalterCQ/example/releases/download/v1.1.1/retro-tech-marketplace.apk',
    );
  });

  test('release parser returns null when no APK asset is available', () {
    final release = <String, Object?>{
      'assets': [
        {
          'name': 'ios-unsigned.zip',
          'browser_download_url':
              'https://github.com/WalterCQ/example/releases/download/v1.1.1/ios-unsigned.zip',
        },
      ],
    };

    expect(selectApkDownloadUrlFromRelease(release), isNull);
  });

  test(
    'product galleries keep original first image and expose three images',
    () {
      for (final listing in seedListings) {
        expect(listing.detailImageAssets, hasLength(3));
        expect(listing.detailImageAssets.first, listing.imageAsset);
      }

      final watchListing = seedListings.first.copyWith(
        imageAsset: Assets.watch,
      );
      expect(watchListing.detailImageAssets, hasLength(3));
      expect(watchListing.detailImageAssets.first, Assets.watch);
    },
  );

  void setPhoneSize(WidgetTester tester, [Size size = const Size(390, 844)]) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpRetroTech(
    WidgetTester tester, {
    ListingStore? store,
    LocalNotificationService? notificationService,
  }) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    SharedPreferences.setMockInitialValues({});
    setPhoneSize(tester);
    await tester.pumpWidget(
      RetroTechApp(
        store: store ?? testStore(),
        notificationService:
            notificationService ?? FakeLocalNotificationService(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> logIn(WidgetTester tester) async {
    await tester.enterText(
      find.widgetWithText(TextField, 'Username or Email'),
      DemoAuthService.defaultUsername,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      DemoAuthService.defaultPassword,
    );
    await tester.ensureVisible(find.text('Log In'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();
  }

  ProductDetailScreen detailScreenForTest(Listing listing) {
    return ProductDetailScreen(
      store: testStore(),
      listing: listing,
      videoPlayerBuilder: (_) => FakeMultimediaPlayer(),
    );
  }

  testWidgets('home listing gallery swipes between product images', (
    WidgetTester tester,
  ) async {
    setPhoneSize(tester);
    final listing = seedListings.first;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: GlassScaffold(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [HomeListingCard(listing: listing)],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final firstDot = find.byKey(
      const ValueKey('home-gallery-motorola-v60-dot-0'),
    );
    final secondDot = find.byKey(
      const ValueKey('home-gallery-motorola-v60-dot-1'),
    );
    expect(tester.getSize(firstDot).width, 20);
    expect(tester.getSize(secondDot).width, 8);

    await tester.drag(
      find.byKey(const ValueKey('home-gallery-page-view-motorola-v60')),
      const Offset(-240, 0),
    );
    await tester.pumpAndSettle();

    expect(tester.getSize(firstDot).width, 8);
    expect(tester.getSize(secondDot).width, 20);

    await tester.drag(secondDot, const Offset(240, 0));
    await tester.pumpAndSettle();

    expect(tester.getSize(firstDot).width, 20);
    expect(tester.getSize(secondDot).width, 8);
  });

  testWidgets('openable listing card gallery still swipes between images', (
    WidgetTester tester,
  ) async {
    setPhoneSize(tester);
    final store = testStore();
    final listing = seedListings.first;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: GlassScaffold(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [ListingCard(listing: listing, openStore: store)],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final firstDot = find.byKey(
      const ValueKey('home-gallery-motorola-v60-dot-0'),
    );
    final secondDot = find.byKey(
      const ValueKey('home-gallery-motorola-v60-dot-1'),
    );
    expect(tester.getSize(firstDot).width, 20);

    await tester.drag(
      find.byKey(const ValueKey('home-gallery-page-view-motorola-v60')),
      const Offset(-240, 0),
    );
    await tester.pumpAndSettle();

    expect(tester.getSize(firstDot).width, 8);
    expect(tester.getSize(secondDot).width, 20);
  });

  testWidgets('home avatar switches the shell to profile', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = testStore();
    await store.load();
    setPhoneSize(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: MainShell(store: store),
      ),
    );
    await tester.pumpAndSettle();

    List<AnimatedShellPage> shellPages() => tester
        .widgetList<AnimatedShellPage>(find.byType(AnimatedShellPage))
        .toList();

    expect(
      shellPages().singleWhere((page) => page.pageIndex == 0).active,
      true,
    );
    expect(
      shellPages().singleWhere((page) => page.pageIndex == 3).active,
      false,
    );

    await tester.tap(find.byKey(const ValueKey('home-profile-avatar-button')));
    await tester.pumpAndSettle();

    expect(
      shellPages().singleWhere((page) => page.pageIndex == 0).active,
      false,
    );
    expect(
      shellPages().singleWhere((page) => page.pageIndex == 3).active,
      true,
    );
  });

  testWidgets('RetroTech app smoke test', (WidgetTester tester) async {
    await pumpRetroTech(tester);

    expect(find.text('Log In'), findsOneWidget);
  });

  testWidgets('launch test notification appears after one minute', (
    WidgetTester tester,
  ) async {
    final notifications = FakeLocalNotificationService();
    await pumpRetroTech(tester, notificationService: notifications);

    await tester.pump(const Duration(minutes: 1));
    await tester.pump();

    expect(notifications.initialized, isTrue);
    expect(notifications.launchTestCount, 1);
    expect(
      find.text('Test notification: RetroTech alerts are working.'),
      findsNothing,
    );
  });

  testWidgets('social auth buttons start demo sessions', (
    WidgetTester tester,
  ) async {
    final cases = <String, DemoAuthProvider>{
      'Continue with Google': DemoAuthProvider.google,
      'Continue with Apple': DemoAuthProvider.apple,
      'Continue with Facebook': DemoAuthProvider.facebook,
    };

    for (final entry in cases.entries) {
      final store = testStore();
      await pumpRetroTech(tester, store: store);

      await tester.tap(find.bySemanticsLabel(entry.key));
      await tester.pumpAndSettle();

      expect(store.demoAuthProvider, entry.value);
      expect(store.profile.displayName, entry.value.profile.displayName);
      expect(
        find.text('Buy, sell, and collect authentic\nY2K electronics.'),
        findsOneWidget,
      );
    }

    await pumpRetroTech(tester);

    await tester.tap(find.byKey(const ValueKey('forgot-password-link')));
    await tester.pumpAndSettle();
    expect(find.text('Reset Local Password'), findsOneWidget);
    expect(
      find.textContaining('default account stays ABC / 123'),
      findsOneWidget,
    );
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: RegistrationScreen(store: testStore()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('terms-policy-link')));
    await tester.pumpAndSettle();
    expect(find.text('Terms & Privacy Policy'), findsWidgets);
    expect(find.textContaining('local coursework demo'), findsOneWidget);
  });

  testWidgets(
    'local auth validates default account and rejects wrong password',
    (WidgetTester tester) async {
      final store = testStore();
      await pumpRetroTech(tester, store: store);

      await tester.enterText(
        find.widgetWithText(TextField, 'Username or Email'),
        'ABC',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'wrong',
      );
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();
      expect(find.text('Invalid username or password.'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Password'), '123');
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();
      expect(store.demoAuthProvider, DemoAuthProvider.local);
      expect(store.profile.displayName, 'ABC');
      expect(
        find.text('Buy, sell, and collect authentic\nY2K electronics.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'registration creates local account and password reset updates it',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final store = testStore();
      await store.load();
      setPhoneSize(tester);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          routes: {'/main': (_) => MainShell(store: store)},
          home: RegistrationScreen(store: store),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Full Name'),
        'Local Buyer',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Email Address'),
        'buyer@local.demo',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'old123',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Confirm Password'),
        'old123',
      );
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(store.demoAuthProvider, DemoAuthProvider.local);
      expect(store.profile.displayName, 'Local Buyer');

      final reset = await store.resetLocalPassword(
        identifier: 'buyer@local.demo',
        newPassword: 'new123',
      );
      expect(reset, isTrue);
      expect(
        await store.signInWithLocalAccount(
          identifier: 'buyer@local.demo',
          password: 'new123',
        ),
        isTrue,
      );
    },
  );

  testWidgets('home segments switch between market and community', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = testStore();
    await store.load();
    await store.toggleFollow('PalmPilotFan');
    await pumpRetroTech(tester, store: store);
    await logIn(tester);

    expect(find.textContaining('Buy, sell'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-search-button')), findsOneWidget);

    await tester.tap(find.text('Community'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Collectors, restorers, and transparent tech fans share finds here.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('home-search-button')), findsNothing);
    expect(find.text('For you'), findsWidgets);
    expect(find.text('Following'), findsNothing);
    await tester.ensureVisible(
      find.byKey(const ValueKey('community-card-like-PalmPilotFan')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('community-card-like-PalmPilotFan')),
    );
    await tester.pumpAndSettle();
    expect(find.text('19'), findsOneWidget);
    expect(find.text('Reply to PalmPilotFan'), findsNothing);

    await tester.ensureVisible(
      find.byKey(const ValueKey('community-card-reply-VintageAudioCo')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('community-card-reply-VintageAudioCo')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reply to VintageAudioCo'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('community-send-reply')));
    await tester.pumpAndSettle();
    expect(find.text('Write a reply first.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Copy post'), findsOneWidget);
    await tester.tap(find.text('Copy post'));
    await tester.pumpAndSettle();
    expect(find.text('Post copied to clipboard.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('community-post-like')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(find.text('25'), findsOneWidget);

    const firstReplyKey =
        'RetroTech Collector|@retrotech|12m|That makes the bundle much more complete.';
    await tester.tap(
      find.byKey(const ValueKey('community-reply-reply-$firstReplyKey')),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(TextField),
        matching: find.textContaining('@retrotech'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('community-reply-like-$firstReplyKey')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Reply liked.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Can you share photos?');
    await tester.tap(find.byKey(const ValueKey('community-send-reply')));
    await tester.pumpAndSettle();
    expect(find.text('Can you share photos?'), findsOneWidget);
    expect(find.text('Now'), findsOneWidget);

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 900));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Market'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-search-button')), findsOneWidget);
  });

  testWidgets('home search opens category product search', (
    WidgetTester tester,
  ) async {
    await pumpRetroTech(tester);
    await logIn(tester);

    expect(find.byKey(const ValueKey('category-search-field')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-search-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('category-search-field')), findsOneWidget);
    expect(tester.testTextInput.isVisible, isTrue);

    await tester.enterText(
      find.byKey(const ValueKey('category-search-field')),
      'gb',
    );
    await tester.pumpAndSettle();

    final categoriesScreen = find.byType(CategoriesScreen);
    expect(
      find.descendant(of: categoriesScreen, matching: find.text('RM 899.00')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: categoriesScreen, matching: find.text('RM 1599.00')),
      findsNothing,
    );
    expect(
      find.descendant(of: categoriesScreen, matching: find.text('Phones')),
      findsNothing,
    );
  });

  testWidgets('category search expands and filters all products', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = testStore();
    await store.load();
    setPhoneSize(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: GlassScaffold(child: CategoriesScreen(store: store)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('category-search-field')), findsNothing);
    expect(find.text('Phones'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('category-search-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('category-search-field')), findsOneWidget);
    expect(tester.testTextInput.isVisible, isTrue);

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Filter Categories'), findsOneWidget);
    await tester.tap(find.text('Gaming').last);
    await tester.pumpAndSettle();
    expect(find.text('RM 899.00'), findsOneWidget);
    expect(find.text('Phones'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('category-search-field')),
      'disc',
    );
    await tester.pumpAndSettle();
    expect(find.text('RM 999.00'), findsOneWidget);
    expect(find.text('RM 1599.00'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('category-search-field')),
      '',
    );
    await tester.pumpAndSettle();
    expect(find.text('Phones'), findsOneWidget);
    expect(find.text('Audio'), findsOneWidget);
    expect(find.text('RM 999.00'), findsNothing);
  });

  testWidgets('category cards show real listing counts', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = testStore();
    await store.load();
    setPhoneSize(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: GlassScaffold(child: CategoriesScreen(store: store)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2 items'), findsOneWidget);
    expect(find.text('4 items'), findsOneWidget);
    expect(find.text('84 items'), findsNothing);

    final wearablesCard = find.byKey(const ValueKey('category-card-Wearables'));
    expect(
      find.descendant(of: wearablesCard, matching: find.text('1 item')),
      findsOneWidget,
    );

    await store.add(
      seedListings.first.copyWith(
        id: 'clear-watch-test',
        title: 'Clear Watch',
        subtitle: 'Digital',
        category: 'Wearables',
        imageAsset: Assets.watch,
      ),
    );
    await tester.pump();

    expect(
      find.descendant(of: wearablesCard, matching: find.text('2 items')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: wearablesCard, matching: find.text('0 items')),
      findsNothing,
    );
  });

  testWidgets('FAQ card expands on tap', (WidgetTester tester) async {
    setPhoneSize(tester);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.theme, home: const HelpSupportScreen()),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Message sellers securely from any product page.'),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('faq-image-${Assets.helpOrders}')),
      findsNothing,
    );

    await tester.tap(find.text('How do I contact a seller?'));
    await tester.pumpAndSettle();

    expect(
      find.text('Message sellers securely from any product page.'),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('faq-card-How do I contact a seller?')),
        matching: find.byKey(const ValueKey('faq-image-${Assets.helpOrders}')),
      ),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('help-search-field')),
      'receipt',
    );
    await tester.pumpAndSettle();
    expect(find.text('Where can I find my order receipt?'), findsOneWidget);
  });

  testWidgets('chat input sends local message', (WidgetTester tester) async {
    setPhoneSize(tester);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.theme, home: const ChatThreadScreen()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('chat-message-field')),
      'Can you send more photos?',
    );
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Can you send more photos?'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('chat-product-card-buy-now')),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Conversation details'), findsOneWidget);
  });

  testWidgets('chat sends to store and updates inbox preview', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = testStore();
    await store.load();
    setPhoneSize(tester);
    final walkman = seedListings.firstWhere((item) => item.id == 'walkman');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: ChatThreadScreen(store: store, listing: walkman),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('chat-message-field')),
      'I can pick it up tomorrow.',
    );
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    final conversationId = ListingStore.conversationIdFor(
      listing: walkman,
      sellerName: walkman.seller,
    );
    expect(
      store.latestChatMessageFor(conversationId)?.text,
      'I can pick it up tomorrow.',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: InboxScreen(store: store),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('I can pick it up tomorrow.'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: ChatThreadScreen(store: store, listing: walkman),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    expect(find.text('Reported Locally'), findsOneWidget);
    await tester.tap(find.text('Block Seller'));
    await tester.pumpAndSettle();
    expect(find.text('Unblock Seller'), findsOneWidget);
  });

  testWidgets('favorite button toggles selected state', (
    WidgetTester tester,
  ) async {
    setPhoneSize(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: detailScreenForTest(seedListings.first),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite_rounded), findsNothing);

    await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.ios_share_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Product details copied to clipboard.'), findsOneWidget);
  });

  testWidgets('profile changes sync into account and settings screens', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = testStore();
    await store.load();
    setPhoneSize(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: AccountProfileScreen(store: store),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Retro Tech'), findsOneWidget);

    await store.saveProfile(
      const UserProfile(
        displayName: 'Walter Collector',
        username: '@walter',
        email: 'walter@example.com',
        bio: 'Restores rare devices.',
        location: 'Kuala Lumpur',
        sellerName: 'Walter Shop',
        preferredContact: 'In-app message',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Walter Collector'), findsOneWidget);
    expect(find.text('@walter'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: SettingsScreen(store: store),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Walter Collector'), findsOneWidget);
    expect(find.text('Language'), findsNothing);
    expect(find.text('Currency'), findsNothing);
    expect(find.text('Theme'), findsNothing);
  });

  testWidgets('listing form validates required fields before publishing', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = testStore();
    setPhoneSize(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: ListingFormScreen(store: store),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.more_horiz_rounded), findsNothing);

    await tester.tap(find.text('Publish Listing'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a product title.'), findsOneWidget);
    expect(find.text('Enter a price.'), findsOneWidget);
    expect(store.listings, isEmpty);
  });

  testWidgets('listing form rejects invalid price and preserves input', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = testStore();
    setPhoneSize(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: ListingFormScreen(store: store),
      ),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Game Boy Pocket');
    await tester.enterText(fields.at(1), 'abc');
    await tester.tap(find.text('Publish Listing'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid number.'), findsOneWidget);
    expect(find.text('Game Boy Pocket'), findsOneWidget);
    expect(store.listings, isEmpty);
  });

  testWidgets('valid listing form creates a published listing', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = testStore();
    setPhoneSize(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: ListingFormScreen(store: store),
      ),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Game Boy Pocket');
    await tester.enterText(fields.at(1), '429.50');
    final dropdowns = find.byType(DropdownButtonFormField<String>);
    await tester.tap(dropdowns.at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gaming').last);
    await tester.pumpAndSettle();
    await tester.tap(dropdowns.at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Used - Good').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Publish Listing'));
    await tester.pumpAndSettle();

    expect(store.listings, hasLength(1));
    expect(store.listings.first.title, 'Game Boy Pocket');
    expect(store.listings.first.category, 'Gaming');
    expect(store.listings.first.price, 429.50);
    expect(store.listings.first.condition, 'Used - Good');
    expect(store.listings.first.status, 'Published');
  });

  testWidgets('edit profile validates email before saving', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = testStore();
    setPhoneSize(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: EditProfileScreen(store: store),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(2), 'not-an-email');
    await tester.tap(find.text('Save Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(store.profile.email, UserProfile.defaults.email);
  });

  testWidgets('delete listing waits for explicit confirmation', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = testStore();
    await store.load();
    final listing = store.listings.firstWhere(
      (item) => item.status != 'Draft' && item.status != 'Sold',
    );
    setPhoneSize(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: MyListingsScreen(store: store),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Delete Listing?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(store.byId(listing.id), isNotNull);

    await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(store.byId(listing.id), isNull);
  });

  testWidgets('payment selection updates checkout and orders can be tracked', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = testStore();
    await store.load();
    setPhoneSize(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: PaymentMethodsScreen(store: store),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey('payment-logo-visa')), findsOneWidget);
    expect(find.byKey(ValueKey('payment-logo-apple-pay')), findsOneWidget);
    expect(find.byKey(ValueKey('payment-logo-tng')), findsOneWidget);
    expect(find.byKey(ValueKey('payment-logo-bank')), findsOneWidget);
    expect(find.text('VISA'), findsNothing);
    expect(find.text('Pay'), findsNothing);
    expect(find.text('TnG'), findsNothing);
    expect(find.text('Bank'), findsNothing);

    await tester.tap(find.text('Apple Pay'));
    await tester.pumpAndSettle();
    expect(store.selectedPaymentMethod?.title, 'Apple Pay');
    expect(find.text('Confirm with device passcode'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await store.saveDeliveryAddress(
      const DeliveryAddress(
        recipient: 'Guest Buyer',
        phone: '+60 12-345 6789',
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
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        onGenerateRoute: (settings) {
          if (settings.name == '/order-confirmed') {
            return MaterialPageRoute<void>(
              builder: (_) => OrderConfirmationScreen(
                store: store,
                order: settings.arguments as OrderRecord?,
              ),
              settings: settings,
            );
          }
          if (settings.name == '/order-detail') {
            return MaterialPageRoute<void>(
              builder: (_) => OrderDetailScreen(
                store: store,
                order: settings.arguments as OrderRecord?,
              ),
              settings: settings,
            );
          }
          return null;
        },
        home: CheckoutScreen(store: store, listing: seedListings.first),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Apple Pay'), findsOneWidget);
    expect(find.text('Buyer Protection'), findsNothing);
    expect(find.text('Protection Fee'), findsNothing);

    await tester.tap(find.text('Place Order'));
    await tester.pumpAndSettle();
    expect(store.orders, hasLength(1));
    expect(store.orders.single.total, seedListings.first.price + 35);
    expect(find.text('Order Confirmed'), findsOneWidget);
    expect(
      find.text('Order placed with selected payment method.'),
      findsOneWidget,
    );
    expect(find.text('Receipt Summary'), findsNothing);
    expect(find.text('Order #${store.orders.single.id}'), findsOneWidget);
    expect(find.text('Next Steps'), findsNothing);
    expect(find.text('Preparing Shipment'), findsNothing);
    expect(find.textContaining('Apple Pay'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Track Order'),
      90,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Track Order'));
    await tester.pumpAndSettle();
    expect(find.text('Order Detail'), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz_rounded), findsNothing);
    expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
  });

  testWidgets('order screens hide unused overflow actions', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = testStore();
    await store.load();
    await store.saveDeliveryAddress(
      const DeliveryAddress(
        recipient: 'Guest Buyer',
        phone: '+60 12 345 6789',
        line1: 'KLCC, Jalan Ampang',
        line2: '',
        city: 'Kuala Lumpur',
        state: 'Kuala Lumpur',
        postcode: '50450',
        country: 'Malaysia',
        note: '',
        latitude: null,
        longitude: null,
        accuracyMeters: null,
      ),
    );
    await store.selectPaymentMethod('visa');
    final order = await store.createOrder(seedListings.first);
    setPhoneSize(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: OrdersScreen(store: store),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Orders'), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz_rounded), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: OrderDetailScreen(store: store, order: order),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Order Detail'), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz_rounded), findsNothing);
  });

  testWidgets('delivery address form saves checkout address', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = testStore();
    await store.load();
    setPhoneSize(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: DeliveryAddressScreen(store: store),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Use current'), findsOneWidget);
    expect(find.text('No delivery address selected'), findsOneWidget);
    expect(find.text('KLCC, Jalan Ampang'), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Recipient name'),
      'Guest Buyer',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Street address or building name'),
      'Kuala Lumpur City Centre',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, '50480'),
      '50088',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Kuala Lumpur'),
      'Kuala Lumpur',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Malaysia'),
      'Malaysia',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Address'));
    await tester.pumpAndSettle();

    expect(store.selectedDeliveryAddress.recipient, 'Guest Buyer');
    expect(store.selectedDeliveryAddress.line1, 'Kuala Lumpur City Centre');
    expect(store.selectedDeliveryAddress.postcode, '50088');
  });

  testWidgets('legacy seed delivery address loads as empty address', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'delivery_address': const DeliveryAddress(
        recipient: 'Legacy Buyer',
        phone: '+60 12-345 6789',
        line1: 'Legacy Street',
        line2: '',
        city: 'Kuala Lumpur',
        state: 'Wilayah Persekutuan',
        postcode: '50480',
        country: 'Malaysia',
        note: 'Leave with reception if unavailable.',
        latitude: 3.1579,
        longitude: 101.7116,
        accuracyMeters: null,
      ).encode(),
    });
    final store = testStore();
    await store.load();

    expect(store.selectedDeliveryAddress.isEmpty, isTrue);
    expect(
      store.selectedDeliveryAddress.checkoutSummary,
      'No delivery address selected',
    );
  });

  testWidgets('profile dashboard opens delivery address management', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = testStore();
    await store.load();
    setPhoneSize(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: AccountProfileScreen(store: store),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delivery Address'));
    await tester.pumpAndSettle();

    expect(find.text('Save Address'), findsOneWidget);
  });

  testWidgets('product detail buy now opens checkout before creating order', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = testStore();
    await store.load();
    setPhoneSize(tester);
    final ipod = seedListings.firstWhere((item) => item.id == 'ipod-classic');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        onGenerateRoute: (settings) {
          if (settings.name == '/checkout') {
            return MaterialPageRoute<void>(
              builder: (_) => CheckoutScreen(
                store: store,
                listing: settings.arguments as Listing?,
              ),
              settings: settings,
            );
          }
          if (settings.name == '/order-confirmed') {
            return MaterialPageRoute<void>(
              builder: (_) => OrderConfirmationScreen(
                store: store,
                order: settings.arguments as OrderRecord?,
              ),
              settings: settings,
            );
          }
          return null;
        },
        home: ProductDetailScreen(
          store: store,
          listing: ipod,
          videoPlayerBuilder: (_) => FakeMultimediaPlayer(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('product-detail-buy-now')));
    await tester.pumpAndSettle();

    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text(ipod.shortTitle), findsOneWidget);
    expect(store.orders, isEmpty);

    await tester.tap(find.text('Place Order'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Add a delivery address and choose a payment method before placing the order.',
      ),
      findsOneWidget,
    );
    expect(store.orders, isEmpty);
  });

  testWidgets('product detail seller chat icon opens listing chat', (
    WidgetTester tester,
  ) async {
    final store = testStore();
    setPhoneSize(tester);
    final ipod = seedListings.firstWhere((item) => item.id == 'ipod-classic');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        onGenerateRoute: (settings) {
          if (settings.name == '/chat') {
            return MaterialPageRoute<void>(
              builder: (_) =>
                  ChatThreadScreen(listing: settings.arguments as Listing?),
              settings: settings,
            );
          }
          return null;
        },
        home: ProductDetailScreen(
          store: store,
          listing: ipod,
          videoPlayerBuilder: (_) => FakeMultimediaPlayer(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final contactButton = find.byKey(
      const ValueKey('product-detail-contact-seller'),
    );
    await tester.ensureVisible(contactButton);
    await tester.pumpAndSettle();
    await tester.tap(contactButton);
    await tester.pumpAndSettle();

    expect(find.text(ipod.seller), findsOneWidget);
    expect(
      find.text('Hi! Thanks for your interest in the ${ipod.title}.'),
      findsOneWidget,
    );
  });

  testWidgets('chat product card buy now opens checkout for that listing', (
    WidgetTester tester,
  ) async {
    final store = testStore();
    setPhoneSize(tester);
    final walkman = seedListings.firstWhere((item) => item.id == 'walkman');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        onGenerateRoute: (settings) {
          if (settings.name == '/checkout') {
            return MaterialPageRoute<void>(
              builder: (_) => CheckoutScreen(
                store: store,
                listing: settings.arguments as Listing?,
              ),
              settings: settings,
            );
          }
          return null;
        },
        home: ChatThreadScreen(listing: walkman),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('chat-product-card-buy-now')));
    await tester.pumpAndSettle();

    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text(walkman.shortTitle), findsOneWidget);
    expect(find.text(walkman.priceLabel), findsWidgets);
    expect(store.orders, isEmpty);
  });

  testWidgets('profile saved items and seller follow use store state', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = testStore();
    await store.load();
    setPhoneSize(tester);

    await store.toggleSaved('ipod-classic');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: AccountProfileScreen(store: store),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Saved Items'), findsOneWidget);
    expect(find.text('Delivery Address'), findsOneWidget);
    expect(find.text('Recent Activity'), findsNothing);
    expect(store.savedListings, hasLength(1));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: SavedItemsScreen(store: store),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Saved Items'), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz_rounded), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: SellerProfileScreen(store: store, sellerName: 'VintageAudioCo'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Follow'), findsOneWidget);
    await tester.tap(find.text('Follow'));
    await tester.pumpAndSettle();
    expect(find.text('Following'), findsOneWidget);
    expect(store.isFollowing('VintageAudioCo'), isTrue);

    await tester.tap(find.byIcon(Icons.ios_share_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Seller profile copied to clipboard.'), findsOneWidget);
  });

  testWidgets('my listings, inbox, and help results show expected content', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = testStore();
    await store.load();
    setPhoneSize(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: MyListingsScreen(store: store),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.delete_outline_rounded), findsWidgets);
    expect(find.byIcon(Icons.filter_alt_outlined), findsNothing);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.theme, home: const InboxScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.text('VintageAudioCo'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Search Inbox'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('inbox-search-sheet-field')),
      'Support',
    );
    await tester.tap(find.text('Apply Search'));
    await tester.pumpAndSettle();
    expect(find.text('No conversations found.'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.tune_rounded), findsNothing);
    expect(find.text('Filter Inbox'), findsNothing);
    await tester.tap(find.text('Support'));
    await tester.pumpAndSettle();
    expect(find.text('RetroTech Support'), findsOneWidget);
    expect(find.text('VintageAudioCo'), findsNothing);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.theme, home: const InboxScreen()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();
    expect(find.text('RetroTech Orders'), findsOneWidget);
    expect(find.text('VintageAudioCo'), findsNothing);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.theme, home: const HelpSupportScreen()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.headset_mic_outlined));
    await tester.pumpAndSettle();
    expect(find.text('RetroTech Support'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Payments'));
    await tester.pumpAndSettle();
    expect(find.text('How are payments protected?'), findsOneWidget);
    expect(find.text('What is Buyer Protection?'), findsOneWidget);
    await tester.tap(find.text('Safety'));
    await tester.pumpAndSettle();
    expect(find.text('How do I report a fake item?'), findsOneWidget);
    expect(find.text('How do I keep a purchase safe?'), findsOneWidget);
    await tester.tap(find.text('Payments'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('help-search-field')),
      'fake',
    );
    await tester.pumpAndSettle();
    expect(find.text('No help topics found.'), findsOneWidget);
  });

  testWidgets('category detail price filter changes visible products', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = testStore();
    await store.load();
    setPhoneSize(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: CategoryDetailScreen(store: store, category: 'Audio'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('RM 1599.00'), findsWidgets);
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Filter Audio'), findsOneWidget);
    await tester.tap(find.text('Under RM1000').last);
    await tester.pumpAndSettle();
    expect(find.text('RM 1599.00'), findsNothing);
    expect(find.text('RM 999.00'), findsWidgets);
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All').last);
    await tester.pumpAndSettle();
    expect(find.text('RM 1599.00'), findsWidgets);
    await tester.tap(find.text('Under RM1000'));
    await tester.pumpAndSettle();
    expect(find.text('RM 1599.00'), findsNothing);
    expect(find.text('RM 999.00'), findsWidgets);
  });

  testWidgets('product detail gallery swipes and dots select images', (
    WidgetTester tester,
  ) async {
    setPhoneSize(tester);
    final ipod = seedListings.firstWhere((item) => item.id == 'ipod-classic');
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.theme, home: detailScreenForTest(ipod)),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('product-gallery-page-view')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('product-gallery-dot-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('product-gallery-dot-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('product-gallery-dot-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('product-gallery-dot-3')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('product-detail-contact-seller')),
      findsOneWidget,
    );
    expect(find.text('Buy Now'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('product-gallery-dot-0'))).width,
      20,
    );

    await tester.drag(
      find.byKey(const ValueKey('product-gallery-page-view')),
      const Offset(-320, 0),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byKey(const ValueKey('product-gallery-dot-1'))).width,
      20,
    );

    await tester.tap(find.byKey(const ValueKey('product-gallery-dot-2')));
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byKey(const ValueKey('product-gallery-dot-2'))).width,
      20,
    );
  });

  testWidgets('product detail starts gallery with playable product video', (
    WidgetTester tester,
  ) async {
    setPhoneSize(tester);
    final player = FakeMultimediaPlayer();
    final ipod = seedListings.firstWhere((item) => item.id == 'ipod-classic');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: ProductDetailScreen(
          store: testStore(),
          listing: ipod,
          videoPlayerBuilder: (_) => player,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('product-gallery-video-toggle')),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('product-gallery-dot-0'))).width,
      20,
    );

    await tester.tap(
      find.byKey(const ValueKey('product-gallery-video-toggle')),
    );
    await tester.pumpAndSettle();
    expect(player.isPlaying, isTrue);

    await tester.tap(
      find.byKey(const ValueKey('product-gallery-video-sound-toggle')),
    );
    await tester.pumpAndSettle();
    expect(player.isMuted, isTrue);
    expect(player.isPlaying, isTrue);

    await tester.tap(
      find.byKey(const ValueKey('product-gallery-video-sound-toggle')),
    );
    await tester.pumpAndSettle();
    expect(player.isMuted, isFalse);
    expect(player.isPlaying, isTrue);

    await tester.tap(
      find.byKey(const ValueKey('product-gallery-video-toggle')),
    );
    await tester.pumpAndSettle();
    expect(player.isPlaying, isFalse);
  });

  testWidgets('key screens fit common phone widths', (
    WidgetTester tester,
  ) async {
    for (final size in const [Size(320, 740), Size(390, 844), Size(430, 932)]) {
      setPhoneSize(tester, size);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: GlassScaffold(child: CategoriesScreen(store: testStore())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('category-search-field')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('category-search-button')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('category-search-field')),
        findsOneWidget,
      );

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.theme, home: const AboutScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.text('ABOUT RETROTECH'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: ProductDetailScreen(
            store: testStore(),
            listing: seedListings.first,
            videoPlayerBuilder: (_) => FakeMultimediaPlayer(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('product-detail-contact-seller')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('product-detail-buy-now')),
        findsOneWidget,
      );
    }
  });

  testWidgets('about page actions open visible feedback', (
    WidgetTester tester,
  ) async {
    setPhoneSize(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        onGenerateRoute: (settings) {
          if (settings.name == '/category') {
            return MaterialPageRoute<void>(
              builder: (_) => CategoryDetailScreen(
                store: testStore(),
                category: settings.arguments as String? ?? 'Phones',
              ),
              settings: settings,
            );
          }
          return null;
        },
        home: const AboutScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byIcon(Icons.ios_share_rounded));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('About RetroTech copied to clipboard.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_forward_rounded).first);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Our mission'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 350));

    await tester.scrollUntilVisible(find.text('Trust & Safety'), 250);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('Trust & Safety'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.textContaining('seller reputation'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 350));

    await tester.scrollUntilVisible(find.text('Transparent Tech Drop'), 250);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('Transparent Tech Drop'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.textContaining('clear-shell phones'), findsOneWidget);
  });
}

ListingStore testStore({FakeListingRepository? repository}) {
  return ListingStore(repository: repository ?? FakeListingRepository());
}

class FakeListingRepository extends ListingRepository {
  FakeListingRepository({List<Listing>? listings})
    : _listings = [...(listings ?? seedListings)];

  final List<Listing> _listings;
  final Set<String> _savedItemIds = {};
  final List<OrderRecord> _orders = [];
  final Set<String> _followedSellers = {};
  final List<ChatMessage> _chatMessages = [];
  final Map<String, ChatConversationState> _chatStates = {};
  final Set<String> _likedCommunityPostIds = {};
  final List<CommunityReplyRecord> _communityReplies = [];
  final Set<String> _likedCommunityReplyIds = {};
  UserProfile _profile = UserProfile.defaults;

  @override
  Future<List<Listing>> load() async => List<Listing>.of(_listings);

  @override
  Future<void> add(Listing listing) async {
    _listings.insert(0, listing);
  }

  @override
  Future<void> update(Listing listing) async {
    final index = _listings.indexWhere((item) => item.id == listing.id);
    if (index != -1) _listings[index] = listing;
  }

  @override
  Future<void> delete(String id) async {
    _listings.removeWhere((listing) => listing.id == id);
    _savedItemIds.remove(id);
  }

  @override
  Future<UserProfile> loadProfile() async => _profile;

  @override
  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
  }

  @override
  Future<Set<String>> loadSavedItemIds() async => Set<String>.of(_savedItemIds);

  @override
  Future<void> setSaved(String listingId, bool saved) async {
    if (saved) {
      _savedItemIds.add(listingId);
    } else {
      _savedItemIds.remove(listingId);
    }
  }

  @override
  Future<List<OrderRecord>> loadOrders() async => List<OrderRecord>.of(_orders);

  @override
  Future<void> addOrder(OrderRecord order) async {
    _orders.insert(0, order);
  }

  @override
  Future<Set<String>> loadFollowedSellers() async {
    return Set<String>.of(_followedSellers);
  }

  @override
  Future<void> setFollowing(String seller, bool following) async {
    if (following) {
      _followedSellers.add(seller);
    } else {
      _followedSellers.remove(seller);
    }
  }

  @override
  Future<List<ChatMessage>> loadChatMessages() async {
    return List<ChatMessage>.of(_chatMessages);
  }

  @override
  Future<void> addChatMessage(ChatMessage message) async {
    _chatMessages.add(message);
  }

  @override
  Future<List<ChatConversationState>> loadChatConversationStates() async {
    return List<ChatConversationState>.of(_chatStates.values);
  }

  @override
  Future<void> saveChatConversationState(ChatConversationState state) async {
    _chatStates[state.conversationId] = state;
  }

  @override
  Future<Set<String>> loadCommunityPostLikeIds() async {
    return Set<String>.of(_likedCommunityPostIds);
  }

  @override
  Future<void> setCommunityPostLiked(String postId, bool liked) async {
    if (liked) {
      _likedCommunityPostIds.add(postId);
    } else {
      _likedCommunityPostIds.remove(postId);
    }
  }

  @override
  Future<List<CommunityReplyRecord>> loadCommunityReplies() async {
    return List<CommunityReplyRecord>.of(_communityReplies);
  }

  @override
  Future<void> addCommunityReply(CommunityReplyRecord reply) async {
    _communityReplies.insert(0, reply);
  }

  @override
  Future<Set<String>> loadCommunityReplyLikeIds() async {
    return Set<String>.of(_likedCommunityReplyIds);
  }

  @override
  Future<void> setCommunityReplyLiked(String replyId, bool liked) async {
    if (liked) {
      _likedCommunityReplyIds.add(replyId);
    } else {
      _likedCommunityReplyIds.remove(replyId);
    }
  }
}

class FakeLocalNotificationService extends LocalNotificationService {
  bool initialized = false;
  int launchTestCount = 0;

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<void> showLaunchTestNotification() async {
    launchTestCount += 1;
  }
}

class FakeMultimediaPlayer implements MultimediaPlayer {
  bool _initialized = false;
  bool _playing = false;
  bool _muted = false;
  bool _disposed = false;

  @override
  Future<void> initialize() async {
    _initialized = true;
  }

  @override
  Future<void> play() async {
    _playing = true;
  }

  @override
  Future<void> pause() async {
    _playing = false;
  }

  @override
  Future<void> setMuted(bool muted) async {
    _muted = muted;
  }

  @override
  Widget buildView() {
    return const ColoredBox(
      key: ValueKey('fake-multimedia-video'),
      color: Colors.black,
    );
  }

  @override
  void dispose() {
    _disposed = true;
  }

  @override
  bool get isInitialized => _initialized && !_disposed;

  @override
  bool get isPlaying => _playing;

  @override
  bool get isMuted => _muted;

  @override
  double get aspectRatio => 16 / 9;
}
