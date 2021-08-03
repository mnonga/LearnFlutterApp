class User {
  int? id;
  String? first_name;
  String? last_name;
  String? avatar;

  User({required this.id, required this.first_name, required this.last_name, required this.avatar});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], first_name: json['first_name'], last_name: json['last_name'], avatar: json['avatar']);
  }
}

class Verset {
  int? id;
  String? text;
}
