import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum RequestType { get, post, put, delete }

class UploadFile {
  /// Name of your file parameter, the default value is 'files'.
  final String fileParameterName;
  /// List of file that you want to upload.
  final List<File> files;
  /// If your file parameter written
  /// "file&#91;0&#93;"
  /// set to true.
  final bool isArrayKeyMethod;

  const UploadFile({
    required this.files,
    this.fileParameterName = "files",
    this.isArrayKeyMethod = false,
  });
}

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
  static Future okDialog({
    required BuildContext context,
    String? title,
    required String contentText,
    Function? onClose,
    TextAlign? contentAlign,
  }) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: title != null ? Text(title) : null,
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
    );

    if(onClose == null) return;

    onClose();
  }

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
  static Future optionDialog({
    required BuildContext context,
    String? title,
    required String contentText,
    String? declineText,
    String? acceptText,
    Function? onDecline,
    required Function onAccept,
    TextAlign? contentAlign,
  }) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: title != null ? Text(title) : null,
          content: Text(
            contentText,
            textAlign: contentAlign ?? TextAlign.center,
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
    );

    if(result == null) return;

    if (result == true) {
      onAccept();
    } else {
      onDecline?.call();
    }
  }

  /// Loading Dialog
  ///
  /// This function return an Alert dialog with a loading that can't be interupted
  ///
  /// Parameters:
  /// * Context (Required): BuildContext required for showDialog function.
  /// * Content Text (Optional): Content text work as body of alert dialog, default value will be "Loading data, please wait...".
  /// * Content Align (Optional): Content Align work as alignment of content text, default value will be start alignment.
  static Future loadingDialog({
    required BuildContext context,
    String? contentText,
    TextAlign? contentAlign,
    CancelToken? cancellationToken,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: cancellationToken != null ? true : false,
      builder: (dialogBuilder) {
        return PopScope(
          canPop: cancellationToken != null ? true : false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop == true && result != "completed") {
              if (cancellationToken != null) {
                cancellationToken.cancel();
              }
            }
          },
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
}

class LocalRouteNavigator {
  /// Move To
  ///
  /// This function serve as a command to navigate to new page and the previous page still existed but not active
  /// Parameters:
  /// * Context (Required): BuildContext required for Navigator function.
  /// * Target (Required): Target is a Widget that intended as target of navigator.
  /// * Callback Function (Optional): After going back from previous page, this parameter will run a function.
  static Future moveTo({
    required BuildContext context,
    required Widget target,
    Function? callbackFunction,
  }) async {
    dynamic callbackResult = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (targetContext) => target,
      ),
    );

    if(callbackFunction == null) return;

    callbackFunction(callbackResult);
  }

  /// Replace With
  ///
  /// This function serve as a command to navigate to new page but the previous page are terminated
  /// Parameters:
  /// * Context (Required): BuildContext required for Navigator function.
  /// * Target (Required): Target is a Widget that intended as target of navigator.
  static void replaceWith({
    required BuildContext context,
    required Widget target,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (targetContext) => target),
    );
  }

  /// Redirect To
  ///
  /// This function serve as a command to navigate to new page but all of the previous page that stacked together are terminated
  /// Parameters:
  /// * Context (Required): BuildContext required for Navigator function.
  /// * Target (Required): Target is a Widget that intended as target of navigator.
  static void redirectTo({
    required BuildContext context,
    required Widget target,
  }) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (targetContext) => target),
          (_) => false,
    );
  }

  /// Close Back
  ///
  /// This function serve as a command to navigate to previous page and the current page are terminated
  /// Parameters:
  /// * Context (Required): BuildContext required for Navigator function.
  /// * Callback Result (Optional): Callback result is a value that will be carried away after leaving current page.
  static void closeBack({
    required BuildContext context,
    dynamic callbackResult,
  }) {
    Navigator.of(context).pop(callbackResult);
  }
}

class LocalSecureStorage {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Write Key
  ///
  /// This function serve as a command to store a nullable String into secure storage using a key from Local Secure Key
  static Future<bool> writeKey({required String key, String? data}) async {
    bool result = false;

    try {
      await _secureStorage.write(
        key: key,
        value: data,
      );

      result = true;
    } catch(e) {
      debugPrint("ERR: $e");
    }

    return result;
  }

  /// Read Key
  ///
  /// This function serve as a command to read data from secure storage using a key from Local Secure Key
  static Future<String?> readKey({required String key}) async {
    String? result;

    try {
      result = await _secureStorage.read(
        key: key,
      );
    } catch(e) {
      debugPrint("ERR: $e");
    }

    return result;
  }

  /// Delete Key
  ///
  /// This function serve as a command to remove data from secure storage using a key from Local Secure Key
  static Future<bool> deleteKey({required String key}) async {
    bool result = false;

    try {
      await _secureStorage.delete(
        key: key,
      );

      result = true;
    } catch(e) {
      debugPrint("ERR: $e");
    }

    return result;
  }

  /// Clear Key
  ///
  /// This function serve as a command to clear any stored data from secure storage
  static Future<bool> clearKey() async {
    bool result = false;

    try {
      await _secureStorage.deleteAll();

      result = true;
    } catch(e) {
      debugPrint("ERR: $e");
    }

    return result;
  }
}

