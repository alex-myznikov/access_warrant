import 'package:access_warrant/access_warrant.dart';
import 'package:flutter/material.dart';

// In this example AccessWarrant is used to guard 'treasury-door' route against
// unauthorized access. After `grantAccess` is called a copy of the route gets pushed
// on top of the stack replacing the old route.

void main() {
  runApp(MyApp());
}

// We store the treasury's state in variable to make this example brief.
bool treasuryIsOpened = false;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dwarves treasury',
      initialRoute: 'treasury-door',
      routes: {
        'treasury-door': (context) => Scaffold(
              body: AccessWarrant(
                wrongBuilder: (context) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('You shall not pass without a key!'),
                      SizedBox(height: 20),
                      RaisedButton(
                        child: Text(
                          'Knock-knock!\nHello, please let me in, I\'ve brought some cookies :)',
                          textAlign: TextAlign.center,
                        ),
                        padding: const EdgeInsets.all(12),
                        onPressed: () {
                          treasuryIsOpened = true;
                          AccessWarrant.grantAccess(context);
                        },
                      ),
                    ],
                  ),
                ),
                validBuilder: (_) => Center(
                  child: Text('Come in, you are welcome!'),
                ),
                check: () => treasuryIsOpened,
              ),
            ),
      },
    );
  }
}
