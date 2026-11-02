import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LocalDialogFunction {
  /// Determines whether the current platform should use Cupertino style (iOS / macOS).
  static bool _isCupertino(BuildContext context) {
    TargetPlatform platform;
    try {
      platform = Theme.of(context).platform;
    } catch (_) {
      platform = defaultTargetPlatform;
    }
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  /// Dismiss a previously opened loading dialog safely.
  ///
  /// Passing the default "completed" result ensures that any associated
  /// [CancelToken] is not accidentally cancelled when dismissing upon normal completion.
  static void dismissLoadingDialog(BuildContext context, [dynamic result = "completed"]) {
    Navigator.of(context).pop(result);
  }

  /// OK Dialog
  ///
  /// Displays an adaptive alert dialog:
  /// * On iOS / macOS: Renders a [CupertinoAlertDialog] using [showCupertinoDialog].
  /// * On Android / others: Renders a Material [AlertDialog] using [showDialog].
  ///
  /// Parameters:
  /// * [context] (Required): BuildContext required for dialog functions.
  /// * [title] (Optional): Title displayed at the top of the alert dialog.
  /// * [contentText] (Required): Text body of the alert dialog.
  /// * [onClose] (Optional): Callback function executed after the dialog is closed.
  /// * [contentAlign] (Optional): Alignment for the content text.
  /// * [barrierDismissible] (Optional): Whether tapping outside the dialog dismisses it. Default is true.
  /// * [okText] (Optional): Label for the OK button. Default is "OK".
  static Future<void> okDialog({
    required BuildContext context,
    String? title,
    required String contentText,
    VoidCallback? onClose,
    TextAlign? contentAlign,
    bool barrierDismissible = true,
    String okText = "OK",
  }) async {
    final bool useCupertino = _isCupertino(context);

    if (useCupertino) {
      await showCupertinoDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (dialogContext) {
          return CupertinoAlertDialog(
            title: title != null ? Text(title) : null,
            content: Text(
              contentText,
              textAlign: contentAlign ?? TextAlign.center,
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(okText),
              ),
            ],
          );
        },
      );
    } else {
      await showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (dialogContext) {
          return AlertDialog(
            title: title != null ? Text(title) : null,
            content: Text(
              contentText,
              textAlign: contentAlign ?? TextAlign.start,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(okText),
              ),
            ],
          );
        },
      );
    }

    onClose?.call();
  }

  /// Option Dialog
  ///
  /// Displays an adaptive alert dialog with two choice buttons:
  /// * On iOS / macOS: Renders a [CupertinoAlertDialog] using [showCupertinoDialog].
  /// * On Android / others: Renders a Material [AlertDialog] using [showDialog].
  ///
  /// Returns `true` if accepted, `false` if declined, or `null` if dismissed.
  ///
  /// Parameters:
  /// * [context] (Required): BuildContext required for dialog functions.
  /// * [title] (Optional): Title displayed at the top of the alert dialog.
  /// * [contentText] (Required): Text body of the alert dialog.
  /// * [declineText] (Optional): Label for the decline button. Default is "No".
  /// * [acceptText] (Optional): Label for the accept button. Default is "Yes".
  /// * [onDecline] (Optional): Callback function executed when declined.
  /// * [onAccept] (Required): Callback function executed when accepted.
  /// * [contentAlign] (Optional): Alignment for the content text.
  /// * [barrierDismissible] (Optional): Whether tapping outside dismisses the dialog. Default is true.
  static Future<bool?> optionDialog({
    required BuildContext context,
    String? title,
    required String contentText,
    String? declineText,
    String? acceptText,
    VoidCallback? onDecline,
    required VoidCallback onAccept,
    TextAlign? contentAlign,
    bool barrierDismissible = true,
  }) async {
    final bool useCupertino = _isCupertino(context);
    final String noText = declineText ?? "No";
    final String yesText = acceptText ?? "Yes";

    final bool? result;
    if (useCupertino) {
      result = await showCupertinoDialog<bool>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (dialogContext) {
          return CupertinoAlertDialog(
            title: title != null ? Text(title) : null,
            content: Text(
              contentText,
              textAlign: contentAlign ?? TextAlign.center,
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(noText),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(yesText),
              ),
            ],
          );
        },
      );
    } else {
      result = await showDialog<bool>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (dialogContext) {
          return AlertDialog(
            title: title != null ? Text(title) : null,
            content: Text(
              contentText,
              textAlign: contentAlign ?? TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(noText),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(yesText),
              ),
            ],
          );
        },
      );
    }

    if (result == true) {
      onAccept();
    } else if (result == false) {
      onDecline?.call();
    }

    return result;
  }

  /// Loading Dialog
  ///
  /// Displays an adaptive, non-interruptible (or cancellable) loading dialog:
  /// * On iOS / macOS: Renders [CupertinoAlertDialog] with [CupertinoActivityIndicator].
  /// * On Android / others: Renders Material [AlertDialog] with [CircularProgressIndicator].
  ///
  /// To close this dialog programmatically without cancelling the [cancellationToken],
  /// call [dismissLoadingDialog] or `Navigator.of(context).pop("completed")`.
  ///
  /// Parameters:
  /// * [context] (Required): BuildContext required for dialog functions.
  /// * [contentText] (Optional): Text displayed above the progress spinner. Default is "Loading data, please wait...".
  /// * [contentAlign] (Optional): Alignment of content text.
  /// * [cancellationToken] (Optional): If provided, allows user to dismiss the dialog which automatically cancels this token.
  /// * [canPop] (Optional): Explicitly allow or disallow back navigation. Default is false unless [cancellationToken] is supplied.
  static Future<T?> loadingDialog<T>({
    required BuildContext context,
    String? contentText,
    TextAlign? contentAlign,
    CancelToken? cancellationToken,
    bool? canPop,
  }) async {
    final bool dismissible = canPop ?? (cancellationToken != null);
    final bool useCupertino = _isCupertino(context);
    final String loadingText = contentText ?? "Loading data, please wait...";

    Widget buildLoadingContent() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            loadingText,
            textAlign: contentAlign ?? (useCupertino ? TextAlign.center : TextAlign.start),
          ),
          const SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                useCupertino
                    ? const CupertinoActivityIndicator(radius: 14.0)
                    : const CircularProgressIndicator(),
              ],
            ),
          ),
        ],
      );
    }

    Widget buildDialog(BuildContext dialogContext) {
      final Widget dialog = useCupertino
          ? CupertinoAlertDialog(content: buildLoadingContent())
          : AlertDialog(content: buildLoadingContent());

      return PopScope(
        canPop: dismissible,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop &&
              result != "completed" &&
              cancellationToken != null &&
              !cancellationToken.isCancelled) {
            cancellationToken.cancel();
          }
        },
        child: dialog,
      );
    }

    if (useCupertino) {
      return await showCupertinoDialog<T>(
        context: context,
        barrierDismissible: dismissible,
        builder: buildDialog,
      );
    } else {
      return await showDialog<T>(
        context: context,
        barrierDismissible: dismissible,
        builder: buildDialog,
      );
    }
  }
}
