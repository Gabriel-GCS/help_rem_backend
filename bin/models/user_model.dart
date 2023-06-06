class UsuarioModel {
  String? name;
  String? email;
  String? password;

  UsuarioModel();

  UsuarioModel.create(
    this.name,
    this.email,
    this.password
  );

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel.create(
      map['nome'] ?? '',
      map['email'] ?? '',
      map['password'] ?? '',
    );
  }
}