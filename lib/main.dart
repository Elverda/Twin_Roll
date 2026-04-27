import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const TwinsRollApp());

// ─── COLORS ───────────────────────────────────────────
class C {
  static const cream    = Color(0xFFFAF3E8);
  static const brown    = Color(0xFF3B1F0E);
  static const caramel  = Color(0xFFC97B3A);
  static const peach    = Color(0xFFF4C9A1);
  static const warm     = Color(0xFFEFA96A);
  static const green    = Color(0xFF4A7C4E);
  static const pinkSoft = Color(0xFFF7D6C8);
  static const white    = Colors.white;
  static const dark1    = Color(0xFF2A1208);
  static const gold     = Color(0xFFD4A853);
}

// ══════════════════════════════════════════════════════
//  SCROLL REVEAL WRAPPER
// ══════════════════════════════════════════════════════
class _RevealOnScroll extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Offset slideFrom;

  const _RevealOnScroll({
    required this.child,
    this.delay = Duration.zero,
    this.slideFrom = const Offset(0, 40),
  });

  @override
  State<_RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<_RevealOnScroll>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: widget.slideFrom,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _trigger() {
    if (_triggered) return;
    _triggered = true;
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetectorCompat(
      onVisible: _trigger,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => FadeTransition(
          opacity: _fade,
          child: Transform.translate(
            offset: _slide.value,
            child: child,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

/// Minimal visibility detector tanpa library eksternal
/// menggunakan NotificationListener + LayoutBuilder trick
class VisibilityDetectorCompat extends StatefulWidget {
  final Widget child;
  final VoidCallback onVisible;

  const VisibilityDetectorCompat({
    super.key,
    required this.child,
    required this.onVisible,
  });

  @override
  State<VisibilityDetectorCompat> createState() =>
      _VisibilityDetectorCompatState();
}

class _VisibilityDetectorCompatState extends State<VisibilityDetectorCompat> {
  bool _notified = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Trigger check on scroll
        if (mounted) {
          final ctx = context;
          WidgetsBinding.instance.addPostFrameCallback((_) => _check(ctx));
        }
        return false;
      },
      child: Builder(
        builder: (ctx) {
          // Schedule post-frame check for initial visibility
          WidgetsBinding.instance.addPostFrameCallback((_) => _check(ctx));
          return widget.child;
        },
      ),
    );
  }

  void _check(BuildContext ctx) {
    if (_notified || !mounted) return;
    final renderObj = ctx.findRenderObject();
    if (renderObj == null) return;

    try {
      final viewport = RenderAbstractViewport.of(renderObj);
      if (viewport == null) return;
      final reveal = viewport.getOffsetToReveal(renderObj, 0.0);
      final scrollable = Scrollable.of(ctx);
      if (scrollable == null) return;
      final offset = scrollable.position.pixels;
      final viewportH = scrollable.position.viewportDimension;

      // Check if the top of the object is within 92% of the viewport
      if (reveal.offset < offset + viewportH * 0.92) {
        _notified = true;
        widget.onVisible();
      }
    } catch (e) {
      // Catch potential errors if the render object is not in a viewport
      // This can happen during transitions or complex layouts.
    }
  }
}

// ──────────────────────────────────────────────────────
//  Simpler approach: use ScrollController globally
// ──────────────────────────────────────────────────────
// Re-implement _RevealOnScroll using GlobalKey + scroll listener

class RevealWrapper extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Offset slideFrom;

  const RevealWrapper({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.slideFrom = const Offset(0, 50),
  });

  @override
  State<RevealWrapper> createState() => RevealWrapperState();
}

class RevealWrapperState extends State<RevealWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  final GlobalKey _key = GlobalKey();
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: widget.slideFrom, end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Check on first frame (item might already be visible)
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void checkFromScroll() => _checkVisibility();

  void _checkVisibility() {
    if (_triggered || !mounted) return;
    final ctx = _key.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final pos    = box.localToGlobal(Offset.zero);
    final size   = MediaQuery.of(ctx).size;
    if (pos.dy < size.height * 0.95) {
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
      key: _key,
      builder: (_, child) => FadeTransition(
        opacity: _fade,
        child: Transform.translate(offset: _slide.value, child: child),
      ),
      child: widget.child,
    );
  }
}

// ──────────────────────────────────────────────────────
//  APP
// ──────────────────────────────────────────────────────
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

// ──────────────────────────────────────────────────────
//  HOME PAGE
// ──────────────────────────────────────────────────────
class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> with TickerProviderStateMixin {
  late final AnimationController _heroCtrl;
  late final AnimationController _floatCtrl;
  late final Animation<double>   _heroFade;
  late final Animation<Offset>   _heroSlide;
  late final Animation<double>   _float;

