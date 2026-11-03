/// A utility class for safely parsing and casting dynamic JSON values.
///
/// Handles common backend response inconsistencies such as numbers delivered
/// as strings, double/int mismatches, boolean flags encoded as integers or strings,
/// null safety issues, and loosely typed collections.
class SafeJson {
  SafeJson._();

  /// Default common JSON wrapper keys checked during recursive key lookup.
  static const List<String> defaultWrappers = [
    'data',
    'user',
    'result',
    'results',
    'payload',
    'attributes',
    'response',
    'item',
    'items',
    'details',
    'detail',
    'body',
    'content',
  ];

  /// Safely converts [value] to a [String].
  ///
  /// * Returns [defaultValue] if [value] is `null`.
  /// * Returns [value] if it is already a [String].
  /// * For other types (e.g., [num], [bool], [Object]), calls `toString()`.
  ///
  /// Example:
  /// ```dart
  /// SafeJson.optString(123); // '123'
  /// SafeJson.optString(null, 'default'); // 'default'
  /// ```
  static String? optString(dynamic value, [String? defaultValue]) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    return value.toString();
  }

  /// Safely converts [value] to an [int].
  ///
  /// * Returns [defaultValue] if [value] is `null` or cannot be parsed.
  /// * Handles [int], [double] (truncated to int), and [bool] (`1` or `0`).
  /// * Handles [String] numbers, including floating-point strings like `"123.0"`.
  ///
  /// Example:
  /// ```dart
  /// SafeJson.optInt('123'); // 123
  /// SafeJson.optInt('123.5'); // 123
  /// SafeJson.optInt(123.45); // 123
  /// SafeJson.optInt('invalid', 0); // 0
  /// ```
  static int? optInt(dynamic value, [int? defaultValue]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is bool) return value ? 1 : 0;
    if (value is String) {
      final trimmed = value.trim();
      final parsedInt = int.tryParse(trimmed);
      if (parsedInt != null) return parsedInt;
      final parsedDouble = double.tryParse(trimmed);
      if (parsedDouble != null) return parsedDouble.toInt();
    }
    return defaultValue;
  }

  /// Safely converts [value] to a [double].
  ///
  /// * Returns [defaultValue] if [value] is `null` or cannot be parsed.
  /// * Handles [double], [int], and [bool] (`1.0` or `0.0`).
  /// * Handles numeric [String] values.
  ///
  /// Example:
  /// ```dart
  /// SafeJson.optDouble('12.34'); // 12.34
  /// SafeJson.optDouble(12); // 12.0
  /// SafeJson.optDouble(null, 0.0); // 0.0
  /// ```
  static double? optDouble(dynamic value, [double? defaultValue]) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is bool) return value ? 1.0 : 0.0;
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
    return defaultValue;
  }

  /// Safely converts [value] to a [bool].
  ///
  /// * Returns [defaultValue] if [value] is `null` or cannot be recognized.
  /// * Directly returns [value] if it is already a [bool].
  /// * Handles [num] where `0` is `false` and any non-zero value is `true`.
  /// * Handles string literals like `'true'`, `'false'`, `'1'`, `'0'`, `'yes'`, `'no'`, `'y'`, `'n'`.
  ///
  /// Example:
  /// ```dart
  /// SafeJson.optBool('true'); // true
  /// SafeJson.optBool('1'); // true
  /// SafeJson.optBool(0); // false
  /// SafeJson.optBool(null, false); // false
  /// ```
  static bool? optBool(dynamic value, [bool? defaultValue]) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' ||
          normalized == '1' ||
          normalized == 'yes' ||
          normalized == 'y' ||
          normalized == 't') {
        return true;
      }
      if (normalized == 'false' ||
          normalized == '0' ||
          normalized == 'no' ||
          normalized == 'n' ||
          normalized == 'f') {
        return false;
      }
    }
    return defaultValue;
  }

  /// Safely extracts a [Map<String, dynamic>] from [value].
  ///
  /// * If [value] is already `Map<String, dynamic>`, returns it as-is.
  /// * If [value] is a generic [Map], converts all keys to [String].
  /// * Returns [defaultValue] or an empty map `<String, dynamic>{}` if [value] is invalid.
  ///
  /// Example:
  /// ```dart
  /// SafeJson.optMap({'name': 'John'}); // {'name': 'John'}
  /// SafeJson.optMap(null); // {}
  /// ```
  static Map<String, dynamic> optMap(
    dynamic value, [
    Map<String, dynamic>? defaultValue,
  ]) {
    if (value == null) return defaultValue ?? <String, dynamic>{};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return defaultValue ?? <String, dynamic>{};
  }

  /// Safely extracts a [List] of mapped objects of type [T].
  ///
  /// Iterates through [value], safely extracts each element as a [Map],
  /// and applies the [mapper] function. If an item fails mapping or throws
  /// an error, it is skipped gracefully to preserve other valid entries.
  ///
  /// Example:
  /// ```dart
  /// final users = SafeJson.optList(json['users'], (map) => User.fromJson(map));
  /// ```
  static List<T> optList<T>(
    dynamic value,
    T Function(Map<String, dynamic> json) mapper,
  ) {
    if (value is! List) return <T>[];
    final result = <T>[];
    for (final item in value) {
      if (item is Map) {
        try {
          final mapped = mapper(optMap(item));
          result.add(mapped);
        } catch (_) {
          // Gracefully skip corrupted or incompatible items
        }
      }
    }
    return result;
  }

  /// Safely extracts a [List] of primitive or direct types of type [T].
  ///
  /// Useful for extracting lists of strings, numbers, or booleans without
  /// crashing when null or mismatched entries occur.
  ///
  /// Example:
  /// ```dart
  /// final tags = SafeJson.optPrimitiveList<String>(json['tags']);
  /// ```
  static List<T> optPrimitiveList<T>(dynamic value, [List<T>? defaultValue]) {
    if (value is! List) return defaultValue ?? <T>[];
    final result = <T>[];
    for (final item in value) {
      if (item is T) {
        result.add(item);
      } else if (T == String && item != null) {
        result.add(item.toString() as T);
      } else if (T == int) {
        final parsed = optInt(item);
        if (parsed != null) result.add(parsed as T);
      } else if (T == double) {
        final parsed = optDouble(item);
        if (parsed != null) result.add(parsed as T);
      } else if (T == bool) {
        final parsed = optBool(item);
        if (parsed != null) result.add(parsed as T);
      }
    }
    return result;
  }

  /// Safely extracts a [String] from a hybrid/polyvalent field that could be either
  /// a raw [String] or a [Map] containing [mapKeyToExtract].
  ///
  /// * If [value] is a [String], returns the string as-is.
  /// * If [value] is a [Map], extracts the value of [mapKeyToExtract] from the map.
  /// * If [value] is `null` or the key is not found, returns [defaultValue].
  ///
  /// Example:
  /// ```dart
  /// // When avatar is "https://site.com/pic.png":
  /// SafeJson.optStringOrMapValue('https://site.com/pic.png', 'url'); // 'https://site.com/pic.png'
  ///
  /// // When avatar is {"url": "https://site.com/pic.png", "width": 200}:
  /// SafeJson.optStringOrMapValue({'url': 'https://site.com/pic.png'}, 'url'); // 'https://site.com/pic.png'
  /// ```
  static String? optStringOrMapValue(
    dynamic value,
    String mapKeyToExtract, [
    String? defaultValue,
  ]) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    if (value is Map) {
      final map = optMap(value);
      return map.getSafeString(mapKeyToExtract, defaultValue);
    }
    return optString(value, defaultValue);
  }

  /// Safely extracts a [Map<String, dynamic>] from a hybrid/polyvalent field that
  /// could be either a [Map] or a raw [String].
  ///
  /// * If [value] is a [Map], returns it safely as a `Map<String, dynamic>`.
  /// * If [value] is a [String] or primitive, wraps it in a map under [stringKeyAsFallback].
  /// * If [value] is `null`, returns [defaultValue] or an empty map `<String, dynamic>{}`.
  ///
  /// Example:
  /// ```dart
  /// // When author is {"name": "Alice", "id": 1}:
  /// SafeJson.optMapOrFallbackString({'name': 'Alice'}, 'name'); // {'name': 'Alice'}
  ///
  /// // When author is "Alice":
  /// SafeJson.optMapOrFallbackString('Alice', 'name'); // {'name': 'Alice'}
  /// ```
  static Map<String, dynamic> optMapOrFallbackString(
    dynamic value,
    String stringKeyAsFallback, [
    Map<String, dynamic>? defaultValue,
  ]) {
    if (value == null) return defaultValue ?? <String, dynamic>{};
    if (value is Map) return optMap(value);
    if (value is String) {
      return <String, dynamic>{stringKeyAsFallback: value};
    }
    if (value is num || value is bool) {
      return <String, dynamic>{stringKeyAsFallback: value.toString()};
    }
    return defaultValue ?? <String, dynamic>{};
  }
}

