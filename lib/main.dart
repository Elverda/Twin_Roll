import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const TwinsRollApp());

// ─── COLORS ───────────────────────────────────────────
class C {
  static const cream     = Color(0xFFFDF6EE);
  static const surface   = Color(0xFFF5E6D6);
  static const brown     = Color(0xFF2C1608);
  static const caramel   = Color(0xFFB86A28);
  static const warm      = Color(0xFFD4733A);
  static const gold      = Color(0xFFC9952E);
  static const peach     = Color(0xFFF2C5A0);
  static const pinkSoft  = Color(0xFFF0CFC0);
  static const green     = Color(0xFF3A6B3E);
  static const white     = Colors.white;
  static const dark1     = Color(0xFF1E0C04);
  static const darkBg    = Color(0xFF251008);
  static const textMuted = Color(0xFF6B4728);
  static const textSub   = Color(0xFF9C6A40);
}

// ══════════════════════════════════════════════════════
//  SCROLL REVEAL — fade + slide
// ══════════════════════════════════════════════════════
class RevealWrapper extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Offset slideFrom;

  const RevealWrapper({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.slideFrom = const Offset(0, 60),
  });

  @override
  State<RevealWrapper> createState() => RevealWrapperState();
}

class RevealWrapperState extends State<RevealWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: widget.slideFrom, end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void checkFromScroll() => _checkVisibility();

  void _checkVisibility() {
    if (_triggered || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final position = box.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Trigger if the top of the widget is visible within the viewport
    if (position.dy < screenHeight * 0.9) {
      _triggered = true;
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => FadeTransition(
        opacity: _fade,
        child: Transform.translate(offset: _slide.value, child: child),
      ),
      child: widget.child,
    );
  }
}

// ══════════════════════════════════════════════════════
//  SCALE REVEAL
// ══════════════════════════════════════════════════════
class ScaleReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double fromScale;

  const ScaleReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.fromScale = 0.75,
  });

  @override
  State<ScaleReveal> createState() => _ScaleRevealState();
}

