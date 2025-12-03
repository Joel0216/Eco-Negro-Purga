import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'game.dart';
import 'player.dart';

abstract class Enemy extends PositionComponent with HasGameReference<EcoNegroGame>, CollisionCallbacks {
  final Player target;
  double health;
  final double maxHealth;
  final double speed;
  final double damage;
  double damageTimer = 0.0;
  final double damageCooldown = 1.0;

  Enemy({
    required this.target,
    required this.health,
    required this.maxHealth,
    required this.speed,
    required this.damage,
    required Vector2 size,
  }) : super(size: size, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(radius: size.x / 2));
  }

  @override
  void update(double dt) {
    super.update(dt);

    damageTimer += dt;

    // IA de persecución mejorada (Steering Behavior - Seek)
    final toTarget = target.position - position;
    final distance = toTarget.length;

    if (distance > 0) {
      // Calcular velocidad deseada
      final desiredVelocity = toTarget.normalized() * speed;

      // Aplicar movimiento
      final newPosition = position + desiredVelocity * dt;

      // Verificar colisiones con paredes y ajustar
      if (game.mapComponent != null) {
        final validPosition = game.mapComponent!
            .getValidPosition(position, newPosition, size.x / 2);
        position = game.mapComponent!.resolveCollision(validPosition, size.x / 2);
      } else {
        position = newPosition;
      }
    }

    // Mantener dentro de la arena (backup)
    position.x = position.x.clamp(size.x / 2, game.arenaWidth - size.x / 2);
    position.y = position.y.clamp(size.y / 2, game.arenaHeight - size.y / 2);
  }

  void takeDamage(double amount) {
    health -= amount;
    if (health <= 0) {
      onDeath();
      removeFromParent();
    }
  }

  void onDeath();

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is Player && damageTimer >= damageCooldown) {
      game.takeDamage(damage);
      damageTimer = 0.0;
    }
  }
}

class Minion extends Enemy {
  Minion({required super.target})
      : super(
          health: 30,
          maxHealth: 30,
          speed: 80,
          damage: 5,
          size: Vector2.all(20),
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Dibujar minion como círculo rojo pulsante
    final pulse = sin(game.currentTime() * 3) * 0.2 + 0.8;
    final paint = Paint()
      ..color = Colors.red.withAlpha((255 * 0.6 * pulse).toInt())
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset.zero, size.x / 2, paint);
    
    // Borde
    final borderPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset.zero, size.x / 2, borderPaint);
    
    // Barra de vida
    _drawHealthBar(canvas);
  }

  void _drawHealthBar(Canvas canvas) {
    final barWidth = size.x;
    final barHeight = 4.0;
    final barY = -size.y / 2 - 10;
    
    // Fondo
    canvas.drawRect(
      Rect.fromLTWH(-barWidth / 2, barY, barWidth, barHeight),
      Paint()..color = Colors.grey.withAlpha(128),
    );
    
    // Vida actual
    final healthPercent = health / maxHealth;
    canvas.drawRect(
      Rect.fromLTWH(-barWidth / 2, barY, barWidth * healthPercent, barHeight),
      Paint()..color = Colors.red,
    );
  }

  @override
  void onDeath() {
    game.onMinionKilled(position);
  }
}

class Alpha extends Enemy {
  Alpha({required super.target})
      : super(
          health: 300,
          maxHealth: 300,
          speed: 60,
          damage: 15,
          size: Vector2.all(50),
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Dibujar Alpha como círculo grande con aura
    final pulse = sin(game.currentTime() * 2) * 0.3 + 0.7;
    
    // Aura exterior
    final auraPaint = Paint()
      ..color = Colors.purple.withAlpha((255 * 0.3 * pulse).toInt())
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, size.x / 2 + 10, auraPaint);
    
    // Cuerpo principal
    final paint = Paint()
      ..color = Colors.purple.withAlpha(204)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, size.x / 2, paint);
    
    // Borde brillante
    final borderPaint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset.zero, size.x / 2, borderPaint);
    
    // Núcleo interno
    final corePaint = Paint()
      ..color = Colors.white.withAlpha(204)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 10, corePaint);
    
    // Barra de vida
    _drawHealthBar(canvas);
  }

  void _drawHealthBar(Canvas canvas) {
    final barWidth = size.x * 1.5;
    final barHeight = 6.0;
    final barY = -size.y / 2 - 15;
    
    // Fondo
    canvas.drawRect(
      Rect.fromLTWH(-barWidth / 2, barY, barWidth, barHeight),
      Paint()..color = Colors.grey.withAlpha(128),
    );
    
    // Vida actual
    final healthPercent = health / maxHealth;
    canvas.drawRect(
      Rect.fromLTWH(-barWidth / 2, barY, barWidth * healthPercent, barHeight),
      Paint()..color = Colors.purple,
    );
    
    // Texto de vida
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${health.toInt()}/${maxHealth.toInt()}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, barY - 15));
  }

  @override
  void onDeath() {
    // Alpha muerto = Victoria
  }
}


class FailedSubject extends Enemy {
  FailedSubject({required super.target})
      : super(
          health: 150,
          maxHealth: 150,
          speed: 70,
          damage: 20, // 20 de daño por segundo
          size: Vector2.all(40),
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Dibujar Sujeto Fallido como círculo rojo grande con efectos
    final pulse = sin(game.currentTime() * 2.5) * 0.3 + 0.7;

    // Aura exterior roja
    final auraPaint = Paint()
      ..color = Colors.red.withAlpha((255 * 0.4 * pulse).toInt())
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, size.x / 2 + 8, auraPaint);

    // Cuerpo principal rojo
    final paint = Paint()
      ..color = Colors.red.withAlpha(220)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, size.x / 2, paint);

    // Borde brillante
    final borderPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset.zero, size.x / 2, borderPaint);

    // Núcleo interno oscuro
    final corePaint = Paint()
      ..color = Colors.black.withAlpha(180)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 12, corePaint);

    // Barra de vida
    _drawHealthBar(canvas);
  }

  void _drawHealthBar(Canvas canvas) {
    final barWidth = size.x * 1.3;
    final barHeight = 5.0;
    final barY = -size.y / 2 - 12;

    // Fondo
    canvas.drawRect(
      Rect.fromLTWH(-barWidth / 2, barY, barWidth, barHeight),
      Paint()..color = Colors.grey.withAlpha(128),
    );

    // Vida actual
    final healthPercent = health / maxHealth;
    canvas.drawRect(
      Rect.fromLTWH(-barWidth / 2, barY, barWidth * healthPercent, barHeight),
      Paint()..color = Colors.red,
    );

    // Texto de vida
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${health.toInt()}/${maxHealth.toInt()}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, barY - 14));
  }

  @override
  void onDeath() {
    // Sujeto Fallido muerto
  }
}
