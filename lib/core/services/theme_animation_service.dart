/// Service d'animations et transitions pour les thèmes
library;
import 'dart:math';
import 'package:flutter/material.dart';

enum AnimationType {
  none,
  fadeIn,
  slideInLeft,
  slideInRight,
  slideInUp,
  slideInDown,
  scaleIn,
  rotateIn,
  bounceIn,
  elasticIn,
  slideInFromCenter,
  flipInHorizontal,
  flipInVertical,
  drawFromTop,
  drawFromBottom,
  drawFromLeft,
  drawFromRight,
  spiralIn,
  waveIn,
  particleIn,
  morphIn,
}

enum TransitionType {
  instant,
  fade,
  slide,
  scale,
  flip,
  dissolve,
  wipe,
  circle,
  pixelate,
  blur,
  glitch,
  ripple,
  shutter,
  curtain,
  pageFlip,
  cube,
}

class ThemeAnimationConfig {

  const ThemeAnimationConfig({
    this.entranceAnimation = AnimationType.fadeIn,
    this.transitionType = TransitionType.fade,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeInOut,
    this.delay = 0.0,
    this.autoPlay = true,
    this.loop = false,
    this.customAnimationId,
  });

  factory ThemeAnimationConfig.fromJson(Map<String, dynamic> json) => ThemeAnimationConfig(
      entranceAnimation: AnimationType.values.firstWhere(
        (e) => e.name == json['entranceAnimation'],
        orElse: () => AnimationType.fadeIn,
      ),
      transitionType: TransitionType.values.firstWhere(
        (e) => e.name == json['transitionType'],
        orElse: () => TransitionType.fade,
      ),
      duration: Duration(milliseconds: json['duration'] ?? 800),
      delay: json['delay']?.toDouble() ?? 0.0,
      autoPlay: json['autoPlay'] ?? true,
      loop: json['loop'] ?? false,
      customAnimationId: json['customAnimationId'],
    );
  final AnimationType entranceAnimation;
  final TransitionType transitionType;
  final Duration duration;
  final Curve curve;
  final double delay;
  final bool autoPlay;
  final bool loop;
  final String? customAnimationId;

  Map<String, dynamic> toJson() => {
        'entranceAnimation': entranceAnimation.name,
        'transitionType': transitionType.name,
        'duration': duration.inMilliseconds,
        'curve': curve.toString(),
        'delay': delay,
        'autoPlay': autoPlay,
        'loop': loop,
        'customAnimationId': customAnimationId,
      };
}

class ThemeAnimationService {
  static final Map<AnimationType, AnimationConfig> _animationConfigs = {
    AnimationType.fadeIn: const AnimationConfig(
      type: 'fade',
      duration: Duration(milliseconds: 600),
      curve: Curves.easeIn,
    ),
    AnimationType.slideInLeft: const AnimationConfig(
      type: 'slide',
      begin: Offset(-1.0, 0.0),
      end: Offset.zero,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    ),
    AnimationType.slideInRight: const AnimationConfig(
      type: 'slide',
      begin: Offset(1.0, 0.0),
      end: Offset.zero,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    ),
    AnimationType.slideInUp: const AnimationConfig(
      type: 'slide',
      begin: Offset(0.0, 1.0),
      end: Offset.zero,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    ),
    AnimationType.slideInDown: const AnimationConfig(
      type: 'slide',
      begin: Offset(0.0, -1.0),
      end: Offset.zero,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    ),
    AnimationType.scaleIn: const AnimationConfig(
      type: 'scale',
      begin: 0.0,
      end: 1.0,
      duration: Duration(milliseconds: 400),
      curve: Curves.elasticOut,
    ),
    AnimationType.rotateIn: const AnimationConfig(
      type: 'rotate',
      begin: -pi / 4,
      end: 0.0,
      duration: Duration(milliseconds: 600),
      curve: Curves.elasticOut,
    ),
    AnimationType.bounceIn: const AnimationConfig(
      type: 'bounce',
      begin: 0.0,
      end: 1.0,
      duration: Duration(milliseconds: 800),
      curve: Curves.bounceOut,
    ),
    AnimationType.elasticIn: const AnimationConfig(
      type: 'elastic',
      begin: 0.0,
      end: 1.0,
      duration: Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
    ),
    AnimationType.flipInHorizontal: const AnimationConfig(
      type: 'flip',
      axis: Axis.horizontal,
      begin: pi / 2,
      end: 0.0,
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    ),
    AnimationType.flipInVertical: const AnimationConfig(
      type: 'flip',
      axis: Axis.vertical,
      begin: pi / 2,
      end: 0.0,
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    ),
  };

