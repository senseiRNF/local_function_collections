import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:local_function_collections/local_function_collections.dart';

void main() {
  runApp(const LFCApp());
}

class LFCApp extends StatelessWidget {
  const LFCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LFC Demo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlue,
        ),
        useMaterial3: true,
      ),
      home: const FirstPage(),
    );
  }
}

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
          contentText:
              "Thank you for appreciating our package!, soon there will be another new package launched.",
          contentAlign: TextAlign.justify,
        ),
        onDecline: () => LocalDialogFunction.okDialog(
          context: context,
          title: "We're Sorry",
          contentText:
              "We're sorry if our package isn't enough for you :(, for any critiques you can DM me on Instagram: @raznovrnf or my LinkedIn: Razy Firdana.",
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
      if (mounted) {
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

  onSubmitRequestPressed({
    required RequestType type,
    required String url,
  }) async {
    CancellationToken cancellationToken = CancellationToken();

    await LocalAPIsRequest.submitRequest(
      requestType: type,
      apisURL: url,
      errorHandler: (exception, stackTrace) {
        LocalDialogFunction.okDialog(
          context: context,
          contentText: "Error when submitting request: $exception",
        );
      },
      cancellationToken: cancellationToken,
      usingloadingDialog: context,
    ).then((result) {
      if (mounted) {
        if (result != null) {
          String? encodedMap;
          List encodedListMap = [];

          if (result.data is Map) {
            encodedMap = jsonEncode(result.data);
          } else if (result.data is List) {
            for (Map<String, dynamic> data in result.data) {
              encodedListMap.add(jsonEncode(data));
            }
          }

          LocalDialogFunction.okDialog(
            context: context,
            title: "Status Code ${result.statusCode}",
            contentText: encodedListMap.isNotEmpty
                ? encodedListMap.first
                : encodedMap ?? "",
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          "LFC Demo App 1st Page",
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
              const Text(
                "APIs Request Collections",
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onSubmitRequestPressed(
                        type: RequestType.get,
                        url: "https://dummyjson.com/test",
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "GET",
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onSubmitRequestPressed(
                        type: RequestType.post,
                        url: "https://dummyjson.com/test",
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "POST",
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onSubmitRequestPressed(
                        type: RequestType.put,
                        url: "https://dummyjson.com/test",
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "PUT",
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onSubmitRequestPressed(
                        type: RequestType.delete,
                        url: "https://dummyjson.com/test",
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "DELETE",
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
  String? storageResult;

  @override
  void initState() {
    super.initState();

    onCheckSecureStorage();
  }

  onCheckSecureStorage() async {
    await LocalSecureStorage.readKey(key: "example").then((result) {
      setState(() {
        storageResult = result;
      });
    });
  }

  onCloseThisPage() => LocalRouteNavigator.closeBack(context: context);

  onReplaceTo3rdPage() => LocalRouteNavigator.replaceWith(
        context: context,
        target: const ThirdPage(
          isJumped: true,
        ),
      );

  onMoveTo3rdPage() => LocalRouteNavigator.moveTo(
        context: context,
        target: const ThirdPage(
          isJumped: false,
        ),
        callbackFunction: (_) => onCheckSecureStorage(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          "LFC Demo App 2nd Page",
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
                "Text Saved on Local Secure Storage: ${storageResult ?? "-"}",
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10.0,
              ),
              ElevatedButton(
                onPressed: () => onCloseThisPage(),
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
                onPressed: () => onMoveTo3rdPage(),
                child: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    "Go to 3rd Page",
                  ),
                ),
              ),
              const SizedBox(
                height: 5.0,
              ),
              ElevatedButton(
                onPressed: () => onReplaceTo3rdPage(),
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
  final bool isJumped;

  const ThirdPage({
    super.key,
    required this.isJumped,
  });

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  String? storageResult;

  @override
  void initState() {
    super.initState();

    onCheckSecureStorage();
  }

  onCheckSecureStorage() async {
    await LocalSecureStorage.readKey(key: "example").then((result) {
      setState(() {
        storageResult = result;
      });
    });
  }

  onCloseThisPage() => LocalRouteNavigator.closeBack(context: context);

  onRedirectThisPage() => LocalRouteNavigator.redirectTo(
        context: context,
        target: const FirstPage(),
      );

  onClearSecureStorage() async =>
      await LocalSecureStorage.clearKey().then((_) => onCheckSecureStorage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          "LFC Demo App 3rd Page",
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
                "Text Saved on Local Secure Storage: ${storageResult ?? "-"}",
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10.0,
              ),
              ElevatedButton(
                onPressed: () => onClearSecureStorage(),
                child: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    "Clear Secure Storage",
                  ),
                ),
              ),
              const SizedBox(
                height: 5.0,
              ),
              ElevatedButton(
                onPressed: () => onCloseThisPage(),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    widget.isJumped == true
                        ? "Back to 1st Page"
                        : "Back to 2nd Page",
                  ),
                ),
              ),
              const SizedBox(
                height: 5.0,
              ),
              widget.isJumped == true
                  ? const Material()
                  : ElevatedButton(
                      onPressed: () => onRedirectThisPage(),
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
