import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const TwinsRollApp());

// ─── COLORS ───────────────────────────────────────────
// REVISI: Kontras ditingkatkan, tone lebih smooth & harmonis
class C {
  // Background & surface
  static const cream    = Color(0xFFFDF6EE);  // sedikit lebih putih, lebih bersih
  static const surface  = Color(0xFFF5E6D6);  // menggantikan peach utk surface cards

  // Brand colors — lebih gelap agar teks di atasnya kontras
  static const brown    = Color(0xFF2C1608);  // lebih gelap dari 0xFF3B1F0E → WCAG AA
  static const caramel  = Color(0xFFB86A28);  // sedikit lebih gelap agar kontras di bg cream
  static const warm     = Color(0xFFD4733A);  // lebih jenuh, tetap hangat

  // Accent & highlight
  static const gold     = Color(0xFFC9952E);  // sedikit lebih gelap dari D4A853, WCAG AA di dark bg
  static const peach    = Color(0xFFF2C5A0);  // tetap, hanya dipakai sbg teks di dark bg
  static const pinkSoft = Color(0xFFF0CFC0);  // soft, tetap

  // Semantic
  static const green    = Color(0xFF3A6B3E);  // lebih gelap → kontras lebih baik
  static const white    = Colors.white;
  static const dark1    = Color(0xFF1E0C04);  // footer bg, lebih gelap dr 2A1208
  static const darkBg   = Color(0xFF251008);  // hero/blind bg atas

  // Teks di atas cream/light bg — pakai brown atau di bawah ini
  static const textMuted = Color(0xFF6B4728); // menggantikan 0xFF7A5C3C dan 0xFFA07850
  static const textSub   = Color(0xFF9C6A40); // untuk subtitle/keterangan
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
        if (mounted) {
          final ctx = context;
          WidgetsBinding.instance.addPostFrameCallback((_) => _check(ctx));
        }
        return false;
      },
      child: Builder(
        builder: (ctx) {
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

      if (reveal.offset < offset + viewportH * 0.92) {
        _notified = true;
        widget.onVisible();
      }
    } catch (e) {
      // ignore
    }
  }
}

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
            _HeroSection(
              fade: _heroFade,
              slide: _heroSlide,
              float: _float,
            ),
            _reveal(0, const _BrandSection()),
            _reveal(1, const _FlyingFlyersWidget()),
            _reveal(2, const _MenuSection()),
            _reveal(3, const _BlindSection()),
            _reveal(4, const _TeamSection()),
            _reveal(5, const _Footer()),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  HERO SECTION