class _ScaleRevealState extends State<ScaleReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _scale = Tween<double>(begin: widget.fromScale, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void checkFromScroll() => _check();

  void _check() {
    if (_triggered || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final position = box.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;

    if (position.dy < screenHeight * 0.9) {
      _triggered = true;
      Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => FadeTransition(
        opacity: _fade,
        child: ScaleTransition(scale: _scale, child: child),
      ),
      child: widget.child,
    );
  }
}

// ══════════════════════════════════════════════════════
//  SHIMMER REVEAL
// ══════════════════════════════════════════════════════
class ShimmerReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const ShimmerReveal({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<ShimmerReveal> createState() => _ShimmerRevealState();
}

class _ShimmerRevealState extends State<ShimmerReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shimmer;
  late Animation<double> _fade;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _shimmer = Tween<double>(begin: -1.0, end: 2.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.5));
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void checkFromScroll() => _check();

  void _check() {
    if (_triggered || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final position = box.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;

    if (position.dy < screenHeight * 0.9) {
      _triggered = true;
      Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: _fade.value,
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [
              Color(0xFFF2C5A0),
              Color(0xFFFFFFFF),
              Color(0xFFF2C5A0),
            ],
            stops: [
              (_shimmer.value - 0.3).clamp(0.0, 1.0),
              _shimmer.value.clamp(0.0, 1.0),
              (_shimmer.value + 0.3).clamp(0.0, 1.0),
            ],
          ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

// ══════════════════════════════════════════════════════
//  PARALLAX WIDGET
// ══════════════════════════════════════════════════════
class ParallaxWidget extends StatefulWidget {
  final Widget child;
  final double factor;
  final ScrollController scrollController;

  const ParallaxWidget({
    super.key,
    required this.child,
    required this.scrollController,
    this.factor = 0.3,
  });

  @override
  State<ParallaxWidget> createState() => _ParallaxWidgetState();
}

class _ParallaxWidgetState extends State<ParallaxWidget> {
  double _offset = 0;
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final box = (_key.currentContext?.findRenderObject() as RenderBox?);
    if (box == null) return;
    final pos = box.localToGlobal(Offset.zero);
    setState(() {
      _offset = pos.dy * widget.factor * -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      key: _key,
      offset: Offset(0, _offset),
      child: widget.child,
    );
  }
}

// ══════════════════════════════════════════════════════
//  WAVE CLIPPER
// ══════════════════════════════════════════════════════
class WaveClipper extends CustomClipper<Path> {
  final double waveHeight;
  final double progress;

  const WaveClipper({this.waveHeight = 30, this.progress = 1.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, waveHeight);
    final w = size.width;
    final h = size.height;
    for (double x = 0; x <= w; x++) {
      final y = waveHeight +
          math.sin((x / w * 2 * math.pi) + (progress * math.pi)) *
              (waveHeight * 0.5);
      path.lineTo(x, y);
    }
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper old) =>
      old.waveHeight != waveHeight || old.progress != progress;
}

// ══════════════════════════════════════════════════════
//  COUNTER ANIMATION
// ══════════════════════════════════════════════════════
class AnimatedCounter extends StatefulWidget {
  final int target;
  final String suffix;
  final TextStyle style;

  const AnimatedCounter({
    super.key,
    required this.target,
    this.suffix = '',
    required this.style,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void checkFromScroll() => _check();

  void _check() {
    if (_triggered || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final position = box.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;

    if (position.dy < screenHeight * 0.9) {
      _triggered = true;
      _ctrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final val = (_anim.value * widget.target).round();
        return Text('$val${widget.suffix}', style: widget.style);
      },
    );
  }
}

// ══════════════════════════════════════════════════════
//  SCROLL PROGRESS BAR
// ══════════════════════════════════════════════════════
class ScrollProgressBar extends StatefulWidget {
  final ScrollController scrollController;

  const ScrollProgressBar({super.key, required this.scrollController});

  @override
  State<ScrollProgressBar> createState() => _ScrollProgressBarState();
}

class _ScrollProgressBarState extends State<ScrollProgressBar> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final max = widget.scrollController.position.maxScrollExtent;
    if (max == 0) return;
    setState(() {
      _progress = widget.scrollController.offset / max;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 50),
      height: 3,
      width: MediaQuery.of(context).size.width * _progress,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [C.gold, C.warm, C.caramel],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  PARTICLE SYSTEM
// ══════════════════════════════════════════════════════
class FloatingParticles extends StatefulWidget {
  final int count;
  final Color color;
  final double maxSize;

  const FloatingParticles({
    super.key,
    this.count = 12,
    this.color = C.gold,
    this.maxSize = 8,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _Particle {
  final double x, y, size, speed, opacity, phase;
  const _Particle({
    required this.x, required this.y, required this.size,
    required this.speed, required this.opacity, required this.phase,
  });
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_Particle> _particles;
  final _rand = math.Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(widget.count, (_) => _Particle(
      x: _rand.nextDouble(),
      y: _rand.nextDouble(),
      size: 2 + _rand.nextDouble() * widget.maxSize,
      speed: 0.5 + _rand.nextDouble() * 2,
      opacity: 0.1 + _rand.nextDouble() * 0.4,
      phase: _rand.nextDouble() * math.pi * 2,
    ));
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            progress: _ctrl.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;

  const _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress * p.speed + p.phase / (2 * math.pi)) % 1.0;
      final x = p.x * size.width +
          math.sin(t * math.pi * 2 + p.phase) * 30;
      final y = (1 - t) * size.height;
      final opacity = p.opacity * math.sin(t * math.pi);

      final paint = Paint()
        ..color = color.withOpacity(opacity.clamp(0, 1))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), p.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

// ══════════════════════════════════════════════════════
//  APP
// ══════════════════════════════════════════════════════
class TwinsRollApp extends StatelessWidget {
  const TwinsRollApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twins Roll',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: C.cream,
        colorScheme: ColorScheme.fromSeed(seedColor: C.caramel),
      ),
      home: const _HomePage(),
    );
  }
}

// ══════════════════════════════════════════════════════
//  HOME PAGE
// ══════════════════════════════════════════════════════
class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> with TickerProviderStateMixin {
  late final AnimationController _heroCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _bgPulseCtrl;
  late final Animation<double>   _heroFade;
  late final Animation<Offset>   _heroSlide;
  late final Animation<double>   _float;
  late final Animation<double>   _bgPulse;

  final ScrollController _scrollCtrl = ScrollController();
  final GlobalKey _menuKey = GlobalKey();

  final List<GlobalKey<RevealWrapperState>> _revealKeys =
  List.generate(40, (_) => GlobalKey<RevealWrapperState>());
  final List<GlobalKey<_ScaleRevealState>> _scaleKeys =
  List.generate(10, (_) => GlobalKey<_ScaleRevealState>());
  final List<GlobalKey<_AnimatedCounterState>> _counterKeys =
  List.generate(5, (_) => GlobalKey<_AnimatedCounterState>());

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _bgPulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 5))
      ..repeat(reverse: true);

    _heroFade  = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(begin: const Offset(0, -.18), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));
    _float = Tween<double>(begin: -8, end: 8)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _bgPulse = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _bgPulseCtrl, curve: Curves.easeInOut));

    _heroCtrl.forward();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    for (final k in _revealKeys) { k.currentState?.checkFromScroll(); }
    for (final k in _scaleKeys)  { k.currentState?.checkFromScroll(); }
    for (final k in _counterKeys) { k.currentState?.checkFromScroll(); }
  }

  void _scrollToMenu() {
    final ctx = _menuKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic);
    }
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _floatCtrl.dispose();
    _bgPulseCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Widget _reveal(int idx, Widget child,
      {Duration delay = Duration.zero, Offset from = const Offset(0, 60)}) {
    return RevealWrapper(
        key: _revealKeys[idx], delay: delay, slideFrom: from, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollCtrl,
            child: Column(
              children: [
                _HeroSection(
                  fade: _heroFade,
                  slide: _heroSlide,
                  float: _float,
                  bgPulse: _bgPulse,
                  scrollController: _scrollCtrl,
                  onLihatMenu: _scrollToMenu,
                ),
                _reveal(0, _StatsBar(counterKeys: _counterKeys)),
                _reveal(1, _BrandSection(scrollController: _scrollCtrl)),
                _reveal(2, const _WaveDivider()),
                _reveal(3, _MenuSection(
                  key: _menuKey,
                  revealKeys: _revealKeys,
                  revealOffset: 4,
                )),
                _reveal(9, const _BlindSection()),
                _reveal(10, _TeamSection(
                  revealKeys: _revealKeys,
                  revealOffset: 11,
                )),
                _reveal(14, const _Footer()),
              ],
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: ScrollProgressBar(scrollController: _scrollCtrl),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  STATS BAR
// ══════════════════════════════════════════════════════
class _StatsBar extends StatelessWidget {
  final List<GlobalKey<_AnimatedCounterState>> counterKeys;

  const _StatsBar({required this.counterKeys});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEDD5B8), Color(0xFFF5E6D6)],
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 32,
        runSpacing: 16,
        children: [
          _StatItem(counterKey: counterKeys[0], target: 6,    suffix: '+', label: 'Varian Rasa'),
          _StatItem(counterKey: counterKeys[1], target: 100,  suffix: '%', label: 'Bahan Alami'),
          _StatItem(counterKey: counterKeys[2], target: 2026, suffix: '',  label: 'Tahun Berdiri'),
          _StatItem(counterKey: counterKeys[3], target: 2,    suffix: '',  label: 'Konsep Blind'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final GlobalKey<_AnimatedCounterState> counterKey;
  final int target;
  final String suffix;
  final String label;

  const _StatItem({
    required this.counterKey,
    required this.target,
    required this.suffix,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedCounter(
          key: counterKey,
          target: target,
          suffix: suffix,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: C.caramel,
            fontFamily: 'Georgia',
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: C.textSub, letterSpacing: 1)),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════
//  WAVE DIVIDER
// ══════════════════════════════════════════════════════
class _WaveDivider extends StatefulWidget {
  const _WaveDivider();

  @override
  State<_WaveDivider> createState() => _WaveDividerState();
}

class _WaveDividerState extends State<_WaveDivider>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _wave;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _wave = Tween<double>(begin: 0, end: 2 * math.pi).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _wave,
      builder: (_, __) {
        return ClipPath(
          clipper: WaveClipper(waveHeight: 30, progress: _wave.value),
          child: Container(
            height: 60,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF120602), C.caramel],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════
//  HERO SECTION
// ══════════════════════════════════════════════════════
class _HeroSection extends StatelessWidget {
  final Animation<double> fade;
  final Animation<Offset> slide;
  final Animation<double> float;
  final Animation<double> bgPulse;
  final ScrollController scrollController;
  final VoidCallback onLihatMenu;

  const _HeroSection({
    required this.fade,
    required this.slide,
    required this.float,
    required this.bgPulse,
    required this.scrollController,
    required this.onLihatMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF120602),
            Color(0xFF2C1608),
            Color(0xFF6B3010),
            Color(0xFFB86A28),
          ],
          stops: [0, 0.28, 0.65, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: FloatingParticles(count: 20, color: C.gold, maxSize: 6),
          ),
          Positioned(
            top: -60, right: -60,
            child: AnimatedBuilder(
              animation: bgPulse,
              builder: (_, __) => Transform.scale(
                scale: 1.0 + bgPulse.value * 0.15,
                child: Container(
                  width: 300, height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: C.caramel
                        .withOpacity(0.04 + bgPulse.value * 0.04),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40, left: -80,
            child: ParallaxWidget(
              scrollController: scrollController,
              factor: 0.2,
              child: Container(
                width: 320, height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: C.warm.withOpacity(0.05),
                ),
              ),
            ),
          ),
          ..._buildStars(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 60),
            child: FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: slide,
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: float,
                      builder: (_, __) => Transform.translate(
                        offset: Offset(0, float.value),
                        child: const _Logo3D(),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'TWINS ROLL',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFDF6EE),
                        letterSpacing: 6,
                        fontFamily: 'Georgia',
                        shadows: [
                          Shadow(
                              color: Color(0x99000000),
                              blurRadius: 16,
                              offset: Offset(0, 5))
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 40,
                            height: 1,
                            color: C.peach.withOpacity(.6)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('✦',
                              style: TextStyle(
                                  color: C.gold, fontSize: 14)),
                        ),
                        Container(
                            width: 40,
                            height: 1,
                            color: C.peach.withOpacity(.6)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Kulit alami, sensasi di setiap gigitan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFF2C5A0),
                        letterSpacing: .5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 520),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: C.peach.withOpacity(.35), width: 1),
                      ),
                      child: const Text(
                        'Risol dengan kulit alami yang renyah dipadukan dengan isian lumer yang lezat. '
                            'Mengusung konsep Blind Flavour — setiap varian menghadirkan kejutan rasa '
                            'manis maupun gurih yang siap memanjakan setiap gigitanmu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFFF7E8D8),
                            height: 1.85),
                      ),
                    ),
                    const SizedBox(height: 36),
                    _GlowButton(
                        label: 'Lihat Menu Kami', onTap: onLihatMenu),
                    const SizedBox(height: 24),
                    const _ScrollIndicator(),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x55B86A28),
                    Color(0xFFFDF6EE)
                  ],
                  stops: [0, 0.55, 1],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStars() => const [
    Positioned(top: 32,  left: 24,  child: _Star(size: 16, delay: 0)),
    Positioned(top: 60,  right: 36, child: _Star(size: 11, delay: .4)),
    Positioned(top: 120, left: 70,  child: _Star(size: 9,  delay: .8)),
    Positioned(top: 160, right: 60, child: _Star(size: 13, delay: .2)),
    Positioned(top: 220, left: 20,  child: _Star(size: 8,  delay: .6)),
    Positioned(top: 250, right: 28, child: _Star(size: 10, delay: 1.0)),
  ];
}

// ── Scroll Indicator ──
class _ScrollIndicator extends StatefulWidget {
  const _ScrollIndicator();

  @override
  State<_ScrollIndicator> createState() => _ScrollIndicatorState();
}

class _ScrollIndicatorState extends State<_ScrollIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _bounce = Tween<double>(begin: 0, end: 12)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _bounce.value),
        child: Column(
          children: [
            Text(
              'Scroll',
              style: TextStyle(
                color: C.peach.withOpacity(0.6),
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Icon(Icons.keyboard_arrow_down,
                color: C.peach.withOpacity(0.6), size: 20),
          ],
        ),
      ),
    );
  }
}