  final ScrollController _scrollCtrl = ScrollController();

  // Keys untuk setiap section reveal
  final List<GlobalKey<RevealWrapperState>> _revealKeys = List.generate(
    20,
        (_) => GlobalKey<RevealWrapperState>(),
  );

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, -.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));
    _float = Tween<double>(begin: -8, end: 8)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _heroCtrl.forward();

    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    for (final k in _revealKeys) {
      k.currentState?.checkFromScroll();
    }
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _floatCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Widget _reveal(int idx, Widget child, {
    Duration delay = Duration.zero,
    Offset from = const Offset(0, 50),
  }) {
    return RevealWrapper(
      key: _revealKeys[idx],
      delay: delay,
      slideFrom: from,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollCtrl,
        child: Column(
          children: [
            // ── HERO (langsung tampil, tidak pakai reveal) ──
            _HeroSection(
              fade: _heroFade,
              slide: _heroSlide,
              float: _float,
            ),

            // ── BRAND (dengan video background) ──
            _reveal(0, const _BrandSection()),

            // ── MENU ──
            _reveal(1, const _MenuSection()),

            // ── BLIND FLAVOUR ──
            _reveal(2, const _BlindSection()),

            // ── TEAM ──
            _reveal(3, const _TeamSection()),

            // ── FOOTER ──
            _reveal(4, const _Footer()),
          ],
        ),
      ),
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

  const _HeroSection({
    required this.fade,
    required this.slide,
    required this.float,
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
            Color(0xFF1A0A03),
            Color(0xFF3B1F0E),
            Color(0xFF7A3B10),
            Color(0xFFC97B3A),
          ],
          stops: [0, .3, .7, 1],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: C.caramel.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 40, left: -80,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: C.warm.withOpacity(0.06),
              ),
            ),
          ),

          // Stars
          ..._buildStars(),

          // Main content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 60),
            child: FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: slide,
                child: Column(
                  children: [
                    // Floating logo
                    AnimatedBuilder(
                      animation: float,
                      builder: (_, __) => Transform.translate(
                        offset: Offset(0, float.value),
                        child: const _Logo3D(),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Brand name
                    ShaderMask(
                      shaderCallback: (b) => const LinearGradient(
                        colors: [
                          Color(0xFFFAF3E8),
                          Color(0xFFEFA96A),
                          Color(0xFFFAF3E8),
                        ],
                      ).createShader(b),
                      child: const Text(
                        'TWINS ROLL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 6,
                          fontFamily: 'Georgia',
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 20,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Decorative divider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 40, height: 1, color: C.warm.withOpacity(.5)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('✦', style: TextStyle(color: C.gold, fontSize: 14)),
                        ),
                        Container(width: 40, height: 1, color: C.warm.withOpacity(.5)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Slogan
                    const Text(
                      'Kulit alami, sensasi di setiap gigitan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: C.peach,
                        letterSpacing: .5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description card
                    Container(
                      constraints: const BoxConstraints(maxWidth: 520),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: C.warm.withOpacity(.25), width: 1,
                        ),
                      ),
                      child: const Text(
                        'Risol dengan kulit alami yang renyah dipadukan dengan isian lumer yang lezat. '
                            'Mengusung konsep Blind Flavour — setiap varian menghadirkan kejutan rasa '
                            'manis maupun gurih yang siap memanjakan setiap gigitanmu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFFF0DCCC),
                          height: 1.85,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    _GlowButton(label: '🍴  Lihat Menu Kami', onTap: () {}),
                  ],
                ),
              ),
            ),
          ),

          // Scallop bottom
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: ClipPath(
              clipper: _ScallopClipper(),
              child: Container(height: 48, color: C.cream),
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

// ─── 3D LOGO ──────────────────────────────────────────
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
                color: C.warm.withOpacity(.18),
                blurRadius: 50, spreadRadius: 18,
              ),
            ],
          ),
        ),
        Container(
          width: 148, height: 148,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: C.warm.withOpacity(.15), width: 2),
          ),
        ),
        Container(
          width: 134, height: 134,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: C.gold.withOpacity(.3), width: 1.5),
          ),
        ),
        Container(
          width: 120, height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD4B896),
            border: Border.all(color: C.gold, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.5),
                blurRadius: 28, offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: C.warm.withOpacity(.7),
                blurRadius: 18, spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFD4B896),
                child: const Center(
                  child: Text(
                    'T',
                    style: TextStyle(
                      fontSize: 36, fontWeight: FontWeight.w900,
                      color: C.brown, fontFamily: 'Georgia',
                    ),
                  ),
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
                    Colors.white.withOpacity(.3),
                    Colors.transparent,
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

// ─── GLOW BUTTON ──────────────────────────────────────
class _GlowButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _GlowButton({required this.label, required this.onTap});

  @override
  State<_GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<_GlowButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:  (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEFA96A), Color(0xFFC97B3A)],
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: _pressed
              ? []
              : [
            BoxShadow(
              color: C.warm.withOpacity(.6),
              blurRadius: 20, offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: C.brown.withOpacity(.2),
              blurRadius: 8, offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          widget.label,
          style: const TextStyle(
            color: C.brown,
            fontWeight: FontWeight.w900,
            fontSize: 15,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

// ─── STAR & SCALLOP ───────────────────────────────────
class _Star extends StatelessWidget {
  final double size, delay;
  const _Star({required this.size, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Text(
      '✦',
      style: TextStyle(fontSize: size, color: C.warm.withOpacity(.65)),
    );
  }
}

class _ScallopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final p = Path();
    final w = s.width / 9;
    p.moveTo(0, s.height);
    for (int i = 0; i < 9; i++) {
      p.quadraticBezierTo(w * i + w / 2, 0, w * (i + 1), s.height);
    }
    p.lineTo(s.width, s.height);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(_) => false;
}

// ══════════════════════════════════════════════════════
//  BRAND SECTION — VIDEO BACKGROUND CINEMATIC
// ══════════════════════════════════════════════════════
class _BrandSection extends StatefulWidget {
  const _BrandSection();

  @override
  State<_BrandSection> createState() => _BrandSectionState();
}

class _BrandSectionState extends State<_BrandSection> {
  late VideoPlayerController _videoCtrl;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    // Ganti 'assets/brand_cinematic.mp4' dengan nama file video kamu
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
  void dispose() {
    _videoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // ── Video Background ──────────────────────────
        if (_videoReady)
          AspectRatio(
            aspectRatio: _videoCtrl.value.aspectRatio,
            child: VideoPlayer(_videoCtrl),
          )
        else
          Container(
            height: 520,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3B1F0E), Color(0xFF7A3B10)],
              ),
            ),
          ),

        // ── Cinematic overlay (gelap + grain feel) ───
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1A0A03).withOpacity(0.60),
                  const Color(0xFF2A1208).withOpacity(0.72),
                  const Color(0xFF1A0A03).withOpacity(0.88),
                ],
              ),
            ),
          ),
        ),

        // ── Konten ───────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 72, 24, 72),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label
              const _SectionLabel('Brand Identity', light: true),
              const SizedBox(height: 8),

              // Title dengan gradient gold
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [C.cream, C.gold, C.peach],
                ).createShader(b),
                child: const Text(
                  'Mengenal Twins Roll',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Accent line gold
              Container(
                width: 60, height: 3,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [C.gold, C.warm]),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 48),

              // Info cards — semi-transparan di atas video
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: const [
                  _BrandCard(
                    icon: '🏷️',
                    label: 'Nama Brand',
                    body: 'Twins Roll\nDua varian rasa dalam satu identitas khas.',
                  ),
                  _BrandCard(
                    icon: '✨',
                    label: 'Slogan',
                    body: '"Kulit alami,\nsensasi di setiap gigitan"',
                  ),
                  _BrandCard(
                    icon: '🎯',
                    label: 'Konsep',
                    body: 'Blind Flavour — kejutan rasa di setiap gigitan.',
                  ),
                  _BrandCard(
                    icon: '📍',
                    label: 'Lokasi',
                    body: 'Jl. Maospati – Bar. No.358-360\nMaospati, Magetan',
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Letterbox bars (efek sinematik) ──────────
        Positioned(
          top: 0, left: 0, right: 0,
          child: Container(height: 18, color: Colors.black.withOpacity(.55)),
        ),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(height: 18, color: Colors.black.withOpacity(.55)),
        ),
      ],
    );
  }
}

