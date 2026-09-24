/// Estados posibles tal como los define el backend
/// (ver formaia-backend/src/domain/entities/SolicitudIA.hpp:
/// estado = "aclaracion" | "rechazada" | "generada" | "error").
/// Se agrega "procesando" solo en el cliente porque el POST inicial
/// devuelve ese texto informativo (ver SolicitudController.hpp), aunque
/// el valor real guardado en BD en ese instante sigue siendo "aclaracion".
enum EstadoSolicitud { procesando, rechazada, generada, error, desconocido }

EstadoSolicitud estadoDesde(String valor) {
  switch (valor) {
    case 'aclaracion':
    case 'procesando':
      return EstadoSolicitud.procesando;
    case 'rechazada':
      return EstadoSolicitud.rechazada;
    case 'generada':
      return EstadoSolicitud.generada;
    case 'error':
      return EstadoSolicitud.error;
    default:
      return EstadoSolicitud.desconocido;
  }
}

/// Refleja la respuesta de GET /api/solicitudes-ia/{id}:
/// { "id", "estado", "motivo_rechazo", "referente_detectado" }
class SolicitudIA {
  final String id;
  final EstadoSolicitud estado;
  final String motivoRechazo;
  final String referenteDetectado;

  SolicitudIA({
    required this.id,
    required this.estado,
    required this.motivoRechazo,
    required this.referenteDetectado,
  });

  factory SolicitudIA.fromJson(Map<String, dynamic> json) {
    return SolicitudIA(
      id: json['id'] as String,
      estado: estadoDesde(json['estado']?.toString() ?? ''),
      motivoRechazo: json['motivo_rechazo']?.toString() ?? '',
      referenteDetectado: json['referente_detectado']?.toString() ?? '',
    );
  }
}
