import 'package:fake_object/src/fake_defaults.dart';
import 'package:fake_object/src/fake_registry.dart';

class CreateFakeObject {
  final FakeRegistry registry;

  CreateFakeObject({FakeRegistry? registry})
      : registry = registry ?? FakeRegistry.withDefaults();

  T make<T>({T Function(T value)? overrides}) {
    return registry.make<T>(overrides: overrides);
  }

  dynamic makeByType(Type type) {
    return registry.makeByType(type);
  }

  void register<T>(FakeFactory<T> factory) {
    registry.register<T>(factory);
  }

  void registerDefaults() {
    registerDefaultPrimitives(registry);
  }
}
