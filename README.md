# Eco Negro: Proyecto Casandra

Un juego móvil de Arena Survival Horror desarrollado con Flutter y Flame Engine.

## 🎮 Concepto del Juego

"Eco Negro" es un juego top-down donde el jugador navega en completa oscuridad usando ecolocalización. El jugador es el "Sujeto 7", quien debe sobrevivir oleadas de enemigos usando ondas sonoras para ver y atacar.

## 🕹️ Controles

- **Joystick Virtual** (esquina inferior izquierda): Mueve al personaje
- **Botón Ping** (derecha, arriba): Lanza rayos de ecolocalización que revelan paredes (GRATIS)
- **Botón Grito** (derecha, abajo): Ataque en cono direccional (costo: 20 energía)
- **Botón Pausa** (esquina superior derecha): Pausa el juego

## 🎯 Mecánicas Principales

### Sistema de Ecolocalización (Ping)
- **SIN COSTO DE ENERGÍA**: El Ping es gratuito y se puede usar ilimitadamente
- Lanza 64 rayos desde el jugador que revelan las paredes al impactar
- Las paredes reveladas permanecen visibles durante 4 segundos
- Desvanecimiento gradual: Las paredes se desvanecen lentamente permitiendo memorizar el camino
- El mapa comienza completamente negro, solo se revela con el Ping

### Cono de Apuntado
- Indicador visual rojo semitransparente siempre visible
- Muestra la dirección del ataque del Grito
- Se orienta según la dirección del joystick

### Sistema de Energía
- **Consumo**: Solo el Grito consume energía (20 puntos)
- **Recarga por Núcleos**: Los minions sueltan núcleos azules al morir (+30 energía)
- **Recarga de Emergencia**: Si la energía llega a 0, después de 60 segundos se recarga automáticamente al 20%

### Enemigos
- **Minions** (rojos): Aparecen cada 5 segundos, débiles pero numerosos
- **Alpha** (morado): Jefe que aparece después de matar 10 minions, muy resistente
- **IA Mejorada**: Los enemigos usan "Steering Behavior" para perseguir al jugador
- **Navegación**: Los enemigos evitan quedarse atascados en paredes
- **Spawn Inteligente**: Siempre aparecen lejos del jugador y nunca dentro de paredes

### Mapa
- **Generación Aleatoria**: Cada partida tiene un mapa único con 8-12 obstáculos
- **Zona Segura**: El centro siempre está libre para el spawn del jugador
- **Variedad**: Paredes horizontales y verticales de tamaños aleatorios
- **Sin Superposición**: Las paredes nunca se superponen entre sí

### Victoria
Derrota al Alpha para silenciar el área y ganar el nivel.

## 🚀 Instalación y Ejecución

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en dispositivo/emulador
flutter run

# Compilar para Android
flutter build apk

# Compilar para iOS
flutter build ios
```

## 📦 Dependencias

- `flame: ^1.18.0` - Motor de juego
- `flame_audio: ^2.1.0` - Sistema de audio

## 🏗️ Estructura del Código

```
lib/
├── main.dart           # Punto de entrada y configuración
├── game.dart           # Lógica principal del juego
├── player.dart         # Componente del jugador y habilidades
├── enemy.dart          # Enemigos (Minion y Alpha) con IA
├── core_pickup.dart    # Núcleos de energía
├── wall_component.dart # Paredes con sistema de revelado
├── map_component.dart  # Generación de mapa y raycasting
└── overlays.dart       # UI (HUD, Menú de Pausa, Victoria)
```

## 🎨 Características Visuales

- Fondo completamente negro (oscuridad total)
- Sistema de revelado de paredes con desvanecimiento gradual
- Cono de apuntado rojo semitransparente
- Ondas de ping cyan que se expanden
- Enemigos con efectos de pulso
- Barras de vida y energía en tiempo real
- Interfaz minimalista y atmosférica
- Mapa único en cada partida (generación procedural)

## 🔧 Mejoras Técnicas v2.2

- **Sistema de Cámara**: La cámara sigue al jugador para explorar mapas grandes
- **Sistema de Colisiones Mejorado**: Sin teletransportación, deslizamiento suave por paredes
- **Generación Procedural**: Mapas aleatorios con 8-12 obstáculos únicos
- **Spawn Inteligente**: 100 intentos con sistema de fallback en esquinas
- **Navegación Fluida**: Enemigos y jugador se mueven naturalmente alrededor de obstáculos
- **Balance Mejorado**: Energía inicial 20%, Alpha con 300 HP, daño gradual

## 🎯 Próximas Mejoras

- Múltiples niveles con dificultad creciente
- Más tipos de enemigos
- Power-ups adicionales
- Sistema de puntuación
- Efectos de sonido y música

---

Desarrollado con ❤️ usando Flutter y Flame Engine

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
