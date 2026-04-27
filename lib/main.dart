import 'package:flutter/material.dart';

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

// ─── APP ──────────────────────────────────────────────
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

// ─── HOME ─────────────────────────────────────────────
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
    _heroSlide = Tween<Offset>(begin: const Offset(0, -.18), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));
    _float = Tween<double>(begin: -8, end: 8)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _heroCtrl.forward();
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(fade: _heroFade, slide: _heroSlide, float: _float),
            const _BrandSection(),
            const _MenuSection(),
            const _BlindSection(),
            const _TeamSection(),
            const _Footer(),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  HERO
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
          // Background decorative circles
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: C.caramel.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: C.warm.withOpacity(0.06),
              ),
            ),
          ),

          // Star sparkles
          ..._stars(),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 60),
            child: FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: slide,
                child: Column(
                  children: [
                    // Animated Logo
                    AnimatedBuilder(
                      animation: float,
                      builder: (_, __) => Transform.translate(
                        offset: Offset(0, float.value),
                        child: const _Logo3D(),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Brand name with gradient
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

                    // Decorative line
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 1,
                          color: C.warm.withOpacity(.5),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '✦',
                            style: TextStyle(color: C.gold, fontSize: 14),
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 1,
                          color: C.warm.withOpacity(.5),
                        ),
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
                        horizontal: 24,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: C.warm.withOpacity(.25),
                          width: 1,
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

                    // CTA Button
                    _GlowButton(label: '🍴  Lihat Menu Kami', onTap: () {}),
                  ],
                ),
              ),
            ),
          ),

          // Scallop bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _ScallopClipper(),
              child: Container(height: 48, color: C.cream),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _stars() => const [
    Positioned(top: 32,  left: 24,  child: _Star(size: 16, delay: 0)),
    Positioned(top: 60,  right: 36, child: _Star(size: 11, delay: .4)),
    Positioned(top: 120, left: 70,  child: _Star(size: 9,  delay: .8)),
    Positioned(top: 160, right: 60, child: _Star(size: 13, delay: .2)),
    Positioned(top: 220, left: 20,  child: _Star(size: 8,  delay: .6)),
    Positioned(top: 250, right: 28, child: _Star(size: 10, delay: 1.0)),
  ];
}

