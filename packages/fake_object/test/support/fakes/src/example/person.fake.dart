// GENERATED CODE - DO NOT MODIFY BY HAND.
// ignore_for_file: directives_ordering, lines_longer_than_80_chars

import 'package:fake_object/src/example/person.dart';
import 'package:fake_object/src/example/pet.dart';
import 'package:fake_object/src/fake_context.dart';
import 'package:fake_object/src/fake_registry.dart';
import 'pet.fake.dart';

void registerPersonFake(FakeRegistry registry) {
  if (registry.hasFactory<Person>()) {
    return;
  }
  if (!registry.hasFactory<Pet>()) {
    registerPetFake(registry);
  }
  registry.register<Person>((FakeContext context) {
    return Person(
      name: context.make<String>(),
      age: context.make<int>(),
      pet: context.make<Pet>(),
    );
  });
}

Person fakePerson({
  FakeRegistry? registry,
  Person Function(Person value, FakeContext context)? customize,
}) {
  final FakeRegistry activeRegistry = registry ?? FakeRegistry.withDefaults();
  registerPersonFake(activeRegistry);

  final FakeContext context = FakeContext.internal(activeRegistry, 0);
  final Person value = activeRegistry.make<Person>();

  if (customize != null) {
    return customize(value, context);
  }

  return value;
}