class _Logo3D extends StatelessWidget {
  const _Logo3D();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 164, height: 164,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: C.warm.withOpacity(.14),
                  blurRadius: 50,
                  spreadRadius: 18)
            ],
          ),
        ),
        Container(
            width: 148,
            height: 148,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                Border.all(color: C.warm.withOpacity(.18), width: 2))),
        Container(
            width: 134,
            height: 134,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: C.gold.withOpacity(.4), width: 1.5))),
        Container(
          width: 120, height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD8B896),
            border: Border.all(color: C.gold, width: 4),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(.45),
                  blurRadius: 28,
                  offset: const Offset(0, 10)),
              BoxShadow(
                  color: C.warm.withOpacity(.6),
                  blurRadius: 18,
                  spreadRadius: 2),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFD8B896),
                child: const Center(
                  child: Text('T',
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: C.brown,
                          fontFamily: 'Georgia')),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 20, left: 0, right: 0,
          child: Center(
            child: Container(
              width: 52, height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(.25),
                    Colors.transparent
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlowButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _GlowButton({required this.label, required this.onTap});

  @override
  State<_GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<_GlowButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.04)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) =>
          Transform.scale(scale: _pulse.value, child: child),
      child: GestureDetector(
        onTapDown:   (_) => setState(() => _pressed = true),
        onTapUp:     (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:
          const EdgeInsets.symmetric(horizontal: 44, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFF0A060), Color(0xFFD4733A)]),
            borderRadius: BorderRadius.circular(50),
            boxShadow: _pressed
                ? []
                : [
              BoxShadow(
                  color: C.warm.withOpacity(.55),
                  blurRadius: 20,
                  offset: const Offset(0, 6)),
              BoxShadow(
                  color: C.brown.withOpacity(.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Color(0xFF1E0C04),
              fontWeight: FontWeight.w900,
              fontSize: 15,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _Star extends StatelessWidget {
  final double size, delay;
  const _Star({required this.size, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Text('✦',
        style: TextStyle(fontSize: size, color: C.peach.withOpacity(.55)));
  }
}

// ══════════════════════════════════════════════════════
//  BRAND SECTION
// ══════════════════════════════════════════════════════
class _BrandSection extends StatefulWidget {
  final ScrollController scrollController;
  const _BrandSection({required this.scrollController});

  @override
  State<_BrandSection> createState() => _BrandSectionState();
}

class _BrandSectionState extends State<_BrandSection> {
  late VideoPlayerController _videoCtrl;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _videoCtrl = VideoPlayerController.asset('assets/brand_cinematic.mp4')
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _videoReady = true);
          _videoCtrl.play();
        }
      });
  }

  @override
  void dispose() { _videoCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_videoReady)
          AspectRatio(
              aspectRatio: _videoCtrl.value.aspectRatio,
              child: VideoPlayer(_videoCtrl))
        else
          Container(
            height: 520, width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2C1608), Color(0xFF6B3010)],
              ),
            ),
          ),
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC120602),
                  Color(0xBF1E0C04),
                  Color(0xCC120602)
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 72, 24, 72),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _SectionLabel('Brand Identity', light: true),
              const SizedBox(height: 8),
              const Text(
                'Mengenal Twins Roll',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFDF6EE)),
              ),
              const SizedBox(height: 14),
              Container(
                  width: 60,
                  height: 3,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [C.gold, C.warm]),
                      borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 48),
              _StaggeredBrandCards(),
            ],
          ),
        ),
        Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
                height: 18,
                color: Colors.black.withOpacity(.5))),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
                height: 18,
                color: Colors.black.withOpacity(.5))),
      ],
    );
  }
}

