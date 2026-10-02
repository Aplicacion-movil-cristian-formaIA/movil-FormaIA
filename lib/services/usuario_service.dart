import '../core/api_client.dart';
import '../models/perfil_fisico.dart';
import '../models/usuario.dart';

/// Consume:
///   POST /api/usuarios              (UsuarioController.hpp)
///   POST /api/usuarios/{id}/perfil  (UsuarioController.hpp)
class UsuarioService {
  UsuarioService(this._api);
  final ApiClient _api;

  Future<Usuario> registrar({
    required String email,
    required String password,
    required String fechaNacimiento, // formato YYYY-MM-DD, igual que espera el backend
  }) async {
    final json = await _api.post('/api/usuarios', {
      'email': email,
      'password': password,
      'fecha_nacimiento': fechaNacimiento,
    });
    return Usuario.fromJson(json);
  }

  Future<Usuario> login({
    required String email,
    required String password,
  }) async {
    final json = await _api.post('/api/login', {
      'email': email,
      'password': password,
    });
    return Usuario.fromJson(json);
  }

  Future<void> guardarPerfil(String usuarioId, PerfilFisico perfil) async {
    await _api.post('/api/usuarios/$usuarioId/perfil', perfil.toJson());
  }

  Future<bool> tienePerfil(String usuarioId) async {
    try {
      await _api.get('/api/usuarios/$usuarioId/perfil');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<PerfilFisico> obtenerPerfil(String usuarioId) async {
    final json = await _api.get('/api/usuarios/$usuarioId/perfil');
    return PerfilFisico.fromJson(json);
  }
}
