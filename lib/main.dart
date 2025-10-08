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

    final bool hitWall =
        nextHead.x < 0 || nextHead.x >= numCols || nextHead.y < 0 || nextHead.y >= numRows;
    final bool hitSelf = snake.contains(nextHead);
    if (hitWall || hitSelf) {
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

          return Column(
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
                        // Food
                        Positioned(
                          left: food.x * cellSize,
                          top: food.y * cellSize,
                          child: _buildCell(cellSize, Colors.redAccent, rounded: true),
                        ),
                        // Snake
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
                        // Grid overlay (optional subtle lines)
                        CustomPaint(
                          size: Size(gridSize, gridSize),
                          painter: _GridPainter(numRows: numRows, numCols: numCols),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _controlButton(Icons.keyboard_arrow_up, () => _changeDirection(MoveDirection.up)),
                  _controlButton(Icons.keyboard_arrow_down, () => _changeDirection(MoveDirection.down)),
                  _controlButton(Icons.keyboard_arrow_left, () => _changeDirection(MoveDirection.left)),
                  _controlButton(Icons.keyboard_arrow_right, () => _changeDirection(MoveDirection.right)),
                ],
              ),
              const SizedBox(height: 12),
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