class _StaggeredBrandCards extends StatefulWidget {
  @override
  State<_StaggeredBrandCards> createState() => _StaggeredBrandCardsState();
}

class _StaggeredBrandCardsState extends State<_StaggeredBrandCards>
    with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;
  late List<Animation<double>> _fades;
  late List<Animation<Offset>> _slides;

  static const _cards = [
    _BrandCardData(
        icon: '🏷️',
        label: 'Nama Brand',
        body: 'Twins Roll\nDua varian rasa dalam satu identitas khas.'),
    _BrandCardData(
        icon: '✨',
        label: 'Slogan',
        body: '"Kulit alami,\nsensasi di setiap gigitan"'),
    _BrandCardData(
        icon: '🎯',
        label: 'Konsep',
        body: 'Blind Flavour — kejutan rasa di setiap gigitan.'),
    _BrandCardData(
        icon: '📍',
        label: 'Lokasi',
        body: 'Jl. Maospati – Bar. No.358-360\nMaospati, Magetan'),
  ];

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
        4,
            (_) => AnimationController(
            vsync: this, duration: const Duration(milliseconds: 600)));
    _fades = _ctrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _slides = _ctrls
        .map((c) => Tween<Offset>(
        begin: const Offset(0, 60), end: Offset.zero)
        .animate(CurvedAnimation(parent: c, curve: Curves.easeOutBack)))
        .toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < 4; i++) {
        Future.delayed(Duration(milliseconds: i * 120), () {
          if (mounted) _ctrls[i].forward();
        });
      }
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20, runSpacing: 20,
      alignment: WrapAlignment.center,
      children: List.generate(4, (i) {
        return AnimatedBuilder(
          animation: _ctrls[i],
          builder: (_, child) => FadeTransition(
            opacity: _fades[i],
            child:
            Transform.translate(offset: _slides[i].value, child: child),
          ),
          child: _BrandCard(data: _cards[i]),
        );
      }),
    );
  }
}

class _BrandCardData {
  final String icon, label, body;
  const _BrandCardData(
      {required this.icon, required this.label, required this.body});
}

class _BrandCard extends StatefulWidget {
  final _BrandCardData data;
  const _BrandCard({required this.data});

  @override
  State<_BrandCard> createState() => _BrandCardState();
}

class _BrandCardState extends State<_BrandCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverCtrl;
  late Animation<double> _hover;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _hover = Tween<double>(begin: 0, end: 1).animate(_hoverCtrl);
  }

  @override
  void dispose() { _hoverCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hoverCtrl.forward(),
      onExit:  (_) => _hoverCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _hover,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, -8 * _hover.value),
          child: child,
        ),
        child: Container(
          width: 185,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: C.peach.withOpacity(.35), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: C.warm.withOpacity(.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: C.warm.withOpacity(.35), width: 1),
                ),
                child: Center(
                    child: Text(widget.data.icon,
                        style: const TextStyle(fontSize: 26))),
              ),
              const SizedBox(height: 12),
              Text(widget.data.label.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFD4A84A),
                      letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text(widget.data.body,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFFF5D0B0),
                      height: 1.65)),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  MENU SECTION
// ══════════════════════════════════════════════════════
class _MenuSection extends StatelessWidget {
  final List<GlobalKey<RevealWrapperState>> revealKeys;
  final int revealOffset;

  const _MenuSection({
    super.key,
    required this.revealKeys,
    this.revealOffset = 4,
  });

