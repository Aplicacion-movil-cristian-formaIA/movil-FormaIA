# FormaIA (app móvil, Flutter)

Frontend en Flutter/Dart que consume el backend en C++ del mismo proyecto
(`formaia-backend`). Cubre el flujo completo de punta a punta: registro →
perfil físico → chat con la IA → (rutina generada | meta rechazada) → plan.

> ⚠️ Igual que el backend, este código se escribió sin acceso a Flutter SDK
> ni a `flutter pub get`/`flutter analyze` en este entorno, así que no se
> pudo compilar aquí. La estructura, los imports y el uso de los paquetes
> (`http`, `provider`, `shared_preferences`) son estándar y estables, pero
> corre `flutter analyze` apenas lo abras para atrapar cualquier detalle
> menor (typo, import faltante) antes de que te frene.

## Cómo se conecta al backend

Todo pasa por **un solo archivo**, `lib/core/api_client.dart`, que arma cada
petición HTTP y traduce errores del backend (`{"error": "..."}`, ver
`Router::despachar` en el backend) a una `ApiException` que la UI sabe
mostrar. Cada servicio (`UsuarioService`, `SolicitudService`,
`RutinaService`) llama a `ApiClient` y mapea el JSON a un modelo Dart que
refleja **exactamente** la forma de la respuesta de cada endpoint en C++
(los comentarios en cada modelo apuntan al archivo del backend
correspondiente).

### Configurar la URL del backend

Ver `lib/core/app_config.dart`. Por defecto:
- **iOS Simulator:** `http://localhost:8080` (funciona tal cual).
- **Emulador de Android:** se usa automáticamente `http://10.0.2.2:8080`
  (`10.0.2.2` es cómo el emulador de Android le dice "la PC que me
  hospeda"; `localhost` ahí apuntaría al propio emulador, no a tu backend).
- **Dispositivo físico** (celular real por USB/Wi-Fi) o para **forzar otra
  URL**: corre la app con
  ```bash
  flutter run --dart-define=API_BASE_URL=http://TU_IP_LOCAL:8080
  ```
  Reemplaza `TU_IP_LOCAL` por la IP de tu PC en la red local (ej.
  `192.168.1.50`), y asegúrate de que:
  - El backend esté corriendo con `HTTP_HOST=0.0.0.0` (ya es el valor por
    defecto en `.env.example` del backend, así escucha en todas las
    interfaces, no solo en loopback).
  - El firewall de tu PC permita conexiones entrantes al puerto `8080`.
  - El celular esté en la misma red Wi-Fi que la PC.

### CORS (si compilas a Flutter Web)

El backend ya responde `Access-Control-Allow-Origin: *` y maneja el
preflight `OPTIONS` (ver `HttpServer.hpp`), así que `flutter run -d chrome`
también debería funcionar contra `http://localhost:8080` sin configuración
adicional.

## Instalar y correr

```bash
flutter pub get
flutter run                 # elige el emulador/dispositivo conectado
# o, apuntando a otra IP del backend:
flutter run --dart-define=API_BASE_URL=http://192.168.1.50:8080
```

## Cómo se prueba el flujo completo

1. Levanta el backend (ver `formaia-backend/README.md`): importa el
   esquema SQL, configura `.env`, compílalo y corre
   `./build/formaia_backend`.
2. Corre la app Flutter apuntando a esa misma URL.
3. En la app: **Crear cuenta** → completa correo/contraseña/fecha de
   nacimiento → **Cuéntanos sobre ti** (perfil físico) → en Inicio, toca
   **Crear rutina con IA** → escribe algo como *"quiero bajar de peso y
   verme como Kirito, tengo 4 días a la semana"* → la pantalla va
   mostrando el estado mientras el backend interpreta la meta con Groq,
   corre las reglas de seguridad y arma la progresión (todo eso pasa de
   forma asíncrona en el backend; el frontend solo pregunta cada 2
   segundos, ver `SolicitudService.esperarResultado`) → termina en la
   pantalla del **plan** (fases con sus semanas) o, si la meta no era
   segura, en la pantalla de **meta rechazada** con el motivo.

## Qué falta para producción (a propósito, fuera de este MVP)

Sigue el mismo alcance que el backend (ver su README, sección "No
incluidos en este MVP"):
- **Login real / JWT:** hoy la "sesión" es solo el `usuario_id` guardado
  con `shared_preferences` (`lib/core/session.dart`). Cuando el backend
  agregue autenticación, ese archivo es el único que necesita cambiar
  para guardar un token en vez de un id plano.
- **Sesión guiada de entrenamiento, progreso/mediciones, notificaciones
  push:** el backend todavía no expone esos endpoints (`entrenamiento`,
  `medicion`, `recordatorio` están en el esquema SQL pero no mapeados en
  el ORM del backend entregado). La estructura de `services/` y
  `screens/` ya está lista para agregarlos siguiendo el mismo patrón
  (`XxxService` + modelo + pantalla) apenas el backend los tenga.
- **Ajustar rutina en lenguaje natural (RF-12), lesiones/equipamiento
  persistidos (RF-13):** la pantalla de perfil ya pide equipamiento, pero
  el backend actual no guarda `limitacion` (lesiones); queda como
  siguiente paso natural en `UsuarioController.hpp`.