/// Extension on [Map<String, dynamic>] providing resilient key lookup and fluent getters.
extension SafeJsonExtension on Map<String, dynamic> {
  /// Searches for the first matching key from [keys].
  ///
  /// Key resolution order:
  /// 1. Direct key match in the current map with a non-null value.
  /// 2. Recursively searches inside common response wrappers (e.g. `data`, `user`, `result`).
  /// 3. Recursively searches other nested maps up to [maxDepth] levels deep.
  /// 4. Direct key match in the current map even if its value is `null`.
  ///
  /// Example:
  /// ```dart
  /// final map = {
  ///   'status': 'success',
  ///   'data': {'user_id': 100}
  /// };
  ///
  /// map.findKey(['id', 'user_id']); // 100
  /// ```
  dynamic findKey(
    List<String> keys, {
    List<String>? wrappers,
    int maxDepth = 3,
  }) {
    // 1. Direct root check for non-null value
    for (final key in keys) {
      if (containsKey(key) && this[key] != null) {
        return this[key];
      }
    }

    if (maxDepth <= 0) {
      // Check if root contains any key with explicit null
      for (final key in keys) {
        if (containsKey(key)) return this[key];
      }
      return null;
    }

    final targetWrappers = wrappers ?? SafeJson.defaultWrappers;

    // 2. Search prioritized wrappers first
    for (final wrapper in targetWrappers) {
      final nested = this[wrapper];
      if (nested is Map) {
        final nestedMap = SafeJson.optMap(nested);
        final found = nestedMap.findKey(
          keys,
          wrappers: targetWrappers,
          maxDepth: maxDepth - 1,
        );
        if (found != null) return found;
      }
    }

    // 3. Search other nested maps
    for (final entry in entries) {
      if (!targetWrappers.contains(entry.key) && entry.value is Map) {
        final nestedMap = SafeJson.optMap(entry.value);
        final found = nestedMap.findKey(
          keys,
          wrappers: targetWrappers,
          maxDepth: maxDepth - 1,
        );
        if (found != null) return found;
      }
    }

    // 4. Fallback check for root key containing explicit null
    for (final key in keys) {
      if (containsKey(key)) {
        return this[key];
      }
    }

    return null;
  }