  static const _sweet = [
    _MenuItem('🍠', 'Ubi Coklat',
        'Ubi ungu lembut berpadu coklat leleh yang kaya rasa.',
        image: 'assets/ubi_coklat.png'),
    _MenuItem('🍌', 'Coklat Pisang',
        'Pisang manis dan coklat premium dalam kulit renyah.',
        image: 'assets/pisang_coklat.png'),
    _MenuItem('🧀', 'Jasuke Mozza',
        'Jagung, susu & keju mozzarella leleh yang gurih-manis.',
        image: 'assets/jasuke_mozza.png'),
  ];
  static const _savory = [
    _MenuItem('🐔', 'Ayam Suwir Kemangi',
        'Ayam suwir harum kemangi dalam kulit hijau alami.',
        image: 'assets/ayam_suwir.png'),
    _MenuItem('🍕', 'Pizza Roll',
        'Saus tomat, keju & topping pizza dalam risol renyah.',
        image: 'assets/pizza_roll.png'),
    _MenuItem('🌶️', 'Korean Spicy Chicken',
        'Ayam pedas ala Korea dengan bumbu gochujang khas.',
        image: 'assets/korean_spicy.png'),
  ];

  Widget _rv(List<GlobalKey<RevealWrapperState>> keys, int idx, Widget child,
      {Duration delay = Duration.zero}) {
    return RevealWrapper(key: keys[idx], delay: delay, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final o = revealOffset;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [C.cream, Color(0xFFEDD5B8)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 72),
      child: Column(
        children: [
          _rv(revealKeys, o,     const _SectionLabel('Menu Produk')),
          const SizedBox(height: 8),
          _rv(revealKeys, o + 1, const _SectionTitle('Varian Pilihan'),
              delay: const Duration(milliseconds: 100)),
          const SizedBox(height: 12),
          _rv(revealKeys, o + 2, _AccentLine(),
              delay: const Duration(milliseconds: 150)),
          const SizedBox(height: 44),
          _rv(revealKeys, o + 3, _VLabel('Sweet Variant', C.caramel),
              delay: const Duration(milliseconds: 200)),
          const SizedBox(height: 20),
          _StaggeredMenuRow(items: _sweet, savory: false),
          const SizedBox(height: 44),
          _rv(revealKeys, o + 4, _VLabel('Savory Variant', C.green),
              delay: const Duration(milliseconds: 100)),
          const SizedBox(height: 20),
          _StaggeredMenuRow(items: _savory, savory: true, fromRight: true),
        ],
      ),
    );
  }
}

// ── Staggered Menu Row ──
class _StaggeredMenuRow extends StatefulWidget {
  final List<_MenuItem> items;
  final bool savory;
  final bool fromRight;

  const _StaggeredMenuRow({
    required this.items,
    required this.savory,
    this.fromRight = false,
  });

  @override
  State<_StaggeredMenuRow> createState() => _StaggeredMenuRowState();
}

class _StaggeredMenuRowState extends State<_StaggeredMenuRow>
    with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;
  late List<Animation<double>> _fades;
  late List<Animation<Offset>> _slides;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
        widget.items.length,
            (_) => AnimationController(
            vsync: this, duration: const Duration(milliseconds: 550)));
    _fades = _ctrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    final dx = widget.fromRight ? 80.0 : -80.0;
    _slides = _ctrls
        .map((c) => Tween<Offset>(
        begin: Offset(dx, 30), end: Offset.zero)
        .animate(
        CurvedAnimation(parent: c, curve: Curves.easeOutCubic)))
        .toList();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < _ctrls.length; i++) {
        Future.delayed(Duration(milliseconds: i * 130), () {
          if (mounted) _ctrls[i].forward();
        });
      }
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20, runSpacing: 20,
      alignment: WrapAlignment.center,
      children: List.generate(widget.items.length, (i) {
        return AnimatedBuilder(
          animation: _ctrls[i],
          builder: (_, child) => FadeTransition(
            opacity: _fades[i],
            child: Transform.translate(
                offset: _slides[i].value, child: child),
          ),
          child: _MenuCard(item: widget.items[i], savory: widget.savory),
        );
      }),
    );
  }
}

class _MenuItem {
  final String emoji, name, desc;
  final String? image;
  const _MenuItem(this.emoji, this.name, this.desc, {this.image});
}

class _MenuCard extends StatefulWidget {
  final _MenuItem item;
  final bool savory;
  const _MenuCard({required this.item, required this.savory});

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard>
    with SingleTickerProviderStateMixin {
  bool _hov = false;
  late AnimationController _rippleCtrl;
  late Animation<double> _ripple;

  @override
  void initState() {
    super.initState();
    _rippleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _ripple =
        CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() { _rippleCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _hov = true);
        _rippleCtrl.forward(from: 0);
      },
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.translationValues(0, _hov ? -10 : 0, 0),
        width: 220,
        decoration: BoxDecoration(
          color: C.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: C.brown.withOpacity(_hov ? .16 : .08),
              blurRadius: _hov ? 40 : 18,
              offset: const Offset(0, 8),
            ),
            if (_hov)
              BoxShadow(
                color:
                (widget.savory ? C.green : C.caramel).withOpacity(.12),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22)),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.savory
                            ? [
                          const Color(0xFFA8D4AA),
                          const Color(0xFF3A6B3E)
                        ]
                            : [
                          const Color(0xFFF5C5A0),
                          const Color(0xFFB86A28)
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                            top: -20,
                            right: -20,
                            child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                    Colors.white.withOpacity(.08)))),
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(22)),
                            child: widget.item.image != null
                                ? Image.asset(widget.item.image!,
                                fit: BoxFit.cover,
                                alignment:
                                const Alignment(0, 0.3),
                                errorBuilder: (_, __, ___) =>
                                    Center(
                                        child: Text(
                                            widget.item.emoji,
                                            style: const TextStyle(
                                                fontSize: 56))))
                                : Center(
                                child: Text(widget.item.emoji,
                                    style: const TextStyle(
                                        fontSize: 56))),
                          ),
                        ),
                        Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                    borderRadius:
                                    const BorderRadius.vertical(
                                        top:
                                        Radius.circular(22)),
                                    color: widget.savory
                                        ? C.green
                                        : C.caramel))),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(widget.item.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: C.brown)),
                        const SizedBox(height: 6),
                        Text(widget.item.desc,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 12,
                                color: C.textMuted,
                                height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
              AnimatedBuilder(
                animation: _ripple,
                builder: (_, __) => Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: (widget.savory ? C.green : C.caramel)
                            .withOpacity((1 - _ripple.value) * 0.08),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _VLabel(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            child: Container(
                height: 1,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      C.surface.withOpacity(0),
                      C.surface
                    ])))),
        const SizedBox(width: 14),
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [color, color.withOpacity(.82)]),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: .5)),
        ),
        const SizedBox(width: 14),
        Expanded(
            child: Container(
                height: 1,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      C.surface,
                      C.surface.withOpacity(0)
                    ])))),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════
