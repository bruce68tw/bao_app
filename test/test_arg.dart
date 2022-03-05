import 'dart:developer';
import 'package:bao_app/all.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base_lib/all.dart';

void main() {

  test('TestArg', () async {
    await XpUt.initFunAsync(true);  //initial
    var data = {'Id':'id1', 'Str':'str1'};  //input data
    await HttpUt.getStrAsync(null, 'TestArg/T1', false, data, (msg)=> log(msg));
    await HttpUt.getStrAsync(null, 'TestArg/T2', true, data, (msg)=> log(msg));
    await HttpUt.getStrAsync(null, 'TestArg/T3', true, data, (msg)=> log(msg));
  });

  /*
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
  */
}
