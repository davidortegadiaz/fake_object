import 'dart:convert';

import 'package:fake_object/src/example/models/pet.dart';

class Person {
  final int age;
  final String name;
  final Pet pet;
  final DateTime birthDate;

  Person({
    this.age,
    this.name,
    this.pet,
    this.birthDate,
  });

  Person copyWith({
    int age,
    String name,
    Pet pet,
    DateTime birthDate,
  }) {
    return Person(
      age: age ?? this.age,
      name: name ?? this.name,
      pet: pet ?? this.pet,
      birthDate: birthDate ?? this.birthDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'name': name,
      'pet': pet?.toMap(),
      'birthDate': birthDate?.toIso8601String(),
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Person(
      age: map['age'],
      name: map['name'],
      pet: Pet.fromMap(map['pet']),
      birthDate: map['birthDate'] != null ? DateTime.parse(map['birthDate'] as String) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Person.fromJson(String source) => Person.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Person(age: $age, name: $name, pet: $pet, birthDate: $birthDate)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Person && o.age == age && o.name == name && o.pet == pet && o.birthDate == birthDate;
  }

  @override
  int get hashCode {
    return age.hashCode ^ name.hashCode ^ pet.hashCode ^ birthDate.hashCode;
  }
}
