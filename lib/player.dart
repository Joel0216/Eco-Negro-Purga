import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'game.dart';
import 'enemy.dart';

class Player extends PositionComponent
    with HasGameReference<EcoNegroGame>, CollisionCallbacks {
  final JoystickComponent joystick;
  final double speed = 200.0;
  Vector2 velocity = Vector2.zero();
  double currentAngle = 0.0;

  // Efectos visuales
  final List<EchoWave> echoWaves = [];

  // Cono de apuntado (siempre visible)
  final double aimConeAngle = pi / 4; // 45 grados
  final double aimConeLength = 150.0;

  // Sistema de invulnerabilidad para evitar múltiples golpes
  double invulnerabilityTimer = 0.0;
  final double invulnerabilityDuration = 0.5; // 0.5 segundos de invulnerabilidad
  bool isInvulnerable = false;

  Player({required this.joystick})
      : super(
          size: Vector2.all(30),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Hitbox del jugador
    add(CircleHitbox(radius: 15));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Sistema de invulnerabilidad
    if (isInvulnerable) {
      invulnerabilityTimer -= dt;
      if (invulnerabilityTimer <= 0) {
        isInvulnerable = false;
      }
    }

    // Movimiento con joystick (sin inversión de Y)
    if (!joystick.delta.isZero()) {
      velocity = joystick.relativeDelta * speed;
      currentAngle = joystick.delta.angleToSigned(Vector2(1, 0));
    } else {
      velocity = Vector2.zero();
    }

    // Calcular posición deseada
    final desiredPosition = position + velocity * dt;

    // Verificar colisiones con paredes y ajustar posición
    if (game.mapComponent != null) {
      // Usar el nuevo sistema de colisiones con deslizamiento
      final validPosition = game.mapComponent!
          .getValidPosition(position, desiredPosition, 15);
      position = game.mapComponent!.resolveCollision(validPosition, 15);
    } else {
      position = desiredPosition;
    }

    // Colisiones con bordes de la arena (backup)
    position.x = position.x.clamp(20, game.arenaWidth - 20);
    position.y = position.y.clamp(20, game.arenaHeight - 20);

    // Actualizar ondas de eco
    echoWaves.removeWhere((wave) => wave.shouldRemove);
    for (final wave in echoWaves) {
      wave.update(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Dibujar cono de apuntado (siempre visible)
    _drawAimCone(canvas);

    // Dibujar ondas de eco
    for (final wave in echoWaves) {
      wave.render(canvas);
    }

    // Dibujar jugador (punto brillante)
    final paint = Paint()..color = Colors.cyan..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 15, paint);

    // Indicador de dirección
    final dirPaint = Paint()..color = Colors.white..strokeWidth = 2;
    final dirEnd = Offset(cos(currentAngle) * 20, sin(currentAngle) * 20);
    canvas.drawLine(Offset.zero, dirEnd, dirPaint);
  }

  void _drawAimCone(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.red.withAlpha(60)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);

    final leftAngle = currentAngle - aimConeAngle / 2;
    final rightAngle = currentAngle + aimConeAngle / 2;

    path.lineTo(
      cos(leftAngle) * aimConeLength,
      sin(leftAngle) * aimConeLength,
    );

    // Arco entre los dos puntos
    final steps = 10;
    for (int i = 0; i <= steps; i++) {
      final angle =
          leftAngle + (rightAngle - leftAngle) * (i / steps);
      path.lineTo(
        cos(angle) * aimConeLength,
        sin(angle) * aimConeLength,
      );
    }

    path.close();
    canvas.drawPath(path, paint);

    // Borde del cono
    final borderPaint = Paint()
      ..color = Colors.red.withAlpha(120)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  void performScream() {
    // Crear cono de ataque
    final scream = ScreamCone(
      origin: position.clone(),
      direction: currentAngle,
      game: game,
    );
    game.world.add(scream);
  }

  void performPing() {
    // Ping NO consume energía
    // Lanzar rayos para revelar paredes
    if (game.mapComponent != null) {
      game.mapComponent!.castRays(position, 64, 400);
    }

    // Crear onda visual de ping
    final wave = EchoWave(
      origin: position.clone(),
      maxRadius: 400,
      duration: 1.5,
      color: Colors.cyan,
    );
    echoWaves.add(wave);
  }

  // El daño se maneja desde los enemigos con cooldown
}

class ScreamCone extends Component with HasGameReference<EcoNegroGame> {
  final Vector2 origin;
  final double direction;
  @override
  final EcoNegroGame game;
  final double coneAngle = pi / 3; // 60 grados
  final double coneLength = 250;
  double lifetime = 0.3;

  ScreamCone({
    required this.origin,
    required this.direction,
    required this.game,
  });

  @override
  void update(double dt) {
    super.update(dt);
    
    lifetime -= dt;
    if (lifetime <= 0) {
      removeFromParent();
      return;
    }
    
    // Detectar enemigos en el cono
    for (final enemy in game.world.children.whereType<Enemy>()) {
      if (_isInCone(enemy.position)) {
        enemy.takeDamage(50);
      }
    }
  }

  bool _isInCone(Vector2 targetPos) {
    final toTarget = targetPos - origin;
    final distance = toTarget.length;
    
    if (distance > coneLength) return false;
    
    final angleToTarget = toTarget.angleToSigned(Vector2(cos(direction), sin(direction)));
    return angleToTarget.abs() <= coneAngle / 2;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final paint = Paint()
      ..color = Colors.cyan.withAlpha(77)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(origin.x, origin.y);
    
    final leftAngle = direction - coneAngle / 2;
    final rightAngle = direction + coneAngle / 2;
    
    path.lineTo(
      origin.x + cos(leftAngle) * coneLength,
      origin.y + sin(leftAngle) * coneLength,
    );
    
    path.arcToPoint(
      Offset(
        origin.x + cos(rightAngle) * coneLength,
        origin.y + sin(rightAngle) * coneLength,
      ),
      radius: Radius.circular(coneLength),
    );
    
    path.close();
    canvas.drawPath(path, paint);
  }
}

class EchoWave {
  final Vector2 origin;
  final double maxRadius;
  final double duration;
  final Color color;
  double elapsed = 0.0;
  bool shouldRemove = false;

  EchoWave({
    required this.origin,
    required this.maxRadius,
    required this.duration,
    this.color = Colors.cyan,
  });

  void update(double dt) {
    elapsed += dt;
    if (elapsed >= duration) {
      shouldRemove = true;
    }
  }

  void render(Canvas canvas) {
    final progress = elapsed / duration;
    final currentRadius = maxRadius * progress;
    final opacity = 1.0 - progress;

    final paint = Paint()
      ..color = color.withAlpha((255 * opacity * 0.5).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(
      Offset(origin.x, origin.y),
      currentRadius,
      paint,
    );
  }
}


