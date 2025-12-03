# Changelog - Eco Negro: Proyecto Casandra

## [2.0.0] - Sistema de Ecolocalización Avanzado

### 🎯 Nuevas Mecánicas Principales

#### Sistema de Ping Mejorado
- **Ping sin costo de energía**: Ahora es completamente gratuito y se puede usar ilimitadamente
- **Raycasting real**: 64 rayos que detectan paredes físicas
- **Memoria visual**: Las paredes reveladas permanecen visibles durante 4 segundos
- **Desvanecimiento gradual**: Transición suave de opacidad para efecto atmosférico
- **Mapa negro por defecto**: El jugador debe usar el Ping para navegar

#### Cono de Apuntado Visual
- Indicador rojo semitransparente siempre visible
- Muestra la dirección y área de efecto del Grito
- Se orienta automáticamente con el joystick
- Apertura de 45 grados, alcance de 150 píxeles

#### Sistema de Paredes (WallComponent)
- Componentes físicos con colisión real
- Propiedad de opacidad dinámica (0.0 a 1.0)
- Timer de visibilidad de 4 segundos
- Desvanecimiento a velocidad de 0.3 por segundo
- Renderizado condicional (solo si opacity > 0)

#### Generación de Mapa (MapComponent)
- Paredes exteriores (bordes de la arena)
- Obstáculos internos (laberinto simple)
- Sistema de raycasting para detección de intersecciones
- Validación de posiciones para evitar spawns en paredes
- Método de ajuste de posición para navegación suave

### 🤖 IA Mejorada

#### Steering Behavior (Seek)
- Cálculo de vector hacia el objetivo
- Velocidad deseada normalizada
- Detección de colisiones con paredes
- Ajuste automático de posición
- Prevención de atascamiento en esquinas

#### Spawning Inteligente
- Verificación de colisiones antes de spawn
- Máximo 50 intentos para encontrar posición válida
- Distancia mínima del jugador (200 píxeles)
- No spawn dentro de paredes

### 🎮 Cambios en Gameplay

#### Sistema de Energía Simplificado
- **Antes**: Echo costaba 10 energía
- **Ahora**: Ping es completamente gratis
- Solo el Grito consume energía (20 puntos)
- Fomenta la exploración activa

#### Controles Actualizados
- Botón "Echo" renombrado a "Ping"
- Indicador "Gratis" en el botón de Ping
- Indicador "20" en el botón de Grito
- Subtítulos informativos en botones de acción

### 🏗️ Arquitectura

#### Nuevos Archivos
- `lib/wall_component.dart`: Componente de pared con sistema de revelado
- `lib/map_component.dart`: Generador de mapa y sistema de raycasting

#### Cambios en Archivos Existentes
- `lib/player.dart`: 
  - Eliminado sistema de rayos pasivos
  - Agregado cono de apuntado visual
  - Método `performPing()` reemplaza `performEcho()`
  - Colisión con paredes usando MapComponent
  
- `lib/enemy.dart`:
  - IA de persecución mejorada
  - Integración con sistema de colisiones de paredes
  
- `lib/game.dart`:
  - Integración de MapComponent
  - Método `usePing()` reemplaza `useEcho()`
  - Spawning con validación de paredes
  
- `lib/overlays.dart`:
  - Botón de acción con subtítulo opcional
  - Actualización de labels y costos

### 🎨 Mejoras Visuales

- Cono de apuntado rojo con transparencia
- Ondas de ping más visibles (strokeWidth: 3)
- Paredes con borde blanco para mejor visibilidad
- Desvanecimiento suave y natural
- Efecto de memoria visual realista

### 📊 Métricas de Rendimiento

- Raycasting optimizado (64 rayos por ping)
- Renderizado condicional de paredes (solo si visibles)
- Sistema de colisiones eficiente
- Sin impacto en framerate en dispositivos modernos

### 🐛 Correcciones

- Enemigos ya no se atascan en paredes
- Jugador no puede atravesar obstáculos
- Spawn de enemigos siempre en posiciones válidas
- Eliminados rayos pasivos que causaban lag visual

### 📝 Documentación Actualizada

- README.md con nuevas mecánicas
- QUICK_START.md con consejos de Ping
- TECHNICAL_NOTES.md con detalles de implementación
- Nuevo CHANGELOG.md (este archivo)

---

## [1.0.0] - Versión Inicial

### Características Iniciales
- Sistema básico de ecolocalización con rayos pasivos
- Joystick virtual para movimiento
- Dos habilidades: Grito y Echo
- Sistema de energía con recarga
- Enemigos: Minions y Alpha
- HUD con barras de vida y energía
- Menú de pausa y pantalla de victoria
- Arena rectangular con límites

---

**Nota**: Este changelog sigue el formato [Keep a Changelog](https://keepachangelog.com/)
