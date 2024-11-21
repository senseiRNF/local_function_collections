<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

Local Function Collections is a simple package that provide navigation, alert dialog and secure storage function.

## Features

There are several function that provided in this package:

1. Navigation Function like move to, replace with and back to previous page.
2. Dialog Function like ok dialog, option dialog and loading dialog.
3. Secure Storage Function like write, read, remove and clear.

## Getting started

Just make sure your flutter version is up to date.

## Usage

Any further instruction has been added into example.dart

```dart
class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {

  @override
  void initState() {
    super.initState();
  }

  onOKDialogPressed() => LocalDialogFunction.okDialog(
    context: context,
    contentText: "Hello Users!!!",
    contentAlign: TextAlign.justify,
  );

  onOptionDialogPressed() => LocalDialogFunction.optionDialog(
    context: context,
    contentText: "Do you like this package?",
    onAccept: () => LocalDialogFunction.okDialog(
      context: context,
      title: "Thank You!!!",
      contentText: "Thank you for appreciating our package!, soon there will be another new package launched.",
      contentAlign: TextAlign.justify,
    ),
    onDecline: () => LocalDialogFunction.okDialog(
      context: context,
      title: "We're Sorry",
      contentText: "We're sorry if our package isn't enough for you :(, for any critiques you can DM me on Instagram: @raznovrnf or my LinkedIn: Razy Firdana.",
      contentAlign: TextAlign.justify,
    ),
    contentAlign: TextAlign.justify,
  );

  onLoadingDialogPressed() {
    LocalDialogFunction.loadingDialog(
      context: context,
      contentText: "This loading will disappear in 3 second",
      contentAlign: TextAlign.justify,
    );

    Future.delayed(const Duration(seconds: 3), () {
      if(mounted) {
        LocalRouteNavigator.closeBack(context: context);
      }
    });
  }

  onMoveTo2ndPage() => LocalRouteNavigator.moveTo(
    context: context,
    target: const SecondPage(),
  );

  onMoveTo3rdPage() => LocalRouteNavigator.moveTo(
    context: context,
    target: const ThirdPage(
      isJumped: true,
    ),
  );

  onUpdateSecureStorage() async => await LocalSecureStorage.writeKey(
    key: "example",
    data: "This example was created at ${DateTime.now()}",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          "LCF Demo App 1st Page",
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
        ),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 4,
          ),
          Column(
            children: <Widget>[
              const Text(
                "Welcome on 1st Page,\nLet's try our Local Function Collections",
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10.0,
              ),
              const Text(
                "Dialog Collections",
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onOKDialogPressed(),
                      child: const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          "OK",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onOptionDialogPressed(),
                      child: const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          "Option",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onLoadingDialogPressed(),
                      child: const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          "Loading",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              const Text(
                "Route Collections",
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onMoveTo2ndPage(),
                      child: const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          "Go to 2nd Page",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onMoveTo3rdPage(),
                      child: const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          "Go to 3rd Page",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              const Text(
                "Secure Storage Collections",
              ),
              ElevatedButton(
                onPressed: () => onUpdateSecureStorage(),
                child: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    "Update Secure Storage Timestamp",
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

## Additional information

If there's any problem with this package, or you just wanted to give credits, critiques and suggestion. You can DM me on Instagram: @raznovrnf or my email: novian.shatter@gmail.com. We should discuss it together. Thanks!!!!
