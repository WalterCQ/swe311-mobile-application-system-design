import 'package:flutter_test/flutter_test.dart';
import 'package:retro_tech_marketplace/main.dart';

void main() {
  testWidgets('RetroTech app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(RetroTechApp(store: ListingStore()));
    await tester.pumpAndSettle();

    expect(find.text('Log In'), findsOneWidget);
  });
}
