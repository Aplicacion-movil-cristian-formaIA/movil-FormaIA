import '../core/api_client.dart';
import '../models/rutina.dart';

/// Consume:
///   GET /api/rutinas/por-solicitud/{solicitud_id}  (RutinaController.hpp)
///   GET /api/rutinas/{id}                          (RutinaController.hpp)
class RutinaService {
  RutinaService(this._api);
  final ApiClient _api;

  /// Cuando SolicitudService.esperarResultado() confirma
  /// estado == generada, la app todavía no sabe el id de la rutina
  /// (el backend no lo expone antes de tiempo, ver el comentario en
  /// RutinaController.hpp). Este paso intermedio lo resuelve.
  Future<String> obtenerRutinaIdPorSolicitud(String solicitudId) async {
    final json = await _api.get('/api/rutinas/por-solicitud/$solicitudId');
    return json['rutina_id'] as String;
  }

  Future<Rutina> obtener(String rutinaId) async {
    final json = await _api.get('/api/rutinas/$rutinaId');
    return Rutina.fromJson(json);
  }

  /// Atajo que encadena los dos pasos anteriores.
  Future<Rutina> obtenerPorSolicitud(String solicitudId) async {
    final rutinaId = await obtenerRutinaIdPorSolicitud(solicitudId);
    return obtener(rutinaId);
  }
}
