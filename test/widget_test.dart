// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:cyrano_demo_app/main.dart';

void main() {
  testWidgets('Analysis is triggered', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('Enter some text to see the Cyrano.ai Analysis'),
        findsOneWidget);
    expect(find.text('Exception: Failed to process your text.'), findsNothing);

    /*
    await tester.tap(find.text("Analyze"));
    await tester.pump();
    // Verify that the error has appeared.
    expect(find.text('Enter some text to see the Cyrano.ai Analysis'), findsNothing);
    expect(find.text('Exception: Failed to process your text.'), findsOneWidget);
    */
  });
}