  static AnimationConfig getConfigForAnimation(AnimationType type) => _animationConfigs[type] ?? _animationConfigs[AnimationType.fadeIn]!;

  static List<AnimationType> getAnimationsForMood(String mood) {
    final moodLower = mood.toLowerCase();

    switch (moodLower) {
      case 'energetic':
      case 'dynamique':
        return [
          AnimationType.bounceIn,
          AnimationType.elasticIn,
          AnimationType.slideInUp,
          AnimationType.scaleIn,
        ];
      case 'calme':
      case 'relaxé':
      case 'élégant':
        return [
          AnimationType.fadeIn,
          AnimationType.slideInUp,
          AnimationType.scaleIn,
        ];
      case 'moderne':
      case 'tech':
        return [
          AnimationType.slideInLeft,
          AnimationType.slideInRight,
          AnimationType.flipInHorizontal,
          AnimationType.flipInVertical,
        ];
      case 'créatif':
      case 'artistique':
        return [
          AnimationType.rotateIn,
          AnimationType.elasticIn,
          AnimationType.spiralIn,
          AnimationType.waveIn,
        ];
      default:
        return [
          AnimationType.fadeIn,
          AnimationType.slideInUp,
          AnimationType.scaleIn,
        ];
    }
  }

  static AnimationType getRandomAnimation() {
    final animations = AnimationType.values.where((a) => a != AnimationType.none);
    final random = Random();
    return animations.elementAt(random.nextInt(animations.length));
  }

  static Duration getOptimalDuration(AnimationType type) {
    final config = getConfigForAnimation(type);
    return config.duration;
  }

  static Curve getOptimalCurve(AnimationType type) {
    final config = getConfigForAnimation(type);
    return config.curve;
  }
}

class AnimationConfig {

  const AnimationConfig({
    required this.type,
    this.begin,
    this.end,
    this.beginDouble,
    this.endDouble,
    this.axis,
    required this.duration,
    required this.curve,
  });
  final String type;
  final Offset? begin;
  final Offset? end;
  final double? beginDouble;
  final double? endDouble;
  final Axis? axis;
  final Duration duration;
  final Curve curve;
}

class AnimatedThemeWidget extends StatefulWidget {
  const AnimatedThemeWidget({
    super.key,
    required this.child,
    required this.animationConfig,
    this.onAnimationComplete,
  });

  final Widget child;
  final ThemeAnimationConfig animationConfig;
  final VoidCallback? onAnimationComplete;

  @override
  State<AnimatedThemeWidget> createState() => _AnimatedThemeWidgetState();
}

class _AnimatedThemeWidgetState extends State<AnimatedThemeWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationConfig.duration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.animationConfig.curve,
    );

    _setupAnimations();

    if (widget.animationConfig.autoPlay) {
      _startAnimation();
    }
  }

  void _setupAnimations() {
    switch (widget.animationConfig.entranceAnimation) {
      case AnimationType.fadeIn:
        _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animation);
        break;
      case AnimationType.slideInLeft:
        _slideAnimation = Tween<Offset>(
          begin: const Offset(-1.0, 0.0),
          end: Offset.zero,
        ).animate(_animation);
        break;
      case AnimationType.slideInRight:
        _slideAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(_animation);
        break;
      case AnimationType.slideInUp:
        _slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(_animation);
        break;
      case AnimationType.slideInDown:
        _slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, -1.0),
          end: Offset.zero,
        ).animate(_animation);
        break;
      case AnimationType.scaleIn:
        _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animation);
        break;
      case AnimationType.rotateIn:
        _rotateAnimation = Tween<double>(begin: -pi / 4, end: 0.0).animate(_animation);
        break;
      case AnimationType.bounceIn:
        _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animation);
        break;
      case AnimationType.elasticIn:
        _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animation);
        break;
      case AnimationType.flipInHorizontal:
        _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animation);
        break;
      case AnimationType.flipInVertical:
        _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animation);
        break;
      default:
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_animation);
    }
  }

  void _startAnimation() {
    Future.delayed(Duration(milliseconds: (widget.animationConfig.delay * 1000).round()), () {
      if (mounted) {
        _controller.forward().then((_) {
          if (widget.onAnimationComplete != null) {
            widget.onAnimationComplete!();
          }

          if (widget.animationConfig.loop) {
            _controller.repeat(reverse: true);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.animationConfig.entranceAnimation) {
      case AnimationType.fadeIn:
        return FadeTransition(
          opacity: _scaleAnimation,
          child: widget.child,
        );
      case AnimationType.slideInLeft:
      case AnimationType.slideInRight:
      case AnimationType.slideInUp:
      case AnimationType.slideInDown:
        return SlideTransition(
          position: _slideAnimation,
          child: widget.child,
        );
      case AnimationType.scaleIn:
      case AnimationType.bounceIn:
      case AnimationType.elasticIn:
        return ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        );
      case AnimationType.rotateIn:
        return AnimatedBuilder(
          animation: _rotateAnimation,
          builder: (context, child) => Transform.rotate(
            angle: _rotateAnimation.value,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: child,
            ),
          ),
          child: widget.child,
        );
      case AnimationType.flipInHorizontal:
      case AnimationType.flipInVertical:
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final isHorizontal = widget.animationConfig.entranceAnimation == AnimationType.flipInHorizontal;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(isHorizontal ? 0 : _animation.value * pi)
                ..rotateY(isHorizontal ? _animation.value * pi : 0),
              child: child,
            );
          },
          child: widget.child,
        );
      case AnimationType.none:
      default:
        return widget.child;
    }
  }
}

