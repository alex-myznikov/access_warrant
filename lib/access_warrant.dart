import 'package:flutter/material.dart';

/// This widget controls access to a certain part in a widgets tree.
///
/// Provide [check] callback to validate access rights to the [validBuilder].
/// Provide [wrongBuilder] to handle case if the validation has failed.
class AccessWarrant extends StatefulWidget {
  /// Checks access rights to a widget built by [validBuilder].
  ///
  /// Returns `true` if access is allowed and `false` otherwise.
  final bool Function() check;

  /// Builds content of a [AccessWarrant] in case access is granted.
  ///
  /// ```dart
  /// AccessWarrant(
  ///   validBuilder: (context) => Text('Restricted area'),
  /// )
  /// ```
  ///
  /// By default it will build an empty [Container].
  final WidgetBuilder validBuilder;

  /// Builds [AccessWarrant]'s content for case of restricted access.
  ///
  /// Usually serves to show an authentication widget. This widget can then handle authentication
  /// and authorization and notify the [AccessWarrant] to grant access to the restricted area like so:
  /// `AccessWarrant.grantAccess(context)`.
  ///
  /// By default it will build an empty [Container].
  final WidgetBuilder wrongBuilder;

  AccessWarrant({
    Key key,
    @required this.check,
    WidgetBuilder validBuilder,
    WidgetBuilder wrongBuilder,
  })  : validBuilder = validBuilder ?? ((_) => Container()),
        wrongBuilder = wrongBuilder ?? ((_) => Container()),
        super(key: key);

  /// Obtains the nearest [AccessWarrant] up its widget tree and updates it access state to 'allowed'.
  static void grantAccess(BuildContext context) {
    final _AccessWarrantState warrant =
        context.findAncestorStateOfType<_AccessWarrantState>();

    assert(
      warrant != null,
      '''
AccessWarrant requested with a context that does not include an AccessWarrant.

The context used to access the AccessWarrant must be that of a widget
that is a descendant of an AccessWarrant widget.
''',
    );

    warrant.grantAccess();
  }

  @override
  _AccessWarrantState createState() => _AccessWarrantState();
}

class _AccessWarrantState extends State<AccessWarrant> {
  /// Whether access to the restricted area is allowed or not.
  /// 
  /// In `null` then [AccessWarrant.check] must be executed to assign the value to this field.
  bool _accessAllowed;

  /// State of the closest [Navigator] instance up the widgets tree.
  NavigatorState _navigator;

  /// Current active route.
  ///
  /// Is used in case of navigation to the restricted area after access right is granted.
  /// See [grantAccess] for details.
  /// ().
  ModalRoute _activeRoute;

  @override
  Widget build(BuildContext context) {
    _navigator = Navigator.of(context);
    _activeRoute = ModalRoute.of(context);

    if (_accessAllowed == null) _accessAllowed = widget.check();

    return !_accessAllowed
        ? Builder(builder: widget.wrongBuilder)
        : Builder(builder: widget.validBuilder);
  }

  /// Updates the current access right state and handles it.
  ///
  /// Extracts route parameters from the current active route and then passes them to the replacement.
  /// The new route's widget tree will have no [AccessWarrant] widget in it. Instead only the result of
  /// calling [AccessWarrant.validBuilder] on that warrant will be attached.
  Future<void> grantAccess() async {
    if (_accessAllowed) return;

    _accessAllowed = true;
    await _navigator.pushReplacement(
      MaterialPageRoute(
        builder: widget.validBuilder,
        settings: _activeRoute.settings.copyWith(isInitialRoute: false),
        maintainState: _activeRoute.maintainState,
      ),
    );
  }
}

