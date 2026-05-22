import 'package:flutter_test/flutter_test.dart';
import 'package:traqa/main.dart';

void main() {
  testWidgets('Showcase screen loads and displays conceptual text', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TraqaApp());

    // Verify that our main title is found.
    expect(find.text('TRAQA'), findsOneWidget);

    // Verify that the showcase description subtitle is found.
    expect(find.text("Your family's health, in words you understand."), findsOneWidget);

    // Verify that the public repo info box is present.
    expect(find.text('Public Showcase Repository'), findsOneWidget);
  });
}