// ─── BRAND CARD (dark mode, di atas video) ────────────
class _BrandCard extends StatelessWidget {
  final String icon, label, body;

  const _BrandCard({
    required this.icon,
    required this.label,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 185,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.09),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: C.warm.withOpacity(.28), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 24, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: C.warm.withOpacity(.15),
              shape: BoxShape.circle,
              border: Border.all(color: C.warm.withOpacity(.3), width: 1),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 12),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w900,
              color: C.gold, letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5, color: C.peach, height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  MENU SECTION
// ══════════════════════════════════════════════════════
class _MenuSection extends StatelessWidget {
  const _MenuSection();

  static const _sweet = [
    _MenuItem('🍠', 'Ubi Coklat',    'Ubi ungu lembut berpadu coklat leleh yang kaya rasa.'),
    _MenuItem('🍌', 'Coklat Pisang', 'Pisang manis dan coklat premium dalam kulit renyah.'),
    _MenuItem('🧀', 'Jasuke Mozza',  'Jagung, susu & keju mozzarella leleh yang gurih-manis.'),
  ];

  static const _savory = [
    _MenuItem('🐔', 'Ayam Suwir Kemangi',   'Ayam suwir harum kemangi dalam kulit hijau alami.'),
    _MenuItem('🍕', 'Pizza Roll',            'Saus tomat, keju & topping pizza dalam risol renyah.'),
    _MenuItem('🌶️', 'Korean Spicy Chicken', 'Ayam pedas ala Korea dengan bumbu gochujang khas.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [C.cream, Color(0xFFF0D8C4)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 72),
      child: Column(
        children: [
          const _SectionLabel('Menu Produk'),
          const SizedBox(height: 8),
          const _SectionTitle('Varian Pilihan'),
          const SizedBox(height: 12),
          _AccentLine(),
          const SizedBox(height: 44),

          // Sweet variant label
          _VLabel('🍫  Sweet Variant', C.caramel),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20, runSpacing: 20,
            alignment: WrapAlignment.center,
            children: _sweet.map((m) => _MenuCard(item: m, savory: false)).toList(),
          ),

          const SizedBox(height: 44),

          // Savory variant label
          _VLabel('🌿  Savory Variant', C.green),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20, runSpacing: 20,
            alignment: WrapAlignment.center,
            children: _savory.map((m) => _MenuCard(item: m, savory: true)).toList(),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final String emoji, name, desc;
  const _MenuItem(this.emoji, this.name, this.desc);
}

class _MenuCard extends StatefulWidget {
  final _MenuItem item;
  final bool savory;
  const _MenuCard({required this.item, required this.savory});

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit:  (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.translationValues(0, _hov ? -10 : 0, 0),
        width: 220,
        decoration: BoxDecoration(
          color: C.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: C.brown.withOpacity(_hov ? .18 : .09),
              blurRadius: _hov ? 40 : 18,
              offset: const Offset(0, 8),
            ),
            if (_hov)
              BoxShadow(
                color: (widget.savory ? C.green : C.caramel).withOpacity(.12),
                blurRadius: 24, offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.savory
                      ? [const Color(0xFFB8DFB9), C.green]
                      : [C.peach, const Color(0xFFD4834A)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -20, right: -20,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(.08),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(widget.item.emoji,
                        style: const TextStyle(fontSize: 56)),
                  ),
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(22)),
                        color: widget.savory ? C.green : C.caramel,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name,
                    style: const TextStyle(
                      fontFamily: 'Georgia', fontSize: 14,
                      fontWeight: FontWeight.bold, color: C.brown,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.item.desc,
                    style: const TextStyle(
                      fontSize: 12, color: Color(0xFF7A5C3C), height: 1.5,
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
}

class _VLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _VLabel(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(.75)]),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(.3),
                blurRadius: 10, offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w900,
              fontSize: 13, letterSpacing: .5,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [C.peach, C.peach.withOpacity(0)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════
//  BLIND FLAVOUR SECTION
// ══════════════════════════════════════════════════════
class _BlindSection extends StatelessWidget {
  const _BlindSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A0A03),
            Color(0xFF3B1F0E),
            Color(0xFF6A2E08),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: C.warm.withOpacity(.12),
              border: Border.all(color: C.warm.withOpacity(.3), width: 1.5),
            ),
            child: const Center(
              child: Text('🎰', style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 20),

          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [C.peach, C.warm, C.peach],
            ).createShader(b),
            child: const Text(
              'Blind Flavour Experience',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Georgia', fontSize: 30,
                fontWeight: FontWeight.bold, color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: const Text(
              'Setiap gigitan adalah kejutan. Pilih varian favoritmu atau coba '
                  'peruntunganmu dengan konsep Blind Flavour khas Twins Roll!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: C.peach, height: 1.75),
            ),
          ),
          const SizedBox(height: 36),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: C.gold, width: 2),
              gradient: LinearGradient(
                colors: [C.warm.withOpacity(.06), C.caramel.withOpacity(.06)],
              ),
              boxShadow: [
                BoxShadow(color: C.warm.withOpacity(.15), blurRadius: 20),
              ],
            ),
            child: const Text(
              'BLIND FLAVOUR',
              style: TextStyle(
                fontFamily: 'Georgia', fontSize: 24,
                fontWeight: FontWeight.bold, color: C.gold, letterSpacing: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  TEAM SECTION — 3 Anggota
// ══════════════════════════════════════════════════════
class _TeamSection extends StatelessWidget {
  const _TeamSection();

  static const _members = [
    _TeamMember(name: 'Nama Anggota 1', role: 'Ketua',   nim: 'NIM / Kelas', emoji: '👤', num: 1),
    _TeamMember(name: 'Nama Anggota 2', role: 'Anggota', nim: 'NIM / Kelas', emoji: '👤', num: 2),
    _TeamMember(name: 'Nama Anggota 3', role: 'Anggota', nim: 'NIM / Kelas', emoji: '👤', num: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.cream,
      padding: const EdgeInsets.fromLTRB(24, 72, 24, 72),
      child: Column(
        children: [
          const _SectionLabel('Tim Penyusun'),
          const SizedBox(height: 8),
          const _SectionTitle('Kelompok Kami'),
          const SizedBox(height: 12),
          _AccentLine(),
          const SizedBox(height: 50),
          Wrap(
            spacing: 28, runSpacing: 28,
            alignment: WrapAlignment.center,
            children: _members.map((m) => _TeamCard(member: m)).toList(),
          ),
        ],
      ),
    );
  }
}

class _TeamMember {
  final String name, role, nim, emoji;
  final int num;
  const _TeamMember({
    required this.name, required this.role,
    required this.nim, required this.emoji, required this.num,
  });
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
            color: _hov ? C.peach : C.peach.withOpacity(.6), width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: C.brown.withOpacity(_hov ? .16 : .08),
              blurRadius: _hov ? 36 : 18, offset: const Offset(0, 8),
            ),
            if (_hov)
              BoxShadow(color: _badge.withOpacity(.1), blurRadius: 20),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                // Avatar
                Container(
                  width: 82, height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [C.warm, _badge],
                    ),
                    border: Border.all(color: C.peach, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: _badge.withOpacity(.3),
                        blurRadius: 14, offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.member.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_badge, _badge.withOpacity(.8)],
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: _badge.withOpacity(.25),
                        blurRadius: 8, offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.member.role.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white, fontSize: 10,
                      fontWeight: FontWeight.w900, letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  widget.member.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Georgia', fontSize: 14,
                    fontWeight: FontWeight.bold, color: C.brown,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.member.nim,
                  style: const TextStyle(fontSize: 12, color: Color(0xFFA07850)),
                ),
              ],
            ),

            // Number badge floating
            Positioned(
              top: -68, left: 0, right: 0,
              child: Center(
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [C.warm, C.caramel]),
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: C.warm.withOpacity(.5),
                        blurRadius: 10, offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${widget.member.num}',
                      style: const TextStyle(
                        color: C.brown,
                        fontWeight: FontWeight.w900, fontSize: 14,
                      ),
                    ),
                  ),
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
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [C.cream, C.warm],
            ).createShader(b),
            child: const Text(
              'Twins Roll',
              style: TextStyle(
                fontFamily: 'Georgia', fontSize: 28,
                fontWeight: FontWeight.bold, color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'SINCE 2026',
            style: TextStyle(fontSize: 10, letterSpacing: 4, color: C.caramel),
          ),
          const SizedBox(height: 24),

          // Divider
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, C.caramel],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: C.caramel,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [C.caramel, Colors.transparent],
                    ),
                  ),
                ),
              ),
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
                  style: TextStyle(fontSize: 12.5, color: C.peach),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone, color: C.warm, size: 16),
              SizedBox(width: 8),
              Text(
                '081 216 363 561',
                style: TextStyle(
                  fontSize: 12.5, color: C.warm, fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Order button
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [C.warm, C.caramel]),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: C.warm.withOpacity(.4),
                  blurRadius: 16, offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: C.brown,
                padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text(
                'ORDER NOW!',
                style: TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),
          Container(height: 1, color: const Color(0xFF3A2010)),
          const SizedBox(height: 16),
          const Text(
            '© 2026 Twins Roll. All rights reserved.',
            style: TextStyle(fontSize: 11, color: Color(0xFF6B4020)),
          ),
        ],
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
        fontSize: 11, fontWeight: FontWeight.w900,
        color: light ? C.warm : C.caramel,
        letterSpacing: 3,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'Georgia', fontSize: 32,
        fontWeight: FontWeight.bold, color: C.brown,
      ),
    );
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