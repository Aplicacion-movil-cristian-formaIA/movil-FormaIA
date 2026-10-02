import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:formaia_app/core/api_client.dart';
import 'package:formaia_app/services/entrenamiento_service.dart';

void main() {
  group('EntrenamientoService Tests (Integración Simulada)', () {
    test('registrarSesion devuelve notificaciones de 1RM si existen', () async {
      // Configuramos el cliente HTTP mockeado para interceptar la llamada
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/sesiones');
        expect(request.method, 'POST');

        // Parsear el body enviado
        final body = jsonDecode(request.body);
        expect(body['usuario_id'], 'test_usr');
        expect(body['sesion_plan_id'], 'sesion_123');
        expect(body['completado'], true);
        expect((body['series'] as List).length, 1);

        // Devolver respuesta mockeada simulando el comportamiento de EjecucionController Fase 3
        return http.Response(jsonEncode({
          'ok': true,
          'mensaje': 'Entrenamiento registrado exitosamente',
          'notificaciones': ['¡Nuevo récord en Press de Banca! Tu 1RM estimado es 100 kg.']
        }), 201);
      });

      final apiClient = ApiClient(httpClient: mockClient);
      final service = EntrenamientoService(apiClient);

      final notificaciones = await service.registrarSesion(
        usuarioId: 'test_usr',
        sesionPlanId: 'sesion_123',
        completado: true,
        series: [{'ejercicio_id': 'Press de Banca', 'numero_serie': 1, 'peso': 90.0, 'reps': 3}]
      );

      expect(notificaciones.length, 1);
      expect(notificaciones.first, contains('Nuevo récord en Press de Banca'));
    });

    test('obtenerAlternativas parsea el JSON correctamente', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/ia/alternativas');
        return http.Response(jsonEncode([
          {'nombre': 'Flexiones', 'razon': 'No requiere equipo'}
        ]), 200);
      });

      final apiClient = ApiClient(httpClient: mockClient);
      final service = EntrenamientoService(apiClient);

      final alternativas = await service.obtenerAlternativas('Press de Banca', 'No tengo banco');
      expect(alternativas.length, 1);
      expect(alternativas.first.nombre, 'Flexiones');
      expect(alternativas.first.razon, 'No requiere equipo');
    });

    test('enviarFeedbackRPE se llama correctamente', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/sesiones/ses_99/completar');
        final body = jsonDecode(request.body);
        expect(body['usuario_id'], 'usr_44');
        expect(body['rpe'], 8);

        return http.Response(jsonEncode({'ok': true}), 200);
      });

      final apiClient = ApiClient(httpClient: mockClient);
      final service = EntrenamientoService(apiClient);

      await service.enviarFeedbackRPE('ses_99', 'usr_44', 8);
      // Si no tira excepción, pasó
    });

    test('adaptarSesionHoy devuelve la nueva estructura', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/ia/adaptar-sesion');
        return http.Response(jsonEncode([
          {'nombre': 'Press de Banca', 'series': 3, 'reps': '8-10', 'completado': false},
          {'nombre': 'Flexiones', 'series': 3, 'reps': '10-15', 'completado': false}
        ]), 200);
      });

      final apiClient = ApiClient(httpClient: mockClient);
      final service = EntrenamientoService(apiClient);

      final nuevaSesion = await service.adaptarSesionHoy(
        ['Ej A', 'Ej B'], // ejerciciosActuales
        'Tengo menos tiempo hoy' // motivo
      );

      expect(nuevaSesion, isNotNull);
      expect(nuevaSesion.length, 2);
    });
  });
}