//  BLIND SECTION
// ══════════════════════════════════════════════════════
class _BlindSection extends StatefulWidget {
  const _BlindSection();

  @override
  State<_BlindSection> createState() => _BlindSectionState();
}

class _BlindSectionState extends State<_BlindSection>
    with TickerProviderStateMixin {
  late AnimationController _ctrl1, _ctrl2, _starCtrl, _glowCtrl;
  late Animation<Offset> _pos1, _pos2;
  late Animation<double> _rot1, _rot2, _starOpacity, _glow;

  static const double _bW = 130,
      _bH = _bW * 2,
      _colW = _bW + 40,
      _colH = _bH + 50;

  @override
  void initState() {
    super.initState();
    _ctrl1 = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 4200))
      ..repeat(reverse: true);
    _ctrl2 = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 5000))
      ..repeat(reverse: true);
    _starCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2500))
      ..repeat(reverse: true);
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    _pos1 = TweenSequence<Offset>([
      TweenSequenceItem(
          tween: Tween(begin: Offset.zero, end: const Offset(5, -18)),
          weight: 25),
      TweenSequenceItem(
          tween:
          Tween(begin: const Offset(5, -18), end: const Offset(2, -9)),
          weight: 25),
      TweenSequenceItem(
          tween: Tween(
              begin: const Offset(2, -9), end: const Offset(-4, -15)),
          weight: 25),
      TweenSequenceItem(
          tween:
          Tween(begin: const Offset(-4, -15), end: Offset.zero),
          weight: 25),
    ]).animate(
        CurvedAnimation(parent: _ctrl1, curve: Curves.easeInOut));

    _rot1 = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: -7.0, end: -2.0), weight: 25),
      TweenSequenceItem(
          tween: Tween(begin: -2.0, end: -10.0), weight: 25),
      TweenSequenceItem(
          tween: Tween(begin: -10.0, end: -5.0), weight: 25),
      TweenSequenceItem(
          tween: Tween(begin: -5.0, end: -7.0), weight: 25),
    ]).animate(
        CurvedAnimation(parent: _ctrl1, curve: Curves.easeInOut));

    _pos2 = TweenSequence<Offset>([
      TweenSequenceItem(
          tween: Tween(begin: Offset.zero, end: const Offset(-4, -20)),
          weight: 20),
      TweenSequenceItem(
          tween: Tween(
              begin: const Offset(-4, -20), end: const Offset(-2, -10)),
          weight: 30),
      TweenSequenceItem(
          tween: Tween(
              begin: const Offset(-2, -10), end: const Offset(6, -16)),
          weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(6, -16), end: Offset.zero),
          weight: 20),
    ]).animate(
        CurvedAnimation(parent: _ctrl2, curve: Curves.easeInOut));

    _rot2 = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 6.0, end: 11.0), weight: 20),
      TweenSequenceItem(
          tween: Tween(begin: 11.0, end: 4.0), weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: 4.0, end: 9.0), weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: 9.0, end: 6.0), weight: 20),
    ]).animate(
        CurvedAnimation(parent: _ctrl2, curve: Curves.easeInOut));

    _starOpacity = Tween<double>(begin: 0.2, end: 0.9).animate(
        CurvedAnimation(parent: _starCtrl, curve: Curves.easeInOut));
    _glow = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    _starCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  Widget _buildBannerCol({
    required bool isSweet,
    required AnimationController ctrl,
    required Animation<Offset> pos,
    required Animation<double> rot,
  }) {
    return SizedBox(
      width: _colW, height: _colH,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: ctrl,
            builder: (_, __) => Transform.translate(
              offset: pos.value,
              child: Transform.rotate(
                angle: rot.value * (math.pi / 180),
                child: _AssetBanner(
                  assetPath: isSweet
                      ? 'assets/banner_sweet.png'
                      : 'assets/banner_savory.png',
                  width: _bW, height: _bH,
                  label: isSweet ? 'Sweet' : 'Savory',
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.50),
                  borderRadius: BorderRadius.circular(14)),
              child: Text(
                  isSweet ? 'Sweet' : 'Savory',
                  style: const TextStyle(
                      color: Color(0xFFF2C5A0),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .5)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF120602),
            Color(0xFF2C1608),
            Color(0xFF5A2608)
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glow,
              builder: (_, __) => Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.6,
                    colors: [
                      C.warm.withOpacity(0.05 + _glow.value * 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          ..._buildDecoStars(),
          Positioned.fill(
              child: FloatingParticles(
                  count: 8, color: C.warm, maxSize: 4)),
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 64, horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBannerCol(
                    isSweet: true,
                    ctrl: _ctrl1,
                    pos: _pos1,
                    rot: _rot1),
                const SizedBox(width: 12),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _BouncingIcon(),
                        const SizedBox(height: 18),
                        const Text('Blind Flavour\nExperience',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFDF6EE),
                                height: 1.25)),
                        const SizedBox(height: 14),
                        const Text(
                          'Setiap gigitan adalah kejutan.\nPilih varian favoritmu atau coba peruntunganmu dengan konsep Blind Flavour khas Twins Roll!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFF2C5A0),
                              height: 1.7),
                        ),
                        const SizedBox(height: 26),
                        _PulsingBlindBox(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildBannerCol(
                    isSweet: false,
                    ctrl: _ctrl2,
                    pos: _pos2,
                    rot: _rot2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDecoStars() {
    const data = [
      [18.0, 18.0, 14.0, 1.0],
      [80.0, 10.0, 9.0, 0.0],
      [170.0, 28.0, 11.0, 1.0],
      [310.0, 12.0, 10.0, 0.0],
      [18.0, 280.0, 9.0, 1.0],
      [340.0, 260.0, 12.0, 0.0],
      [180.0, 340.0, 8.0, 1.0],
      [55.0, 360.0, 10.0, 0.0],
      [320.0, 350.0, 11.0, 1.0],
    ];
    return data.asMap().entries.map((e) {
      final i = e.key;
      final d = e.value;
      return Positioned(
        left: d[0], top: d[1],
        child: AnimatedBuilder(
          animation: _starOpacity,
          builder: (_, __) => Opacity(
            opacity: (_starOpacity.value *
                (0.35 + 0.4 * ((i % 3) / 3.0)))
                .clamp(0.08, 0.7),
            child: Text('✦',
                style: TextStyle(
                    fontSize: d[2],
                    color: d[3] == 1.0 ? C.gold : C.warm)),
          ),
        ),
      );
    }).toList();
  }
}

class _BouncingIcon extends StatefulWidget {
  @override
  State<_BouncingIcon> createState() => _BouncingIconState();
}

class _BouncingIconState extends State<_BouncingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _bounce = Tween<double>(begin: 0, end: -10)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (_, child) => Transform.translate(
          offset: Offset(0, _bounce.value), child: child),
      child: Container(
        width: 68, height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: C.warm.withOpacity(.16),
          border: Border.all(
              color: C.warm.withOpacity(.38), width: 1.5),
        ),
        child: const Center(
            child: Text('🎰', style: TextStyle(fontSize: 30))),
      ),
    );
  }
}

