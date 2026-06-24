import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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