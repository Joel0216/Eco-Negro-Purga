import 'package:flutter/material.dart';
import 'game.dart';

class HUDOverlay extends StatelessWidget {
  final EcoNegroGame game;

  const HUDOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Barras de vida y energía (esquina superior izquierda)
        Positioned(
          top: 20,
          left: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(180),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withAlpha(100), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra de vida
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 150,
                      child: StreamBuilder<double>(
                        stream: Stream.periodic(
                          const Duration(milliseconds: 100),
                          (_) => game.playerHealth,
                        ),
                        builder: (context, snapshot) {
                          final health = snapshot.data ?? game.playerHealth;
                          return _buildBar(
                            health / game.maxHealth,
                            Colors.red,
                            '${health.toInt()}/${game.maxHealth.toInt()}',
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Barra de energía
                Row(
                  children: [
                    const Icon(Icons.bolt, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 150,
                      child: StreamBuilder<double>(
                        stream: Stream.periodic(
                          const Duration(milliseconds: 100),
                          (_) => game.playerEnergy,
                        ),
                        builder: (context, snapshot) {
                          final energy = snapshot.data ?? game.playerEnergy;
                          return _buildBar(
                            energy / game.maxEnergy,
                            Colors.blue,
                            '${energy.toInt()}/${game.maxEnergy.toInt()}',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Botón de pausa (esquina superior derecha)
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(180),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(100), width: 2),
            ),
            child: IconButton(
              icon: const Icon(Icons.pause, color: Colors.white, size: 28),
              onPressed: () => game.togglePause(),
            ),
          ),
        ),
        
        // Botones de acción (abajo derecha)
        Positioned(
          bottom: 40,
          right: 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón de Ping (SIN COSTO)
              _ActionButton(
                icon: Icons.radar,
                color: Colors.cyan,
                label: 'Ping',
                subtitle: 'Gratis',
                onPressed: () => game.usePing(),
              ),
              const SizedBox(height: 20),
              // Botón de Grito
              _ActionButton(
                icon: Icons.campaign,
                color: Colors.red,
                label: 'Grito',
                subtitle: '20',
                onPressed: () => game.useScream(),
              ),
            ],
          ),
        ),
        
        // Indicador de ronda (centro superior)
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: StreamBuilder<int>(
              stream: Stream.periodic(
                const Duration(milliseconds: 500),
                (_) => game.currentRound,
              ),
              builder: (context, snapshot) {
                final round = snapshot.data ?? game.currentRound;
                final killed = game.minionsKilledThisRound;
                final total = game.minionsToSpawnThisRound;
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(180),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.cyan, width: 2),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'RONDA $round',
                            style: const TextStyle(
                              color: Colors.cyan,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Minions: $killed / $total',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Barra de vida del Sujeto Corrupto (si existe)
                    if (game.failedSubjectSpawned && game.currentFailedSubject != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: StreamBuilder<double>(
                          stream: Stream.periodic(
                            const Duration(milliseconds: 100),
                            (_) => game.currentFailedSubject?.health ?? 0,
                          ),
                          builder: (context, snapshot) {
                            final failedSubject = game.currentFailedSubject;
                            if (failedSubject == null || !failedSubject.isMounted) {
                              return const SizedBox.shrink();
                            }
                            final health = failedSubject.health;
                            final maxHealth = failedSubject.maxHealth;
                            return Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(180),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red, width: 2),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'SUJETO CORRUPTO',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    width: 200,
                                    child: _buildBar(
                                      health / maxHealth,
                                      Colors.red,
                                      '${health.toInt()}/${maxHealth.toInt()}',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBar(double percent, Color color, String text) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: percent.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
          Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String? subtitle;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.label,
    this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color.withAlpha(77),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          child: IconButton(
            icon: Icon(icon, color: color, size: 32),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: TextStyle(
              color: color.withAlpha(180),
              fontSize: 10,
            ),
          ),
      ],
    );
  }
}

class PauseMenu extends StatelessWidget {
  final EcoNegroGame game;

  const PauseMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(204),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.cyan, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAUSA',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              _MenuButton(
                text: 'Reanudar',
                icon: Icons.play_arrow,
                color: Colors.green,
                onPressed: () => game.togglePause(),
              ),
              const SizedBox(height: 20),
              _MenuButton(
                text: 'Reintentar',
                icon: Icons.refresh,
                color: Colors.orange,
                onPressed: () {
                  game.overlays.remove('Pause');
                  game.restartGame();
                  game.resumeEngine();
                },
              ),
              const SizedBox(height: 20),
              _MenuButton(
                text: 'Salir',
                icon: Icons.exit_to_app,
                color: Colors.red,
                onPressed: () {
                  game.overlays.remove('Pause');
                  game.overlays.add('MainMenu');
                  game.pauseEngine();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VictoryScreen extends StatelessWidget {
  final EcoNegroGame game;

  const VictoryScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(230),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.purple, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events,
                color: Colors.yellow,
                size: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                '¡ÁREA SILENCIADA!',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Has derrotado al Alpha',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 40),
              _MenuButton(
                text: 'Siguiente Nivel',
                icon: Icons.arrow_forward,
                color: Colors.green,
                onPressed: () {
                  game.overlays.remove('Victory');
                  game.restartGame();
                },
              ),
              const SizedBox(height: 20),
              _MenuButton(
                text: 'Reintentar',
                icon: Icons.refresh,
                color: Colors.orange,
                onPressed: () {
                  game.overlays.remove('Victory');
                  game.restartGame();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      label: Text(
        text,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}


class GameOverScreen extends StatelessWidget {
  final EcoNegroGame game;

  const GameOverScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(230),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.dangerous,
                color: Colors.red,
                size: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Llegaste a la Ronda ${game.currentRound}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              _MenuButton(
                text: 'Reintentar',
                icon: Icons.refresh,
                color: Colors.orange,
                onPressed: () {
                  game.overlays.remove('GameOver');
                  game.restartGame();
                  game.resumeEngine();
                },
              ),
              const SizedBox(height: 20),
              _MenuButton(
                text: 'Salir',
                icon: Icons.exit_to_app,
                color: Colors.red,
                onPressed: () {
                  game.overlays.remove('GameOver');
                  game.restartGame();
                  game.resumeEngine();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class IntroScreen extends StatefulWidget {
  final EcoNegroGame game;

  const IntroScreen({super.key, required this.game});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _lorePages = [
    {
      'title': 'EL PROYECTO CASANDRA',
      'text':
          'En el apogeo de una guerra fría no declarada, las agencias de inteligencia buscaban la ventaja definitiva: la infiltración indetectable.\n\nEl Proyecto Casandra nació con un objetivo: convertir la percepción en un arma.',
    },
    {
      'title': 'LA METODOLOGÍA',
      'text':
          'Dirigido por la organización "Aethel", el proyecto reclutó sujetos con sinestesia auditiva.\n\nPrimero, inducían ceguera total. Luego, mediante tratamientos químicos e implantes neurales, intentaban crear al "Infiltrado Sónico".',
    },
    {
      'title': 'EL FRACASO: LAS RESONANCIAS',
      'text':
          'El proyecto fue un fracaso catastrófico. Los sujetos se convirtieron en "Las Resonancias".\n\nAtrapados en agonía constante, con poder incontrolado, cazan cualquier sonido para silenciar su tormento.',
    },
    {
      'title': 'SUJETO 7: EL ÉXITO',
      'text':
          'Tú eres el Sujeto 7. El único éxito.\n\nTu ceguera es total, pero tu mente procesa los ecos con claridad perfecta. Puedes canalizar el "Grito de Ruptura".\n\nEras el activo más valioso... hasta el colapso.',
    },
    {
      'title': 'EL INCIDENTE',
      'text':
          'Una Resonancia Alfa perdió el control. Las instalaciones colapsaron. El personal fue masacrado.\n\nDespertas en tu celda rota, en medio del caos. Ciego, solo y vulnerable.\n\nTu única arma: el Grito de Ruptura.',
    },
    {
      'title': 'CANIBALISMO ENERGÉTICO',
      'text':
          'Tu poder consume energía biológica. Para sobrevivir, debes absorber los "Núcleos Resonantes" de tus hermanos caídos.\n\nCada núcleo te recarga... pero también absorbes fragmentos de su conciencia rota.',
    },
    {
      'title': 'TU MISIÓN',
      'text':
          'Escapa antes de que el "ruido" de tus hermanos ahogue tu propia mente.\n\nNavega en la oscuridad usando ecolocalización.\nSobrevive oleadas infinitas.\nNo te conviertas en lo que cazas.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _lorePages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _lorePages[index]['title']!,
                          style: const TextStyle(
                            color: Colors.cyan,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          _lorePages[index]['text']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Indicadores de página
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _lorePages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.cyan
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            // Botones
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text(
                        'Anterior',
                        style: TextStyle(color: Colors.cyan, fontSize: 16),
                      ),
                    )
                  else
                    const SizedBox(width: 80),
                  ElevatedButton(
                    onPressed: () {
                      widget.game.overlays.remove('Intro');
                      widget.game.overlays.add('HUD');
                      widget.game.resumeEngine();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Saltar',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  if (_currentPage < _lorePages.length - 1)
                    TextButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text(
                        'Siguiente',
                        style: TextStyle(color: Colors.cyan, fontSize: 16),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        widget.game.overlays.remove('Intro');
                        widget.game.overlays.add('HUD');
                        widget.game.resumeEngine();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      child: const Text(
                        'Comenzar',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class MainMenuScreen extends StatelessWidget {
  final EcoNegroGame game;

  const MainMenuScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ECO NEGRO',
              style: TextStyle(
                color: Colors.cyan,
                fontSize: 64,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'PROYECTO CASANDRA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 80),
            _MenuButton(
              text: 'Jugar',
              icon: Icons.play_arrow,
              color: Colors.green,
              onPressed: () {
                game.overlays.remove('MainMenu');
                game.overlays.add('Intro');
              },
            ),
            const SizedBox(height: 20),
            _MenuButton(
              text: 'Salir',
              icon: Icons.exit_to_app,
              color: Colors.red,
              onPressed: () {
                // Cerrar la aplicación
              },
            ),
          ],
        ),
      ),
    );
  }
}