  /// Internal helper to extract dynamic value from single key or key list.
  dynamic _findValue(dynamic key) {
    if (key is List<String>) {
      return findKey(key);
    } else if (key is List) {
      return findKey(key.map((e) => e.toString()).toList());
    } else if (key is String) {
      return findKey([key]);
    }
    return null;
  }

  /// Safely extracts a [String] value.
  ///
  /// Accepts either a single key [String] or a fallback [List] of keys.
  /// If the value is missing or null, returns [defaultValue].
  ///
  /// Example:
  /// ```dart
  /// map.getSafeString('name');
  /// map.getSafeString(['user_name', 'name'], 'Anonymous');
  /// ```
  String? getSafeString(dynamic key, [String? defaultValue]) {
    final value = _findValue(key);
    return SafeJson.optString(value, defaultValue);
  }

  /// Safely extracts an [int] value.
  ///
  /// Accepts either a single key [String] or a fallback [List] of keys.
  /// Automatically parses string numbers (e.g. `"123"`) or double numbers (e.g. `123.0`).
  /// If the value is missing or null, returns [defaultValue].
  ///
  /// Example:
  /// ```dart
  /// map.getSafeInt('age');
  /// map.getSafeInt(['user_id', 'id'], 0);
  /// ```
  int? getSafeInt(dynamic key, [int? defaultValue]) {
    final value = _findValue(key);
    return SafeJson.optInt(value, defaultValue);
  }

