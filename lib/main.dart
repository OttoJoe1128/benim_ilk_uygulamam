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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yılan Oyunu'),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double gridSize = min(constraints.maxWidth, constraints.maxHeight - 120);
          final double cellSize = gridSize / numCols;

          return Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Icon(Icons.star, color: Colors.amber),
                            const SizedBox(width: 8),
                            Text('Skor: $score', style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: isPlaying ? _stop : _start,
                          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                          label: Text(isPlaying ? 'Duraklat' : 'Başlat'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _resetGame,
                          icon: const Icon(Icons.restart_alt),
                          label: const Text('Sıfırla'),
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
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              left: food.x * cellSize,
                              top: food.y * cellSize,
                              child: _buildCell(cellSize, Colors.redAccent, rounded: true),
                            ),
                            ...snake.map((Point<int> p) {
                              final bool isHead = p == snake.first;
                              return Positioned(
                                left: p.x * cellSize,
                                top: p.y * cellSize,
                                child: _buildCell(
                                  cellSize,
                                  isHead ? Colors.green.shade700 : Colors.green,
                                  rounded: isHead,
                                ),
                              );
                            }),
                            CustomPaint(
                              size: Size(gridSize, gridSize),
                              painter: _GridPainter(numRows: numRows, numCols: numCols),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: Center(
                  child: _Joystick(
                    size: min(220, constraints.maxWidth * 0.6),
                    onDirectionChanged: (MoveDirection? dir) {
                      if (dir != null) _changeDirection(dir);
                    },
                  ),
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
  const _Joystick({required this.size, required this.onDirectionChanged});

  final double size;
  final void Function(MoveDirection? direction) onDirectionChanged;

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
            onPanStart: (DragStartDetails d) => _updateKnob(d.localPosition),
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
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.numRows, required this.numCols});

  final int numRows;
  final int numCols;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black12
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
    return oldDelegate.numRows != numRows || oldDelegate.numCols != numCols;
  }
}
