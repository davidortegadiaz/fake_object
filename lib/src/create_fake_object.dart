import 'dart:mirrors';
import 'package:faker/faker.dart';

class CreateFakeObject {
  final _primitives = [int, double, String, bool, DateTime];
  final Faker _faker = Faker();

  bool _isPrimitive(Type type) {
    return _primitives.contains(type);
  }

  ClassMirror _getInstanceMirror(dynamic object) {
    var instanceMirror = reflect(object);
    return instanceMirror.type;
  }

  dynamic setFakeValues(dynamic object) {
    var map = <String, dynamic>{};
    var classMirror = _getInstanceMirror(object);
    for (var v in classMirror.declarations.values) {
      if (v is VariableMirror) {
        if (_isPrimitive(v.type.reflectedType)) {
          var name = MirrorSystem.getName(v.simpleName);
          map[name] = _fakerValue(v.type.reflectedType);
        } else {
          var typeMirror = reflectType(v.type.reflectedType);
          if (typeMirror is ClassMirror) {
            var instance = typeMirror.newInstance(Symbol(''), []).reflectee;
            map['${MirrorSystem.getName(v.simpleName)}'] = setFakeValues(instance);
          }
        }
      }
    }
    return map;
  }

  dynamic _fakerValue(Type type) {
    if (type == int) {
      return _faker.randomGenerator.integer(100);
    }
    if (type == double) {
      return _faker.randomGenerator.decimal();
    }
    if (type == String) {
      return _faker.lorem.word();
    }
    if (type == bool) {
      return _faker.randomGenerator.boolean();
    }
    if (type == DateTime) {
      return _faker.date;
    }
    return null;
  }
}
