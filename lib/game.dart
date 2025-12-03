import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'player.dart';
import 'enemy.dart';
import 'core_pickup.dart';
import 'map_component.dart';

class EcoNegroGame extends FlameGame with HasCollisionDetection {
  late Player player;
  late JoystickComponent joystick;
  MapComponent? mapComponent;

  // Estado del juego
  double playerHealth = 100.0;
  double playerEnergy = 20.0; // Iniciar con 20% de energía
  final double maxHealth = 100.0;
  final double maxEnergy = 100.0;
  
  // Sistema de rondas
  int currentRound = 1;
  int minionsToSpawnThisRound = 0;
  int minionsSpawnedThisRound = 0;
  int minionsKilledThisRound = 0;
  bool roundInProgress = false;
  bool waitingForNextRound = false;
  
  // Sujetos Fallidos (cada 5 rondas)
  bool failedSubjectSpawned = false;
  FailedSubject? currentFailedSubject;
  
  // Spawning de enemigos
  double spawnTimer = 0.0;
  double spawnInterval = 2.0; // Intervalo inicial
  
  // Dimensiones de la arena
  final double arenaWidth = 1200;
  final double arenaHeight = 800;
  
  // Botones de acción
  Vector2? screamButtonPosition;
  Vector2? echoButtonPosition;
  bool isScreamPressed = false;
  bool isEchoPressed = false;

  @override
  Color backgroundColor() => Colors.black;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Configurar cámara para seguir al jugador
    camera.viewfinder.anchor = Anchor.center;

