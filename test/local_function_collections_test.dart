import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_function_collections/local_function_collections.dart';

void main() {
  group('UploadFile Model Tests', () {
    test('default parameters are set correctly', () {
      final upload = UploadFile(files: []);
      expect(upload.fileParameterName, 'files');
      expect(upload.isArrayKeyMethod, isFalse);
      expect(upload.isSingleFile, isFalse);
      expect(upload.files, isEmpty);
      expect(upload.rawFiles, isEmpty);
    });

    test('custom parameters are set correctly', () {
      final file1 = File('dummy1.txt');
      final file2 = File('dummy2.txt');
      final upload = UploadFile(
        files: [file1, file2],
        fileParameterName: 'attachments',
        isArrayKeyMethod: true,
        isSingleFile: false,
      );
      expect(upload.fileParameterName, 'attachments');
      expect(upload.isArrayKeyMethod, isTrue);
      expect(upload.isSingleFile, isFalse);
      expect(upload.files.length, 2);
    });

    test('UploadFile.fromBytes creates multipart items safely for web/memory', () {
      final upload = UploadFile.fromBytes(
        bytesList: [
          [1, 2, 3],
          [4, 5, 6],
        ],
        fileNames: ['doc1.pdf', 'doc2.pdf'],
        fileParameterName: 'docs',
        isSingleFile: false,
      );

      expect(upload.rawFiles.length, 2);
      expect(upload.rawFiles.first.filename, 'doc1.pdf');
      expect(upload.rawFiles.last.filename, 'doc2.pdf');
      expect(upload.fileParameterName, 'docs');
    });

    test('UploadFile.fromMultipartFiles wraps raw multipart files', () {
      final multipart = MultipartFile.fromBytes([10, 20], filename: 'img.png');
      final upload = UploadFile.fromMultipartFiles(
        multipartFiles: [multipart],
        isSingleFile: true,
      );

      expect(upload.rawFiles.length, 1);
      expect(upload.isSingleFile, isTrue);
    });
  });

  group('LocalRouteNavigator Tests', () {
    testWidgets('moveTo navigates to target and triggers callbackFunction and returns value', (tester) async {
      dynamic callbackValue;
      dynamic awaitedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  awaitedValue = await LocalRouteNavigator.moveTo<String>(
                    context: context,
                    target: const Scaffold(body: Text('Target Page')),
                    callbackFunction: (result) {
                      callbackValue = result;
                    },
                  );
                },
                child: const Text('Go Target'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Go Target'));
      await tester.pumpAndSettle();

      expect(find.text('Target Page'), findsOneWidget);

      final BuildContext targetContext = tester.element(find.text('Target Page'));
      LocalRouteNavigator.closeBack<String>(
        context: targetContext,
        callbackResult: 'returned_value',
      );
      await tester.pumpAndSettle();

      expect(find.text('Target Page'), findsNothing);
      expect(callbackValue, 'returned_value');
      expect(awaitedValue, 'returned_value');
    });

    testWidgets('replaceWith replaces current route and returns future', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  LocalRouteNavigator.replaceWith(
                    context: context,
                    target: const Scaffold(body: Text('Replaced Page')),
                  );
                },
                child: const Text('Replace'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Replace'));
      await tester.pumpAndSettle();

      expect(find.text('Replaced Page'), findsOneWidget);
      expect(find.text('Replace'), findsNothing);
    });

    testWidgets('redirectTo removes all routes in stack', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  LocalRouteNavigator.redirectTo(
                    context: context,
                    target: const Scaffold(body: Text('Redirected Page')),
                  );
                },
                child: const Text('Redirect'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Redirect'));
      await tester.pumpAndSettle();

      expect(find.text('Redirected Page'), findsOneWidget);
      expect(find.text('Redirect'), findsNothing);
    });
  });

  group('LocalDialogFunction Tests', () {
    testWidgets('okDialog shows title, content and handles OK click & onClose', (tester) async {
      bool onCloseCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  LocalDialogFunction.okDialog(
                    context: context,
                    title: 'Alert Title',
                    contentText: 'Alert Content',
                    onClose: () {
                      onCloseCalled = true;
                    },
                  );
                },
                child: const Text('Show OK Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show OK Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Alert Title'), findsOneWidget);
      expect(find.text('Alert Content'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Alert Title'), findsNothing);
      expect(onCloseCalled, isTrue);
    });

    testWidgets('optionDialog handles Accept click and returns true', (tester) async {
      bool accepted = false;
      bool declined = false;
      bool? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  dialogResult = await LocalDialogFunction.optionDialog(
                    context: context,
                    title: 'Confirm',
                    contentText: 'Are you sure?',
                    acceptText: 'Confirm Yes',
                    declineText: 'Cancel No',
                    onAccept: () {
                      accepted = true;
                    },
                    onDecline: () {
                      declined = true;
                    },
                  );
                },
                child: const Text('Show Option Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Option Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);
      expect(find.text('Confirm Yes'), findsOneWidget);
      expect(find.text('Cancel No'), findsOneWidget);

      await tester.tap(find.text('Confirm Yes'));
      await tester.pumpAndSettle();

      expect(accepted, isTrue);
      expect(declined, isFalse);
      expect(dialogResult, isTrue);
    });

    testWidgets('optionDialog handles Decline click and returns false', (tester) async {
      bool accepted = false;
      bool declined = false;
      bool? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  dialogResult = await LocalDialogFunction.optionDialog(
                    context: context,
                    contentText: 'Are you sure?',
                    onAccept: () {
                      accepted = true;
                    },
                    onDecline: () {
                      declined = true;
                    },
                  );
                },
                child: const Text('Show Option Dialog'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Option Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      expect(accepted, isFalse);
      expect(declined, isTrue);
      expect(dialogResult, isFalse);
    });

    testWidgets('loadingDialog shows content and dismissLoadingDialog keeps token active', (tester) async {
      final cancelToken = CancelToken();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  LocalDialogFunction.loadingDialog(
                    context: context,
                    contentText: 'Custom loading...',
                    cancellationToken: cancelToken,
                  );
                },
                child: const Text('Show Loading'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Loading'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Custom loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final BuildContext dialogContext = tester.element(find.text('Custom loading...'));
      LocalDialogFunction.dismissLoadingDialog(dialogContext);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Custom loading...'), findsNothing);
      expect(cancelToken.isCancelled, isFalse);
    });

    testWidgets('adaptive dialogs render Cupertino on iOS', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Builder(
            builder: (context) {
              return Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      LocalDialogFunction.okDialog(
                        context: context,
                        title: 'iOS Title',
                        contentText: 'iOS Body',
                      );
                    },
                    child: const Text('Show iOS Dialog'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      LocalDialogFunction.loadingDialog(
                        context: context,
                        contentText: 'iOS Loading',
                      );
                    },
                    child: const Text('Show iOS Loading'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      // Test okDialog on iOS
      await tester.tap(find.text('Show iOS Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.byType(CupertinoDialogAction), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsNothing);

      // Test loadingDialog on iOS
      await tester.tap(find.text('Show iOS Loading'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

      final BuildContext dialogContext = tester.element(find.text('iOS Loading'));
      LocalDialogFunction.dismissLoadingDialog(dialogContext);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(CupertinoAlertDialog), findsNothing);
    });
  });

  group('LocalAPIsRequest Tests', () {
    setUp(() {
      LocalAPIsRequest.clearInterceptors();
    });

    test('addInterceptors and clearInterceptors work as expected', () {
      final interceptor = InterceptorsWrapper();
      LocalAPIsRequest.addInterceptors([interceptor]);
      expect(LocalAPIsRequest.dio.interceptors.contains(interceptor), isTrue);

      LocalAPIsRequest.clearInterceptors();
      expect(LocalAPIsRequest.dio.interceptors.contains(interceptor), isFalse);
    });

    test('setupCertificatePinning accepts fingerprints and allowedHosts', () {
      expect(
        () => LocalAPIsRequest.setupCertificatePinning(
          ['AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99'],
          allowedHosts: ['api.example.com'],
        ),
        returnsNormally,
      );
    });

    test('submitRequest handles timeouts and PATCH method', () async {
      CancelToken token = CancelToken();
      token.cancel();

      // Cancelled request should return immediately with null/response without throwing
      final response = await LocalAPIsRequest.submitRequest(
        requestType: RequestType.patch,
        apisURL: 'https://example.com/api',
        cancelToken: token,
        connectionTimeoutInSecond: 10,
        sendTimeoutInSecond: 10,
      );

      expect(response, isNull);
    });
  });

  group('LocalSecureStorage Tests', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      LocalSecureStorage.configure();
    });

    test('writeKey, readKey, containsKey, readAll, deleteKey, and clearKey workflow', () async {
      // Initially null
      final initial = await LocalSecureStorage.readKey(key: 'token');
      expect(initial, isNull);
      expect(await LocalSecureStorage.containsKey(key: 'token'), isFalse);

      // Write
      final writeResult = await LocalSecureStorage.writeKey(key: 'token', data: 'secret123');
      expect(writeResult, isTrue);

      // Read & contains
      final readResult = await LocalSecureStorage.readKey(key: 'token');
      expect(readResult, 'secret123');
      expect(await LocalSecureStorage.containsKey(key: 'token'), isTrue);

      // Read all
      final all = await LocalSecureStorage.readAll();
      expect(all['token'], 'secret123');

      // Delete
      final deleteResult = await LocalSecureStorage.deleteKey(key: 'token');
      expect(deleteResult, isTrue);
      expect(await LocalSecureStorage.readKey(key: 'token'), isNull);
      expect(await LocalSecureStorage.containsKey(key: 'token'), isFalse);

      // Clear all
      await LocalSecureStorage.writeKey(key: 'key1', data: 'val1');
      await LocalSecureStorage.writeKey(key: 'key2', data: 'val2');
      final clearResult = await LocalSecureStorage.clearKey();
      expect(clearResult, isTrue);
      expect(await LocalSecureStorage.readKey(key: 'key1'), isNull);
      expect(await LocalSecureStorage.readKey(key: 'key2'), isNull);
    });
  });
}
