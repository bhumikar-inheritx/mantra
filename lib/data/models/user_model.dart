class UserModel {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final bool isNewUser;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.isNewUser = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'isNewUser': isNewUser,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      isNewUser: json['isNewUser'] ?? false,
    );
  }

  UserModel copyWith({bool? isNewUser}) {
    return UserModel(
      id: id,
      email: email,
      name: name,
      photoUrl: photoUrl,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}
