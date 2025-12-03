import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'game.dart';
import 'player.dart';

class CorePickup extends PositionComponent with HasGameReference<EcoNegroGame>, CollisionCallbacks {
  double lifetime = 10.0; // Desaparece después de 10 segundos
  double pulseTimer = 0.0;

  CorePickup() : super(
    size: Vector2.all(15),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(radius: 7.5));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    lifetime -= dt;
    pulseTimer += dt;
    
    if (lifetime <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Efecto de pulso
    final pulse = sin(pulseTimer * 4) * 0.3 + 0.7;
    
    // Aura exterior
    final auraPaint = Paint()
      ..color = Colors.blue.withAlpha((255 * 0.3 * pulse).toInt())
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 12 * pulse, auraPaint);
    
    // Núcleo
    final corePaint = Paint()
      ..color = Colors.blue.withAlpha(230)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 7.5, corePaint);
    
    // Borde brillante
    final borderPaint = Paint()
      ..color = Colors.lightBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset.zero, 7.5, borderPaint);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    
    if (other is Player) {
      game.collectCore();
      removeFromParent();
    }
  }
}
