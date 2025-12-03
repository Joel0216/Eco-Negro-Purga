import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class WallComponent extends RectangleComponent {
  @override
  double opacity = 0.0; // Comienza invisible
  final double fadeSpeed = 0.3; // Velocidad de desvanecimiento
  final double visibleDuration = 4.0; // Tiempo visible después del ping
  double visibilityTimer = 0.0;

  WallComponent({
    required Vector2 position,
    required Vector2 size,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.topLeft,
        );

  @override
  void update(double dt) {
    super.update(dt);

    // Si la pared está visible, reducir el timer
    if (visibilityTimer > 0) {
      visibilityTimer -= dt;
      opacity = 1.0; // Mantener completamente visible
    } else if (opacity > 0) {
      // Desvanecimiento gradual
      opacity -= dt * fadeSpeed;
      if (opacity < 0) opacity = 0.0;
    }
  }

  @override
  void render(Canvas canvas) {
    if (opacity > 0) {
      final paint = Paint()
        ..color = Colors.grey.withAlpha((255 * opacity).toInt())
        ..style = PaintingStyle.fill;

      canvas.drawRect(size.toRect(), paint);

      // Borde más visible
      final borderPaint = Paint()
        ..color = Colors.white.withAlpha((255 * opacity * 0.8).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawRect(size.toRect(), borderPaint);
    }
  }

  /// Revela la pared cuando es golpeada por un rayo
  void reveal() {
    visibilityTimer = visibleDuration;
    opacity = 1.0;
  }

  /// Verifica si un rayo intersecta con esta pared
  bool intersectsRay(Vector2 origin, Vector2 direction, double maxLength) {
    // Convertir a coordenadas globales
    final wallRect = toRect();

    // Calcular intersección rayo-rectángulo
    final rayEnd = origin + direction * maxLength;

    return _lineIntersectsRect(origin, rayEnd, wallRect);
  }

  bool _lineIntersectsRect(Vector2 p1, Vector2 p2, Rect rect) {
    // Verificar si la línea intersecta con alguno de los 4 lados del rectángulo
    return _lineIntersectsLine(
            p1, p2, Offset(rect.left, rect.top), Offset(rect.right, rect.top)) ||
        _lineIntersectsLine(p1, p2, Offset(rect.right, rect.top),
            Offset(rect.right, rect.bottom)) ||
        _lineIntersectsLine(p1, p2, Offset(rect.right, rect.bottom),
            Offset(rect.left, rect.bottom)) ||
        _lineIntersectsLine(p1, p2, Offset(rect.left, rect.bottom),
            Offset(rect.left, rect.top));
  }

  bool _lineIntersectsLine(Vector2 p1, Vector2 p2, Offset p3, Offset p4) {
    final x1 = p1.x;
    final y1 = p1.y;
    final x2 = p2.x;
    final y2 = p2.y;
    final x3 = p3.dx;
    final y3 = p3.dy;
    final x4 = p4.dx;
    final y4 = p4.dy;

    final denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if (denom == 0) return false;

    final t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom;
    final u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denom;

    return t >= 0 && t <= 1 && u >= 0 && u <= 1;
  }
}
