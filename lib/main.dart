import 'package:flutter/material.dart';

void main() {
  runApp(const TwinsRollApp());
}

// ─── COLOR PALETTE ────────────────────────────────────────────
class AppColors {
  static const cream = Color(0xFFFAF3E8);
  static const brown = Color(0xFF3B1F0E);
  static const caramel = Color(0xFFC97B3A);
  static const peach = Color(0xFFF4C9A1);
  static const warm = Color(0xFFEFA96A);
  static const green = Color(0xFF4A7C4E);
  static const pinkSoft = Color(0xFFF7D6C8);
  static const white = Colors.white;
}

// ─── APP ──────────────────────────────────────────────────────
class TwinsRollApp extends StatelessWidget {
  const TwinsRollApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twins Roll',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Georgia',
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.caramel),
      ),
      home: const CompanyProfilePage(),
    );
  }
}

// ─── MAIN PAGE ────────────────────────────────────────────────
class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({super.key});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _heroAnimCtrl;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;

  @override
  void initState() {
    super.initState();
    _heroAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _heroFade = CurvedAnimation(parent: _heroAnimCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroAnimCtrl, curve: Curves.easeOut));
    _heroAnimCtrl.forward();
  }

  @override
  void dispose() {
    _heroAnimCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _HeroSection(fade: _heroFade, slide: _heroSlide),
            _BrandIdentitySection(),
            _MenuSection(),
            _BlindFlavourSection(),
            _TeamSection(),
            _FooterSection(),
          ],
        ),
      ),
    );
  }
}

// ─── HERO SECTION ─────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final Animation<double> fade;
  final Animation<Offset> slide;
  const _HeroSection({required this.fade, required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B1F0E),
            Color(0xFF7A3B10),
            Color(0xFFC97B3A),
          ],
        ),
      ),
      child: Stack(
        children: [
          // decorative stars
          const Positioned(top: 40, left: 30, child: _StarDeco(size: 14)),
          const Positioned(top: 80, right: 40, child: _StarDeco(size: 10)),
          const Positioned(top: 160, left: 60, child: _StarDeco(size: 8)),
          const Positioned(top: 200, right: 20, child: _StarDeco(size: 12)),

          // content
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 24),
            child: FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: slide,
                child: Column(
                  children: [
                    // Logo circle
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.caramel,
                        border: Border.all(color: AppColors.warm, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.warm.withOpacity(0.5),
                            blurRadius: 28,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🌀', style: TextStyle(fontSize: 44)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Brand name
                    const Text(
                      'TWINS ROLL',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cream,
                        letterSpacing: 5,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Slogan
                    const Text(
                      '✦ Kulit alami, sensasi di setiap gigitan ✦',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: AppColors.peach,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Description
                    Container(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: const Text(
                        'Risol risol dengan kulit alami yang renyah dipadukan dengan isian lumer yang lezat. '
                            'Mengusung konsep Blind Flavour — setiap varian menghadirkan kejutan rasa '
                            'manis maupun gurih yang siap memanjakan setiap gigitanmu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFFF0DCCC),
                          height: 1.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // CTA Button
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warm,
                        foregroundColor: AppColors.brown,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black38,
                      ),
                      child: const Text(
                        '🍴  Lihat Menu Kami',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
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
              child: Container(height: 40, color: AppColors.cream),
            ),
          ),
        ],
      ),
    );
  }
}

// Scallop shape clipper
class _ScallopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const scallops = 8;
    final w = size.width / scallops;
    path.moveTo(0, size.height);
    for (int i = 0; i < scallops; i++) {
      path.quadraticBezierTo(
        w * i + w / 2,
        0,
        w * (i + 1),
        size.height,
      );
    }
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}

// Star decoration widget
class _StarDeco extends StatelessWidget {
  final double size;
  const _StarDeco({required this.size});

  @override
  Widget build(BuildContext context) {
    return Text(
      '✦',
      style: TextStyle(
        fontSize: size,
        color: AppColors.warm.withOpacity(0.7),
      ),
    );
  }
}

