import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'wall_component.dart';

class MapComponent extends Component {
  final double arenaWidth;
  final double arenaHeight;
  final List<WallComponent> walls = [];

  MapComponent({
    required this.arenaWidth,
    required this.arenaHeight,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _generateWalls();
  }

  void _generateWalls() {
    final wallThickness = 20.0;
    final random = Random();

    // Paredes exteriores (bordes de la arena)
    // Pared superior
    walls.add(WallComponent(
      position: Vector2(0, 0),
      size: Vector2(arenaWidth, wallThickness),
    ));

    // Pared inferior
    walls.add(WallComponent(
      position: Vector2(0, arenaHeight - wallThickness),
      size: Vector2(arenaWidth, wallThickness),
    ));

    // Pared izquierda
    walls.add(WallComponent(
      position: Vector2(0, 0),
      size: Vector2(wallThickness, arenaHeight),
    ));

    // Pared derecha
    walls.add(WallComponent(
      position: Vector2(arenaWidth - wallThickness, 0),
      size: Vector2(wallThickness, arenaHeight),
    ));

    // Generar obstáculos aleatorios
    final numObstacles = 8 + random.nextInt(5); // 8-12 obstáculos
    final centerX = arenaWidth / 2;
    final centerY = arenaHeight / 2;
    final safeZoneRadius = 150.0; // Zona segura alrededor del centro

    for (int i = 0; i < numObstacles; i++) {
      // Decidir si es horizontal o vertical
      final isHorizontal = random.nextBool();

      double x, y, width, height;

      if (isHorizontal) {
        // Pared horizontal
        width = 100 + random.nextDouble() * 200; // 100-300 de ancho
        height = wallThickness;
        x = 50 + random.nextDouble() * (arenaWidth - width - 100);
        y = 50 + random.nextDouble() * (arenaHeight - 100);
      } else {
        // Pared vertical
        width = wallThickness;
        height = 100 + random.nextDouble() * 200; // 100-300 de alto
        x = 50 + random.nextDouble() * (arenaWidth - 100);
        y = 50 + random.nextDouble() * (arenaHeight - height - 100);
      }

      // Verificar que no esté en la zona segura del centro
      final obstacleCenter = Vector2(x + width / 2, y + height / 2);
      final distanceToCenter =
          obstacleCenter.distanceTo(Vector2(centerX, centerY));

      if (distanceToCenter > safeZoneRadius) {
        // Verificar que no se superponga con otras paredes
        final newWallRect = Rect.fromLTWH(x, y, width, height);
        bool overlaps = false;

        for (final existingWall in walls) {
          final existingRect = existingWall.toRect();
          if (newWallRect.overlaps(existingRect)) {
            overlaps = true;
            break;
          }
        }

        if (!overlaps) {
          walls.add(WallComponent(
            position: Vector2(x, y),
            size: Vector2(width, height),
          ));
        }
      }
    }

    // Agregar todas las paredes al juego
    for (final wall in walls) {
      add(wall);
    }
  }

  /// Verifica colisión de un punto con las paredes
  bool collidesWithWalls(Vector2 position, double radius) {
    for (final wall in walls) {
      final wallRect = wall.toRect();
      final expandedRect = Rect.fromLTRB(
        wallRect.left - radius,
        wallRect.top - radius,
        wallRect.right + radius,
        wallRect.bottom + radius,
      );

      if (expandedRect.contains(Offset(position.x, position.y))) {
        return true;
      }
    }
    return false;
  }

  /// Obtiene la posición ajustada para evitar colisiones con paredes
  Vector2 getValidPosition(
      Vector2 currentPosition, Vector2 desiredPosition, double radius) {
    // Verificar si la posición deseada colisiona
    if (!collidesWithWalls(desiredPosition, radius)) {
      return desiredPosition;
    }

    // Si colisiona, intentar deslizamiento en X e Y por separado
    final slideX = Vector2(desiredPosition.x, currentPosition.y);
    final slideY = Vector2(currentPosition.x, desiredPosition.y);

    // Intentar deslizar en X
    if (!collidesWithWalls(slideX, radius)) {
      return slideX;
    }

    // Intentar deslizar en Y
    if (!collidesWithWalls(slideY, radius)) {
      return slideY;
    }

    // Si ninguno funciona, quedarse en la posición actual
    return currentPosition;
  }

  /// Método alternativo más preciso para validar posición
  Vector2 resolveCollision(Vector2 position, double radius) {
    Vector2 resolvedPosition = position.clone();

    for (final wall in walls) {
      final wallRect = wall.toRect();

      // Calcular el punto más cercano del rectángulo al círculo
      final closestX = position.x.clamp(wallRect.left, wallRect.right);
      final closestY = position.y.clamp(wallRect.top, wallRect.bottom);

      final distanceX = position.x - closestX;
      final distanceY = position.y - closestY;
      final distanceSquared = distanceX * distanceX + distanceY * distanceY;

      // Si hay colisión
      if (distanceSquared < radius * radius) {
        final distance = sqrt(distanceSquared);

        if (distance > 0) {
          // Calcular vector de separación
          final separationX = distanceX / distance;
          final separationY = distanceY / distance;

          // Empujar fuera de la pared
          final overlap = radius - distance;
          resolvedPosition.x += separationX * overlap;
          resolvedPosition.y += separationY * overlap;
        } else {
          // El centro está dentro del rectángulo, empujar hacia el borde más cercano
          final pushLeft = position.x - wallRect.left;
          final pushRight = wallRect.right - position.x;
          final pushTop = position.y - wallRect.top;
          final pushBottom = wallRect.bottom - position.y;

          final minPush = [pushLeft, pushRight, pushTop, pushBottom].reduce(min);

          if (minPush == pushLeft) {
            resolvedPosition.x = wallRect.left - radius;
          } else if (minPush == pushRight) {
            resolvedPosition.x = wallRect.right + radius;
          } else if (minPush == pushTop) {
            resolvedPosition.y = wallRect.top - radius;
          } else {
            resolvedPosition.y = wallRect.bottom + radius;
          }
        }
      }
    }

    return resolvedPosition;
  }

  /// Lanza rayos desde una posición y revela las paredes que toca
  void castRays(Vector2 origin, int numRays, double maxLength) {
    for (int i = 0; i < numRays; i++) {
      final angle = (i / numRays) * 2 * 3.14159265359;
      final direction = Vector2(
        maxLength * cos(angle),
        maxLength * sin(angle),
      );

      // Verificar intersección con cada pared
      for (final wall in walls) {
        if (wall.intersectsRay(origin, direction.normalized(), maxLength)) {
          wall.reveal();
        }
      }
    }
  }
}
