library local_function_collections;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalDialogFunction {
  /// OK Dialog
  ///
  /// This function return an Alert dialog with content and "OK" button
  ///
  /// Parameters:
  /// * Context (Required): BuildContext required for showDialog function.
  /// * Title (Optional): Title work as head title of alert dialog, default will be null.
  /// * Content Text (Required): Content text work as body of alert dialog.
  /// * On Close (Optional): On close function work as function that run after you close the dialog, default will be an empty function.
  /// * Content Align (Optional): Content Align work as alignment of content text, default value will be start alignment.
  static okDialog({
    required BuildContext context,
    String? title,
    required String contentText,
    Function? onClose,
    TextAlign? contentAlign,
  }) => showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: title != null
            ? Text(title)
            : null,
        content: Text(
          contentText,
          textAlign: contentAlign ?? TextAlign.start,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "OK",
            ),
          ),
        ],
      );
    },
  ).then((_) => onClose != null ? onClose() : {});

  /// Option Dialog
  ///
  /// This function return an Alert dialog with content and "Yes" or "No" button
  ///
  /// Parameters:
  /// * Context (Required): BuildContext required for showDialog function.
  /// * Title (Optional): Title work as head title of alert dialog, default will be null.
  /// * Content Text (Required): Content text work as body of alert dialog.
  /// * Decline Text (Optional): Decline text work as text that display decline button, default value will be "No".
  /// * Accept Text (Optional): Accept text work as  text that display accept button, default value will be "Yes".
  /// * On Decline (Optional): On decline function work as function that run after you decline the option, default will be an empty function.
  /// * On Accept (Required): On accept function work as function that run after you accept the option.
  /// * Content Align (Optional): Content Align work as alignment of content text, default value will be start alignment.
  static optionDialog({
    required BuildContext context,
    String? title,
    required String contentText,
    String? declineText,
    String? acceptText,
    Function? onDecline,
    required Function onAccept,
    TextAlign? contentAlign,
  }) => showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: title != null
            ? Text(title)
            : null,
        content: Text(
          contentText,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              declineText ?? "No",
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              acceptText ?? "Yes",
            ),
          ),
        ],
      );
    },
  ).then((result) {
    if(result != null && result == true) {
      onAccept();
    } else if(result != null && result == false) {
      if(onDecline != null) {
        onDecline();
      }
    }
  });

  /// Loading Dialog
  ///
  /// This function return an Alert dialog with a loading that can't be interupted
  ///
  /// Parameters:
  /// * Context (Required): BuildContext required for showDialog function.
  /// * Content Text (Optional): Content text work as body of alert dialog, default value will be "Loading data, please wait...".
  /// * Content Align (Optional): Content Align work as alignment of content text, default value will be start alignment.
  static loadingDialog({
    required BuildContext context,
    String? contentText,
    TextAlign? contentAlign,
  }) => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogBuilder) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                contentText ?? "Loading data, please wait...",
                textAlign: contentAlign ?? TextAlign.start,
              ),
              const SizedBox(
                height: 10.0,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 20.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class LocalRouteNavigator {
  /// Move To
  ///
  /// This function serve as a command to navigate to new page and the previous page still existed but not active
  /// Parameters:
  /// * Context (Required): BuildContext required for Navigator function.
  /// * Target (Required): Target is a StatefulWidget that intended as target of navigator.
  static moveTo({
    required BuildContext context,
    required StatefulWidget target,
    Function? callbackFunction,
  }) => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (targetContext) => target,
      )
  ).then((callbackResult) => callbackFunction != null
      ? callbackFunction(callbackResult)
      : {});

  /// Replace With
  ///
  /// This function serve as a command to navigate to new page but the previous page are terminated
  /// Parameters:
  /// * Context (Required): BuildContext required for Navigator function.
  /// * Target (Required): Target is a StatefulWidget that intended as target of navigator.
  static replaceWith({
    required BuildContext context,
    required StatefulWidget target,
  }) => Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (targetContext) => target),
  );

  /// Redirect To
  ///
  /// This function serve as a command to navigate to new page but all of the previous page that stacked together are terminated
  /// Parameters:
  /// * Context (Required): BuildContext required for Navigator function.
  /// * Target (Required): Target is a StatefulWidget that intended as target of navigator.
  static redirectTo({
    required BuildContext context,
    required StatefulWidget target,
  }) => Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (targetContext) => target),
        (_) => false,
  );

  /// Close Back
  ///
  /// This function serve as a command to navigate to previous page and the current page are terminated
  /// Parameters:
  /// * Context (Required): BuildContext required for Navigator function.
  /// * Callback Result (Optional): Callback result is a value that will be carried away after leaving current page.
  static closeBack({
    required BuildContext context,
    dynamic callbackResult,
  }) => Navigator.of(context).pop(callbackResult);
}

class LocalSecureStorage {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Write Key
  ///
  /// This function serve as a command to store a nullable String into secure storage using a key from Local Secure Key
  static Future<bool> writeKey({required String key, String? data}) async {
    bool result = false;

    await _secureStorage.write(
      key: key,
      value: data,
    ).then((_) {
      result = true;
    });

    return result;
  }

  /// Read Key
  ///
  /// This function serve as a command to read data from secure storage using a key from Local Secure Key
  static Future<String?> readKey({required String key}) async {
    String? result;

    await _secureStorage.read(
      key: key,
    ).then((readResult) {
      result = readResult;
    });

    return result;
  }

  /// Delete Key
  ///
  /// This function serve as a command to remove data from secure storage using a key from Local Secure Key
  static Future<bool> deleteKey({required String key}) async {
    bool result = false;

    await _secureStorage.delete(
      key: key,
    ).then((_) {
      result = true;
    });

    return result;
  }

  /// Clear Key
  ///
  /// This function serve as a command to clear any stored data from secure storage
  static Future<bool> clearKey() async {
    bool result = false;

    await _secureStorage.deleteAll().then((_) {
      result = true;
    });

    return result;
  }
}