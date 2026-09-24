/// Excepción que representa un error de comunicación con el backend:
/// de red (sin conexión, timeout) o de negocio (4xx/5xx con un cuerpo
/// {"error": "..."} tal como lo devuelve el backend en C++, ver
/// Router::despachar y cada controlador en src/http/routes/*.hpp).
class ApiException implements Exception {
  final String mensaje;
  final int? statusCode;

  ApiException(this.mensaje, {this.statusCode});

  /// true si es un problema de red (no llegó respuesta del servidor),
  /// útil para mostrar "revisa tu conexión" en vez de un error genérico.
  bool get esErrorDeRed => statusCode == null;

  @override
  String toString() => mensaje;
}
