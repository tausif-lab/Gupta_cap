import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class UserInfoPage extends StatefulWidget {
  final String userId;
  final String userName;

  const UserInfoPage({super.key, required this.userId, required this.userName});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _rentInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final response = await http
          .get(Uri.parse('${AuthService().baseUrl}/api/user/${widget.userId}'), headers: AuthService().headers)
          .timeout(const Duration(seconds: 8));

      if (!mounted) return;
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _user = data['user'];
          _rentInfo = data['rentInfo'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF6B6154), fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1A3A5C))),
        ],
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1A3A5C))),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3A5C),
        foregroundColor: Colors.white,
        title: Text(widget.userName, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // User info card
                  if (_user != null)
                    _card('Personal Details', [
                      _infoRow('Name', _user!['name'] ?? '-'),
                      _infoRow('Mobile', _user!['mobile'] ?? '-'),
                      _infoRow('Email', _user!['email']?.isNotEmpty == true ? _user!['email'] : 'Not provided'),
                      _infoRow('Floor', _user!['floor'] ?? '-'),
                      _infoRow('Room', _user!['room'] ?? '-'),
                      _infoRow('Room Type', _user!['roomType'] ?? '-'),
                      _infoRow('Payment Status', _user!['paymentStatus'] ?? 'Pending'),
                    ]),

                  // Rent info card
                  if (_rentInfo != null)
                    _card('Rent Details', [
                      _infoRow('Monthly Rent', '₹${_rentInfo!['monthlyRent']}'),
                      _infoRow('Due Date', () {
                        final d = DateTime.parse(_rentInfo!['dueDate']);
                        return '${d.day}/${d.month}/${d.year}';
                      }()),
                      _infoRow(
                        'Days Left to Pay',
                        _rentInfo!['daysLeft'] >= 0
                            ? '${_rentInfo!['daysLeft']} days'
                            : 'Overdue by ${_rentInfo!['daysLeft'].abs()} days',
                      ),
                      if (_rentInfo!['penaltyEnabled'] && (_rentInfo!['penaltyAmount'] ?? 0) > 0) ...[
                        _infoRow('Penalty Amount', '₹${_rentInfo!['penaltyAmount']}'),
                        _infoRow('Total Due', '₹${_rentInfo!['totalDue']}'),
                      ],

                      // Pay by date highlight
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _rentInfo!['daysLeft'] >= 0
                              ? const Color(0xFFD4A843).withOpacity(0.12)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _rentInfo!['daysLeft'] >= 0 ? const Color(0xFFD4A843) : Colors.red,
                          ),
                        ),
                        child: Text(
                          _rentInfo!['daysLeft'] >= 0
                              ? 'Pay ₹${_rentInfo!['monthlyRent']} before ${() { final d = DateTime.parse(_rentInfo!['dueDate']); return '${d.day}/${d.month}/${d.year}'; }()} (${_rentInfo!['daysLeft']} days left)'
                              : 'Payment overdue! Total due: ₹${_rentInfo!['totalDue']}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _rentInfo!['daysLeft'] >= 0 ? const Color(0xFFD4A843) : Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ])
                  else
                    _card('Rent Details', [
                      const Text('No rent configuration set yet. Contact your admin.', style: TextStyle(color: Color(0xFF6B6154))),
                    ]),
                ],
              ),
            ),
    );
  }
}