// REVISI: Stop gradient lebih smooth, teks pakai warna kontras tinggi
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
        // REVISI: gradient lebih smooth, stop lebih merata
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF120602), // sangat gelap di atas
            Color(0xFF2C1608), // brown gelap
            Color(0xFF6B3010), // mid brown-orange
            Color(0xFFB86A28), // caramel (sama dengan C.caramel)
          ],
          stops: [0, 0.28, 0.65, 1],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles — lebih transparan agar tidak mengganggu teks
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: C.caramel.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 40, left: -80,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: C.warm.withOpacity(0.05),
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

                    // REVISI: judul pakai warna solid cream (bukan gradient) → lebih terbaca
                    const Text(
                      'TWINS ROLL',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFDF6EE), // C.cream, solid — kontras tinggi
                        letterSpacing: 6,
                        fontFamily: 'Georgia',
                        shadows: [
                          Shadow(
                            color: Color(0x99000000),
                            blurRadius: 16,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 40, height: 1, color: C.peach.withOpacity(.6)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          // REVISI: gold lebih gelap, kontras lebih baik
                          child: Text('✦', style: TextStyle(color: C.gold, fontSize: 14)),
                        ),
                        Container(width: 40, height: 1, color: C.peach.withOpacity(.6)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // REVISI: slogan pakai C.peach bukan italic kecil — lebih terbaca
                    const Text(
                      'Kulit alami, sensasi di setiap gigitan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFF2C5A0), // C.peach, kontras cukup di dark bg
                        letterSpacing: .5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // REVISI: card border lebih visible, teks lebih terang
                    Container(
                      constraints: const BoxConstraints(maxWidth: 520),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: C.peach.withOpacity(.35), width: 1,
                        ),
                      ),
                      child: const Text(
                        'Risol dengan kulit alami yang renyah dipadukan dengan isian lumer yang lezat. '
                            'Mengusung konsep Blind Flavour — setiap varian menghadirkan kejutan rasa '
                            'manis maupun gurih yang siap memanjakan setiap gigitanmu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          // REVISI: 0xFFF0DCCC → lebih terang: 0xFFF7E8D8 (kontras lebih baik)
                          color: Color(0xFFF7E8D8),
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

          // Smooth fade ke cream — tanpa lengkungan
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
                    Color(0x55B86A28), // warm semi-transparan
                    Color(0xFFFDF6EE), // C.cream solid
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
                color: C.warm.withOpacity(.14),
                blurRadius: 50, spreadRadius: 18,
              ),
            ],
          ),
        ),
        Container(
          width: 148, height: 148,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: C.warm.withOpacity(.18), width: 2),
          ),
        ),
        Container(
          width: 134, height: 134,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: C.gold.withOpacity(.4), width: 1.5),
          ),
        ),
        Container(
          width: 120, height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // REVISI: bg logo lebih terang agar logo terlihat jelas
            color: const Color(0xFFD8B896),
            border: Border.all(color: C.gold, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.45),
                blurRadius: 28, offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: C.warm.withOpacity(.6),
                blurRadius: 18, spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFD8B896),
                child: const Center(
                  child: Text(
                    'T',
                    style: TextStyle(
                      fontSize: 36, fontWeight: FontWeight.w900,
                      // REVISI: teks fallback pakai C.brown agar kontras di bg terang
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
                    Colors.white.withOpacity(.25),
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
// REVISI: teks button pakai C.brown (gelap) di atas gradient warm → kontras tinggi
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
          // REVISI: gradient lebih terang agar teks coklat gelap kontras
          gradient: const LinearGradient(
            colors: [Color(0xFFF0A060), Color(0xFFD4733A)],
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: _pressed
              ? []
              : [
            BoxShadow(
              color: C.warm.withOpacity(.55),
              blurRadius: 20, offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: C.brown.withOpacity(.25),
              blurRadius: 8, offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          widget.label,
          style: const TextStyle(
            color: Color(0xFF1E0C04), // C.dark1 — paling gelap untuk kontras max
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
      // REVISI: opacity naik sedikit agar bintang lebih visible di dark bg
      style: TextStyle(fontSize: size, color: C.peach.withOpacity(.55)),
    );
  }
}


// ══════════════════════════════════════════════════════
//  BRAND SECTION — VIDEO BACKGROUND CINEMATIC
// REVISI: overlay lebih konsisten, teks brand lebih kontras
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
                // REVISI: fallback bg sedikit lebih terang agar kartu card terlihat
                colors: [Color(0xFF2C1608), Color(0xFF6B3010)],
              ),
            ),
          ),

        // REVISI: overlay lebih konsisten — tidak terlalu gelap di tengah
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC120602), // 80% opacity
                  Color(0xBF1E0C04), // 75% opacity — lebih merata
                  Color(0xCC120602), // 80% opacity
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

              // REVISI: judul brand pakai teks solid, bukan gradient → lebih terbaca
              const Text(
                'Mengenal Twins Roll',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  // C.cream — kontras sangat tinggi di dark overlay
                  color: Color(0xFFFDF6EE),
                ),
              ),
              const SizedBox(height: 14),

              Container(
                width: 60, height: 3,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [C.gold, C.warm]),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 48),

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

        Positioned(
          top: 0, left: 0, right: 0,
          child: Container(height: 18, color: Colors.black.withOpacity(.5)),
        ),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(height: 18, color: Colors.black.withOpacity(.5)),
        ),
      ],
    );
  }
}

