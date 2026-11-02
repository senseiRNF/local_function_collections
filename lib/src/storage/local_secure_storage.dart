import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalSecureStorage {
  static FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Configure custom storage options or inject a custom instance (e.g., for testing).
  static void configure({
    FlutterSecureStorage? secureStorage,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
  }) {
    if (secureStorage != null) {
      _secureStorage = secureStorage;
    } else {
      _secureStorage = FlutterSecureStorage(
        aOptions: aOptions ?? AndroidOptions.defaultOptions,
        iOptions: iOptions ?? IOSOptions.defaultOptions,
        lOptions: lOptions ?? LinuxOptions.defaultOptions,
        wOptions: wOptions ?? WindowsOptions.defaultOptions,
        webOptions: webOptions ?? WebOptions.defaultOptions,
        mOptions: mOptions ?? MacOsOptions.defaultOptions,
      );
    }
  }

  /// Direct access to the underlying [FlutterSecureStorage] instance.
  static FlutterSecureStorage get instance => _secureStorage;

  /// Write Key
  ///
  /// Stores a [String] value into secure storage for the given [key].
  static Future<bool> writeKey({
    required String key,
    String? data,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
  }) async {
    bool result = false;

    try {
      await _secureStorage.write(
        key: key,
        value: data,
        aOptions: aOptions,
        iOptions: iOptions,
      );

      result = true;
    } catch (e) {
      debugPrint("ERR [writeKey]: $e");
    }

    return result;
  }

  /// Read Key
  ///
  /// Reads data from secure storage using the specified [key].
  static Future<String?> readKey({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
  }) async {
    String? result;

    try {
      result = await _secureStorage.read(
        key: key,
        aOptions: aOptions,
        iOptions: iOptions,
      );
    } catch (e) {
      debugPrint("ERR [readKey]: $e");
    }

    return result;
  }

  /// Contains Key
  ///
  /// Returns `true` if secure storage contains the given [key].
  static Future<bool> containsKey({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
  }) async {
    bool result = false;

    try {
      result = await _secureStorage.containsKey(
        key: key,
        aOptions: aOptions,
        iOptions: iOptions,
      );
    } catch (e) {
      debugPrint("ERR [containsKey]: $e");
    }

    return result;
  }

  /// Read All
  ///
  /// Reads all key-value pairs stored in secure storage.
  static Future<Map<String, String>> readAll({
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
  }) async {
    Map<String, String> result = {};

    try {
      result = await _secureStorage.readAll(
        aOptions: aOptions,
        iOptions: iOptions,
      );
    } catch (e) {
      debugPrint("ERR [readAll]: $e");
    }

    return result;
  }

  /// Delete Key
  ///
  /// Removes data associated with the specified [key] from secure storage.
  static Future<bool> deleteKey({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
  }) async {
    bool result = false;

    try {
      await _secureStorage.delete(
        key: key,
        aOptions: aOptions,
        iOptions: iOptions,
      );

      result = true;
    } catch (e) {
      debugPrint("ERR [deleteKey]: $e");
    }

    return result;
  }

  /// Clear Key
  ///
  /// Clears all stored data from secure storage.
  static Future<bool> clearKey({
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
  }) async {
    bool result = false;

    try {
      await _secureStorage.deleteAll(
        aOptions: aOptions,
        iOptions: iOptions,
      );

      result = true;
    } catch (e) {
      debugPrint("ERR [clearKey]: $e");
    }

    return result;
  }
}
