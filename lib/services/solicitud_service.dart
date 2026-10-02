import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../core/app_config.dart';
import '../models/solicitud_ia.dart';

/// Consume:
///   POST /api/solicitudes-ia        (SolicitudController.hpp)
///   GET  /api/solicitudes-ia/{id}   (SolicitudController.hpp)
///
/// El backend responde 202 Accepted de inmediato al crear la solicitud
/// (ver el comentario en SolicitudController.hpp: "el hilo HTTP queda
/// libre de inmediato" mientras Groq y el resto de la cadena de eventos
/// procesan en segundo plano). Por eso este servicio no puede simplemente
/// esperar UNA respuesta: tiene que preguntar repetidamente
/// (polling) hasta que `estado` deje de ser "procesando".
class SolicitudService {
  SolicitudService(this._api);
  final ApiClient _api;

  /// Crea la solicitud y devuelve su id de inmediato (estado ~ "procesando").
  Future<String> crear({required String usuarioId, required String texto}) async {
    final json = await _api.post('/api/solicitudes-ia', {
      'usuario_id': usuarioId,
      'texto': texto,
    });
    return json['id'] as String;
  }

  Future<SolicitudIA> consultar(String solicitudId) async {
    final json = await _api.get('/api/solicitudes-ia/$solicitudId');
    return SolicitudIA.fromJson(json);
  }

  /// Va emitiendo cada consulta de estado (útil para mostrar "buscando la
  /// ficha del personaje...", "armando tu plan...", etc. en la UI) hasta
  /// que el backend termina de procesar la solicitud (estado = generada,
  /// rechazada o error) o se cumple AppConfig.timeoutPolling.
  ///
  /// Se usa así, desde la pantalla de chat con la IA:
  /// ```dart
  /// await for (final s in solicitudService.esperarResultado(id)) {
  ///   // actualizar UI con s.estado
  /// }
  /// ```
  Stream<SolicitudIA> esperarResultado(String solicitudId) async* {
    final inicio = DateTime.now();

    while (true) {
      final solicitud = await consultar(solicitudId);
      yield solicitud;

      final termino = solicitud.estado == EstadoSolicitud.generada ||
          solicitud.estado == EstadoSolicitud.rechazada ||
          solicitud.estado == EstadoSolicitud.error;
      if (termino) return;

      if (DateTime.now().difference(inicio) > AppConfig.timeoutPolling) {
        throw ApiException(
            'Tu rutina está tardando más de lo normal. Vuelve a intentarlo en un momento.');
      }

      await Future.delayed(AppConfig.intervaloPolling);
    }
  }
}
