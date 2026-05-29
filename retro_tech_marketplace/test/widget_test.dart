import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retro_tech_marketplace/main.dart';

void main() {
  void setPhoneSize(WidgetTester tester, [Size size = const Size(390, 844)]) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpRetroTech(WidgetTester tester) async {
    setPhoneSize(tester);
    await tester.pumpWidget(RetroTechApp(store: ListingStore()));
    await tester.pumpAndSettle();
  }

  Future<void> logIn(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Log In'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();
  }

  testWidgets('RetroTech app smoke test', (WidgetTester tester) async {
    await pumpRetroTech(tester);

    expect(find.text('Log In'), findsOneWidget);
  });

  testWidgets('home segments switch between market and community', (
    WidgetTester tester,
  ) async {
    await pumpRetroTech(tester);
    await logIn(tester);

    expect(find.textContaining('Buy, sell'), findsOneWidget);

    await tester.tap(find.text('Community'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Collectors, restorers, and transparent tech fans share finds here.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('category search filters visible categories', (
    WidgetTester tester,
  ) async {
    await pumpRetroTech(tester);
    await logIn(tester);

    await tester.tap(find.text('Categories').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('category-search-field')),
      'Gaming',
    );
    await tester.pumpAndSettle();

    expect(find.text('Gaming'), findsWidgets);
    expect(find.text('Phones'), findsNothing);
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

    await tester.tap(find.text('How do I contact a seller?'));
    await tester.pumpAndSettle();

    expect(
      find.text('Message sellers securely from any product page.'),
      findsOneWidget,
    );
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
  });

  testWidgets('favorite button toggles selected state', (
    WidgetTester tester,
  ) async {
    setPhoneSize(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: ProductDetailScreen(
          store: ListingStore(),
          listing: seedListings.first,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite_rounded), findsNothing);

    await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
  });

  testWidgets('key screens fit common phone widths', (
    WidgetTester tester,
  ) async {
    for (final size in const [Size(320, 740), Size(390, 844), Size(430, 932)]) {
      setPhoneSize(tester, size);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: GlassScaffold(child: CategoriesScreen(store: ListingStore())),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('category-search-field')),
        findsOneWidget,
      );

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.theme, home: const AboutScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.text('ABOUT US'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: ProductDetailScreen(
            store: ListingStore(),
            listing: seedListings.first,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Contact Seller'), findsOneWidget);
    }
  });
}
