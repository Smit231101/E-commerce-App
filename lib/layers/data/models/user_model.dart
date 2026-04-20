class UserModel {
  final String uid;
  final String name;
  final String surname;
  final String email;

  UserModel({
    required this.uid,
    required this.name,
    required this.surname,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      "uid" : uid,
      "name": name,
      "surname": surname,
      "email": email,
      "createdAt" : DateTime.now().toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? "",
      name: json['name'] ?? "",
      surname: json['surname'] ?? "",
      email: json['email'] ?? "",
    );
  }
}
