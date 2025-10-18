/// Éditeur visuel de motifs personnalisés
library;

import 'dart:math';
import 'package:flutter/material.dart';

enum PatternType {
  dots,
  lines,
  grid,
  diagonal,
  waves,
  circles,
  triangles,
  hexagons,
  stars,
  hearts,
  geometric,
  abstract,
  custom,
}

class PatternEditor extends StatefulWidget {
  const PatternEditor({
    super.key,
    required this.onPatternChanged,
    this.initialPattern,
    this.initialColor = Colors.blue,
    this.initialSize = 20.0,
    this.initialSpacing = 10.0,
    this.initialOpacity = 0.3,
  });

  final Function(PatternData) onPatternChanged;
  final PatternData? initialPattern;
  final Color initialColor;
  final double initialSize;
  final double initialSpacing;
  final double initialOpacity;

  @override
  State<PatternEditor> createState() => _PatternEditorState();
}

class _PatternEditorState extends State<PatternEditor>
    with TickerProviderStateMixin {
  late PatternType _selectedType;
  late Color _patternColor;
  late double _patternSize;
  late double _patternSpacing;
  late double _patternOpacity;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final _customPoints = <Offset>[];
  bool _isDrawing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _initializeFromInitialPattern();
    _animationController.repeat(reverse: true);
  }

  void _initializeFromInitialPattern() {
    if (widget.initialPattern != null) {
      _selectedType = widget.initialPattern!.type;
      _patternColor = widget.initialPattern!.color;
      _patternSize = widget.initialPattern!.size;
      _patternSpacing = widget.initialPattern!.spacing;
      _patternOpacity = widget.initialPattern!.opacity;
      if (widget.initialPattern!.customPoints != null) {
        _customPoints.addAll(widget.initialPattern!.customPoints!);
      }
    } else {
      _selectedType = PatternType.dots;
      _patternColor = widget.initialColor;
      _patternSize = widget.initialSize;
      _patternSpacing = widget.initialSpacing;
      _patternOpacity = widget.initialOpacity;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      // Aperçu du motif
      _buildPatternPreview(),
      const SizedBox(height: 20),

      // Contrôles
      Expanded(child: _buildControls()),
    ],
  );

  Widget _buildPatternPreview() => Container(
    height: 150,
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CustomPaint(
        painter: PatternPainter(
          pattern: PatternData(
            type: _selectedType,
            color: _patternColor,
            size: _patternSize,
            spacing: _patternSpacing,
            opacity: _patternOpacity,
            customPoints: _customPoints.isEmpty ? null : _customPoints,
          ),
          animation: _animation.value,
        ),
        child: _selectedType == PatternType.custom
            ? GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    _isDrawing = true;
                    _customPoints.add(details.localPosition);
                  });
                },
                onPanUpdate: (details) {
                  if (_isDrawing) {
                    setState(() {
                      _customPoints.add(details.localPosition);
                    });
                  }
                },
                onPanEnd: (details) {
                  setState(() {
                    _isDrawing = false;
                  });
                  _notifyPatternChanged();
                },
                child: ColoredBox(
                  color: Colors.transparent,
                  child: _isDrawing
                      ? const Center(
                          child: Text(
                            'Dessinez votre motif...',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : const Center(
                          child: Text(
                            'Touchez pour dessiner',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                ),
              )
            : null,
      ),
    ),
  );

  Widget _buildControls() => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sélection du type de motif
        _buildTypeSelector(),
        const SizedBox(height: 20),

        // Couleur du motif
        _buildColorPicker(),
        const SizedBox(height: 20),

        // Taille du motif
        _buildSizeSlider(),
        const SizedBox(height: 20),

        // Espacement
        _buildSpacingSlider(),
        const SizedBox(height: 20),

        // Opacité
        _buildOpacitySlider(),
        const SizedBox(height: 20),

        // Actions pour motif personnalisé
        if (_selectedType == PatternType.custom) ...[
          _buildCustomPatternActions(),
          const SizedBox(height: 20),
        ],

        // Bouton appliquer
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _notifyPatternChanged();
              Navigator.pop(context);
            },
            child: const Text('Appliquer le motif'),
          ),
        ),
      ],
    ),
  );

  Widget _buildTypeSelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Type de motif',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: PatternType.values.map((type) {
          final isSelected = _selectedType == type;
          return InkWell(
            onTap: () {
              setState(() {
                _selectedType = type;
                if (type != PatternType.custom) {
                  _customPoints.clear();
                }
              });
              _notifyPatternChanged();
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? _patternColor.withValues(alpha: 0.2)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected ? _patternColor : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getIconForType(type), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _getLabelForType(type),
                    style: TextStyle(
                      color: isSelected ? _patternColor : Colors.grey[700],
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );

  Widget _buildColorPicker() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Couleur du motif',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: _patternColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _showColorPicker,
            child: const Text('Choisir'),
          ),
        ],
      ),
    ],
  );

  Widget _buildSizeSlider() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Taille',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text('${_patternSize.round()}px'),
        ],
      ),
      Slider(
        value: _patternSize,
        min: 5.0,
        max: 50.0,
        divisions: 45,
        onChanged: (value) {
          setState(() {
            _patternSize = value;
          });
          _notifyPatternChanged();
        },
      ),
    ],
  );

  Widget _buildSpacingSlider() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Espacement',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text('${_patternSpacing.round()}px'),
        ],
      ),
      Slider(
        value: _patternSpacing,
        min: 5.0,
        max: 50.0,
        divisions: 45,
        onChanged: (value) {
          setState(() {
            _patternSpacing = value;
          });
          _notifyPatternChanged();
        },
      ),
    ],
  );

  Widget _buildOpacitySlider() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Opacité',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text('${(_patternOpacity * 100).round()}%'),
        ],
      ),
      Slider(
        value: _patternOpacity,
        min: 0.1,
        max: 1.0,
        divisions: 18,
        onChanged: (value) {
          setState(() {
            _patternOpacity = value;
          });
          _notifyPatternChanged();
        },
      ),
    ],
  );

  Widget _buildCustomPatternActions() => Row(
    children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () {
            setState(_customPoints.clear);
            _notifyPatternChanged();
          },
          icon: const Icon(Icons.clear),
          label: const Text('Effacer'),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _customPoints.clear();
              // Ajouter des points prédéfinis
              const size = 150.0;
              const center = Offset(size / 2, size / 2);
              const radius = 30.0;

              for (var i = 0; i < 8; i++) {
                final angle = (i * pi * 2) / 8;
                _customPoints.add(
                  Offset(
                    center.dx + cos(angle) * radius,
                    center.dy + sin(angle) * radius,
                  ),
                );
              }
            });
            _notifyPatternChanged();
          },
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Cercle'),
        ),
      ),
    ],
  );

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir une couleur'),
        content: SizedBox(width: 300, height: 300, child: _buildColorGrid()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorGrid() {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final color = colors[index];
        return InkWell(
          onTap: () {
            setState(() {
              _patternColor = color;
            });
            _notifyPatternChanged();
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: color == _patternColor ? Colors.blue : Colors.grey[300]!,
                width: color == _patternColor ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForType(PatternType type) {
    switch (type) {
      case PatternType.dots:
        return Icons.circle_outlined;
      case PatternType.lines:
        return Icons.horizontal_rule;
      case PatternType.grid:
        return Icons.grid_on;
      case PatternType.diagonal:
        return Icons.format_align_right;
      case PatternType.waves:
        return Icons.waves;
      case PatternType.circles:
        return Icons.radio_button_unchecked;
      case PatternType.triangles:
        return Icons.change_history;
      case PatternType.hexagons:
        return Icons.hexagon;
      case PatternType.stars:
        return Icons.star_border;
      case PatternType.hearts:
        return Icons.favorite_border;
      case PatternType.geometric:
        return Icons.category;
      case PatternType.abstract:
        return Icons.grain;
      case PatternType.custom:
        return Icons.edit;
    }
  }

  String _getLabelForType(PatternType type) {
    switch (type) {
      case PatternType.dots:
        return 'Points';
      case PatternType.lines:
        return 'Lignes';
      case PatternType.grid:
        return 'Grille';
      case PatternType.diagonal:
        return 'Diagonal';
      case PatternType.waves:
        return 'Vagues';
      case PatternType.circles:
        return 'Cercles';
      case PatternType.triangles:
        return 'Triangles';
      case PatternType.hexagons:
        return 'Hexagones';
      case PatternType.stars:
        return 'Étoiles';
      case PatternType.hearts:
        return 'Cœurs';
      case PatternType.geometric:
        return 'Géométrique';
      case PatternType.abstract:
        return 'Abstrait';
      case PatternType.custom:
        return 'Personnalisé';
    }
  }

  void _notifyPatternChanged() {
    final patternData = PatternData(
      type: _selectedType,
      color: _patternColor,
      size: _patternSize,
      spacing: _patternSpacing,
      opacity: _patternOpacity,
      customPoints: _customPoints.isEmpty ? null : _customPoints,
    );
    widget.onPatternChanged(patternData);
  }
}

class PatternData {
  const PatternData({
    required this.type,
    required this.color,
    required this.size,
    required this.spacing,
    required this.opacity,
    this.customPoints,
  });

  factory PatternData.fromJson(Map<String, dynamic> json) {
    final customPoints = json['customPoints'] as List?;
    return PatternData(
      type: PatternType.values.firstWhere((e) => e.name == json['type']),
      color: Color(json['color']),
      size: json['size'].toDouble(),
      spacing: json['spacing'].toDouble(),
      opacity: json['opacity'].toDouble(),
      customPoints: customPoints?.map((p) => Offset(p['dx'], p['dy'])).toList(),
    );
  }
  final PatternType type;
  final Color color;
  final double size;
  final double spacing;
  final double opacity;
  final List<Offset>? customPoints;

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'color': color.value,
    'size': size,
    'spacing': spacing,
    'opacity': opacity,
    'customPoints': customPoints?.map((p) => {'dx': p.dx, 'dy': p.dy}).toList(),
  };
}

class PatternPainter extends CustomPainter {
  PatternPainter({required this.pattern, required this.animation});
  final PatternData pattern;
  final double animation;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = pattern.color.withValues(alpha: pattern.opacity)
      ..style = PaintingStyle.fill;

    switch (pattern.type) {
      case PatternType.custom:
        _drawCustomPattern(canvas, size, paint);
        break;
      case PatternType.dots:
        _drawDots(canvas, size, paint);
        break;
      case PatternType.lines:
        _drawLines(canvas, size, paint);
        break;
      case PatternType.grid:
        _drawGrid(canvas, size, paint);
        break;
      case PatternType.diagonal:
        _drawDiagonal(canvas, size, paint);
        break;
      case PatternType.waves:
        _drawWaves(canvas, size, paint);
        break;
      case PatternType.circles:
        _drawCircles(canvas, size, paint);
        break;
      case PatternType.triangles:
        _drawTriangles(canvas, size, paint);
        break;
      case PatternType.hexagons:
        _drawHexagons(canvas, size, paint);
        break;
      case PatternType.stars:
        _drawStars(canvas, size, paint);
        break;
      case PatternType.hearts:
        _drawHearts(canvas, size, paint);
        break;
      case PatternType.geometric:
        _drawGeometric(canvas, size, paint);
        break;
      case PatternType.abstract:
        _drawAbstract(canvas, size, paint);
        break;
    }
  }

  void _drawCustomPattern(Canvas canvas, Size size, Paint paint) {
    if (pattern.customPoints == null) return;

    for (final point in pattern.customPoints!) {
      canvas.drawCircle(point, pattern.size / 2, paint);
    }
  }

  void _drawDots(Canvas canvas, Size size, Paint paint) {
    final spacing = pattern.size + pattern.spacing;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final animatedSize = pattern.size * (0.8 + 0.2 * animation);
        canvas.drawCircle(Offset(x, y), animatedSize / 2, paint);
      }
    }
  }

  void _drawLines(Canvas canvas, Size size, Paint paint) {
    final spacing = pattern.size + pattern.spacing;
    paint.strokeWidth = 2;

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawGrid(Canvas canvas, Size size, Paint paint) {
    final spacing = pattern.size + pattern.spacing;
    paint.strokeWidth = 1;

    // Lignes horizontales
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Lignes verticales
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  void _drawDiagonal(Canvas canvas, Size size, Paint paint) {
    final spacing = pattern.size + pattern.spacing;
    paint.strokeWidth = 2;

    for (var i = -size.height; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  void _drawWaves(Canvas canvas, Size size, Paint paint) {
    final spacing = pattern.size + pattern.spacing;
    paint.strokeWidth = 2;

    for (double y = 0; y < size.height; y += spacing) {
      final path = Path();
      for (double x = 0; x <= size.width; x += 5) {
        final waveY = y + sin((x / 30) + (animation * 2 * pi)) * 5;
        if (x == 0) {
          path.moveTo(x, waveY);
        } else {
          path.lineTo(x, waveY);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawCircles(Canvas canvas, Size size, Paint paint) {
    final spacing = pattern.size * 2 + pattern.spacing;

    for (var x = spacing / 2; x < size.width; x += spacing) {
      for (var y = spacing / 2; y < size.height; y += spacing) {
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 2;
        canvas.drawCircle(Offset(x, y), pattern.size / 2, paint);

        paint.style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), pattern.size / 4, paint);
      }
    }
  }

  void _drawTriangles(Canvas canvas, Size size, Paint paint) {
    final spacing = pattern.size + pattern.spacing;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final path = Path();
        path.moveTo(x + pattern.size / 2, y);
        path.lineTo(x, y + pattern.size);
        path.lineTo(x + pattern.size, y + pattern.size);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawHexagons(Canvas canvas, Size size, Paint paint) {
    final spacing = pattern.size + pattern.spacing;

    for (double x = 0; x < size.width; x += spacing * 1.5) {
      for (double y = 0; y < size.height; y += spacing * 0.866) {
        final offset = (x / (spacing * 1.5)).floor() % 2 == 0
            ? 0
            : spacing * 0.433;
        _drawHexagon(canvas, Offset(x, y + offset), pattern.size / 2, paint);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (i * pi * 2) / 6;
      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawStars(Canvas canvas, Size size, Paint paint) {
    final spacing = pattern.size + pattern.spacing;

    for (var x = spacing / 2; x < size.width; x += spacing) {
      for (var y = spacing / 2; y < size.height; y += spacing) {
        _drawStar(canvas, Offset(x, y), pattern.size / 2, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const points = 5;
    final outerRadius = radius;
    final innerRadius = radius * 0.4;

    for (var i = 0; i < points * 2; i++) {
      final angle = (i * pi) / points - pi / 2;
      final r = i % 2 == 0 ? outerRadius : innerRadius;
      final x = center.dx + cos(angle) * r;
      final y = center.dy + sin(angle) * r;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHearts(Canvas canvas, Size size, Paint paint) {
    final spacing = pattern.size + pattern.spacing;

    for (var x = spacing / 2; x < size.width; x += spacing) {
      for (var y = spacing / 2; y < size.height; y += spacing) {
        _drawHeart(canvas, Offset(x, y), pattern.size / 2, paint);
      }
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.3);

    path.cubicTo(
      center.dx - size * 0.5,
      center.dy - size * 0.3,
      center.dx - size,
      center.dy - size * 0.1,
      center.dx - size,
      center.dy,
    );

    path.cubicTo(
      center.dx - size,
      center.dy + size * 0.2,
      center.dx - size * 0.5,
      center.dy + size * 0.5,
      center.dx,
      center.dy + size,
    );

    path.cubicTo(
      center.dx + size * 0.5,
      center.dy + size * 0.5,
      center.dx + size,
      center.dy + size * 0.2,
      center.dx + size,
      center.dy,
    );

    path.cubicTo(
      center.dx + size,
      center.dy - size * 0.1,
      center.dx + size * 0.5,
      center.dy - size * 0.3,
      center.dx,
      center.dy + size * 0.3,
    );

    canvas.drawPath(path, paint);
  }

  void _drawGeometric(Canvas canvas, Size size, Paint paint) {
    final spacing = pattern.size + pattern.spacing;
    final random = Random(42); // Seed for reproducibility

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final shape = random.nextInt(3);
        switch (shape) {
          case 0: // Square
            canvas.drawRect(
              Rect.fromCenter(
                center: Offset(x, y),
                width: pattern.size * 0.8,
                height: pattern.size * 0.8,
              ),
              paint,
            );
            break;
          case 1: // Circle
            canvas.drawCircle(Offset(x, y), pattern.size * 0.4, paint);
            break;
          case 2: // Triangle
            final path = Path();
            path.moveTo(x, y - pattern.size * 0.4);
            path.lineTo(x - pattern.size * 0.35, y + pattern.size * 0.3);
            path.lineTo(x + pattern.size * 0.35, y + pattern.size * 0.3);
            path.close();
            canvas.drawPath(path, paint);
            break;
        }
      }
    }
  }

  void _drawAbstract(Canvas canvas, Size size, Paint paint) {
    final random = Random(42 + (animation * 100).floor());

    for (var i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * pattern.size + 5;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(PatternPainter oldDelegate) =>
      oldDelegate.pattern != pattern || oldDelegate.animation != animation;
}
