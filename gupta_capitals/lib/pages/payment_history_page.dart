import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'payment_detail_page.dart';

class PaymentHistoryPage extends StatefulWidget {
  final String userId;
  final String userName;

  const PaymentHistoryPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final response = await AuthService().get('/api/payment/history/${widget.userId}');

      if (!mounted) return;
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _history = data['requests'];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Verified':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3A5C),
        foregroundColor: Colors.white,
        title: const Text(
          'Payment History',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
          ? const Center(child: Text('No payment history yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _history[index];
                final status = item['status'] ?? 'Pending Verification';

                final cycleStart = DateTime.parse(item['cycleStart']);
final periodEnd = item['periodEnd'] != null
    ? DateTime.parse(item['periodEnd'])
    : DateTime(cycleStart.year, cycleStart.month + 1, cycleStart.day);
final requestDate = DateTime.parse(item['createdAt']);

                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentDetailPage(
                        request: item,
                        userName: widget.userName,
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['cycleMonthLabel'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: Color(0xFF1A3A5C),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _statusColor(status)),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: _statusColor(status),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rent period: ${cycleStart.day}/${cycleStart.month}/${cycleStart.year} → ${periodEnd.day}/${periodEnd.month}/${periodEnd.year}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B6154),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Requested on: ${requestDate.day}/${requestDate.month}/${requestDate.year}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B6154),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${item['totalPaid']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Color(0xFFD4A843),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
