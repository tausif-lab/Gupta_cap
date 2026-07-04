import 'package:flutter/material.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _currentIndex = 0;

  List<Widget> get _screens {
    return [
      _HomeScreen(onNavigate: (index) => setState(() => _currentIndex = index)),
      const _PaymentsScreen(),
      const _MaintenanceScreen(),
      const _NoticesScreen(),
      const _LeaseScreen(),
      const _ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3A5C),
        foregroundColor: Colors.white,
        title: Text(_appBarTitle(_currentIndex)),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You have 2 new notices')),
              );
            },
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: SafeArea(child: _screens[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A3A5C),
        unselectedItemColor: const Color(0xFF6B6154),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.payment_outlined), activeIcon: Icon(Icons.payment), label: 'Payments'),
          BottomNavigationBarItem(icon: Icon(Icons.build_outlined), activeIcon: Icon(Icons.build), label: 'Maintenance'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined), activeIcon: Icon(Icons.campaign), label: 'Notices'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description), label: 'Lease'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  String _appBarTitle(int index) {
    switch (index) {
      case 1:
        return 'Payments';
      case 2:
        return 'Maintenance';
      case 3:
        return 'Notices';
      case 4:
        return 'Lease';
      case 5:
        return 'Profile';
      default:
        return 'Home';
    }
  }
}

class _HomeScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const _HomeScreen({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A3A5C), Color(0xFF2E5B84)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hi, Prinshu 👋', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Welcome back to your home dashboard.', style: TextStyle(color: Color(0xFFDDE9F5), fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _InfoChip(icon: Icons.home_outlined, label: 'Room A-203'),
                    const SizedBox(width: 10),
                    _InfoChip(icon: Icons.calendar_today, label: 'Due 10 Jul'),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Rent Due', style: TextStyle(color: Color(0xFFDDE9F5), fontSize: 14)),
                const SizedBox(height: 4),
                const Text('₹8,000', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('Payment Status: Due', style: TextStyle(color: Color(0xFFF9E9B8), fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Recent Notice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A3A5C))),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Color(0xFF1A3A5C).withOpacity(0.06), blurRadius: 10, offset: Offset(0, 3))]),
            child: const Row(
              children: [
                Icon(Icons.campaign_outlined, color: Color(0xFFD4A843)),
                SizedBox(width: 12),
                Expanded(child: Text('Water supply maintenance tomorrow from 10 AM to 2 PM.', style: TextStyle(fontSize: 14, color: Color(0xFF1A3A5C), fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A3A5C))),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              _ActionCard(icon: Icons.payment, title: 'Pay Rent', onTap: () => onNavigate(1)),
              _ActionCard(icon: Icons.build, title: 'Report Issue', onTap: () => onNavigate(2)),
              _ActionCard(icon: Icons.description, title: 'View Lease', onTap: () => onNavigate(4)),
              _ActionCard(icon: Icons.history, title: 'Payment History', onTap: () => onNavigate(1)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentsScreen extends StatelessWidget {
  const _PaymentsScreen();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryCard(title: 'Outstanding Balance', value: '₹8,000', subtitle: 'Next due on 10 July'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.payment_outlined),
              label: const Text('Pay Rent'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4A843), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Payment History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A3A5C))),
          const SizedBox(height: 10),
          _HistoryTile(date: '05 Jul 2026', amount: '₹8,000', status: 'Paid'),
          _HistoryTile(date: '05 Jun 2026', amount: '₹8,000', status: 'Paid'),
          _HistoryTile(date: '05 May 2026', amount: '₹8,000', status: 'Paid'),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_outlined),
            label: const Text('Download Receipt'),
            style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF1A3A5C), side: const BorderSide(color: Color(0xFF1A3A5C)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          ),
        ],
      ),
    );
  }
}

class _MaintenanceScreen extends StatelessWidget {
  const _MaintenanceScreen();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Color(0xFF1A3A5C).withOpacity(0.06), blurRadius: 10, offset: Offset(0, 3))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Report a New Issue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A3A5C))),
                const SizedBox(height: 8),
                const Text('Use this section to report plumbing, electrical, or general maintenance issues.', style: TextStyle(color: Color(0xFF6B6154), fontSize: 14)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Create Request'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A3A5C), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Request Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A3A5C))),
          const SizedBox(height: 10),
          _StatusTile(title: 'Water heater problem', status: 'In Progress', icon: Icons.bolt_outlined),
          _StatusTile(title: 'AC not cooling', status: 'Pending', icon: Icons.ac_unit_outlined),
          _StatusTile(title: 'Door lock repair', status: 'Completed', icon: Icons.lock_outlined),
        ],
      ),
    );
  }
}

