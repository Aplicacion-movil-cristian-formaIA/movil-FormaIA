import '../core/api_client.dart';

class Alternativa {
  final String nombre;
  final String razon;

  Alternativa({required this.nombre, required this.razon});

  factory Alternativa.fromJson(Map<String, dynamic> json) {
    return Alternativa(
      nombre: json['nombre'] ?? '',
      razon: json['razon'] ?? '',
    );
  }
}

class EntrenamientoService {
  final ApiClient _api;

  EntrenamientoService(this._api);

  Future<List<String>> registrarSesion({
    required String usuarioId,
    required String sesionPlanId,
    required bool completado,
    required List<Map<String, dynamic>> series,
  }) async {
    final res = await _api.post('/api/sesiones', {
      'usuario_id': usuarioId,
      'sesion_plan_id': sesionPlanId,
      'completado': completado,
      'series': series,
    });
    
    if (res is Map<String, dynamic> && res.containsKey('notificaciones')) {
      final notifs = res['notificaciones'] as List<dynamic>;
      return notifs.map((e) => e.toString()).toList();
    }
    return [];
  }

  Future<List<Alternativa>> obtenerAlternativas(String ejercicio, String motivo) async {
    final res = await _api.post('/api/ia/alternativas', {
      'ejercicio': ejercicio,
      'motivo': motivo,
    });
    
    if (res is List) {
      final list = res as List<dynamic>;
      return list.map((e) => Alternativa.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> adaptarSesionHoy(List<dynamic> ejerciciosActuales, String motivo) async {
    final res = await _api.post('/api/ia/adaptar-sesion', {
      'ejercicios': ejerciciosActuales,
      'motivo': motivo,
    });
    
    if (res is List) {
      return List<Map<String, dynamic>>.from(res);
    }
    return [];
  }

  Future<void> enviarFeedbackRPE(String sesionId, String usuarioId, int rpe) async {
    await _api.post('/api/sesiones/$sesionId/completar', {
      'usuario_id': usuarioId,
      'rpe': rpe,
    });
  }

  Future<Map<String, dynamic>> evaluarSemana(String usuarioId) async {
    final res = await _api.get('/api/ia/evolucionar/$usuarioId');
    if (res is Map<String, dynamic>) {
      return res;
    }
    throw Exception('Formato de respuesta inválido');
  }
}
