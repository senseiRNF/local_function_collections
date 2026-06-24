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

# Local Function Collections

[![pub package](https://img.shields.io/pub/v/local_function_collections.svg)](https://pub.dev/packages/local_function_collections)
[![likes](https://img.shields.io/pub/likes/local_function_collections.svg)](https://pub.dev/packages/local_function_collections)
[![Flutter Platform](https://img.shields.io/badge/platform-flutter-lightgrey.svg)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A robust, production-ready helper utility package for Flutter that encapsulates standard workflows: advanced network requests, context-safe navigation, customized alert dialogs, and persistent encrypted secure storage.

---

## Features

| Category           | Class                 | Description                                                                                                                                 |
|:-------------------|:----------------------|:--------------------------------------------------------------------------------------------------------------------------------------------|
| 🌐 **Networking**  | `LocalAPIsRequest`    | Unified HTTP client powered by Dio with dynamic loading states, automatic `FormData` construction for file uploads, and flexible callbacks. |
| 🛡️ **Storage**    | `LocalSecureStorage`  | Simple keychain/keystore encapsulation for reading, writing, and wiping highly sensitive encrypted key-value string data.                   |
| 💬 **Dialogs**     | `LocalDialogFunction` | Pre-built alert interfaces including context-safe blocking Loaders, standard OK Informational alerts, and dynamic Option Dialogs.           |
| 🗺️ **Navigation** | `LocalRouteNavigator` | Simplified routing patterns including basic pushes, inline replacements, complete stack-resets, and parameterized pops.                     |

---

## Getting Started

Just make sure your flutter version is up to date.

### Installation

Add `local_function_collections` to your `pubspec.yaml` file:

## Usage

You only need a single import statement to gain access to the entire utility pipeline:

```dart
import 'package:local_function_collections/local_function_collections.dart';
```

## 1. Network Request & Multi-File Upload (`LocalAPIsRequest`)

Execute network protocols (GET, POST, PUT, DELETE) with flexible loading lifecycle callbacks and centralized error delegation seamlessly.

```dart
void makeNetworkCall(BuildContext context) async {
  final cancelToken = CancelToken();

  Response? response = await LocalAPIsRequest.submitRequest(
    requestType: RequestType.post,
    apisURL: "[https://api.example.com/v1/upload](https://api.example.com/v1/upload)",
    cancelToken: cancelToken,
    bodyData: {"category": "profile_pictures"},
    files: UploadFile(
      fileParameterName: "images",
      files: [File("/path/to/image1.png"), File("/path/to/image2.png")],
      isArrayKeyMethod: true, // Appends 'images[0]', 'images[1]' parameter structural keys
    ),
    onStart: () {
      // 💡 Trigger your custom loading layout before request hits the server
      LocalDialogFunction.loadingDialog(
        context: context,
        contentText: "Uploading files...",
        cancellationToken: cancelToken, // Enables safe manual dismissal
      );
    },
    onFinish: () {
      // 💡 Automatically dismisses loader when request completes (Success OR Error)
      LocalRouteNavigator.closeBack(context: context);
    },
    errorHandler: (exception, stackTrace) {
      // Handles anomalies or non-200 Status Code responses safely inside the scope
      print("Network Anomaly Caught: $exception");
    },
  );

  if (response != null) {
    print("Payload received: ${response.data}");
  }
}
```

### 2. Dialog Operations (`LocalDialogFunction`)

```dart
// Trigger an Information Alert
void showSuccessDialog() {
  LocalDialogFunction.okDialog(
    context: context,
    title: "Operation Successful",
    contentText: "Your preferences have been updated successfully.",
    contentAlign: TextAlign.center,
    onClose: () => print("Dialog dismissed"),
  );
}

// Trigger an Action Prompt Option
void onDeletePressed() {
  LocalDialogFunction.optionDialog(
    context: context,
    title: "Confirm Deletion",
    contentText: "Are you sure you want to purge this asset permanently?",
    acceptText: "Delete",
    declineText: "Cancel",
    onAccept: () => proceedDestruction(),
    onDecline: () => traceCancellation(),
  );
}
```

## 3. Encrypted Key-Value Persistence (`LocalSecureStorage`)

```dart
// Write Encrypted Session Tokens
Future<bool> onWriteAuth() async {
  bool result = await LocalSecureStorage.writeKey(key: "auth_token", data: "JWT_STRING");
  
  return result;
}

// Retrieve Protected Credentials Safely 
Future<String?> onReadAuth() async {
  String? secureToken = await LocalSecureStorage.readKey(key: "auth_token");
  
  return secureToken;
}

// Purge Selected Registry Entries
Future<bool> onDeleteAuth() async {
  bool result = await LocalSecureStorage.deleteKey(key: "auth_token");
  
  return result;
}

// Total Storage Wipeout
Future<bool> onClearKey() async {
  bool result = await LocalSecureStorage.clearKey();
  
  return result;
}
```

## 4. Contextual Route Navigation (`LocalRouteNavigator`)

```dart
// Standard Navigation Push
void openDetailPage() {
  LocalRouteNavigator.moveTo(
    context: context,
    target: const DetailScreen(),
    callbackFunction: (result) => processReturnedValue(result),
  );
}

// Destructive Linear Target Replacement
void onLoginSuccess() {
  LocalRouteNavigator.replaceWith(
    context: context, target: const DashboardView(),
  );
}

// Complete Navigation Stack Flush and Root Redirection
void onLogoutSuccess() {
  LocalRouteNavigator.redirectTo(
    context: context, target: const LoginView(),
  );
}

// Parameterized Stack Pop Closures
void onPopWithResult(bool? result) {
  LocalRouteNavigator.closeBack(
    context: context, callbackResult: result,
  );
}
```

## Technical Details & Architecture

Iterable TCP Lifecycle Performance: LocalAPIsRequest uses a unified, static shared Dio instance under the hood. This ensures connection reuse via connection pools, saving system memory and accelerating subsequent handshakes.
Asynchronous Lifecycle Gap Protections: Dialog closures and network dispatches respect stateful attachment checking (Widget.mounted), guarding your runtime stack against thread safety alerts or memory leakage crashes.

## Additional information

Contributions, feature extensions, and architectural critiques are highly welcome. Feel free to connect or log technical feedback via our official touchpoints:

Instagram: @raznovrnf 
email: novian.shatter@gmail.com.

Developed with 💙 by Razy Novian. Licensed under the MIT License.
