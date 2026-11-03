import 'package:flutter_test/flutter_test.dart';
import 'package:local_function_collections/local_function_collections.dart';

void main() {
  group('SafeJson Utility Tests', () {
    group('optString', () {
      test('returns string as-is', () {
        expect(SafeJson.optString('hello'), 'hello');
      });

      test('returns defaultValue when null', () {
        expect(SafeJson.optString(null), isNull);
        expect(SafeJson.optString(null, 'default'), 'default');
      });

      test('converts numbers and booleans to string', () {
        expect(SafeJson.optString(123), '123');
        expect(SafeJson.optString(45.67), '45.67');
        expect(SafeJson.optString(true), 'true');
        expect(SafeJson.optString(false), 'false');
      });

      test('converts custom objects to string', () {
        expect(SafeJson.optString([1, 2]), '[1, 2]');
      });
    });

    group('optInt', () {
      test('returns int as-is', () {
        expect(SafeJson.optInt(42), 42);
      });

      test('returns defaultValue when null or invalid', () {
        expect(SafeJson.optInt(null), isNull);
        expect(SafeJson.optInt(null, 10), 10);
        expect(SafeJson.optInt('not_a_number', 5), 5);
      });

      test('converts double to int', () {
        expect(SafeJson.optInt(42.0), 42);
        expect(SafeJson.optInt(42.9), 42);
      });

      test('converts numeric string to int', () {
        expect(SafeJson.optInt('123'), 123);
        expect(SafeJson.optInt('  123  '), 123);
        expect(SafeJson.optInt('123.0'), 123);
        expect(SafeJson.optInt('123.85'), 123);
      });

      test('converts boolean to int', () {
        expect(SafeJson.optInt(true), 1);
        expect(SafeJson.optInt(false), 0);
      });
    });

    group('optDouble', () {
      test('returns double as-is', () {
        expect(SafeJson.optDouble(3.14), 3.14);
      });

      test('converts int to double', () {
        expect(SafeJson.optDouble(42), 42.0);
      });

      test('converts numeric string to double', () {
        expect(SafeJson.optDouble('12.34'), 12.34);
        expect(SafeJson.optDouble('  100  '), 100.0);
      });

      test('converts boolean to double', () {
        expect(SafeJson.optDouble(true), 1.0);
        expect(SafeJson.optDouble(false), 0.0);
      });

      test('returns defaultValue when null or invalid', () {
        expect(SafeJson.optDouble(null), isNull);
        expect(SafeJson.optDouble(null, 0.5), 0.5);
        expect(SafeJson.optDouble('abc', 1.5), 1.5);
      });
    });

    group('optBool', () {
      test('returns bool as-is', () {
        expect(SafeJson.optBool(true), isTrue);
        expect(SafeJson.optBool(false), isFalse);
      });

      test('converts numbers to bool', () {
        expect(SafeJson.optBool(1), isTrue);
        expect(SafeJson.optBool(0), isFalse);
        expect(SafeJson.optBool(99), isTrue);
      });

      test('converts standard string literals to bool', () {
        expect(SafeJson.optBool('true'), isTrue);
        expect(SafeJson.optBool('True'), isTrue);
        expect(SafeJson.optBool('TRUE'), isTrue);
        expect(SafeJson.optBool('1'), isTrue);
        expect(SafeJson.optBool('yes'), isTrue);
        expect(SafeJson.optBool('y'), isTrue);
        expect(SafeJson.optBool('t'), isTrue);

        expect(SafeJson.optBool('false'), isFalse);
        expect(SafeJson.optBool('False'), isFalse);
        expect(SafeJson.optBool('0'), isFalse);
        expect(SafeJson.optBool('no'), isFalse);
        expect(SafeJson.optBool('n'), isFalse);
        expect(SafeJson.optBool('f'), isFalse);
      });

      test('returns defaultValue when null or unparseable', () {
        expect(SafeJson.optBool(null), isNull);
        expect(SafeJson.optBool(null, false), isFalse);
        expect(SafeJson.optBool('random_text', true), isTrue);
      });
    });

    group('optMap', () {
      test('returns Map<String, dynamic> directly', () {
        final original = <String, dynamic>{'a': 1};
        expect(SafeJson.optMap(original), equals(original));
      });

      test('converts dynamic key maps to string keys', () {
        final dynamicMap = {1: 'one', 2: 'two'};
        final map = SafeJson.optMap(dynamicMap);
        expect(map['1'], 'one');
        expect(map['2'], 'two');
      });

      test('returns empty map or default when invalid or null', () {
        expect(SafeJson.optMap(null), isEmpty);
        expect(SafeJson.optMap('not_a_map'), isEmpty);
        expect(
          SafeJson.optMap(null, {'fallback': true}),
          equals({'fallback': true}),
        );
      });
    });

    group('optList and optPrimitiveList', () {
      test('maps list of maps correctly', () {
        final rawList = [
          {'id': 1, 'name': 'First'},
          {'id': 2, 'name': 'Second'},
        ];

        final result = SafeJson.optList<String>(
          rawList,
          (item) => item.getSafeString('name') ?? '',
        );

        expect(result, ['First', 'Second']);
      });

      test('skips corrupted items in list without crashing', () {
        final rawList = [
          {'id': 1, 'name': 'First'},
          'invalid_item',
          {'id': 2}, // missing name will throw if mapped strictly
        ];

        final result = SafeJson.optList<String>(
          rawList,
          (item) {
            if (!item.containsKey('name')) {
              throw ArgumentError('missing name');
            }
            return item['name'] as String;
          },
        );

        expect(result, ['First']);
      });

      test('returns empty list for non-list inputs', () {
        expect(SafeJson.optList(null, (json) => json), isEmpty);
        expect(SafeJson.optList('string', (json) => json), isEmpty);
      });

      test('optPrimitiveList casts items safely', () {
        final raw = ['10', 20, '30.0', null];
        final ints = SafeJson.optPrimitiveList<int>(raw);
        expect(ints, [10, 20, 30]);

        final strings = SafeJson.optPrimitiveList<String>([1, 2.5, true]);
        expect(strings, ['1', '2.5', 'true']);
      });
    });

    group('Hybrid / Polyvalent Fields', () {
      test('optStringOrMapValue handles string or map correctly', () {
        // String case
        expect(
          SafeJson.optStringOrMapValue('https://img.com/a.png', 'url'),
          'https://img.com/a.png',
        );

        // Map case
        expect(
          SafeJson.optStringOrMapValue({'url': 'https://img.com/b.png'}, 'url'),
          'https://img.com/b.png',
        );

        // Map with missing key
        expect(
          SafeJson.optStringOrMapValue({'path': 'foo'}, 'url', 'fallback.png'),
          'fallback.png',
        );

        // Null case
        expect(
          SafeJson.optStringOrMapValue(null, 'url', 'fallback.png'),
          'fallback.png',
        );
      });

      test('optMapOrFallbackString handles map or string fallback', () {
        // Map case
        expect(
          SafeJson.optMapOrFallbackString({'name': 'Tech'}, 'name'),
          {'name': 'Tech'},
        );

        // String case
        expect(
          SafeJson.optMapOrFallbackString('Tech', 'name'),
          {'name': 'Tech'},
        );

        // Number/primitive case
        expect(
          SafeJson.optMapOrFallbackString(123, 'id'),
          {'id': '123'},
        );

        // Null case
        expect(
          SafeJson.optMapOrFallbackString(null, 'name', {'name': 'Default'}),
          {'name': 'Default'},
        );
      });
    });
  });

  group('SafeJsonExtension Tests', () {
    final complexResponse = <String, dynamic>{
      'status': 'success',
      'user_id': null, // null at root
      'avatar_simple': 'https://img.com/simple.png',
      'avatar_object': {'url': 'https://img.com/nested.png'},
      'category_raw': 'Mobile Development',
      'category_object': {'id': 1, 'name': 'Mobile Development'},
      'data': {
        'user': {
          'id': 1001,
          'username': 'antigravity_dev',
          'is_active': '1',
          'rating': '4.85',
        },
        'roles': ['admin', 'developer'],
      },
    };

    test('findKey locates key in nested common wrappers', () {
      expect(complexResponse.findKey(['username']), 'antigravity_dev');
      expect(complexResponse.findKey(['id']), 1001);
    });

    test('findKey prioritizes fallback keys and ignores root nulls', () {
      expect(
        complexResponse.findKey(['user_id', 'id']),
        1001,
      );
    });

    test('getSafeString extracts nested string safely', () {
      expect(complexResponse.getSafeString('username'), 'antigravity_dev');
      expect(complexResponse.getSafeString('missing_key', 'N/A'), 'N/A');
    });

    test('getSafeInt extracts and parses nested numbers', () {
      expect(complexResponse.getSafeInt('id'), 1001);
      expect(complexResponse.getSafeInt(['user_id', 'id']), 1001);
      expect(complexResponse.getSafeInt('unknown', 99), 99);
    });

    test('getSafeDouble extracts nested double from string', () {
      expect(complexResponse.getSafeDouble('rating'), 4.85);
      expect(complexResponse.getSafeDouble('missing_rate', 0.0), 0.0);
    });

    test('getSafeBool extracts nested boolean from string "1"', () {
      expect(complexResponse.getSafeBool('is_active'), isTrue);
      expect(complexResponse.getSafeBool('missing_flag', false), isFalse);
    });

    test('getSafeMap extracts nested map safely', () {
      final userMap = complexResponse.getSafeMap('user');
      expect(userMap['username'], 'antigravity_dev');
    });

    test('getSafePrimitiveList extracts nested primitive list', () {
      final roles = complexResponse.getSafePrimitiveList<String>('roles');
      expect(roles, ['admin', 'developer']);
    });

    test('getSafeStringOrMapValue extracts string from hybrid field', () {
      expect(
        complexResponse.getSafeStringOrMapValue('avatar_simple', 'url'),
        'https://img.com/simple.png',
      );
      expect(
        complexResponse.getSafeStringOrMapValue('avatar_object', 'url'),
        'https://img.com/nested.png',
      );
      expect(
        complexResponse.getSafeStringOrMapValue('missing_avatar', 'url', 'default.png'),
        'default.png',
      );
    });

    test('getSafeMapOrFallbackString wraps string fallback into map', () {
      final fromObject = complexResponse.getSafeMapOrFallbackString('category_object', 'name');
      expect(fromObject['name'], 'Mobile Development');
      expect(fromObject['id'], 1);

      final fromString = complexResponse.getSafeMapOrFallbackString('category_raw', 'name');
      expect(fromString, {'name': 'Mobile Development'});
    });
  });
}

