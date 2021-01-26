import 'dart:convert';

import 'package:collection/collection.dart';

import 'package:fake_object/src/create_fake_object.dart';
import 'package:fake_object/src/example/models/Behavoir.dart';

class Pet extends CreateFakeObject {
  final int age;
  final String name;
  final List<String> friendNames;
  final List<Behavoir> behavoirList;

  Pet({
    this.age,
    this.name,
    this.friendNames,
    this.behavoirList,
  });

  Pet copyWith({
    int age,
    String name,
    List<String> friendNames,
    List<Behavoir> behavoirList,
  }) {
    return Pet(
      age: age ?? this.age,
      name: name ?? this.name,
      friendNames: friendNames ?? this.friendNames,
      behavoirList: behavoirList ?? this.behavoirList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'name': name,
      'friendNames': friendNames,
      'behavoirList': behavoirList?.map((x) => x?.toMap())?.toList(),
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Pet(
      age: map['age'],
      name: map['name'],
      friendNames: List<String>.from(map['friendNames']),
      behavoirList: List<Behavoir>.from(map['behavoirList']?.map((x) => Behavoir.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory Pet.fromJson(String source) => Pet.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Pet(age: $age, name: $name, friendNames: $friendNames, behavoirList: $behavoirList)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return o is Pet &&
        o.age == age &&
        o.name == name &&
        listEquals(o.friendNames, friendNames) &&
        listEquals(o.behavoirList, behavoirList);
  }

  @override
  int get hashCode {
    return age.hashCode ^ name.hashCode ^ friendNames.hashCode ^ behavoirList.hashCode;
  }
}