class _NoticesScreen extends StatelessWidget {
  const _NoticesScreen();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        _NoticeCard(title: 'Water supply interruption', description: 'Water supply will be interrupted tomorrow between 10 AM and 2 PM.', tag: 'Maintenance'),
        _NoticeCard(title: 'Rent reminder', description: 'Monthly rent for July is due on 10 July.', tag: 'Payment'),
        _NoticeCard(title: 'Building maintenance', description: 'Lift servicing will be done this weekend.', tag: 'Notice'),
        _NoticeCard(title: 'General notice', description: 'Please keep the common area clean and quiet.', tag: 'Community'),
      ],
    );
  }
}

class _LeaseScreen extends StatelessWidget {
  const _LeaseScreen();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryCard(title: 'Lease Start', value: '01 Jan 2025', subtitle: 'Lease End: 31 Dec 2026'),
          const SizedBox(height: 12),
          _SummaryCard(title: 'Monthly Rent', value: '₹8,000', subtitle: 'Security Deposit: ₹16,000'),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Color(0xFF1A3A5C).withOpacity(0.06), blurRadius: 10, offset: Offset(0, 3))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lease Agreement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A3A5C))),
                const SizedBox(height: 8),
                const Text('Download or view your signed lease agreement for reference.', style: TextStyle(color: Color(0xFF6B6154), fontSize: 14)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('View / Download Lease'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4A843), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Color(0xFF1A3A5C).withOpacity(0.06), blurRadius: 10, offset: Offset(0, 3))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A3A5C))),
                const SizedBox(height: 12),
                _DetailTile(icon: Icons.person_outline, title: 'Name', value: 'Prinshu Gupta'),
                _DetailTile(icon: Icons.phone_outlined, title: 'Phone', value: '+91 98765 43210'),
                _DetailTile(icon: Icons.email_outlined, title: 'Email', value: 'prinshu@example.com'),
                _DetailTile(icon: Icons.contacts_outlined, title: 'Emergency Contact', value: 'Ravi Gupta'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.lock_outline),
            label: const Text('Change Password'),
            style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF1A3A5C), side: const BorderSide(color: Color(0xFF1A3A5C)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4A843), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: const Color(0xFF1A3A5C).withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF1A3A5C), size: 24),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A3A5C))),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _SummaryCard({required this.title, required this.value, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF1A3A5C).withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF6B6154))),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A3A5C))),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF6B6154))),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final String date;
  final String amount;
  final String status;

  const _HistoryTile({required this.date, required this.amount, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: const Color(0xFF1A3A5C).withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))]),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_outlined, color: Color(0xFF1A3A5C)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A3A5C))),
                const SizedBox(height: 2),
                Text(amount, style: const TextStyle(fontSize: 13, color: Color(0xFF6B6154))),
              ],
            ),
          ),
          Chip(label: Text(status), backgroundColor: const Color(0xFFE8F6EA), labelStyle: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final String title;
  final String status;
  final IconData icon;

  const _StatusTile({required this.title, required this.status, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: const Color(0xFF1A3A5C).withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))]),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1A3A5C)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A3A5C)))),
          Chip(label: Text(status), backgroundColor: status == 'Completed' ? const Color(0xFFE8F6EA) : status == 'In Progress' ? const Color(0xFFFFF4D6) : const Color(0xFFFDECEC), labelStyle: TextStyle(color: status == 'Completed' ? const Color(0xFF2E7D32) : status == 'In Progress' ? const Color(0xFFB8860B) : const Color(0xFFC62828), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final String title;
  final String description;
  final String tag;

  const _NoticeCard({required this.title, required this.description, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF1A3A5C).withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A3A5C)))),
              Chip(label: Text(tag), backgroundColor: const Color(0xFFF3E8FF), labelStyle: const TextStyle(color: Color(0xFF6A1B9A), fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 13, color: Color(0xFF6B6154))),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1A3A5C)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF6B6154))),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A3A5C))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
