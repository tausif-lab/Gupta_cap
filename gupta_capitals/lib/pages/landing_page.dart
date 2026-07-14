import 'package:flutter/material.dart';
import '../widgets/custom_widgets.dart'; // Ensure correct relative import to your modular custom widgets file
import 'login_page.dart';
import 'register_page.dart';
import 'admin_login_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      body: ScrollConfiguration(
        behavior: const _NoStretchScrollBehavior(),
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
          // Fixed-size App Header block optimized as a sliver component
          const SliverToBoxAdapter(
            child: _HeroBanner(),
          ),
          
          // Main core content container optimized inside a single static padding box layout
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text(
                  'Everything you need, in one place',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A3A5C),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Feature Container Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A3A5C).withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _FeatureRow(
                        icon: Icons.home_outlined,
                        title: 'Manage Your Home',
                        desc: 'View rent details and flat information easily.',
                      ),
                      Divider(height: 24, color: Color(0xFFF0EAE1)),
                      _FeatureRow(
                        icon: Icons.receipt_long_outlined,
                        title: 'Pay Rent Online',
                        desc: 'Safe and simple monthly rent payments.',
                      ),
                      Divider(height: 24, color: Color(0xFFF0EAE1)),
                      _FeatureRow(
                        icon: Icons.notifications_active_outlined,
                        title: 'Get Reminders',
                        desc: 'Never miss a due date — we remind you on time.',
                      ),
                      Divider(height: 24, color: Color(0xFFF0EAE1)),
                      _FeatureRow(
                        icon: Icons.support_agent_outlined,
                        title: 'Raise Complaints',
                        desc: 'Request repairs or report issues directly.',
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // CTA Controls — Now mapped to use your reusable modular PrimaryButton component!
                PrimaryButton(
                  text: 'Login to Your Account',
                  backgroundColor: const Color(0xFF1A3A5C),
                  onPressed: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  ),
                ),
                const SizedBox(height: 14),
                
                // Outlined Registration action styling wrapper
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A3A5C),
                      side: const BorderSide(color: Color(0xFF1A3A5C), width: 1.8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    ),
                    child: const Text(
                      'New User? Register Here',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                Center(
                  child: TextButton.icon(
                    onPressed: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const AdminLoginPage()),
                    ),
                    icon: const Icon(Icons.admin_panel_settings_outlined, size: 20, color: Color(0xFF6B6154)),
                    label: const Text(
                      'Admin / Owner Login',
                      style: TextStyle(
                        fontSize: 15, 
                        color: Color(0xFF6B6154), 
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                const Center(
                  child: Text(
                    '© 2026 Gupta Capitals. All rights reserved.',
                    style: TextStyle(fontSize: 12, color: Color(0xFFAA9E90)),
                  ),
                ),
              ]),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
class _NoStretchScrollBehavior extends ScrollBehavior {
  const _NoStretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Return child directly — removes both the Android stretch effect
    // and the Material glow effect entirely.
    return child;
  }
}
class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A3A5C), Color(0xFF11253B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, topPadding + 16, 24, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A843),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gupta Capitals', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  Text('Rent Management System', style: TextStyle(color: Color(0xFFB8D4EF), fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Your Home,\nManaged Simply.', 
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.2),
          ),
          const SizedBox(height: 12),
          const Text(
            'Pay rent, raise requests, and stay updated — all from your phone.', 
            style: TextStyle(color: Color(0xFFB8D4EF), fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureRow({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A3A5C).withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1A3A5C), size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A3A5C))),
              const SizedBox(height: 3),
              Text(desc, style: const TextStyle(fontSize: 14, color: Color(0xFF6B6154), height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}