// ─── 3D LOGO WIDGET — menggunakan Image.asset ─────────
class _Logo3D extends StatelessWidget {
  const _Logo3D();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring 3
        Container(
          width: 164,
          height: 164,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: C.warm.withOpacity(.18),
                blurRadius: 50,
                spreadRadius: 18,
              ),
            ],
          ),
        ),
        // Outer glow ring 2
        Container(
          width: 148,
          height: 148,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: C.warm.withOpacity(.15), width: 2),
          ),
        ),
        // Outer glow ring 1
        Container(
          width: 134,
          height: 134,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: C.gold.withOpacity(.3), width: 1.5),
          ),
        ),
        // Main logo circle dengan Image.asset
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD4B896),
            border: Border.all(color: C.gold, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.5),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: C.warm.withOpacity(.7),
                blurRadius: 18,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: C.brown.withOpacity(.25),
                blurRadius: 8,
                offset: const Offset(4, 4),
              ),
              const BoxShadow(
                color: Color(0x55FFFFFF),
                blurRadius: 8,
                offset: Offset(-3, -3),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.cover,
              // Tampilkan placeholder jika gambar gagal dimuat
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFD4B896),
                  child: const Center(
                    child: Text(
                      'T',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: C.brown,
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Top highlight for 3D effect
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 52,
              height: 20,
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
      onTapDown: (_) => setState(() => _pressed = true),
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
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: C.brown.withOpacity(.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
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

// ─── STAR ─────────────────────────────────────────────
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

// ─── SCALLOP ──────────────────────────────────────────
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
//  BRAND IDENTITY
// ══════════════════════════════════════════════════════
class _BrandSection extends StatelessWidget {
  const _BrandSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.cream,
      padding: const EdgeInsets.fromLTRB(24, 72, 24, 64),
      child: Column(
        children: [
          const _Label('Brand Identity'),
          const SizedBox(height: 8),
          const _Title('Mengenal Twins Roll'),
          const SizedBox(height: 12),
          Container(
            width: 60,
            height: 3,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [C.caramel, C.warm]),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 44),

          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: const [
              _ICard(
                icon: '🏷️',
                label: 'Nama Brand',
                body: 'Twins Roll\nDua varian rasa dalam satu identitas khas.',
              ),
              _ICard(
                icon: '✨',
                label: 'Slogan',
                body: '"Kulit alami,\nsensasi di setiap gigitan"',
              ),
              _ICard(
                icon: '🎯',
                label: 'Konsep',
                body: 'Blind Flavour — kejutan rasa di setiap gigitan.',
              ),
              _ICard(
                icon: '📍',
                label: 'Lokasi',
                body: 'Jl. Maospati – Bar. No.358-360\nMaospati, Magetan',
              ),
            ],
          ),

          const SizedBox(height: 60),
          const _Label('Warna Khas Produk'),
          const SizedBox(height: 28),

          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: const [
              _Swatch(color: Color(0xFF3B1F0E), label: 'Coklat Tua'),
              _Swatch(color: Color(0xFFC97B3A), label: 'Karamel'),
              _Swatch(color: Color(0xFFEFA96A), label: 'Warm Orange'),
              _Swatch(color: Color(0xFFF4C9A1), label: 'Peach Lembut'),
              _Swatch(color: Color(0xFFFAF3E8), label: 'Krim Alami'),
              _Swatch(color: Color(0xFF4A7C4E), label: 'Hijau Alami'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ICard extends StatelessWidget {
  final String icon, label, body;

  const _ICard({required this.icon, required this.label, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 185,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: C.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: C.peach, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: C.brown.withOpacity(.07),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          const BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: C.peach.withOpacity(.4),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 12),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: C.caramel,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: C.brown,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  final String label;

  const _Swatch({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: C.peach.withOpacity(.8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: C.brown,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════
//  MENU
// ══════════════════════════════════════════════════════
class _MenuSection extends StatelessWidget {
  const _MenuSection();

  static const _sweet = [
    _MItem('🍠', 'Ubi Coklat',    'Ubi ungu lembut berpadu coklat leleh yang kaya rasa.'),
    _MItem('🍌', 'Coklat Pisang', 'Pisang manis dan coklat premium dalam kulit renyah.'),
    _MItem('🧀', 'Jasuke Mozza',  'Jagung, susu & keju mozzarella leleh yang gurih-manis.'),
  ];

  static const _savory = [
    _MItem('🐔', 'Ayam Suwir Kemangi',   'Ayam suwir harum kemangi dalam kulit hijau alami.'),
    _MItem('🍕', 'Pizza Roll',            'Saus tomat, keju & topping pizza dalam risol renyah.'),
    _MItem('🌶️', 'Korean Spicy Chicken', 'Ayam pedas ala Korea dengan bumbu gochujang khas.'),
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
          const _Label('Menu Produk'),
          const SizedBox(height: 8),
          const _Title('Varian Pilihan'),
          const SizedBox(height: 12),
          Container(
            width: 60,
            height: 3,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [C.caramel, C.warm]),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 44),

          _VLabel('🍫  Sweet Variant', C.caramel),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: _sweet.map((m) => _MCard(item: m, savory: false)).toList(),
          ),

          const SizedBox(height: 44),
          _VLabel('🌿  Savory Variant', C.green),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: _savory.map((m) => _MCard(item: m, savory: true)).toList(),
          ),
        ],
      ),
    );
  }
}

class _MItem {
  final String emoji, name, desc;

  const _MItem(this.emoji, this.name, this.desc);
}

class _MCard extends StatefulWidget {
  final _MItem item;
  final bool savory;

  const _MCard({required this.item, required this.savory});

  @override
  State<_MCard> createState() => _MCardState();
}

class _MCardState extends State<_MCard> {
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
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image area with gradient
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
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(.08),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      widget.item.emoji,
                      style: const TextStyle(fontSize: 56),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                        color: widget.savory ? C.green : C.caramel,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: C.brown,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.item.desc,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7A5C3C),
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
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(.75)]),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(.3),
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
//  BLIND FLAVOUR
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
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: C.warm.withOpacity(.12),
              border: Border.all(color: C.warm.withOpacity(.3), width: 1.5),
            ),
            child: const Center(child: Text('🎰', style: TextStyle(fontSize: 32))),
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
                fontFamily: 'Georgia',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
                fontFamily: 'Georgia',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: C.gold,
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
//  TEAM
// ══════════════════════════════════════════════════════
class _TeamSection extends StatelessWidget {
  const _TeamSection();

  static const _members = [
    _TM('Nama Anggota 1', 'Ketua',   'NIM / Kelas', '👤', 1),
    _TM('Nama Anggota 2', 'Anggota', 'NIM / Kelas', '👤', 2),
    _TM('Nama Anggota 3', 'Anggota', 'NIM / Kelas', '👤', 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.cream,
      padding: const EdgeInsets.fromLTRB(24, 72, 24, 72),
      child: Column(
        children: [
          const _Label('Tim Penyusun'),
          const SizedBox(height: 8),
          const _Title('Kelompok Kami'),
          const SizedBox(height: 12),
          Container(
            width: 60,
            height: 3,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [C.caramel, C.warm]),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 50),
          Wrap(
            spacing: 28,
            runSpacing: 28,
            alignment: WrapAlignment.center,
            children: _members.map((m) => _TCard(m: m)).toList(),
          ),
        ],
      ),
    );
  }
}

class _TM {
  final String name, role, nim, emoji;
  final int num;

  const _TM(this.name, this.role, this.nim, this.emoji, this.num);
}

class _TCard extends StatefulWidget {
  final _TM m;

  const _TCard({required this.m});

  @override
  State<_TCard> createState() => _TCardState();
}

class _TCardState extends State<_TCard> {
  bool _hov = false;

  Color get _badge {
    if (widget.m.num == 1) return C.brown;
    if (widget.m.num == 3) return C.green;
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
            color: _hov ? C.peach : C.peach.withOpacity(.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: C.brown.withOpacity(_hov ? .16 : .08),
              blurRadius: _hov ? 36 : 18,
              offset: const Offset(0, 8),
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
                  width: 82,
                  height: 82,
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
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.m.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Badge
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
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.m.role.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  widget.m.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: C.brown,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.m.nim,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFA07850),
                  ),
                ),
              ],
            ),

            // Number badge floating above
            Positioned(
              top: -68,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [C.warm, C.caramel],
                    ),
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: C.warm.withOpacity(.5),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${widget.m.num}',
                      style: const TextStyle(
                        color: C.brown,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
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
          // Logo text
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [C.cream, C.warm],
            ).createShader(b),
            child: const Text(
              'Twins Roll',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: C.caramel,
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
                  fontSize: 12.5,
                  color: C.warm,
                  fontWeight: FontWeight.w700,
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
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: C.brown,
                padding: const EdgeInsets.symmetric(
                  horizontal: 44,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text(
                'ORDER NOW!',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 2,
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
class _Label extends StatelessWidget {
  final String label;

  const _Label(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: C.caramel,
        letterSpacing: 3,
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String title;

  const _Title(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'Georgia',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: C.brown,
      ),
    );
  }
}