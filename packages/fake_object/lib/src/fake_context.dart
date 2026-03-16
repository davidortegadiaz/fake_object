import 'dart:math';

import 'package:fake_object/src/fake_registry.dart';
import 'package:faker/faker.dart';

class FakeContext {
  final FakeRegistry _registry;
  final int _depth;

  FakeContext.internal(this._registry, this._depth);

  Faker get faker => _registry.faker;
  Random get random => _registry.random;

  T make<T>({T Function(T value)? overrides}) {
    return _registry.makeAtDepth<T>(_depth + 1, overrides: overrides);
  }

  dynamic makeByType(Type type) {
    return _registry.makeByType(type, depth: _depth + 1);
  }

  List<T> listOf<T>({int min = 1, int max = 3}) {
    if (min < 0) {
      throw ArgumentError('min cannot be negative');
    }
    if (max < min) {
      throw ArgumentError('max cannot be smaller than min');
    }

    final int count = min + random.nextInt((max - min) + 1);
    final List<T> values = <T>[];

    for (int i = 0; i < count; i++) {
      values.add(make<T>());
    }

    return values;
  }

  int intInRange(int min, int max) {
    if (max < min) {
      throw ArgumentError('max cannot be smaller than min');
    }
    return min + random.nextInt((max - min) + 1);
  }

  double decimal({double min = 0, double max = 1}) {
    if (max < min) {
      throw ArgumentError('max cannot be smaller than min');
    }
    return min + (random.nextDouble() * (max - min));
  }

  T pick<T>(List<T> options) {
    if (options.isEmpty) {
      throw ArgumentError('options cannot be empty');
    }

    return options[random.nextInt(options.length)];
  }

  bool chance(double probability) {
    if (probability < 0 || probability > 1) {
      throw ArgumentError('probability must be between 0 and 1');
    }

    return random.nextDouble() < probability;
  }
}
