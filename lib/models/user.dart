class User {
 int? id;
 String name;
 String email;
 bool active;

 User({
   this.id,
   required this.name,
   required this.email,
   this.active = true,
 });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'active': active ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      active: map['active'] == 1, 
    );
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    bool? active,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      active: active ?? this.active,
    );
  }
}