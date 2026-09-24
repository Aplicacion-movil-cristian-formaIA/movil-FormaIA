/// Refleja la respuesta de POST /api/usuarios
/// (ver formaia-backend/src/http/routes/UsuarioController.hpp):
/// { "id": "...", "email": "..." }
class Usuario {
  final String id;
  final String email;

  Usuario({required this.id, required this.email});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      email: json['email'] as String,
    );
  }
}
