import 'package:flutter/material.dart';
import 'package:local_function_collections/local_function_collections.dart';

void main() {
  runApp(const LFCApp());
}

class LFCApp extends StatelessWidget {
  const LFCApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LFC Demo App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
        ),
        useMaterial3: false,
      ),
      home: const FirstPage(),
    );
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

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
      contentText: "This loading will appear for 3 second",
      contentAlign: TextAlign.justify,
    );

    Future.delayed(const Duration(seconds: 3), () {
      if(mounted) {
        LocalRouteNavigator.closeBack(context: context);
      }
    });
  }

  onUpdateSecureStorage() => LocalSecureStorage.writeKey(
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
              ElevatedButton(
                onPressed: () => onOKDialogPressed(),
                child: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    "OK Dialog",
                  ),
                ),
              ),
              const SizedBox(
                height: 5.0,
              ),
              ElevatedButton(
                onPressed: () => onOptionDialogPressed(),
                child: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    "Option Dialog",
                  ),
                ),
              ),
              const SizedBox(
                height: 5.0,
              ),
              ElevatedButton(
                onPressed: () => onLoadingDialogPressed(),
                child: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    "Loading Dialog",
                  ),
                ),
              ),
              const SizedBox(
                height: 5.0,
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

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {

  @override
  void initState() {
    super.initState();
  }

  onCheckSecureStorage() async {
    String? result = await LocalSecureStorage.readKey(key: "example");

    return result;
  }

  onCloseThisPage() => LocalRouteNavigator.closeBack(context: context);

  onReplaceThisPage() => LocalRouteNavigator.replaceWith(
    context: context,
    target: const ThirdPage(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          "LCF Demo App 2nd Page",
        ),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 4,
          ),
          Column(
            children: <Widget>[
              const Text(
                "Welcome on 2nd page...",
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10.0,
              ),
              Text(
                "Text Saved on Local Secure Storage: ${onCheckSecureStorage() ?? "-"}",
              ),
              const SizedBox(
                height: 10.0,
              ),
              ElevatedButton(
                onPressed: () => onCloseThisPage,
                child: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    "Back to 1st Page",
                  ),
                ),
              ),
              const SizedBox(
                height: 5.0,
              ),
              ElevatedButton(
                onPressed: () => onReplaceThisPage(),
                child: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    "Replace this page with 3rd Page",
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

class ThirdPage extends StatefulWidget {
  const ThirdPage({super.key});

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {

  @override
  void initState() {
    super.initState();
  }

  onCheckSecureStorage() async {
    String? result = await LocalSecureStorage.readKey(key: "example");

    return result;
  }

  onCloseThisPage() => LocalRouteNavigator.closeBack(context: context);

  onRedirectThisPage() => LocalRouteNavigator.redirectTo(
    context: context,
    target: const FirstPage(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          "LCF Demo App 3rd Page",
        ),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 4,
          ),
          Column(
            children: <Widget>[
              const Text(
                "Welcome on 3rd page...",
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10.0,
              ),
              Text(
                "Text Saved on Local Secure Storage: ${onCheckSecureStorage() ?? "-"}",
              ),
              const SizedBox(
                height: 10.0,
              ),
              ElevatedButton(
                onPressed: () => onCloseThisPage,
                child: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    "Back to 2nd Page",
                  ),
                ),
              ),
              const SizedBox(
                height: 5.0,
              ),
              ElevatedButton(
                onPressed: () => onRedirectThisPage,
                child: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    "Redirect to 1st Page",
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