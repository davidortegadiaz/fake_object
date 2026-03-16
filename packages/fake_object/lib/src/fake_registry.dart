import 'dart:math';

import 'package:fake_object/src/fake_context.dart';
import 'package:fake_object/src/fake_defaults.dart';
import 'package:faker/faker.dart';

typedef FakeFactory<T> = T Function(FakeContext context);

class FakeRegistry {
  final Faker faker;
  final int maxDepth;
  final Random _random;
  final Map<Type, FakeFactory<dynamic>> _factories =
      <Type, FakeFactory<dynamic>>{};

  FakeRegistry({int? seed, Faker? faker, this.maxDepth = 5})
      : faker = faker ?? Faker(),
        _random = Random(seed);

  factory FakeRegistry.withDefaults({int? seed, int maxDepth = 5}) {
    final FakeRegistry registry = FakeRegistry(seed: seed, maxDepth: maxDepth);
    registerDefaultPrimitives(registry);
    return registry;
  }

  Random get random => _random;

  void register<T>(FakeFactory<T> factory) {
    _factories[T] = (FakeContext context) => factory(context);
  }

  bool hasFactory<T>() {
    return _factories.containsKey(T);
  }

  T make<T>({T Function(T value)? overrides}) {
    return makeAtDepth<T>(0, overrides: overrides);
  }

  T makeAtDepth<T>(int depth, {T Function(T value)? overrides}) {
    final T value = _make(T, depth) as T;
    if (overrides != null) {
      return overrides(value);
    }
    return value;
  }

  dynamic makeByType(Type type, {int depth = 0}) {
    return _make(type, depth);
  }

  dynamic _make(Type type, int depth) {
    if (depth > maxDepth) {
      throw StateError(
        'Max depth reached while creating type $type. Increase maxDepth or break cycles in factories.',
      );
    }

    final FakeFactory<dynamic>? factory = _factories[type];
    if (factory == null) {
      throw StateError(
        'No fake factory registered for type $type. Register one before calling make<$type>().',
      );
    }

    return factory(FakeContext.internal(this, depth));
  }
}
