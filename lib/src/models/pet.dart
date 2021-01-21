import 'dart:convert';

import 'package:fake_object/src/create_fake_object.dart';

class Pet extends CreateFakeObject {
  final int age;
  final String name;

  Pet({
    this.age,
    this.name,
  });

  Pet copyWith({
    int age,
    String name,
  }) {
    return Pet(
      age: age ?? this.age,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'name': name,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Pet(
      age: map['age'],
      name: map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Pet.fromJson(String source) => Pet.fromMap(json.decode(source));

  @override
  String toString() => 'Pet(age: $age, name: $name)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Pet && o.age == age && o.name == name;
  }

  @override
  int get hashCode => age.hashCode ^ name.hashCode;
}
