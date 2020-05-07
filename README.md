# Access Warrant

This package provides a way to control access to a specific widget subtree with a conception called hereinafter “warrant check”.

## Usage

To use this package, add `access_warrant` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Example

Import the library.

``` dart
import 'package:access_warrant/access_warrant.dart';
```

Then use it in any part of your widget tree just like an ordinary widget with builder method:

```dart
AccessWarrant(
  // Provide a [validBuilder] to build a view of restricted access.
  validBuilder: (context) => Text('A widget you can not see until access rights confirmed.'),

  // Provide a [check] callback to verify access rights to the [validBuilder] result.
  check: () => {
    // Procedure of the check is literally any business logic that approves or denies
    // access rights to a specific part of the application. Returns `true` if access is
    // granted and `false` otherwise.
  },

  // Provide a [wrongBuilder] to build a view for case if warrant check has failed.
  // This widget can then handle authentication or other procedure of getting valid warrant
  // to pass the check and access the restricted area like so:
  // `AccessWarrant.grantAccess(context)`.
  wrongBuilder: (context) => Text('Show this if the warrant is wrong.'),
)
```

Example of making your warrant valid from a page built by [wrongBuilder]:

```dart
AccessWarrant(
  validBuilder: (context) => Text('Can not see this until you are authorized.'),
  wrongBuilder: (_) => RaisedButton(
    child: Text('Click me to get authorized!'),
    // [AccessWarrant.check] is called again on the new route so the warrant state should be
    // persisted in any appropriate way between the two routes to make AccessWarrant behaviour change.
    onPressed: () => AccessWarrant.grantAccess(context),
  ),
  // Return `false` to show the result of the [wrongBuilder] first.
  check: () => false,
)
```

> Currently this package is developed for material applications. Other support will be added up to the 0.1.0 release.
