// GENERATED CODE - DO NOT MODIFY BY HAND.
// ignore_for_file: directives_ordering, lines_longer_than_80_chars

import 'package:fake_object/src/example/pet.dart';
import 'package:fake_object/src/fake_context.dart';
import 'package:fake_object/src/fake_registry.dart';

void registerPetFake(FakeRegistry registry) {
  if (registry.hasFactory<Pet>()) {
    return;
  }
  registry.register<Pet>((FakeContext context) {
    return Pet(
      name: context.make<String>(),
    );
  });
}

Pet fakePet({
  FakeRegistry? registry,
  Pet Function(Pet value, FakeContext context)? customize,
}) {
  final FakeRegistry activeRegistry = registry ?? FakeRegistry.withDefaults();
  registerPetFake(activeRegistry);

  final FakeContext context = FakeContext.internal(activeRegistry, 0);
  final Pet value = activeRegistry.make<Pet>();

  if (customize != null) {
    return customize(value, context);
  }

  return value;
}
