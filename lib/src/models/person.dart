import 'dart:convert';
import 'package:fake_object/src/models/pet.dart';

class Person {
  final int age;
  final String name;
  final Pet pet;

  Person({
    this.age,
    this.name,
    this.pet,
  });

  Person copyWith({
    int age,
    String name,
    Pet pet,
  }) {
    return Person(
      age: age ?? this.age,
      name: name ?? this.name,
      pet: pet ?? this.pet,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'name': name,
      'pet': pet?.toMap(),
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Person(
      age: map['age'],
      name: map['name'],
      pet: Pet.fromMap(map['pet']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Person.fromJson(String source) => Person.fromMap(json.decode(source));

  @override
  String toString() => 'Person(age: $age, name: $name, pet: $pet)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Person && o.age == age && o.name == name && o.pet == pet;
  }

  @override
  int get hashCode => age.hashCode ^ name.hashCode ^ pet.hashCode;
}
