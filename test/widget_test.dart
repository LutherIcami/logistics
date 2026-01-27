import 'package:flutter_test/flutter_test.dart';
import 'package:projo/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    // Verify that our app shows Home.
    expect(find.text('Home'), findsOneWidget);
  });
}
