import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const SnakeApp());
}

class SnakeApp extends StatelessWidget {
  const SnakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yılan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SnakeGamePage(),
    );
  }
}

class SnakeGamePage extends StatefulWidget {
  const SnakeGamePage({super.key});

  @override
  State<SnakeGamePage> createState() => _SnakeGamePageState();
}

enum MoveDirection { up, down, left, right }

class _SnakeGamePageState extends State<SnakeGamePage> {
  static const int numRows = 20;
  static const int numCols = 20;
  static const Duration tick = Duration(milliseconds: 140);

  final Random _random = Random();

  late Timer _timer;
  List<Point<int>> snake = <Point<int>>[];
  Point<int> food = const Point<int>(10, 10);
  MoveDirection currentDirection = MoveDirection.right;
  bool isPlaying = false;
  int score = 0;
  bool _twoHanded = false;

  // Themes
  int _currentThemeIndex = 0;
  late final List<_GameTheme> _themes = <_GameTheme>[
    const _GameTheme(
      key: 'space',
      label: 'Uzay',
      backgroundUrl: 'https://images.unsplash.com/photo-1444703686981-a3abbc4d4fe3?w=1600',
      snakeHead: Color(0xFF00E5FF),
      snakeBody: Color(0xFF26C6DA),
      gridColor: Color(0x33B2EBF2),
      foodUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=256',
    ),
    const _GameTheme(
      key: 'hell',
      label: 'Cehennem',
      backgroundUrl: 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=1600',
      snakeHead: Color(0xFFFF6D00),
      snakeBody: Color(0xFFFF8F00),
      gridColor: Color(0x33FFAB40),
      foodUrl: 'https://images.unsplash.com/photo-1604909053282-3cdfb0b96517?w=256',
    ),
    const _GameTheme(
      key: 'zombie',
      label: 'Zombi',
      backgroundUrl: 'https://images.unsplash.com/photo-1605559424843-9c95327c71d4?w=1600',
      snakeHead: Color(0xFF43A047),
      snakeBody: Color(0xFF66BB6A),
      gridColor: Color(0x334CAF50),
      foodUrl: 'https://images.unsplash.com/photo-1559750988-c5ea45c5b5c8?w=256',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  void _start() {
    if (isPlaying) return;
    isPlaying = true;
    _timer = Timer.periodic(tick, (_) => _step());
    setState(() {});
  }

  void _stop() {
    if (isPlaying) {
      _timer.cancel();
      isPlaying = false;
    }
  }

  void _resetGame() {
    _stop();
    score = 0;
    currentDirection = MoveDirection.right;
    snake = <Point<int>>[
      const Point<int>(5, 10),
      const Point<int>(4, 10),
      const Point<int>(3, 10),
    ];
    food = _spawnFood();
    setState(() {});
  }

  void _ensureStarted() {
    if (!isPlaying) {
      _start();
    }
  }

  Point<int> _spawnFood() {
    while (true) {
      final int x = _random.nextInt(numCols);
      final int y = _random.nextInt(numRows);
      final Point<int> candidate = Point<int>(x, y);
      if (!snake.contains(candidate)) return candidate;
    }
  }

  void _changeDirection(MoveDirection next) {
    final bool isOpposite =
        (currentDirection == MoveDirection.up && next == MoveDirection.down) ||
        (currentDirection == MoveDirection.down && next == MoveDirection.up) ||
        (currentDirection == MoveDirection.left && next == MoveDirection.right) ||
        (currentDirection == MoveDirection.right && next == MoveDirection.left);
    if (isOpposite) return;
    currentDirection = next;
    _ensureStarted();
  }

  void _step() {
    final Point<int> head = snake.first;
    Point<int> nextHead;
    switch (currentDirection) {
      case MoveDirection.up:
        nextHead = Point<int>(head.x, head.y - 1);
        break;
      case MoveDirection.down:
        nextHead = Point<int>(head.x, head.y + 1);
        break;
      case MoveDirection.left:
        nextHead = Point<int>(head.x - 1, head.y);
        break;
      case MoveDirection.right:
        nextHead = Point<int>(head.x + 1, head.y);
        break;
    }

    // Wrap-around: move through walls and appear on the opposite side
    int wrappedX = nextHead.x;
    int wrappedY = nextHead.y;
    if (wrappedX < 0) wrappedX = numCols - 1;
    if (wrappedX >= numCols) wrappedX = 0;
    if (wrappedY < 0) wrappedY = numRows - 1;
    if (wrappedY >= numRows) wrappedY = 0;
    nextHead = Point<int>(wrappedX, wrappedY);

    final bool hitSelf = snake.contains(nextHead);
    if (hitSelf) {
      _stop();
      _showGameOver();
      return;
    }

    final bool ateFood = nextHead == food;
    setState(() {
      snake = <Point<int>>[nextHead, ...snake];
      if (ateFood) {
        score += 10;
        food = _spawnFood();
      } else {
        snake.removeLast();
      }
    });
  }

  void _handleSwipe(DragUpdateDetails details) {
    if (details.delta.dx.abs() > details.delta.dy.abs()) {
      if (details.delta.dx > 0) {
        _changeDirection(MoveDirection.right);
      } else {
        _changeDirection(MoveDirection.left);
      }
    } else {
      if (details.delta.dy > 0) {
        _changeDirection(MoveDirection.down);
      } else {
        _changeDirection(MoveDirection.up);
      }
    }
  }

  Future<void> _showGameOver() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Oyun Bitti'),
          content: Text('Skor: $score'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: const Text('Yeniden Başlat'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _GameTheme theme = _themes[_currentThemeIndex];
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double gridSize = min(constraints.maxWidth, constraints.maxHeight - 120);
          final double cellSize = gridSize / numCols;

          return Stack(
            children: <Widget>[
              // Background
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(theme.backgroundUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Colors.black.withOpacity(0.25),
                          Colors.black.withOpacity(0.15),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: <Widget>[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: <Widget>[
                              const Icon(Icons.star, color: Colors.amber),
                              const SizedBox(width: 8),
                              const Text('Skor: ', style: TextStyle(fontSize: 18, color: Colors.white)),
                              Text('$score', style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Dual-joystick toggle
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.35),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => setState(() => _twoHanded = !_twoHanded),
                            icon: Icon(_twoHanded ? Icons.pan_tool_alt : Icons.pan_tool_outlined),
                            label: Text(_twoHanded ? 'Çift El: Açık' : 'Çift El: Kapalı'),
                          ),
                        ),
                        _ThemeSelectors(
                          themes: _themes,
                          selectedIndex: _currentThemeIndex,
                          onSelected: (int i) => setState(() => _currentThemeIndex = i),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      onPanUpdate: _handleSwipe,
                      child: Container(
                        width: gridSize,
                        height: gridSize,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.08),
                          border: Border.all(color: Colors.white24),
                          boxShadow: <BoxShadow>[
                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12),
                          ],
                        ),
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              left: food.x * cellSize,
                              top: food.y * cellSize,
                              child: _FoodWidget(size: cellSize * 0.9, theme: theme),
                            ),
                            ...snake.map((Point<int> p) {
                              final bool isHead = p == snake.first;
                              return Positioned(
                                left: p.x * cellSize,
                                top: p.y * cellSize,
                                child: _buildCell(
                                  cellSize,
                                  isHead ? theme.snakeHead : theme.snakeBody,
                                  rounded: isHead,
                                ),
                              );
                            }),
                            CustomPaint(
                              size: Size(gridSize, gridSize),
                              painter: _GridPainter(numRows: numRows, numCols: numCols, color: theme.gridColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    // Left joystick (only in two-handed mode)
                    if (_twoHanded)
                      _Joystick(
                        size: min(200, constraints.maxWidth * 0.35),
                        onDirectionChanged: (MoveDirection? dir) {
                          if (dir != null) _changeDirection(dir);
                        },
                        onTouchStart: (MoveDirection? initial) {
                          _ensureStarted();
                          if (initial != null) _changeDirection(initial);
                          _step();
                        },
                      )
                    else
                      const SizedBox(width: 1),
                    // Stop button in the middle
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.45),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _stop,
                      icon: const Icon(Icons.stop_circle_outlined),
                      label: const Text('Stop'),
                    ),
                    // Right joystick (always visible)
                    _Joystick(
                      size: min(200, constraints.maxWidth * 0.35),
                      onDirectionChanged: (MoveDirection? dir) {
                        if (dir != null) _changeDirection(dir);
                      },
                      onTouchStart: (MoveDirection? initial) {
                        _ensureStarted();
                        if (initial != null) _changeDirection(initial);
                        _step();
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCell(double size, Color color, {bool rounded = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: rounded ? BorderRadius.circular(size * 0.2) : null,
      ),
    );
  }

  Widget _controlButton(IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(minimumSize: const Size(48, 48)),
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
}

class _Joystick extends StatefulWidget {
  const _Joystick({required this.size, required this.onDirectionChanged, this.onTouchStart});

  final double size;
  final void Function(MoveDirection? direction) onDirectionChanged;
  final void Function(MoveDirection? initialDirection)? onTouchStart;

  @override
  State<_Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<_Joystick> {
  late double _radius;
  Offset _knob = Offset.zero; // relative to center

  @override
  void initState() {
    super.initState();
    _radius = widget.size / 2.2; // some padding inside base
  }

  void _updateKnob(Offset localPosition) {
    final Offset center = Offset(widget.size / 2, widget.size / 2);
    Offset delta = localPosition - center;
    if (delta.distance > _radius) {
      delta = Offset.fromDirection(delta.direction, _radius);
    }
    setState(() => _knob = delta);

    // Deadzone to avoid jitter
    if (delta.distance < _radius * 0.25) {
      widget.onDirectionChanged(null);
      return;
    }

    final double dx = delta.dx;
    final double dy = delta.dy;
    // Determine dominant axis for cardinal direction
    if (dx.abs() > dy.abs()) {
      widget.onDirectionChanged(dx > 0 ? MoveDirection.right : MoveDirection.left);
    } else {
      widget.onDirectionChanged(dy > 0 ? MoveDirection.down : MoveDirection.up);
    }
  }

  void _resetKnob() {
    setState(() => _knob = Offset.zero);
    widget.onDirectionChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final double baseSize = widget.size;
    final double knobSize = baseSize * 0.35;

    return IgnorePointer(
      ignoring: false,
      child: Opacity(
        opacity: 0.9,
        child: Container(
          width: baseSize,
          height: baseSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.25),
            boxShadow: <BoxShadow>[
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 18, spreadRadius: 2),
            ],
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (DragStartDetails d) {
              _updateKnob(d.localPosition);
              final MoveDirection? initial = _directionFromOffset(_knob);
              if (widget.onTouchStart != null) widget.onTouchStart!(initial);
            },
            onPanUpdate: (DragUpdateDetails d) => _updateKnob(d.localPosition),
            onPanEnd: (_) => _resetKnob(),
            onPanCancel: _resetKnob,
            child: Stack(
              children: <Widget>[
                // Direction hints
                Align(
                  alignment: Alignment.topCenter,
                  child: Icon(Icons.keyboard_arrow_up, color: Colors.white54, size: baseSize * 0.22),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: baseSize * 0.22),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(Icons.keyboard_arrow_left, color: Colors.white54, size: baseSize * 0.22),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.keyboard_arrow_right, color: Colors.white54, size: baseSize * 0.22),
                ),
                // Knob
                Positioned(
                  left: (baseSize - knobSize) / 2 + _knob.dx,
                  top: (baseSize - knobSize) / 2 + _knob.dy,
                  child: Container(
                    width: knobSize,
                    height: knobSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: <Color>[Colors.white.withOpacity(0.95), Colors.grey.shade300],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 6)),
                      ],
                      border: Border.all(color: Colors.white70, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  MoveDirection? _directionFromOffset(Offset delta) {
    if (delta.distance < _radius * 0.25) return null;
    if (delta.dx.abs() > delta.dy.abs()) {
      return delta.dx > 0 ? MoveDirection.right : MoveDirection.left;
    } else {
      return delta.dy > 0 ? MoveDirection.down : MoveDirection.up;
    }
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.numRows, required this.numCols, this.color = const Color(0x11000000)});

  final int numRows;
  final int numCols;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    final double cellWidth = size.width / numCols;
    final double cellHeight = size.height / numRows;

    for (int c = 1; c < numCols; c++) {
      final double x = c * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (int r = 1; r < numRows; r++) {
      final double y = r * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.numRows != numRows || oldDelegate.numCols != numCols || oldDelegate.color != color;
  }
}

class _GameTheme {
  const _GameTheme({
    required this.key,
    required this.label,
    required this.backgroundUrl,
    required this.snakeHead,
    required this.snakeBody,
    required this.gridColor,
    required this.foodUrl,
  });

  final String key;
  final String label;
  final String backgroundUrl;
  final Color snakeHead;
  final Color snakeBody;
  final Color gridColor;
  final String foodUrl;
}

class _FoodWidget extends StatefulWidget {
  const _FoodWidget({required this.size, required this.theme});

  final double size;
  final _GameTheme theme;

  @override
  State<_FoodWidget> createState() => _FoodWidgetState();
}

class _FoodWidgetState extends State<_FoodWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _spin;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _spin = Tween<double>(begin: 0, end: 2 * pi).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    _pulse = Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size;
    final String imageUrl = widget.theme.foodUrl;
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return Transform.rotate(
            angle: _spin.value,
            child: Transform.scale(
              scale: _pulse.value,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4)),
                    BoxShadow(color: Colors.white.withOpacity(0.08), blurRadius: 20, spreadRadius: -8),
                  ],
                  gradient: RadialGradient(
                    colors: <Color>[
                      Colors.white.withOpacity(0.95),
                      Colors.white.withOpacity(0.75),
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(size * 0.08),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(size),
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (BuildContext _, Object __, StackTrace? ___) {
                          return Container(color: Colors.redAccent);
                        }),
                        // Subtle highlight to simulate gloss
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            width: size * 0.35,
                            height: size * 0.35,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: <Color>[
                                  Colors.white.withOpacity(0.45),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ThemeSelectors extends StatelessWidget {
  const _ThemeSelectors({
    required this.themes,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_GameTheme> themes;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < themes.length; i++)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: InkWell(
              onTap: () => onSelected(i),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: i == selectedIndex ? Colors.white : Colors.white54,
                    width: i == selectedIndex ? 3 : 1.5,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 8),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Image.network(themes[i].backgroundUrl, fit: BoxFit.cover),
                    Container(color: Colors.black26),
                    Center(
                      child: Text(
                        themes[i].label.substring(0, 1),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