class ThemeTransitionBuilder {
  static Widget buildTransition({
    required Widget child,
    required TransitionType transitionType,
    required Animation<double> animation,
    required Widget? previousChild,
  }) {
    switch (transitionType) {
      case TransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      case TransitionType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      case TransitionType.scale:
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      case TransitionType.flip:
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(animation.value * pi),
            child: child,
          ),
          child: child,
        );
      case TransitionType.circle:
        return ClipPath(
          clipper: CircleRevealClipper(animation.value),
          child: child,
        );
      case TransitionType.wipe:
        return ClipPath(
          clipper: WipeClipper(animation.value),
          child: child,
        );
      case TransitionType.blur:
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) => ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: (1 - animation.value) * 10,
              sigmaY: (1 - animation.value) * 10,
            ),
            child: child,
          ),
          child: child,
        );
      case TransitionType.instant:
      default:
        return child;
    }
  }
}

class CircleRevealClipper extends CustomClipper<Path> {

  CircleRevealClipper(this.progress);
  final double progress;

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = sqrt(size.width * size.width + size.height * size.height) * progress;
    return Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..close();
  }

  @override
  bool shouldReclip(CircleRevealClipper oldClipper) => oldClipper.progress != progress;
}

class WipeClipper extends CustomClipper<Path> {

  WipeClipper(this.progress);
  final double progress;

  @override
  Path getClip(Size size) => Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width * progress, size.height))
      ..close();

  @override
  bool shouldReclip(WipeClipper oldClipper) => oldClipper.progress != progress;
}

class ParticleAnimationWidget extends StatefulWidget {
  const ParticleAnimationWidget({
    super.key,
    required this.child,
    this.particleCount = 20,
    this.particleColor = Colors.blue,
    this.duration = const Duration(seconds: 2),
  });

  final Widget child;
  final int particleCount;
  final Color particleColor;
  final Duration duration;

  @override
  State<ParticleAnimationWidget> createState() => _ParticleAnimationWidgetState();
}

class _ParticleAnimationWidgetState extends State<ParticleAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _generateParticles();
    _controller.repeat();
  }

  void _generateParticles() {
    final random = Random();
    for (var i = 0; i < widget.particleCount; i++) {
      _particles.add(Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 4 + 1,
        speed: random.nextDouble() * 2 + 1,
        angle: random.nextDouble() * 2 * pi,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => CustomPaint(
              painter: ParticlePainter(
                particles: _particles,
                progress: _controller.value,
                color: widget.particleColor,
              ),
              child: child,
            ),
          child: widget.child,
        ),
      ],
    );
}

class Particle {

  const Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
  });
  final double x;
  final double y;
  final double size;
  final double speed;
  final double angle;
}

class ParticlePainter extends CustomPainter {

  ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });
  final List<Particle> particles;
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      final currentProgress = (progress + particle.angle / (2 * pi)) % 1.0;
      final x = particle.x * size.width;
      final y = particle.y * size.height - (currentProgress * size.height * 2);

      if (y >= -10 && y <= size.height + 10) {
        canvas.drawCircle(
          Offset(x, y),
          particle.size,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => oldDelegate.progress != progress;
}