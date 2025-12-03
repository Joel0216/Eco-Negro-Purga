# Eco Negro: Proyecto Casandra

<div align="center">

![Version](https://img.shields.io/badge/version-3.1.2-cyan)
![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-green)
![License](https://img.shields.io/badge/license-MIT-red)

**Un juego móvil de Arena Survival Horror con ecolocalización**

[Características](#características) • [Instalación](#instalación) • [Gameplay](#gameplay) • [Lore](#lore) • [Desarrollo](#desarrollo)

</div>

---

## 📖 Descripción

**Eco Negro: Proyecto Casandra** es un juego de supervivencia en arena con mecánicas únicas de ecolocalización. Desarrollado con Flutter y Flame Engine, ofrece una experiencia inmersiva donde navegas en la oscuridad total usando ondas sonoras.

### 🎮 Concepto

Eres el **Sujeto 7**, el único éxito del Proyecto Casandra. Ciego pero con ecolocalización perfecta, debes sobrevivir oleadas infinitas de "Resonancias" (sujetos fallidos) en las ruinas de un laboratorio colapsado.

---

## ✨ Características

### 🎯 Mecánicas Principales

- **Sistema de Ecolocalización (Ping)**: Revela paredes con rayos sónicos (GRATIS)
- **Grito de Ruptura**: Ataque en cono direccional (50 daño)
- **Rondas Infinitas**: Dificultad escalable con progresión infinita
- **Boss cada 5 Rondas**: Sujeto Corrupto con 150 HP
- **Canibalismo Energético**: Absorbe núcleos de enemigos caídos

### 🗺️ Mundo del Juego

- **Mapa Procedural**: Cada partida genera un laberinto único
- **Oscuridad Total**: Solo ves lo que revelas con ecolocalización
- **Paredes con Memoria**: Se desvanecen gradualmente (4 segundos visibles)
- **Cámara Dinámica**: Sigue al jugador para exploración amplia

### 🎨 Características Visuales

- Diseño minimalista en negro y cyan
- Efectos de pulso en enemigos
- Cono de apuntado siempre visible
- UI optimizada para móvil
- Orientación horizontal forzada

---

## 🎮 Gameplay

### Controles

| Control | Función | Costo |
|---------|---------|-------|
| 🕹️ Joystick | Movimiento | - |
| 🔵 Ping | Revelar paredes | Gratis |
| 🔴 Grito | Ataque en cono | 20 energía |
| ⏸️ Pausa | Pausar juego | - |

### Sistema de Rondas

```
Ronda 1: 3 minions
Ronda 2: 5 minions
Ronda 3: 7 minions
Ronda 5: 11 minions + Sujeto Corrupto
...
Ronda ∞: Progresión infinita
```

### Enemigos

| Enemigo | HP | Daño/s | Velocidad |
|---------|-----|--------|-----------|
| Minion | 30 | 5 | 80 px/s |
| Sujeto Corrupto | 150 | 20 | 70 px/s |

### Progresión

- **Energía Inicial**: 20% (20 puntos)
- **Curación entre Rondas**: 20% de vida actual
- **Energía Persistente**: Se mantiene entre rondas
- **Núcleos**: +30 energía por minion eliminado

---

## 📚 Lore

### El Proyecto Casandra

En el apogeo de una guerra fría no declarada, las agencias de inteligencia buscaban la ventaja definitiva: la infiltración indetectable. El **Proyecto Casandra** nació con un objetivo: convertir la percepción en un arma.

### Las Resonancias

El proyecto fue un fracaso catastrófico. Los sujetos se convirtieron en "Las Resonancias": atrapados en agonía constante, con poder incontrolado, cazan cualquier sonido para silenciar su tormento.

### Sujeto 7 (Tú)

Eres el único éxito. Tu ceguera es total, pero tu mente procesa los ecos con claridad perfecta. Puedes canalizar el "Grito de Ruptura". Eras el activo más valioso... hasta el colapso.

### Tu Misión

Escapa antes de que el "ruido" de tus hermanos ahogue tu propia mente. Navega en la oscuridad usando ecolocalización. Sobrevive oleadas infinitas. No te conviertas en lo que cazas.

---

## 🚀 Instalación

### Requisitos

- Flutter 3.10 o superior
- Dart 3.0 o superior
- Android Studio / Xcode (para compilación móvil)

### Clonar el Repositorio

```bash
git clone https://github.com/Joel0216/Eco-Negro-Purga.git
cd Eco-Negro-Purga
```

### Instalar Dependencias

```bash
flutter pub get
```

### Ejecutar en Desarrollo

```bash
flutter run
```

### Compilar para Producción

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

---

## 🛠️ Desarrollo

### Estructura del Proyecto

```
lib/
├── main.dart              # Punto de entrada
├── game.dart              # Lógica principal del juego
├── player.dart            # Jugador y habilidades
├── enemy.dart             # Enemigos (Minion, Corrupto)
├── core_pickup.dart       # Núcleos de energía
├── wall_component.dart    # Sistema de paredes
├── map_component.dart     # Generación procedural
└── overlays.dart          # UI (HUD, Menús, Intro)
```

### Tecnologías

- **Flutter**: Framework de UI
- **Flame Engine**: Motor de juego 2D
- **Flame Audio**: Sistema de audio (preparado)
- **Dart**: Lenguaje de programación

### Características Técnicas

- Sistema de colisiones con deslizamiento
- Generación procedural de mapas
- IA de enemigos con Steering Behavior
- Raycasting para ecolocalización
- Sistema de rondas infinitas
- Daño gradual con cooldown

---

## 📊 Estadísticas

### Jugador
- Vida: 100 HP
- Energía: 20-100 puntos
- Velocidad: 200 px/s

### Habilidades
- **Ping**: 0 energía, 400 px alcance, 64 rayos
- **Grito**: 20 energía, 50 daño, 250 px alcance

### Mapa
- Dimensiones: 1200x800 píxeles
- Obstáculos: 8-12 por partida
- Zona segura: 150 px de radio

---

## 🎯 Roadmap

### Versión Actual (3.1.2)
- ✅ Sistema de rondas infinitas
- ✅ Generación procedural de mapas
- ✅ Historia completa integrada
- ✅ Controles optimizados
- ✅ Daño gradual

### Futuras Mejoras
- [ ] Efectos de sonido
- [ ] Música ambiental
- [ ] Más tipos de enemigos
- [ ] Power-ups especiales
- [ ] Sistema de logros
- [ ] Leaderboard global

---

## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📝 Changelog

### v3.1.2 (Actual)
- Corregidos controles invertidos
- Eliminado daño instantáneo
- Sistema de daño gradual funcional

### v3.1.1
- Agregada pantalla de introducción con lore
- Juego pausado durante la intro
- HUD aparece correctamente al iniciar

### v3.0.0
- Sistema de rondas infinitas
- Sujeto Corrupto cada 5 rondas
- Curación entre rondas
- Energía persistente

### v2.2.0
- Sistema de cámara que sigue al jugador
- Balance de energía mejorado
- Alpha con 300 HP

### v2.1.0
- Sistema de colisiones mejorado
- Generación procedural de mapas
- Spawn inteligente de enemigos

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

---

## 👥 Autor

**Joel** - [GitHub](https://github.com/Joel0216)

---

## 🙏 Agradecimientos

- Flame Engine Community
- Flutter Team
- Todos los testers y jugadores

---

<div align="center">

**¿Te gusta el proyecto? Dale una ⭐ en GitHub!**

[Reportar Bug](https://github.com/Joel0216/Eco-Negro-Purga/issues) • [Solicitar Feature](https://github.com/Joel0216/Eco-Negro-Purga/issues)

</div>
