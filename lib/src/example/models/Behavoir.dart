import 'dart:convert';

class Behavoir {
  final bool isAgresive;
  final bool isLoving;
  Behavoir({
    this.isAgresive,
    this.isLoving,
  });

  Behavoir copyWith({
    bool isAgresive,
    bool isLoving,
  }) {
    return Behavoir(
      isAgresive: isAgresive ?? this.isAgresive,
      isLoving: isLoving ?? this.isLoving,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isAgresive': isAgresive,
      'isLoving': isLoving,
    };
  }

  factory Behavoir.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Behavoir(
      isAgresive: map['isAgresive'],
      isLoving: map['isLoving'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Behavoir.fromJson(String source) => Behavoir.fromMap(json.decode(source));

  @override
  String toString() => 'Behavoir(isAgresive: $isAgresive, isLoving: $isLoving)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Behavoir && o.isAgresive == isAgresive && o.isLoving == isLoving;
  }

  @override
  int get hashCode => isAgresive.hashCode ^ isLoving.hashCode;
}
