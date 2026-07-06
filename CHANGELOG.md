## 0.0.10 - 2026-07-06

* 🔥 **NEW UPDATE HAS BEEN DROPPED!**
* **Feature (Network/Security):** Added `withCredentials` parameter to `LocalAPIsRequest.submitRequest` for web security, enabling cross-site requests to securely include cookies and session headers.

## 0.0.9 - 2026-07-06

* 🔥 **NEW UPDATE HAS BEEN DROPPED!**
* **Refactor (Network):** Removed `onStart` and `onFinsih` parameter from `LocalAPIsRequest.submitRequest`. this service are now separated from UI state in order to maintain clean architecture.

## 0.0.8 - 2026-06-24

* 🔥 **NEW UPDATE HAS BEEN DROPPED!**
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