// ─── BRAND IDENTITY SECTION ───────────────────────────────────
class _BrandIdentitySection extends StatelessWidget {
  const _BrandIdentitySection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cream,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Column(
        children: [
          _SectionLabel(label: 'Brand Identity'),
          const SizedBox(height: 6),
          _SectionTitle(title: 'Mengenal Twins Roll'),
          const SizedBox(height: 40),

          // Identity cards
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: const [
              _IdentityCard(icon: '🏷️', label: 'Nama Brand', content: 'Twins Roll\nDua varian rasa dalam satu identitas khas.'),
              _IdentityCard(icon: '✨', label: 'Slogan', content: '"Kulit alami, sensasi di setiap gigitan"'),
              _IdentityCard(icon: '🎯', label: 'Konsep', content: 'Blind Flavour — kejutan rasa di setiap gigitan yang tak terduga.'),
              _IdentityCard(icon: '📍', label: 'Lokasi', content: 'Jl. Maospati – Bar. No.358-360\nMaospati, Magetan'),
            ],
          ),

          const SizedBox(height: 56),
          _SectionLabel(label: 'Warna Khas Produk'),
          const SizedBox(height: 24),

          // Color swatches
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: const [
              _ColorSwatch(color: Color(0xFF3B1F0E), label: 'Coklat Tua'),
              _ColorSwatch(color: Color(0xFFC97B3A), label: 'Karamel'),
              _ColorSwatch(color: Color(0xFFEFA96A), label: 'Warm Orange'),
              _ColorSwatch(color: Color(0xFFF4C9A1), label: 'Peach Lembut'),
              _ColorSwatch(color: Color(0xFFFAF3E8), label: 'Krim Alami'),
              _ColorSwatch(color: Color(0xFF4A7C4E), label: 'Hijau Alami'),
            ],
          ),
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final String icon, label, content;
  const _IdentityCard({required this.icon, required this.label, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.peach, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.brown.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 12),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.caramel,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.brown,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final String label;
  const _ColorSwatch({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.peach, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.brown,
          ),
        ),
      ],
    );
  }
}

// ─── MENU SECTION ─────────────────────────────────────────────
class _MenuSection extends StatelessWidget {
  const _MenuSection();

  static const _sweetItems = [
    _MenuItem(emoji: '🍠', name: 'Ubi Coklat', desc: 'Ubi ungu lembut berpadu coklat leleh yang kaya rasa.'),
    _MenuItem(emoji: '🍌', name: 'Coklat Pisang', desc: 'Pisang manis dan coklat premium dalam kulit renyah.'),
    _MenuItem(emoji: '🧀', name: 'Jasuke Mozza', desc: 'Jagung, susu, dan keju mozzarella leleh yang gurih-manis.'),
  ];

  static const _savoryItems = [
    _MenuItem(emoji: '🐔', name: 'Ayam Suwir Kemangi', desc: 'Ayam suwir harum kemangi dalam kulit hijau alami.'),
    _MenuItem(emoji: '🍕', name: 'Pizza Roll', desc: 'Saus tomat, keju, dan topping pizza dalam risol renyah.'),
    _MenuItem(emoji: '🌶️', name: 'Korean Spicy Chicken', desc: 'Ayam pedas ala Korea dengan bumbu gochujang khas.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.cream, Color(0xFFF7D6C8)],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Column(
        children: [
          _SectionLabel(label: 'Menu Produk'),
          const SizedBox(height: 6),
          _SectionTitle(title: 'Varian Pilihan'),
          const SizedBox(height: 36),

          // Sweet variant label
          _VariantLabel(label: '🍫  Sweet Variant', color: AppColors.caramel),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20, runSpacing: 20,
            alignment: WrapAlignment.center,
            children: _sweetItems.map((m) => _MenuCard(item: m, isSavory: false)).toList(),
          ),

          const SizedBox(height: 40),

          // Savory variant label
          _VariantLabel(label: '🌿  Savory Variant', color: AppColors.green),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20, runSpacing: 20,
            alignment: WrapAlignment.center,
            children: _savoryItems.map((m) => _MenuCard(item: m, isSavory: true)).toList(),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final String emoji, name, desc;
  const _MenuItem({required this.emoji, required this.name, required this.desc});
}

class _MenuCard extends StatefulWidget {
  final _MenuItem item;
  final bool isSavory;
  const _MenuCard({required this.item, required this.isSavory});

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.translationValues(0, _hovered ? -8 : 0, 0),
        width: 220,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border(
            top: BorderSide(
              color: widget.isSavory ? AppColors.green : AppColors.warm,
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.brown.withOpacity(_hovered ? 0.18 : 0.10),
              blurRadius: _hovered ? 40 : 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image area
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  colors: widget.isSavory
                      ? [const Color(0xFFC8E6C9), AppColors.green]
                      : [AppColors.peach, AppColors.warm],
                ),
              ),
              child: Center(
                child: Text(
                  widget.item.emoji,
                  style: const TextStyle(fontSize: 52),
                ),
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
                      color: AppColors.brown,
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

class _VariantLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _VariantLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Container(height: 1, color: AppColors.peach)),
      ],
    );
  }
}