    // Crear joystick primero
    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: 25,
        paint: Paint()..color = Colors.cyan.withAlpha(179),
      ),
      background: CircleComponent(
        radius: 60,
        paint: Paint()..color = Colors.cyan.withAlpha(77),
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    camera.viewport.add(joystick);

    // Crear mapa con paredes
    mapComponent = MapComponent(
      arenaWidth: arenaWidth,
      arenaHeight: arenaHeight,
    );
    world.add(mapComponent!);

    // Crear jugador en el centro
    player = Player(joystick: joystick);
    player.position = Vector2(arenaWidth / 2, arenaHeight / 2);
    world.add(player);

    // Configurar cámara para seguir al jugador
    camera.follow(player);

    // Posiciones de botones de acción
    screamButtonPosition = Vector2(size.x - 120, size.y - 120);
    echoButtonPosition = Vector2(size.x - 120, size.y - 240);

    // NO iniciar el juego hasta que termine la intro
    pauseEngine();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Iniciar primera ronda si no está en progreso
    if (!roundInProgress && !waitingForNextRound) {
      _startRound();
    }
    
    // Spawning de minions durante la ronda
    if (roundInProgress && minionsSpawnedThisRound < minionsToSpawnThisRound) {
      spawnTimer += dt;
      if (spawnTimer >= spawnInterval) {
        spawnTimer = 0.0;
        _spawnMinion();
        minionsSpawnedThisRound++;
      }
    }
    
    // Verificar si la ronda terminó
    if (roundInProgress && minionsKilledThisRound >= minionsToSpawnThisRound) {
      // Verificar si también murió el Sujeto Fallido (si había)
      if (failedSubjectSpawned) {
        if (currentFailedSubject == null || !currentFailedSubject!.isMounted) {
          _endRound();
        }
      } else {
        _endRound();
      }
    }
  }

  void _startRound() {
    roundInProgress = true;
    waitingForNextRound = false;
    
    // Calcular cuántos minions spawnearan esta ronda
    // Fórmula: 3 + (ronda - 1) * 2
    // Ronda 1: 3 minions
    // Ronda 2: 5 minions
    // Ronda 3: 7 minions, etc.
    minionsToSpawnThisRound = 3 + (currentRound - 1) * 2;
    minionsSpawnedThisRound = 0;
    minionsKilledThisRound = 0;
    
    // Ajustar intervalo de spawn (más rápido en rondas avanzadas)
    spawnInterval = max(0.5, 2.0 - (currentRound * 0.1));
    
    // Cada 5 rondas, spawneear un Sujeto Fallido
    if (currentRound % 5 == 0) {
      failedSubjectSpawned = true;
      _spawnFailedSubject();
    } else {
      failedSubjectSpawned = false;
    }
    
    // Ronda iniciada
  }

  void _endRound() {
    roundInProgress = false;
    waitingForNextRound = true;
    
    // Curar 20% de la vida actual (con redondeo correcto)
    final healPercent = playerHealth * 0.2;
    final decimal = healPercent - healPercent.floor();
    double healAmount;
    
    if (decimal >= 0.6) {
      healAmount = healPercent.ceil().toDouble();
    } else if (decimal <= 0.5) {
      healAmount = healPercent.floor().toDouble();
    } else {
      healAmount = healPercent.round().toDouble();
    }
    
    playerHealth = min(maxHealth, playerHealth + healAmount);
    
    // La energía se mantiene de la ronda anterior
    
    // Avanzar a la siguiente ronda
    currentRound++;
    
    // Pequeña pausa antes de la siguiente ronda
    Future.delayed(const Duration(seconds: 2), () {
      if (isMounted) {
        _startRound();
      }
    });
  }

  void _spawnFailedSubject() {
    final random = Random();
    Vector2 spawnPos;
    int attempts = 0;
    const maxAttempts = 100;
    const failedSubjectRadius = 30.0;
    const minDistanceFromPlayer = 350.0;

    do {
      spawnPos = Vector2(
        100 + random.nextDouble() * (arenaWidth - 200),
        100 + random.nextDouble() * (arenaHeight - 200),
      );
      attempts++;

      final farFromPlayer = spawnPos.distanceTo(player.position) >= minDistanceFromPlayer;
      final notInWall = !(mapComponent?.collidesWithWalls(spawnPos, failedSubjectRadius) ?? false);

      if (farFromPlayer && notInWall) {
        break;
      }
    } while (attempts < maxAttempts);

    if (attempts >= maxAttempts) {
      spawnPos = Vector2(arenaWidth / 2, arenaHeight / 2);
    }

    currentFailedSubject = FailedSubject(target: player);
    currentFailedSubject!.position = spawnPos;
    world.add(currentFailedSubject!);
  }

  void _spawnMinion() {
    final random = Random();
    Vector2 spawnPos;
    int attempts = 0;
    const maxAttempts = 100;
    const minDistanceFromPlayer = 250.0;
    const minionRadius = 10.0;

    // Spawn lejos del jugador y no dentro de paredes
    do {
      // Generar posición aleatoria en toda la arena
      spawnPos = Vector2(
        50 + random.nextDouble() * (arenaWidth - 100),
        50 + random.nextDouble() * (arenaHeight - 100),
      );
      attempts++;

      // Verificar condiciones
      final farFromPlayer = spawnPos.distanceTo(player.position) >= minDistanceFromPlayer;
      final notInWall = !(mapComponent?.collidesWithWalls(spawnPos, minionRadius) ?? false);

      if (farFromPlayer && notInWall) {
        break;
      }
    } while (attempts < maxAttempts);

    // Si después de muchos intentos no encontramos posición, spawneamos en una esquina segura
    if (attempts >= maxAttempts) {
      final corners = [
        Vector2(100, 100),
        Vector2(arenaWidth - 100, 100),
        Vector2(100, arenaHeight - 100),
        Vector2(arenaWidth - 100, arenaHeight - 100),
      ];

      // Elegir esquina más lejana del jugador
      spawnPos = corners.reduce((a, b) =>
          a.distanceTo(player.position) > b.distanceTo(player.position) ? a : b);
    }

    final minion = Minion(target: player);
    minion.position = spawnPos;
    world.add(minion);
  }



  void onMinionKilled(Vector2 position) {
    minionsKilledThisRound++;
    
    // Soltar núcleo de energía
    final core = CorePickup();
    core.position = position;
    world.add(core);
  }

  void collectCore() {
    playerEnergy = (playerEnergy + 30).clamp(0, maxEnergy);
  }

  void useScream() {
    if (playerEnergy >= 20) {
      playerEnergy -= 20;
      player.performScream();
    }
  }

  void usePing() {
    // Ping NO consume energía
    player.performPing();
  }

  void takeDamage(double damage) {
    playerHealth = (playerHealth - damage).clamp(0, maxHealth);
    if (playerHealth <= 0) {
      // Game Over - Mostrar pantalla con ronda alcanzada
      pauseEngine();
      overlays.add('GameOver');
    }
  }

  void restartGame() {
    // Remover todos los enemigos y pickups del mundo
    world.children.whereType<Enemy>().forEach((enemy) => enemy.removeFromParent());
    world.children.whereType<CorePickup>().forEach((core) => core.removeFromParent());
    
    // Resetear estado
    playerHealth = maxHealth;
    playerEnergy = maxEnergy * 0.2; // Iniciar con 20% de energía
    
    // Resetear sistema de rondas
    currentRound = 1;
    minionsToSpawnThisRound = 0;
    minionsSpawnedThisRound = 0;
    minionsKilledThisRound = 0;
    roundInProgress = false;
    waitingForNextRound = false;
    failedSubjectSpawned = false;
    currentFailedSubject = null;
    spawnTimer = 0.0;
    
    // Resetear posición del jugador
    player.position = Vector2(arenaWidth / 2, arenaHeight / 2);
    player.velocity = Vector2.zero();
    
    // Remover overlay de victoria si existe
    overlays.remove('Victory');
    overlays.remove('Pause');
  }

  void togglePause() {
    if (overlays.isActive('Pause')) {
      overlays.remove('Pause');
      resumeEngine();
    } else {
      overlays.add('Pause');
      pauseEngine();
    }
  }
}
