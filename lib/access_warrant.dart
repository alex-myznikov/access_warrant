import 'package:flutter/material.dart';

/// This widget provides a way to control access to a specific widget subtree
/// with a conception called hereinafter “warrant check”.
///
/// Provide a [validBuilder] to build a view of restricted access.
/// Provide a [check] callback to verify access rights to the [validBuilder] result.
/// Provide a [wrongBuilder] to build a view for case if warrant check has failed.
class AccessWarrant extends StatefulWidget {
  /// Checks warrant for the widget subtree built by [valid Builder].
  ///
  /// Procedure of the check is literally any business logic that approves or denies
  /// access rights to specific part of the application. Returns `true` if access is
  /// granted and `false` otherwise.
  final bool Function() check;

  /// Builds a widget tree in case the warrant check went successful.
  ///
  /// ```dart
  /// AccessWarrant(
  ///   validBuilder: (context) => Text('Restricted area.'),
  /// )
  /// ```
  ///
  /// If omitted in constructor, it will build an empty [Container].
  final WidgetBuilder validBuilder;

  /// Builds a widget tree in case the warrant is wrong. Usually serves to show an authentication page
  /// or original page with reduced number of widgets available for open usage.
  ///
  /// This widget can then handle authentication or other procedure of getting valid warrant
  /// to pass the check and access the restricted area like so:
  /// `AccessWarrant.grantAccess(context)`.
  ///
  /// If omitted in constructor, it will build an empty [Container].
  final WidgetBuilder wrongBuilder;

  AccessWarrant({
    Key key,
    @required this.check,
    WidgetBuilder validBuilder,
    WidgetBuilder wrongBuilder,
  })  : validBuilder = validBuilder ?? ((_) => Container()),
        wrongBuilder = wrongBuilder ?? ((_) => Container()),
        super(key: key);

  /// Obtains the nearest [AccessWarrant] up its widget tree and makes its warrant valid.
  static void grantAccess(BuildContext context) {
    final _AccessWarrantState warrantState =
        context.findAncestorStateOfType<_AccessWarrantState>();

    assert(
      warrantState != null,
      '''
AccessWarrant requested with a context that does not include an AccessWarrant.

The context used to access the AccessWarrant must be that of a widget
that is a descendant of an AccessWarrant widget.
''',
    );

    warrantState.grantAccess();
  }

  @override
  _AccessWarrantState createState() => _AccessWarrantState();
}

class _AccessWarrantState extends State<AccessWarrant> {
  /// Whether the warrant is valid or not.
  ///
  /// In `null` then [AccessWarrant.check] must be executed to assign value to this field.
  bool _isValid;

  /// State of the closest [Navigator] instance up the widgets tree.
  NavigatorState _navigator;

  /// Current active route.
  ///
  /// Is used in case of navigation to the restricted area after the warrant gets valid.
  /// See [grantAccess] for details.
  MaterialPageRoute _activeRoute;

  @override
  Widget build(BuildContext context) {
    _navigator = Navigator.of(context);
    _activeRoute = ModalRoute.of(context);

    if (_isValid == null) _isValid = widget.check();

    return _isValid
        ? Builder(builder: widget.validBuilder)
        : Builder(builder: widget.wrongBuilder);
  }

  /// Updates the warrant state and rebuilds the current route pushing it on top of the stack and removing the old route after the animation.
  ///
  /// [AccessWarrant.check] is called again on the new route so the warrant state should be
  /// persisted in any appropriate way between the two routes to make AccessWarrant behaviour change.
  Future<void> grantAccess() async {
    if (_isValid) return;

    _isValid = true;
    await _navigator.pushReplacement(
      MaterialPageRoute(
        builder: _activeRoute.builder,
        settings: _activeRoute.settings,
        maintainState: _activeRoute.maintainState,
      ),
    );
  }
}
