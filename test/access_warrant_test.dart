import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:access_warrant/access_warrant.dart';

import 'utils.dart';

void main() {
  testWidgets('Shows wrongBuilder widget if warrant is wrong',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AccessWarrant(
          wrongBuilder: (_) => Text('Warrant check failed!'),
          check: () => false,
        ),
      ),
    );

    final textFinder = find.text('Warrant check failed!');

    expect(textFinder, findsOneWidget);
  });

  testWidgets('Shows validBuilder widget if warrant is valid',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AccessWarrant(
          validBuilder: (_) => Text('Warrant check succeeded!'),
          check: () => true,
        ),
      ),
    );

    final textFinder = find.text('Warrant check succeeded!');

    expect(textFinder, findsOneWidget);
  });

  testWidgets(
      'Shows an empty Container if widget for certain warrant state is absent',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AccessWarrant(
          key: ValueKey('warrant'),
          check: () => true,
        ),
      ),
    );

    final warrantFinder = find.byKey(ValueKey('warrant'));
    final containerFinder = find.descendant(
      of: warrantFinder,
      matching: find.byWidgetPredicate((Widget widget) =>
          widget is Container &&
          widget.child == null &&
          widget.decoration == null &&
          widget.constraints == null),
    );

    expect(warrantFinder, findsOneWidget);
    expect(containerFinder, findsOneWidget);
  });

  testWidgets('Rebuilds the route with the new state after access is granted',
      (WidgetTester tester) async {
    final observer = NavigatorObserverMock();
    bool warrantIsValid = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return AccessWarrant(
              wrongBuilder: (context) => RaisedButton(
                onPressed: () {
                  warrantIsValid = true;
                  AccessWarrant.grantAccess(context);
                },
              ),
              validBuilder: (_) => Text('Navigation successful!'),
              check: () => warrantIsValid,
            );
          },
        ),
        navigatorObservers: [observer],
      ),
    );

    final raisedButtonFinder = find.byType(RaisedButton);

    expect(raisedButtonFinder, findsOneWidget);
    expect(observer.history.length, equals(0));

    await tester.tap(raisedButtonFinder);

    expect(observer.history.length, equals(1));
    expect(
      observer.history.first[0].settings,
      predicate((RouteSettings oldSettings) {
        final newSettings = observer.history.first[1].settings;

        return oldSettings.name == newSettings.name &&
            oldSettings.arguments == newSettings.arguments;
      }),
    );

    await tester.pumpAndSettle();

    expect(find.text('Navigation successful!'), findsOneWidget);
  });

  // TODO: skipNavigation - rebuild AccessWarrant instead of doing Navigator.pushReplacement on warrant state change

  // TODO: clearHistory - clear the navigation history before the current route after the navigation

  // TODO: copyWith - copy this AccessWarrant with some new parameters
}
