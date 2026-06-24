import 'package:flutter/material.dart';

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