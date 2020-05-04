# Access Warrant

A package responsible for controlling access to a specific part in the widget tree.

## Usage

To use this plugin, add `access_warrant` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Example

Import the library.

``` dart
import 'package:access_warrant/access_warrant.dart';
```

Then wrap the code you want to controll access to in `validBuilder` like so:

``` dart
AccessWarrant(
  validBuilder: (context) => Text('A widget you do not want to show until access rights confirmed.'),
  check: () => {
    // Any code that checks "access warrant" and returns boolean to claim whether access is allowed or not.
  },
  wrongBuilder: (context) => Text('Show this if access is restricted.'),
),
```

Then on `wrongBuilder` page you can perform user authorization or do any other things necessary and notify the closest AccessWarrant to show the restricted content:

```dart
AccessWarrant.grantAccess(context);
```
