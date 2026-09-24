/// Refleja cada elemento de "fases" en la respuesta de
/// GET /api/rutinas/{id} (ver RutinaController.hpp):
/// { "orden", "nombre", "semana_inicio", "semana_fin", "objetivo" }
class Fase {
  final int orden;
  final String nombre;
  final int semanaInicio;
  final int semanaFin;
  final String objetivo;

  Fase({
    required this.orden,
    required this.nombre,
    required this.semanaInicio,
    required this.semanaFin,
    required this.objetivo,
  });

  factory Fase.fromJson(Map<String, dynamic> json) {
    return Fase(
      orden: json['orden'] as int,
      nombre: json['nombre']?.toString() ?? '',
      semanaInicio: json['semana_inicio'] as int,
      semanaFin: json['semana_fin'] as int,
      objetivo: json['objetivo']?.toString() ?? '',
    );
  }

  int get duracionSemanas => (semanaFin - semanaInicio) + 1;
}

/// Refleja la respuesta de GET /api/rutinas/{id}:
/// { "id", "nombre", "semanas_totales", "activa", "fases": [...] }
class Rutina {
  final String id;
  final String nombre;
  final int semanasTotales;
  final bool activa;
  final List<Fase> fases;

  Rutina({
    required this.id,
    required this.nombre,
    required this.semanasTotales,
    required this.activa,
    required this.fases,
  });

  factory Rutina.fromJson(Map<String, dynamic> json) {
    final listaFases = (json['fases'] as List<dynamic>? ?? [])
        .map((f) => Fase.fromJson(f as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.orden.compareTo(b.orden));

    return Rutina(
      id: json['id'] as String,
      nombre: json['nombre']?.toString() ?? '',
      semanasTotales: json['semanas_totales'] as int,
      activa: json['activa'] as bool? ?? true,
      fases: listaFases,
    );
  }
}