// ─── BRAND CARD ───────────────────────────────────────
// REVISI: border lebih visible, teks body pakai warna lebih terang
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
        // REVISI: opacity naik dari .09 → .12 agar card terlihat jelas di video
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          // REVISI: border lebih terang agar card terlihat di video gelap
          color: C.peach.withOpacity(.35), width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.3),
            blurRadius: 24, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: C.warm.withOpacity(.18),
              shape: BoxShape.circle,
              border: Border.all(color: C.warm.withOpacity(.35), width: 1),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 12),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w900,
              // REVISI: gold lebih terang di sini agar kontras di bg gelap
              color: Color(0xFFD4A84A),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              // REVISI: dari C.peach (0xFFF2C5A0) → sedikit lebih terang untuk keterbacaan
              color: Color(0xFFF5D0B0),
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  FLYING FLYERS WIDGET
//  2 selebaran beterbangan seperti kertas di angin
// ══════════════════════════════════════════════════════
class _FlyingFlyersWidget extends StatefulWidget {
  const _FlyingFlyersWidget();

  @override
  State<_FlyingFlyersWidget> createState() => _FlyingFlyersWidgetState();
}

class _FlyingFlyersWidgetState extends State<_FlyingFlyersWidget>
    with TickerProviderStateMixin {
  late AnimationController _ctrl1;
  late AnimationController _ctrl2;
  late AnimationController _starCtrl;

  // Flyer 1 — Sweet, melayang ke kiri atas
  late Animation<Offset> _pos1;
  late Animation<double> _rot1;

  // Flyer 2 — Savory, melayang ke kanan bawah
  late Animation<Offset> _pos2;
  late Animation<double> _rot2;

  // Star twinkle
  late Animation<double> _starOpacity;

  @override
  void initState() {
    super.initState();

    _ctrl1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat(reverse: true);

    _ctrl2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat(reverse: true);

    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _pos1 = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(18, -22)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(18, -22), end: const Offset(8, -10)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(8, -10), end: const Offset(-10, -18)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-10, -18), end: Offset.zero),
        weight: 25,
      ),
    ]).animate(CurvedAnimation(parent: _ctrl1, curve: Curves.easeInOut));

    _rot1 = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: -12.0, end: -6.0),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -6.0, end: -15.0),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -15.0, end: -9.0),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -9.0, end: -12.0),
        weight: 25,
      ),
    ]).animate(CurvedAnimation(parent: _ctrl1, curve: Curves.easeInOut));

    _pos2 = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(-14, -18)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-14, -18), end: const Offset(-6, -26)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-6, -26), end: const Offset(12, -12)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(12, -12), end: Offset.zero),
        weight: 20,
      ),
    ]).animate(CurvedAnimation(parent: _ctrl2, curve: Curves.easeInOut));

    _rot2 = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 10.0, end: 16.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 16.0, end: 8.0),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 8.0, end: 14.0),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 14.0, end: 10.0),
        weight: 20,
      ),
    ]).animate(CurvedAnimation(parent: _ctrl2, curve: Curves.easeInOut));

    _starOpacity = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _starCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    _starCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 420,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [C.cream, Color(0xFFEDD5B8)],
        ),
      ),
      child: Stack(
        children: [
          // ── Bintang dekoratif ──────────────────────
          ..._buildStars(),

          // ── Label tengah ──────────────────────────
          Positioned(
            top: 28,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'SPECIAL OFFER'.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: C.caramel,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pilih Favoritmu!',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: C.brown,
                  ),
                ),
              ],
            ),
          ),

          // ── Flyer 1: Sweet ────────────────────────
          AnimatedBuilder(
            animation: _ctrl1,
            builder: (_, __) {
              return Positioned(
                left: 24 + _pos1.value.dx,
                top: 80 + _pos1.value.dy,
                child: Transform.rotate(
                  angle: _rot1.value * (3.14159 / 180),
                  child: const _FlyerCard(
                    isSweet: true,
                    width: 155,
                  ),
                ),
              );
            },
          ),

          // ── Flyer 2: Savory ───────────────────────
          AnimatedBuilder(
            animation: _ctrl2,
            builder: (_, __) {
              return Positioned(
                right: 24 + (-_pos2.value.dx),
                top: 110 + _pos2.value.dy,
                child: Transform.rotate(
                  angle: _rot2.value * (3.14159 / 180),
                  child: const _FlyerCard(
                    isSweet: false,
                    width: 150,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStars() {
    final positions = [
      const Offset(16, 36),
      const Offset(200, 24),
      const Offset(340, 52),
      const Offset(44, 360),
      const Offset(310, 370),
    ];
    final sizes = [16.0, 11.0, 13.0, 10.0, 14.0];
    final delays = [0, 1, 2, 0, 1]; // index modulus untuk delay feel

    return List.generate(positions.length, (i) {
      return Positioned(
        left: positions[i].dx,
        top: positions[i].dy,
        child: AnimatedBuilder(
          animation: _starOpacity,
          builder: (_, __) {
            // Simulasi delay sederhana dengan offset sinus
            return Opacity(
              opacity: (_starOpacity.value * (0.5 + 0.5 * ((i % 3) / 3)))
                  .clamp(0.2, 1.0),
              child: Text(
                '✦',
                style: TextStyle(
                  fontSize: sizes[i],
                  color: i.isEven ? C.gold : C.caramel,
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

// ══════════════════════════════════════════════════════
//  FLYER CARD — selebaran kertas individual
// ══════════════════════════════════════════════════════
class _FlyerCard extends StatelessWidget {
  final bool isSweet;
  final double width;

  const _FlyerCard({required this.isSweet, required this.width});

  @override
  Widget build(BuildContext context) {
    final topColor  = isSweet ? C.brown      : C.green;
    final accentClr = isSweet ? C.caramel    : const Color(0xFF5A9E5E);
    final bgColor   = isSweet
        ? const Color(0xFFFEF8F0)
        : const Color(0xFFF4FFF4);
    final textClr   = isSweet ? C.brown      : C.green;
    final bottomBg  = isSweet
        ? const Color(0xFFFEF0DC)
        : const Color(0xFFD8F0DC);
    final label     = isSweet ? '🍫  Sweet Variant' : '🌿  Savory Variant';
    final items     = isSweet
        ? ['🍠 Ubi Coklat', '🍌 Coklat Pisang', '🧀 Jasuke Mozza']
        : ['🐔 Ayam Suwir Kemangi', '🍕 Pizza Roll', '🌶️ Korean Spicy'];
    final bottomText = isSweet ? 'Mulai Rp 8.000' : '✦ BLIND FLAVOUR ✦';
    final contact    = isSweet
        ? 'Jl. Maospati – Bar. No.358-360'
        : '📞 081 216 363 561';

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accentClr.withOpacity(.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: C.brown.withOpacity(.25),
            blurRadius: 18,
            offset: const Offset(4, 8),
          ),
          BoxShadow(
            color: topColor.withOpacity(.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Lipatan pojok kanan atas
          Positioned(
            top: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(20, 20),
              painter: _FoldPainter(color: accentClr),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header bar ──────────────────────
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: topColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                ),
                child: Column(
                  children: [
                    // Mini logo circle
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentClr,
                        border: Border.all(
                          color: C.gold.withOpacity(.7),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'TR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontFamily: 'Georgia',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'TWINS ROLL',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFDF6EE),
                        letterSpacing: 2,
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ],
                ),
              ),

              // ── Label variant ────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: topColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),

              // ── Menu items ───────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 9,
                          color: textClr,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ── Scallop separator ────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: CustomPaint(
                  size: Size(width, 12),
                  painter: _ScallopPainter(color: bottomBg),
                ),
              ),

              // ── Bottom info ──────────────────────
              Container(
                color: bottomBg,
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                child: Column(
                  children: [
                    Text(
                      bottomText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: topColor,
                        fontFamily: 'Georgia',
                        letterSpacing: isSweet ? 0 : 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      contact,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 7.5,
                        color: C.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  CUSTOM PAINTERS
// ══════════════════════════════════════════════════════

/// Lipatan pojok kertas (dog-ear)
class _FoldPainter extends CustomPainter {
  final Color color;
  const _FoldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final shadow = Paint()
      ..color = Colors.black.withOpacity(.15)
      ..style = PaintingStyle.fill;
    final fill = Paint()
      ..color = color.withOpacity(.65)
      ..style = PaintingStyle.fill;
    final fold = Paint()
      ..color = color.withOpacity(.4)
      ..style = PaintingStyle.fill;

    // Segitiga lipatan
    final path1 = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path1, fill);

    // Shadow segitiga bawah
    final path2 = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, fold);
  }

  @override
  bool shouldRepaint(_FoldPainter old) => old.color != color;
}

/// Tepian scallop/bergelombang antara konten dan footer
class _ScallopPainter extends CustomPainter {
  final Color color;
  const _ScallopPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    const scallop = 10.0;
    double x = 0;
    bool up = true;
    while (x < size.width) {
      path.quadraticBezierTo(
        x + scallop / 2,
        up ? 0 : size.height,
        x + scallop,
        size.height / 2,
      );
      x += scallop;
      up = !up;
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ScallopPainter old) => old.color != color;
}

// ══════════════════════════════════════════════════════
//  MENU SECTION
// REVISI: bg section lebih clean, teks deskripsi lebih kontras
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
      // REVISI: gradient lebih subtle dan smooth
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
          const _SectionLabel('Menu Produk'),
          const SizedBox(height: 8),
          const _SectionTitle('Varian Pilihan'),
          const SizedBox(height: 12),
          _AccentLine(),
          const SizedBox(height: 44),

          _VLabel('🍫  Sweet Variant', C.caramel),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20, runSpacing: 20,
            alignment: WrapAlignment.center,
            children: _sweet.map((m) => _MenuCard(item: m, savory: false)).toList(),
          ),

          const SizedBox(height: 44),

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
              color: C.brown.withOpacity(_hov ? .16 : .08),
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
                  // REVISI: warna gradient card lebih smooth dan kontras dengan card body putih
                  colors: widget.savory
                      ? [const Color(0xFFA8D4AA), const Color(0xFF3A6B3E)]
                      : [const Color(0xFFF5C5A0), const Color(0xFFB86A28)],
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
                      fontWeight: FontWeight.bold,
                      color: C.brown, // kontras tinggi di white card
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.item.desc,
                    style: const TextStyle(
                      fontSize: 12,
                      // REVISI: C.textMuted (0xFF6B4728) → lebih gelap dari 0xFF7A5C3C
                      color: C.textMuted,
                      height: 1.5,
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [C.surface.withOpacity(0), C.surface],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(.82)],
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: .5,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [C.surface, C.surface.withOpacity(0)],
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
// REVISI: teks body lebih terang, badge text kontras
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
          // REVISI: gradient lebih konsisten dan dalam
          colors: [
            Color(0xFF120602),
            Color(0xFF2C1608),
            Color(0xFF5A2608),
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
              // REVISI: icon bg lebih visible
              color: C.warm.withOpacity(.16),
              border: Border.all(color: C.warm.withOpacity(.38), width: 1.5),
            ),
            child: const Center(
              child: Text('🎰', style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 20),

          // REVISI: judul solid cream — lebih mudah dibaca
          const Text(
            'Blind Flavour Experience',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Georgia', fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFDF6EE), // C.cream
            ),
          ),
          const SizedBox(height: 16),

          Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: const Text(
              'Setiap gigitan adalah kejutan. Pilih varian favoritmu atau coba '
                  'peruntunganmu dengan konsep Blind Flavour khas Twins Roll!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                // REVISI: C.peach solid — kontras cukup baik di dark bg
                color: Color(0xFFF2C5A0),
                height: 1.75,
              ),
            ),
          ),
          const SizedBox(height: 36),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              // REVISI: border gold lebih tebal agar lebih visible
              border: Border.all(color: C.gold, width: 2.5),
              gradient: LinearGradient(
                colors: [C.warm.withOpacity(.08), C.caramel.withOpacity(.08)],
              ),
              boxShadow: [
                BoxShadow(color: C.warm.withOpacity(.18), blurRadius: 20),
              ],
            ),
            child: const Text(
              'BLIND FLAVOUR',
              style: TextStyle(
                fontFamily: 'Georgia', fontSize: 24,
                fontWeight: FontWeight.bold,
                // REVISI: warna text gold lebih terang di dark bg
                color: Color(0xFFD4A84A),
                letterSpacing: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  TEAM SECTION
// REVISI: warna avatar badge lebih konsisten, teks nim lebih terbaca
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
            // REVISI: border hover lebih terlihat
            color: _hov ? C.warm.withOpacity(.5) : C.surface,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: C.brown.withOpacity(_hov ? .14 : .07),
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
                Container(
                  width: 82, height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [C.warm, _badge],
                    ),
                    // REVISI: border avatar pakai surface agar kontras di white card
                    border: Border.all(color: C.surface, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: _badge.withOpacity(.28),
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

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_badge, _badge.withOpacity(.85)],
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
                      color: Colors.white, // putih di badge berwarna — kontras baik
                      fontSize: 10,
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
                  style: const TextStyle(
                    fontSize: 12,
                    // REVISI: C.textSub (0xFF9C6A40) → lebih gelap dari 0xFFA07850
                    color: C.textSub,
                  ),
                ),
              ],
            ),

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
                        color: C.warm.withOpacity(.45),
                        blurRadius: 10, offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${widget.member.num}',
                      style: const TextStyle(
                        // REVISI: teks nomor badge pakai white bukan brown — kontras lebih baik di gradient
                        color: Colors.white,
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
// REVISI: copyright text lebih terbaca, divider lebih subtle
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
          // REVISI: brand name solid cream — kontras tinggi di dark bg
          const Text(
            'Twins Roll',
            style: TextStyle(
              fontFamily: 'Georgia', fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFDF6EE), // C.cream
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'SINCE 2026',
            style: TextStyle(
              fontSize: 10, letterSpacing: 4,
              // REVISI: caramel lebih terang agar terbaca di dark1
              color: Color(0xFFD4733A),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Color(0xFFB86A28)],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFB86A28), // C.caramel
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFB86A28), Colors.transparent],
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
                  // REVISI: C.peach cukup kontras di dark1 bg
                  style: TextStyle(fontSize: 12.5, color: Color(0xFFF2C5A0)),
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
                  fontSize: 12.5,
                  color: C.warm, // warm orange di dark bg — kontras baik
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4733A), Color(0xFFB86A28)],
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: C.warm.withOpacity(.38),
                  blurRadius: 16, offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                // REVISI: teks button putih di atas gradient gelap — kontras lebih baik
                foregroundColor: Colors.white,
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
          // REVISI: copyright text lebih terang — dari 0xFF6B4020 → 0xFF8A5530
          const Text(
            '© 2026 Twins Roll. All rights reserved.',
            style: TextStyle(fontSize: 11, color: Color(0xFF8A5530)),
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
        // REVISI: label light pakai C.warm (lebih kontras di dark bg) bukan caramel
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
        fontWeight: FontWeight.bold,
        color: C.brown, // kontras tinggi di cream bg
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
