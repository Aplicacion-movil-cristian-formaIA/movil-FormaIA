/// Representa lo que la app ENVÍA a POST /api/usuarios/{id}/perfil
/// (ver UsuarioController.hpp). No hace falta un fromJson porque el
/// backend responde solo {"ok": true}; este modelo existe para que el
/// formulario de perfil arme el cuerpo de la petición de forma tipada
/// en vez de pasar un Map suelto por la UI.
class PerfilFisico {
  final String sexo; // 'femenino' | 'masculino' | 'prefiero_no_decir'
  final double estaturaCm;
  final double pesoKg;
  final String nivel; // 'principiante' | 'intermedio' | 'avanzado'
  final int diasSemana;
  final int minutosSesion;
  final List<String> equipamiento;

  PerfilFisico({
    required this.sexo,
    required this.estaturaCm,
    required this.pesoKg,
    required this.nivel,
    required this.diasSemana,
    required this.minutosSesion,
    required this.equipamiento,
  });

  Map<String, dynamic> toJson() => {
        'sexo': sexo,
        'estatura_cm': estaturaCm,
        'peso_kg': pesoKg,
        'nivel': nivel,
        'dias_semana': diasSemana,
        'minutos_sesion': minutosSesion,
        'equipamiento': equipamiento,
      };

  factory PerfilFisico.fromJson(Map<String, dynamic> json) {
    return PerfilFisico(
      sexo: json['sexo'] ?? '',
      estaturaCm: (json['estatura_cm'] ?? 0).toDouble(),
      pesoKg: (json['peso_kg'] ?? 0).toDouble(),
      nivel: json['nivel'] ?? '',
      diasSemana: json['dias_semana'] ?? 0,
      minutosSesion: json['minutos_sesion'] ?? 0,
      equipamiento: (json['equipamiento'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
