import 'package:flutter/material.dart';

/// This class mocks [NavigatorObserver] to record interactions with navigation stack
/// for testing purposes.
///
/// Add it to `navigatorObservers` in your test suite, excercise you test and refer to
/// the `history` field to verify expectations against the current navigation stack.
// TODO: move to a separate package and use it for all tests utilizing the Navigator widget
class NavigatorObserverMock extends NavigatorObserver {
  /// History of routes recorded by this instance of observer.
  final history = <List<Route>>[];

  @override
  void didReplace({Route newRoute, Route oldRoute}) {
    history.add([oldRoute, newRoute]);
  }
}
