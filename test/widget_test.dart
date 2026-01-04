import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartShopApp());

    // Check that SmartShop text appears on screen
    expect(find.text('SmartShop'), findsOneWidget);
  });
}
