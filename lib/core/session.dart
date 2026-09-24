import 'package:shared_preferences/shared_preferences.dart';

/// Guarda localmente lo mínimo necesario para que la app recuerde al
/// usuario entre pantallas y reinicios, ya que el backend de este MVP
/// todavía no expone login/JWT (ver README del backend, sección "No
/// incluidos en este MVP"). Cuando se agregue autenticación real, este
/// es el único archivo que debería cambiar para guardar un token en vez
/// de solo el usuario_id.
class Session {
  Session._();
  static final Session instance = Session._();

  static const _kUsuarioId = 'usuario_id';
  static const _kSolicitudId = 'ultima_solicitud_id';
  static const _kRutinaId = 'rutina_activa_id';

  Future<void> guardarUsuarioId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsuarioId, id);
  }

  Future<String?> obtenerUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUsuarioId);
  }

  Future<void> guardarSolicitudId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSolicitudId, id);
  }

  Future<String?> obtenerSolicitudId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kSolicitudId);
  }

  Future<void> guardarRutinaId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRutinaId, id);
  }

  Future<String?> obtenerRutinaId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kRutinaId);
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUsuarioId);
    await prefs.remove(_kSolicitudId);
    await prefs.remove(_kRutinaId);
  }
}
