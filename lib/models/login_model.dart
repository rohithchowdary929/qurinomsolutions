class LoginModel {
  final String? token;
  final String? id;
  final String? email;
  final String? name;

  LoginModel({
    this.token,
    this.id,
    this.email,
    this.name,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"];
    final user = data["user"];
    return LoginModel(
      token: data["token"],
      id: user["_id"],
      email: user["email"],
      name: user["name"],
    );
  }
}