class LocalAPIsRequest {
  static final Dio _dio = Dio();

  /// Submit Request
  ///
  /// This function will handle a network request using Dio
  ///
  /// Parameters:
  /// * Request Type (Required): Determine request type for submitting request (GET, POST, PUT or DELETE).
  /// * APIs URL (Required): URL required to reach APIs address.
  /// * Header Request (Optional): Header that set for request.
  /// * Parameters (Required): Query Parameter that will be carried when reaching APIs address.
  /// * Body Data (Required): Map of data that will be carried when reaching APIs address.
  /// * Connection Timeout in Second (Optional): Timeout set in second, to determined how long request could try reach the APIs address before it's declared as timeout.
  /// * Receive Timeout in Second (Optional): Timeout set in second, to determined how long response could received before it's declared as timeout.
  /// * Use Preserve Header Case (Optional): An option that used as parameter for determined if header need to be keep on sensitve case or not.
  /// * Cancel Token (Optional): If this request run at background and needs to handle cancellation, this parameter need to be declared.
  /// * Error Handler (Optional): Handling an error request and carried DioException and StackTrace result value. You could utilize this function to handle error.
  /// * Using Loading Dialog (Optional): Will show and handle a loading dialog from Local Dialog Function.
  /// * Upload File (Optional): An option that used when you want to upload a file, this parameter will using UploadFile class.
  static Future<Response?> submitRequest({
    required RequestType requestType,
    required String apisURL,
    Map<String, dynamic>? headerRequest,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? bodyData,
    int? connectionTimeoutInSecond,
    int? receiveTimeoutInSecond,
    bool? usePreserveHeadercase,
    CancelToken? cancelToken,
    Function(DioException, StackTrace)? errorHandler,
    BuildContext? usingloadingDialog,
    UploadFile? files,
  }) async {
    _dio.options = BaseOptions(
      headers: headerRequest,
      preserveHeaderCase: usePreserveHeadercase,
      connectTimeout: Duration(
        seconds: connectionTimeoutInSecond ?? 30,
      ),
      receiveTimeout: Duration(
        seconds: receiveTimeoutInSecond ?? 30,
      ),
    );

    if (usingloadingDialog != null) {
      LocalDialogFunction.loadingDialog(
        context: usingloadingDialog,
        cancellationToken: cancelToken,
      );
    }

    try {
      Response? response;
      dynamic requestData = bodyData;

      if (requestType == RequestType.post && files != null && files.files.isNotEmpty) {
        requestData = _buildFormData(files, bodyData);
      }

      switch (requestType) {
        case RequestType.get:
          response = await _dio.get(
            apisURL,
            queryParameters: parameters,
            data: bodyData,
            cancelToken: cancelToken,
          );
          break;
        case RequestType.post:
          response = await _dio.post(
            apisURL,
            queryParameters: parameters,
            data: requestData,
            cancelToken: cancelToken,
          );
          break;
        case RequestType.put:
          response = await _dio.put(
            apisURL,
            queryParameters: parameters,
            data: bodyData,
            cancelToken: cancelToken,
          );
          break;
        case RequestType.delete:
          response = await _dio.delete(
            apisURL,
            queryParameters: parameters,
            data: bodyData,
            cancelToken: cancelToken,
          );
          break;
      }

      if(usingloadingDialog != null && usingloadingDialog.mounted) {
        _dismissLoadingDialog(usingloadingDialog);
      }

      return response;
    } on DioException catch(err, stackTrace) {
      if (err.type != DioExceptionType.cancel) {
        if(usingloadingDialog != null && usingloadingDialog.mounted) {
          _dismissLoadingDialog(usingloadingDialog);
        }
      }

      if (errorHandler != null) {
        errorHandler(err, stackTrace);
      }

      return err.response;
    } catch(e) {
      if(usingloadingDialog != null && usingloadingDialog.mounted) {
        _dismissLoadingDialog(usingloadingDialog);
      }

      rethrow;
    }
  }

  static FormData _buildFormData(UploadFile files, Map<String, dynamic>? bodyData) {
    if (files.isArrayKeyMethod) {
      final tempBodyData = Map<String, dynamic>.from(bodyData ?? {});
      tempBodyData.addEntries(
        files.files.asMap().entries.map(
              (entry) => MapEntry("${files.fileParameterName}[${entry.key}]", MultipartFile.fromFileSync(entry.value.path)),
        ),
      );
      return FormData.fromMap(tempBodyData);
    } else {
      final formData = FormData();
      if (bodyData != null) {
        formData.fields.addAll(bodyData.entries.map((e) => MapEntry(e.key, e.value.toString())));
      }
      formData.files.addAll(
        files.files.map((file) => MapEntry(
          files.fileParameterName,
          MultipartFile.fromFileSync(file.path),
        )),
      );
      return formData;
    }
  }

  static void _dismissLoadingDialog(BuildContext context) {
    LocalRouteNavigator.closeBack(
      context: context,
      callbackResult: "completed",
    );
  }
}
