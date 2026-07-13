import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class PayRentPage extends StatefulWidget {
  final String userId;
  final String userName;

  const PayRentPage({super.key, required this.userId, required this.userName});

  @override
  State<PayRentPage> createState() => _PayRentPageState();
}

class _PayRentPageState extends State<PayRentPage> {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _rentInfo;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _requestSubmitted = false;
  bool _hasPendingRequest = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
    _checkPaymentStatus();
  }

  Future<void> _checkPaymentStatus() async {
    try {
      final response = await AuthService().get('/api/payment/status/${widget.userId}');

      if (!mounted) return;
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _hasPendingRequest = data['hasPendingRequest'] ?? false;
        });
      }
    } catch (_) {
    }
  }

  Future<void> _fetchDetails() async {
    try {
      final response = await AuthService().get('/api/user/${widget.userId}');

      if (!mounted) return;
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final rentInfo = data['rentInfo'];
        setState(() {
          _user = data['user'];
          _rentInfo = rentInfo;
          _isLoading = false;
        });
        if (rentInfo != null && (rentInfo['daysLeft'] ?? 99) <= 2) {
          _sendPaymentReminder();
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendPaymentReminder() async {
    try {
      await AuthService().post('/api/notifications/remind-payment', body: {'userId': widget.userId});
    } catch (_) {
    }
  }

  Future<void> _submitPaymentRequest() async {
    setState(() => _isSubmitting = true);
    try {
      final response = await AuthService().post('/api/payment/request', body: {
  'userId': widget.userId,
  'userName': _user!['name'],
  'mobile': _user!['mobile'],
  'flat': _user!['flat'],
  'monthlyRent': _rentInfo!['monthlyRent'],
  'penaltyAmount': _rentInfo!['penaltyAmount'] ?? 0,
  'totalPaid': _rentInfo!['totalDue'],
  'dueDate': _rentInfo!['dueDate'],
  'cycleStart': _rentInfo!['cycleStart'],
  'periodEnd': _rentInfo!['periodEnd'],
  'cycleMonthLabel': _rentInfo!['cycleMonthLabel'],
});

      if (!mounted) return;
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
  setState(() {
    _requestSubmitted = true;
    _hasPendingRequest = true;
  });
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Payment request submitted for verification')),
  );
} else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to submit')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3A5C),
        foregroundColor: Colors.white,
        title: const Text('Pay Rent', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

   Widget _buildBody() {
    if (_rentInfo == null) {
      return const Center(child: Text('No rent configuration set yet. Contact your admin.'));
    }

    // If a verification request is already pending, show waiting screen instead of the bill
    if (_hasPendingRequest) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_top, color: Colors.orange, size: 50),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your payment is pending verification',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: Color(0xFF1A3A5C)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please wait until the admin confirms your payment.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6B6154), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final int daysLeft = _rentInfo!['daysLeft'];

    // Only show payment option if 2 or fewer days left (including overdue)
    if (daysLeft > 2) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Rent payment will open 2 days before your due date.\nYou have $daysLeft days left.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Color(0xFF6B6154)),
          ),
        ),
      );
    }

    final hasPenalty = (_rentInfo!['penaltyAmount'] ?? 0) > 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Bill card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_user!['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A3A5C))),
                Text('${_user!['floor'] ?? '-'} - Room ${_user!['room'] ?? '-'}', style: const TextStyle(color: Color(0xFF6B6154), fontSize: 14)),
                const Divider(height: 24),
                const SizedBox(height: 6),
                Text('Rent for: ${_rentInfo!['cycleMonthLabel']}', style: const TextStyle(color: Color(0xFFD4A843), fontWeight: FontWeight.w700, fontSize: 13)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Monthly Rent'),
                    Text('₹${_rentInfo!['monthlyRent']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
                if (hasPenalty) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Penalty', style: TextStyle(color: Colors.red)),
                      Text('₹${_rentInfo!['penaltyAmount']}', style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.red)),
                    ],
                  ),
                ],
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    Text(
                      '₹${_rentInfo!['totalDue']}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFFD4A843)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (!_requestSubmitted) ...[
            const Text('Scan & Pay via UPI', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1A3A5C))),
            const SizedBox(height: 16),
            // Hardcoded QR image — place your QR file at assets/images/admin_qr.png
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD0C9BC)),
              ),
              child: Image.asset(
                'assets/images/admin_qr.jpeg',
                width: 220,
                height: 220,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPaymentRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A3A5C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _isSubmitting ? 'Submitting...' : 'I Have Paid — Request Verification',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.green),
              ),
              child: const Column(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green, size: 40),
                  SizedBox(height: 10),
                  Text(
                    'Your payment request has been submitted.\nAdmin will verify shortly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}