// ─── BLIND FLAVOUR SECTION ────────────────────────────────────
class _BlindFlavourSection extends StatelessWidget {
  const _BlindFlavourSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B1F0E), Color(0xFF7A3B10)],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 24),
      child: Column(
        children: [
          const Text(
            'Blind Flavour Experience',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: const Text(
              'Setiap gigitan adalah kejutan. Pilih varian favoritmu atau coba peruntunganmu '
                  'dengan konsep Blind Flavour khas Twins Roll!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.peach,
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.warm, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'BLIND FLAVOUR',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.warm,
                letterSpacing: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── TEAM SECTION ─────────────────────────────────────────────
class _TeamSection extends StatelessWidget {
  const _TeamSection();

  static const _members = [
    _TeamMember(name: 'Nama Anggota 1', role: 'Ketua', nim: 'NIM / Kelas', emoji: '👤'),
    _TeamMember(name: 'Nama Anggota 2', role: 'Anggota', nim: 'NIM / Kelas', emoji: '👤'),
    _TeamMember(name: 'Nama Anggota 3', role: 'Anggota', nim: 'NIM / Kelas', emoji: '👤'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cream,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Column(
        children: [
          _SectionLabel(label: 'Tim Penyusun'),
          const SizedBox(height: 6),
          _SectionTitle(title: 'Kelompok Kami'),
          const SizedBox(height: 40),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: List.generate(
              _members.length,
                  (i) => _TeamCard(member: _members[i], number: i + 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMember {
  final String name, role, nim, emoji;
  const _TeamMember({required this.name, required this.role, required this.nim, required this.emoji});
}

class _TeamCard extends StatefulWidget {
  final _TeamMember member;
  final int number;
  const _TeamCard({required this.member, required this.number});

  @override
  State<_TeamCard> createState() => _TeamCardState();
}

class _TeamCardState extends State<_TeamCard> {
  bool _hovered = false;

  Color get _badgeColor {
    if (widget.number == 1) return AppColors.brown;
    if (widget.number == 3) return AppColors.green;
    return AppColors.caramel;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.translationValues(0, _hovered ? -8 : 0, 0),
        width: 200,
        padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.peach, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.brown.withOpacity(_hovered ? 0.18 : 0.09),
              blurRadius: _hovered ? 40 : 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                // Avatar
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.warm, AppColors.caramel],
                    ),
                    border: Border.all(color: AppColors.peach, width: 3),
                  ),
                  child: Center(
                    child: Text(widget.member.emoji, style: const TextStyle(fontSize: 30)),
                  ),
                ),
                const SizedBox(height: 14),

                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: _badgeColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    widget.member.role.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Name
                Text(
                  widget.member.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brown,
                  ),
                ),
                const SizedBox(height: 4),

                // NIM
                Text(
                  widget.member.nim,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFFA07850),
                  ),
                ),
              ],
            ),

            // Number badge (top center)
            Positioned(
              top: -50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.warm,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${widget.number}',
                      style: const TextStyle(
                        color: AppColors.brown,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
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

// ─── FOOTER ───────────────────────────────────────────────────
class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.brown,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          // Brand
          const Text(
            'Twins Roll',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'SINCE 2026',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 3,
              color: AppColors.peach,
            ),
          ),
          const SizedBox(height: 20),

          // Info
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: AppColors.warm, size: 16),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Jl. Maospati – Bar. No.358-360, Maospati, Magetan',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: AppColors.peach),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone, color: AppColors.warm, size: 16),
              SizedBox(width: 6),
              Text(
                '081 216 363 561',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.warm,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Order button
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warm,
              foregroundColor: AppColors.brown,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 6,
            ),
            child: const Text(
              'ORDER NOW!',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(color: Color(0xFF5C3A20)),
          const SizedBox(height: 12),
          const Text(
            '© 2026 Twins Roll. All rights reserved.',
            style: TextStyle(fontSize: 11, color: Color(0xFF8B6040)),
          ),
        ],
      ),
    );
  }
}

// ─── SHARED WIDGETS ───────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: AppColors.caramel,
        letterSpacing: 2.5,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'Georgia',
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: AppColors.brown,
      ),
    );
  }
}