class _PulsingBlindBox extends StatefulWidget {
  @override
  State<_PulsingBlindBox> createState() => _PulsingBlindBoxState();
}

class _PulsingBlindBoxState extends State<_PulsingBlindBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.06)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) =>
          Transform.scale(scale: _pulse.value, child: child),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: C.gold, width: 2.5),
          gradient: LinearGradient(colors: [
            C.warm.withOpacity(.08),
            C.caramel.withOpacity(.08)
          ]),
          boxShadow: [
            BoxShadow(color: C.warm.withOpacity(.2), blurRadius: 20)
          ],
        ),
        child: const Text(
          'BLIND FLAVOUR',
          style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4A84A),
              letterSpacing: 5),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  ASSET BANNER
// ══════════════════════════════════════════════════════
class _AssetBanner extends StatelessWidget {
  final String assetPath;
  final double width, height;
  final String label;

  const _AssetBanner(
      {required this.assetPath,
        required this.width,
        required this.height,
        required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.55),
              blurRadius: 30,
              offset: const Offset(4, 14)),
          BoxShadow(
              color: C.warm.withOpacity(.22),
              blurRadius: 18,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(assetPath,
            width: width, height: height, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _FallbackBanner(
                width: width, height: height, label: label)),
      ),
    );
  }
}

class _FallbackBanner extends StatelessWidget {
  final double width, height;
  final String label;
  const _FallbackBanner(
      {required this.width, required this.height, required this.label});

  @override
  Widget build(BuildContext context) {
    final isSweet = label == 'Sweet';
    final topColor = isSweet ? C.brown : C.green;
    final accentClr =
    isSweet ? C.caramel : const Color(0xFF5A9E5E);
    return Container(
      width: width, height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topColor, accentClr]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(isSweet ? '🍫' : '🌿',
              style: const TextStyle(fontSize: 30)),
          const SizedBox(height: 8),
          const Text('TWINS ROLL',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Georgia',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2)),
          const SizedBox(height: 4),
          Text('$label Variant',
              style: const TextStyle(
                  color: Color(0xFFF2C5A0),
                  fontSize: 8,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Container(
              width: width * 0.55,
              height: 1,
              color: Colors.white.withOpacity(.2)),
          const SizedBox(height: 8),
          Text('1890 × 3780',
              style: TextStyle(
                  color: Colors.white.withOpacity(.3), fontSize: 7)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  TEAM SECTION
// ══════════════════════════════════════════════════════
class _TeamSection extends StatelessWidget {
  final List<GlobalKey<RevealWrapperState>> revealKeys;
  final int revealOffset;

  const _TeamSection({
    required this.revealKeys,
    this.revealOffset = 11,
  });

  static const _members = [
    _TeamMember(
        name: 'Izora Elverda Narulita Putri',
        role: 'Ketua',
        nim: '25051204287',
        emoji: '👤',
        num: 1),
    _TeamMember(
        name: 'Muhammad Abdullah Ro\'in',
        role: 'Anggota',
        nim: '25051204270',
        emoji: '👤',
        num: 2),
    _TeamMember(
        name: 'Manda Fatimah Azaziah',
        role: 'Anggota',
        nim: '25051204310',
        emoji: '👤',
        num: 3),
  ];

  @override
  Widget build(BuildContext context) {
    final o = revealOffset;
    return Container(
      color: C.cream,
      padding: const EdgeInsets.fromLTRB(24, 72, 24, 72),
      child: Column(
        children: [
          RevealWrapper(
              key: revealKeys[o],
              child: const _SectionLabel('Tim Penyusun')),
          const SizedBox(height: 8),
          RevealWrapper(
              key: revealKeys[o + 1],
              delay: const Duration(milliseconds: 80),
              child: const _SectionTitle('Kelompok Kami')),
          const SizedBox(height: 12),
          RevealWrapper(
              key: revealKeys[o + 2],
              delay: const Duration(milliseconds: 130),
              child: _AccentLine()),
          const SizedBox(height: 50),
          _StaggeredTeamCards(members: _members),
        ],
      ),
    );
  }
}

class _StaggeredTeamCards extends StatefulWidget {
  final List<_TeamMember> members;
  const _StaggeredTeamCards({required this.members});

  @override
  State<_StaggeredTeamCards> createState() => _StaggeredTeamCardsState();
}

class _StaggeredTeamCardsState extends State<_StaggeredTeamCards>
    with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;
  late List<Animation<double>> _scales, _fades;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
        widget.members.length,
            (_) => AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 700)));
    _fades = _ctrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _scales = _ctrls
        .map((c) => Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.elasticOut)))
        .toList();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < _ctrls.length; i++) {
        Future.delayed(Duration(milliseconds: i * 150), () {
          if (mounted) _ctrls[i].forward();
        });
      }
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 28, runSpacing: 28,
      alignment: WrapAlignment.center,
      children: List.generate(widget.members.length, (i) {
        return AnimatedBuilder(
          animation: _ctrls[i],
          builder: (_, child) => FadeTransition(
            opacity: _fades[i],
            child: ScaleTransition(scale: _scales[i], child: child),
          ),
          child: _TeamCard(member: widget.members[i]),
        );
      }),
    );
  }
}

