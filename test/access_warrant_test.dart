import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:access_warrant/access_warrant.dart';

import 'utils.dart';

void main() {
  testWidgets('Shows wrongBuilder widget if access check failed',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AccessWarrant(
          wrongBuilder: (_) => Text('Authorization failed!'),
          check: () => false,
        ),
      ),
    );

    final textFinder = find.text('Authorization failed!');

    expect(textFinder, findsOneWidget);
  });

  testWidgets('Shows validBuilder widget if access check passed',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AccessWarrant(
          validBuilder: (_) => Text('Authorization succeeded!'),
          check: () => true,
        ),
      ),
    );

    final textFinder = find.text('Authorization succeeded!');

    expect(textFinder, findsOneWidget);
  });

  testWidgets(
      'Shows an empty Container if widget for certain access state is absent',
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

  testWidgets('Navigates to validBuilder widget after access is granted',
      (WidgetTester tester) async {
    final observer = NavigatorObserverMock();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return AccessWarrant(
              wrongBuilder: (context) => RaisedButton(
                onPressed: () => AccessWarrant.grantAccess(context),
              ),
              validBuilder: (_) => Text('Navigation successful!'),
              check: () => false,
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

  // TODO: skipNavigation - rebuild AccessWarrant instead of navigating to
  // AccessWarrant.validBuilder when access approved

  // TODO: clearHistory - clear the previous navigation history when access approved

  // TODO: copyWith - copy this AccessWarrant with some new parameters
}
