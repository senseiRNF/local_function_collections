import 'package:flutter/material.dart';

class LocalRouteNavigator {
  /// Move To
  ///
  /// Navigates to a new page, keeping the previous page in the route stack.
  /// Returns a [Future] that completes to the result value passed when the route is popped.
  ///
  /// Parameters:
  /// * [context] (Required): BuildContext required for Navigator function.
  /// * [target] (Required): Target Widget intended as destination.
  /// * [callbackFunction] (Optional): Callback function executed when returning from the target page.
  static Future<T?> moveTo<T extends Object?>({
    required BuildContext context,
    required Widget target,
    Function(T? result)? callbackFunction,
  }) async {
    final T? callbackResult = await Navigator.of(context).push<T>(
      MaterialPageRoute<T>(
        builder: (targetContext) => target,
      ),
    );

    if (callbackFunction != null) {
      callbackFunction(callbackResult);
    }

    return callbackResult;
  }

  /// Replace With
  ///
  /// Navigates to a new page by replacing the current route.
  /// Returns a [Future] that completes to the result value passed when the route is popped.
  ///
  /// Parameters:
  /// * [context] (Required): BuildContext required for Navigator function.
  /// * [target] (Required): Target Widget intended as destination.
  /// * [result] (Optional): Value to return to the route that pushed this current route.
  static Future<T?> replaceWith<T extends Object?, TO extends Object?>({
    required BuildContext context,
    required Widget target,
    TO? result,
  }) {
    return Navigator.of(context).pushReplacement<T, TO>(
      MaterialPageRoute<T>(builder: (targetContext) => target),
      result: result,
    );
  }

  /// Redirect To
  ///
  /// Navigates to a new page and removes previous routes according to [predicate].
  /// By default, all previous routes in the stack are removed.
  ///
  /// Parameters:
  /// * [context] (Required): BuildContext required for Navigator function.
  /// * [target] (Required): Target Widget intended as destination.
  /// * [predicate] (Optional): Determines which routes to keep. Defaults to removing all routes (`(_) => false`).
  static Future<T?> redirectTo<T extends Object?>({
    required BuildContext context,
    required Widget target,
    RoutePredicate? predicate,
  }) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      MaterialPageRoute<T>(builder: (targetContext) => target),
      predicate ?? (_) => false,
    );
  }

  /// Close Back
  ///
  /// Pops the current page from the navigation stack.
  ///
  /// Parameters:
  /// * [context] (Required): BuildContext required for Navigator function.
  /// * [callbackResult] (Optional): Return value passed back to the previous route.
  static void closeBack<T extends Object?>({
    required BuildContext context,
    T? callbackResult,
  }) {
    Navigator.of(context).pop<T>(callbackResult);
  }
}
