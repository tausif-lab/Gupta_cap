import 'package:flutter/material.dart';

class PaymentDetailPage extends StatelessWidget {
  final Map<String, dynamic> request;
  final String userName;

  const PaymentDetailPage({super.key, required this.request, required this.userName});

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF6B6154), fontSize: 14)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: valueColor ?? const Color(0xFF1A3A5C))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cycleStart = DateTime.parse(request['cycleStart']);
final periodEnd = request['periodEnd'] != null
    ? DateTime.parse(request['periodEnd'])
    : DateTime(cycleStart.year, cycleStart.month + 1, cycleStart.day);
final dueDate = DateTime.parse(request['dueDate']);
final requestDate = DateTime.parse(request['createdAt']);
    final penaltyAmount = request['penaltyAmount'] ?? 0;
    final status = request['status'] ?? 'Pending Verification';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3A5C),
        foregroundColor: Colors.white,
        title: const Text('Payment Bill', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
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
              Text(userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A3A5C))),
              Text(request['flat'] ?? '', style: const TextStyle(color: Color(0xFF6B6154), fontSize: 14)),
              const Divider(height: 28),

              Text('Rent Period', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1A3A5C))),
              const SizedBox(height: 8),
              _row('Starting Date', '${cycleStart.day}/${cycleStart.month}/${cycleStart.year}'),
_row('Ending Date', '${periodEnd.day}/${periodEnd.month}/${periodEnd.year}'),
_row('Payment Due Date', '${dueDate.day}/${dueDate.month}/${dueDate.year}'),

              const Divider(height: 28),
              Text('Payment Details', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1A3A5C))),
              const SizedBox(height: 8),
              _row('Monthly Rent', '₹${request['monthlyRent']}'),
              if (penaltyAmount > 0) _row('Penalty', '₹$penaltyAmount', valueColor: Colors.red),
              _row('Total Paid', '₹${request['totalPaid']}', valueColor: const Color(0xFFD4A843)),

              const Divider(height: 28),
              Text('Verification', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1A3A5C))),
              const SizedBox(height: 8),
              _row('Requested On', '${requestDate.day}/${requestDate.month}/${requestDate.year}'),
              _row(
                'Status',
                status,
                valueColor: status == 'Verified' ? Colors.green : (status == 'Rejected' ? Colors.red : Colors.orange),
              ),
            ],
          ),
        ),
      ),
    );
  }
}