class _TeamMember {
  final String name, role, nim, emoji;
  final int num;
  const _TeamMember(
      {required this.name,
        required this.role,
        required this.nim,
        required this.emoji,
        required this.num});
}

class _TeamCard extends StatefulWidget {
  final _TeamMember member;
  const _TeamCard({required this.member});

  @override
  State<_TeamCard> createState() => _TeamCardState();
}

class _TeamCardState extends State<_TeamCard> {
  bool _hov = false;

  Color get _badge {
    if (widget.member.num == 1) return C.brown;
    if (widget.member.num == 3) return C.green;
    return C.caramel;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit:  (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.translationValues(0, _hov ? -10 : 0, 0),
        width: 210,
        padding: const EdgeInsets.fromLTRB(24, 44, 24, 28),
        decoration: BoxDecoration(
          color: C.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
              color: _hov ? C.warm.withOpacity(.5) : C.surface,
              width: 1.5),
          boxShadow: [
            BoxShadow(
                color: C.brown.withOpacity(_hov ? .14 : .07),
                blurRadius: _hov ? 36 : 18,
                offset: const Offset(0, 8)),
            if (_hov)
              BoxShadow(
                  color: _badge.withOpacity(.1), blurRadius: 20),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                Container(
                  width: 82, height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [C.warm, _badge]),
                    border:
                    Border.all(color: C.surface, width: 3),
                    boxShadow: [
                      BoxShadow(
                          color: _badge.withOpacity(.28),
                          blurRadius: 14,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Center(
                      child: Text(widget.member.emoji,
                          style: const TextStyle(fontSize: 32))),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [_badge, _badge.withOpacity(.85)]),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                          color: _badge.withOpacity(.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Text(
                      widget.member.role.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2)),
                ),
                const SizedBox(height: 12),
                Text(widget.member.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: C.brown)),
                const SizedBox(height: 5),
                Text(widget.member.nim,
                    style: const TextStyle(
                        fontSize: 12, color: C.textSub)),
              ],
            ),
            Positioned(
              top: -68, left: 0, right: 0,
              child: Center(
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                        colors: [C.warm, C.caramel]),
                    border:
                    Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                          color: C.warm.withOpacity(.45),
                          blurRadius: 10,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Center(
                      child: Text('${widget.member.num}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  FOOTER
// ══════════════════════════════════════════════════════
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.dark1,
      padding: const EdgeInsets.fromLTRB(24, 44, 24, 32),
      child: Column(
        children: [
          _ShimmerText(
            'Twins Roll',
            style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFDF6EE)),
          ),
          const SizedBox(height: 4),
          const Text('SINCE 2026',
              style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 4,
                  color: Color(0xFFD4733A))),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                  child: Container(
                      height: 1,
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Colors.transparent,
                            Color(0xFFB86A28)
                          ])))),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFB86A28)))),
              Expanded(
                  child: Container(
                      height: 1,
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Color(0xFFB86A28),
                            Colors.transparent
                          ])))),
            ],
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: C.warm, size: 16),
              SizedBox(width: 8),
              Flexible(
                  child: Text(
                      'Jl. Maospati – Bar. No.358-360, Maospati, Magetan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFFF2C5A0)))),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone, color: C.warm, size: 16),
              SizedBox(width: 8),
              Text('081 216 363 561',
                  style: TextStyle(
                      fontSize: 12.5,
                      color: C.warm,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 28),
          Container(height: 1, color: const Color(0xFF3A2010)),
          const SizedBox(height: 16),
          const Text('© 2026 Twins Roll. All rights reserved.',
              style: TextStyle(
                  fontSize: 11, color: Color(0xFF8A5530))),
        ],
      ),
    );
  }
}

class _ShimmerText extends StatefulWidget {
  final String text;
  final TextStyle style;
  const _ShimmerText(this.text, {required this.style});

  @override
  State<_ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<_ShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
    _anim = Tween<double>(begin: -1.0, end: 2.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Color(0xFFFDF6EE),
            Color(0xFFFFFFDD),
            Color(0xFFFDF6EE)
          ],
          stops: [
            (_anim.value - 0.3).clamp(0.0, 1.0),
            _anim.value.clamp(0.0, 1.0),
            (_anim.value + 0.3).clamp(0.0, 1.0),
          ],
        ).createShader(bounds),
        child: Text(widget.text, style: widget.style),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  SHARED WIDGETS
// ══════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final String label;
  final bool light;
  const _SectionLabel(this.label, {this.light = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: light ? C.warm : C.caramel,
          letterSpacing: 3),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: C.brown));
  }
}

class _AccentLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60, height: 3,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [C.caramel, C.warm]),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}