  /// Safely extracts a [double] value.
  ///
  /// Accepts either a single key [String] or a fallback [List] of keys.
  /// Automatically parses string doubles (e.g. `"123.45"`) or integer numbers.
  /// If the value is missing or null, returns [defaultValue].
  ///
  /// Example:
  /// ```dart
  /// map.getSafeDouble('price');
  /// map.getSafeDouble(['discount_rate', 'rate'], 0.0);
  /// ```
  double? getSafeDouble(dynamic key, [double? defaultValue]) {
    final value = _findValue(key);
    return SafeJson.optDouble(value, defaultValue);
  }

  /// Safely extracts a [bool] value.
  ///
  /// Accepts either a single key [String] or a fallback [List] of keys.
  /// Handles booleans, numbers (`1`/`0`), and string representations (`"true"`, `"false"`).
  /// If the value is missing or null, returns [defaultValue].
  ///
  /// Example:
  /// ```dart
  /// map.getSafeBool('is_active');
  /// map.getSafeBool(['verified', 'is_verified'], false);
  /// ```
  bool? getSafeBool(dynamic key, [bool? defaultValue]) {
    final value = _findValue(key);
    return SafeJson.optBool(value, defaultValue);
  }

  /// Safely extracts a nested [Map<String, dynamic>].
  ///
  /// Accepts either a single key [String] or a fallback [List] of keys.
  /// Returns [defaultValue] (or empty map `{}`) if not found or invalid.
  ///
  /// Example:
  /// ```dart
  /// final profile = map.getSafeMap('profile');
  /// ```
  Map<String, dynamic> getSafeMap(
    dynamic key, [
    Map<String, dynamic>? defaultValue,
  ]) {
    final value = _findValue(key);
    return SafeJson.optMap(value, defaultValue);
  }

  /// Safely extracts a [List] of mapped objects.
  ///
  /// Accepts either a single key [String] or a fallback [List] of keys.
  /// Uses [mapper] to map each nested JSON map into type [T].
  ///
  /// Example:
  /// ```dart
  /// final items = map.getSafeList('items', (json) => Item.fromJson(json));
  /// ```
  List<T> getSafeList<T>(
    dynamic key,
    T Function(Map<String, dynamic> json) mapper,
  ) {
    final value = _findValue(key);
    return SafeJson.optList<T>(value, mapper);
  }

  /// Safely extracts a [List] of primitive types.
  ///
  /// Accepts either a single key [String] or a fallback [List] of keys.
  ///
  /// Example:
  /// ```dart
  /// final tags = map.getSafePrimitiveList<String>('tags');
  /// ```
  List<T> getSafePrimitiveList<T>(dynamic key, [List<T>? defaultValue]) {
    final value = _findValue(key);
    return SafeJson.optPrimitiveList<T>(value, defaultValue);
  }

  /// Safely extracts a [String] from a field that could be either a primitive [String]
  /// or a [Map] containing [mapKeyToExtract].
  ///
  /// Useful for hybrid/polyvalent backend responses where a property might be
  /// `"https://site.com/image.png"` or `{"url": "https://site.com/image.png"}`.
  ///
  /// Example:
  /// ```dart
  /// final avatar = map.getSafeStringOrMapValue('avatar', 'url');
  /// ```
  String? getSafeStringOrMapValue(
    dynamic key,
    String mapKeyToExtract, [
    String? defaultValue,
  ]) {
    final value = _findValue(key);
    return SafeJson.optStringOrMapValue(
      value,
      mapKeyToExtract,
      defaultValue,
    );
  }

  /// Safely extracts a [Map<String, dynamic>] from a field that could be either
  /// a [Map] or a raw [String].
  ///
  /// If the backend sends a [String] instead of an expected [Map], this wraps
  /// the string into a map under [stringKeyAsFallback].
  ///
  /// Example:
  /// ```dart
  /// // When category is {"name": "Tech"} -> returns {'name': 'Tech'}
  /// // When category is "Tech" -> returns {'name': 'Tech'}
  /// final categoryMap = map.getSafeMapOrFallbackString('category', 'name');
  /// ```
  Map<String, dynamic> getSafeMapOrFallbackString(
    dynamic key,
    String stringKeyAsFallback, [
    Map<String, dynamic>? defaultValue,
  ]) {
    final value = _findValue(key);
    return SafeJson.optMapOrFallbackString(
      value,
      stringKeyAsFallback,
      defaultValue,
    );
  }
}

