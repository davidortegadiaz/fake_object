import 'package:fake_object/fake_object.dart';
import 'package:fake_object/src/example/pet.dart';

@Fakeable()
class Person {
  final String name;
  final int age;
  final Pet pet;

  Person({required this.name, required this.age, required this.pet});

  Person copyWith({String? name, int? age, Pet? pet}) {
    return Person(
      name: name ?? this.name,
      age: age ?? this.age,
      pet: pet ?? this.pet,
    );
  }
}
