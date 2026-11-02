## 0.0.14 - 2026-11-02

* **Feature (UI/Dialog):** Added adaptive dialog support to `LocalDialogFunction` (`okDialog`, `optionDialog`, and `loadingDialog`) — automatically rendering Material styles on Android and Cupertino styles on iOS / macOS.
* **Fix (UI/Dialog):** Resolved context deactivation warnings and potential pop leaks in `okDialog` and `optionDialog` by properly utilizing `dialogContext`.
* **Fix (UI/Dialog):** Added `dismissLoadingDialog` and improved `PopScope` cancellation logic to avoid accidentally cancelling `CancelToken` on standard dialog dismissal.
* **Feature (UI/Dialog):** `optionDialog` now returns `Future<bool?>`, enabling callers to directly `await` user response in addition to callbacks.
* **Fix (Navigation):** Fixed `LocalRouteNavigator.moveTo` dropping the popped return value; callers can now `await` the returned route result.
* **Feature (Navigation):** Added full generic type support (`<T>`) across `moveTo`, `replaceWith`, `redirectTo`, and `closeBack`.
* **Feature (Network):** Added `RequestType.patch` to `LocalAPIsRequest` and `RequestType` enum.
* **Feature (Network):** Added multipart file upload support to `PUT` and `PATCH` requests in `LocalAPIsRequest.submitRequest`.
* **Fix (Network):** Correctly mapped `connectionTimeoutInSecond` to `connectTimeout` in `Options` and added `sendTimeoutInSecond`.
* **Feature (Network/Security):** Added optional `allowedHosts` host validation to `LocalAPIsRequest.setupCertificatePinning`.
* **Feature (Network):** Added `LocalAPIsRequest.dio` accessor and `clearInterceptors()` method.
* **Feature (Models):** Added `UploadFile.fromBytes`, `UploadFile.fromMultipartFiles`, and `isSingleFile` option for Flutter Web and cross-platform uploads.
* **Feature (Storage):** Added `LocalSecureStorage.configure` for custom platform options / test mocking, plus `containsKey` and `readAll` methods.
* **Refactor (Exports):** Re-exported essential types from `dio`, `flutter_secure_storage`, and Flutter widgets in `local_function_collections.dart`.

## 0.0.13 - 2026-08-06

* **Feature (Network):** Enable `DioExceptionType` to be accessed inside the project without importing Dio.

## 0.0.12 - 2026-07-09

* **Feature (Network/Security):** Added `setupCertificatePinning` method to `LocalAPIsRequest` class, enabling robust SSL/TLS certificate pinning via SHA-256 fingerprints to mitigate Man-In-The-Middle (MITM) attacks.
* **Refactor (Network/Security):** Enforced strict handshake validation by setting `withTrustedRoots: false` to bypass the OS trust store, ensuring absolute fingerprint matching.
* **Performance (Network):** Optimized memory allocation within `setupCertificatePinning` by isolating and pre-compiling string normalization patterns (`cleanAllowedPins`) outside the HTTP client stream loop.
* **Fix (Network/Web):** Added `kIsWeb` guards inside `setupCertificatePinning` to prevent compilation overhead and runtime failures related to `dart:io` on browser platforms.
* **Fix (Network/HTTP):** Streamlined `RequestType.get` processing by removing the `data` body parameter from the underlying Dio instance, ensuring strict compliance with standard HTTP GET specifications across different backend servers.

## 0.0.11- 2026-07-08

* **Feature (Network/Interceptors):** Added `addInterceptors` method to `LocalAPIsRequest` class, allowing developers to inject custom interceptors (e.g., Auth, Logging, Performance) globally.
* **Refactor (Network/Timeout):** Centralized default connection and receive timeouts inside `BaseOptions` (default 30 seconds) instead of request-specific `Options`.

## 0.0.10 - 2026-07-07

* **Feature (Network/Security):** Added `withCredentials` parameter to `LocalAPIsRequest.submitRequest` for web security, enabling cross-site requests to securely include cookies and session headers.

## 0.0.9 - 2026-07-06

* **Refactor (Network):** Removed `onStart` and `onFinsih` parameter from `LocalAPIsRequest.submitRequest`. this service are now separated from UI state in order to maintain clean architecture.

## 0.0.8 - 2026-06-24

* **Refactor (Network):** Removed `usingloadingDialog` parameter from `LocalAPIsRequest.submitRequest` and replaced it with flexible `onStart` and `onFinish` callbacks. This decouples the UI layer from network data complexity for a cleaner architecture.
* **Fix (Network/UI):** Handled `DioExceptionType.cancel` and optimized `onFinish` execution order to prevent unexpected page dismissal or frozen loading states during network errors.

## 0.0.7 - 2026-05-25

* **Refactor:** Optimized code imports and structure, leading to faster project compilation times.

## 0.0.6 - 2026-04-09

* **Feature:** Re-exported Dio components globally. You can now access Dio utilities without needing to import the package manually in your main project.

## 0.0.5 - 2026-01-22

* **Feature:** Added `files` parameter support in `LocalAPIsRequest.submitRequest` for handling file uploads.

## 0.0.4 - 2025-11-14

* **Feature:** Added `usePreserveHeaderCase` option in `LocalAPIsRequest.submitRequest`.

## 0.0.3 - 2025-11-03

* **Refactor:** Migrated `LocalRouteNavigator` to use `Widget` instead of `StatefulWidget` for broader compatibility.
* **Feature:** Re-exported `CancelToken` from Dio so it can be used directly without additional imports.

## 0.0.2 - 2025-09-18

* **Feature:** Introduced `LocalAPIsRequest` helper class to manage network requests (GET, POST, PUT, DELETE).

## 0.0.1 - 2024-11-20

* 🎉 Initial release of Local Function Collections.

---

### 📢 Community & Support

Every critique and advice is welcome! Feel free to reach me on:
* **Instagram:** [@raznovrnf](https://instagram.com/raznovrnf)
* **LinkedIn:** [Razy Firdana](https://linkedin.com/in/razyfirdana)

Thanks for all the support! 🚀