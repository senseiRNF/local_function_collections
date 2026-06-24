import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

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