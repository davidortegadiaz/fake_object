import 'dart:mirrors';
import 'package:faker/faker.dart';
import 'package:intl/intl.dart';

class CreateFakeObject {
  final _primitives = [int, double, String, bool, DateTime, List];
  final Faker _faker = Faker();

  bool _isPrimitive(Type type) {
    return _primitives.contains(type);
  }

  ClassMirror _getInstanceMirror(dynamic object) {
    var instanceMirror = reflect(object);
    return instanceMirror.type;
  }

  bool _isList(TypeMirror type) {
    try {
      if (type is ClassMirror) {
        type.newInstance(Symbol(''), []).reflectee as List;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  dynamic setFakeValues(dynamic object) {
    var map = <String, dynamic>{};
    var classMirror = _getInstanceMirror(object);
    for (var v in classMirror.declarations.values) {
      if (v is VariableMirror) {
        if (_isPrimitive(v.type.reflectedType)) {
          var name = MirrorSystem.getName(v.simpleName);
          map[name] = _fakerValue(v.type.reflectedType);
        } else if (_isList(v.type)) {
          var listType = v.type.typeArguments[0].reflectedType;
          if (_isPrimitive(listType)) {
            map['${MirrorSystem.getName(v.simpleName)}'] = List.filled(3, _fakerValue(listType));
          } else {
            var typeMirror = v.type.typeArguments[0];
            if (typeMirror is ClassMirror) {
              var instance = typeMirror.newInstance(Symbol(''), []).reflectee;
              map['${MirrorSystem.getName(v.simpleName)}'] = List.filled(2, setFakeValues(instance));
            }
          }
        } else {
          var typeMirror = v.type;
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
    switch (type) {
      case int:
        return _faker.randomGenerator.integer(100);
        break;
      case double:
        return _faker.randomGenerator.decimal();
        break;
      case String:
        return _faker.lorem.word();
        break;
      case bool:
        return _faker.randomGenerator.boolean();
        break;
      case DateTime:
        return DateFormat('yyyy-MM-dd hh:mm:ss').format(_faker.date.dateTime(maxYear: 2020, minYear: 1980)).toString();
        break;
      default:
        return null;
    }
  }
}
