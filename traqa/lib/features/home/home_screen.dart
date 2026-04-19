import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../shared/widgets/futuristic_bg.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/language_provider.dart';

class HomeScreen extends StatefulWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageNotifier>();

    return Scaffold(
      body: FuturisticBackground(child: widget.child),

      // Floating action button — ABOVE nav bar, center
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [TraqaTheme.neonMint, TraqaTheme.neonBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: TraqaTheme.neonMint.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => context.go('/upload'),
          icon: const Icon(Icons.camera_alt_rounded,
            color: TraqaTheme.textInverse, size: 28),
          tooltip: AppStrings.get(lang.state, 'fabTooltip'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: TraqaTheme.bgSurface,
          border: const Border(
            top: BorderSide(color: TraqaTheme.borderFaint, width: 0.5),
          ),
        ),
        child: BottomAppBar(
          color: TraqaTheme.bgSurface,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: AppStrings.get(lang.state, 'tabHistory'),
                index: 0,
                currentIndex: _currentIndex,
                onTap: () {
                  setState(() => _currentIndex = 0);
                  context.go('/history');
                },
              ),
              _NavItem(
                icon: Icons.people_rounded,
                label: AppStrings.get(lang.state, 'tabFamily'),
                index: 1,
                currentIndex: _currentIndex,
                onTap: () {
                  setState(() => _currentIndex = 1);
                  context.go('/family');
                },
              ),
              const SizedBox(width: 64), // Space for FAB
              _NavItem(
                icon: Icons.local_fire_department_rounded,
                label: AppStrings.get(lang.state, 'tabStreak'),
                index: 2,
                currentIndex: _currentIndex,
                onTap: () {
                  setState(() => _currentIndex = 2);
                  context.go('/streak');
                },
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: AppStrings.get(lang.state, 'tabProfile'),
                index: 3,
                currentIndex: _currentIndex,
                onTap: () {
                  setState(() => _currentIndex = 3);
                  context.go('/profile');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, currentIndex;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label,
    required this.index, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active indicator line above icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: isActive ? 24 : 0,
              decoration: BoxDecoration(
                color: TraqaTheme.neonMint,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(height: 4),
            Icon(icon,
              color: isActive ? TraqaTheme.neonMint : TraqaTheme.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.ibmPlexSans(
              fontSize: 10,
              color: isActive ? TraqaTheme.neonMint : TraqaTheme.textTertiary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            )),
          ],
        ),
      ),
    );
  }
}