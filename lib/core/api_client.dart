import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'app_config.dart';

/// Único punto de entrada HTTP hacia el backend en C++. Todos los
/// servicios (UsuarioService, SolicitudService, RutinaService) pasan por
/// aquí, así que el manejo de errores, encabezados y el parseo de JSON
/// queda en un solo lugar en vez de repetirse en cada llamada.
///
/// Contrato asumido con el backend (ver src/http/Router.hpp y cada
/// controlador en src/http/routes/*.hpp del backend en C++):
/// - Toda petición con cuerpo se envía como JSON
///   (Content-Type: application/json), que es justo lo que
///   Router::despachar exige para parsear ctx.body.
/// - Toda respuesta viene en JSON. Los errores de negocio llegan con un
///   cuerpo {"error": "mensaje"} y un status code 4xx (ver, por ejemplo,
///   SolicitudController: 400 si faltan campos, 404 si no existe).
class ApiClient {
  ApiClient({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;
  final String _baseUrl = AppConfig.apiBaseUrl;

  Future<Map<String, dynamic>> get(String path) async {
    return _enviar(() => _client
        .get(_uri(path), headers: _headers())
        .timeout(AppConfig.timeoutHttp));
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    return _enviar(() => _client
        .post(_uri(path), headers: _headers(), body: jsonEncode(body))
        .timeout(AppConfig.timeoutHttp));
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> _headers() => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<Map<String, dynamic>> _enviar(Future<http.Response> Function() peticion) async {
    http.Response respuesta;
    try {
      respuesta = await peticion();
    } on TimeoutException {
      throw ApiException(
          'El servidor no respondió a tiempo. Revisa tu conexión o que el backend esté corriendo.');
    } catch (_) {
      // SocketException u otros errores de bajo nivel: se homogenizan
      // como error de red para que la UI muestre un mensaje consistente
      // (ver AppConfig sobre "localhost" vs "10.0.2.2" en emuladores).
      throw ApiException(
          'No se pudo conectar con el servidor. Verifica la URL del backend y tu conexión.');
    }

    Map<String, dynamic> cuerpo;
    try {
      cuerpo = respuesta.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(respuesta.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('El servidor devolvió una respuesta inesperada.',
          statusCode: respuesta.statusCode);
    }

    if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
      return cuerpo;
    }

    final mensaje = cuerpo['error']?.toString() ?? 'Ocurrió un error inesperado.';
    throw ApiException(mensaje, statusCode: respuesta.statusCode);
  }
}
