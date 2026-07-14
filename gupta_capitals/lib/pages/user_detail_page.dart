import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'payment_history_page.dart';


class UserDetailPage extends StatefulWidget {
  final String userId;
  final String userName;

  const UserDetailPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  
  final _formKey = GlobalKey<FormState>();
  final _monthlyRentController = TextEditingController();
  final _penaltyStartDayController = TextEditingController();
  final _penaltyPerDayController = TextEditingController();

  DateTime? _rentStartDate;
  bool _penaltyEnabled = true;
  bool _isLoading = true;
  bool _isSaving = false;

  List<dynamic> _paymentRequests = [];
  bool _isLoadingRequests = true;
  String? _verifyingRequestId;

  @override
  void initState() {
    super.initState();
    _loadRentConfig();
    _loadPaymentRequests();
  }

  Future<void> _loadPaymentRequests() async {
    try {
      final response = await AuthService().get('/api/payment/user-requests/${widget.userId}');

      if (!mounted) return;
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _paymentRequests = data['requests'];
          _isLoadingRequests = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingRequests = false);
    }
  }

  Future<void> _verifyRequest(String requestId) async {
    setState(() => _verifyingRequestId = requestId);
    try {
      final response = await AuthService().post('/api/payment/verify/$requestId');

      if (!mounted) return;
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment verified — cycle restarted')),
        );
        _loadPaymentRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to verify')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _verifyingRequestId = null);
    }
  }



  Future<void> _deleteUser() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete User'),
      content: Text('Are you sure you want to permanently delete ${widget.userName}? This will remove all their data including rent config and payment history.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  try {
  final response = await AuthService().delete('/api/admin/users/${widget.userId}');

  if (!mounted) return;
  final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'User deleted')),
      );
      Navigator.pop(context, true); // Go back to dashboard, signal refresh needed
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Failed to delete user')),
      );
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

  @override
  void dispose() {
    _monthlyRentController.dispose();
    _penaltyStartDayController.dispose();
    _penaltyPerDayController.dispose();
    super.dispose();
  }

  Future<void> _loadRentConfig() async {
    try {
      final response = await AuthService().get('/api/admin/rent/${widget.userId}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _rentStartDate = DateTime.parse(data['rentStartDate']);
          _penaltyStartDayController.text = data['penaltyStartDay'].toString();
          _monthlyRentController.text = data['monthlyRent'].toString();
          _penaltyPerDayController.text = data['penaltyPerDay'].toString();
          _penaltyEnabled = data['penaltyEnabled'];
        });
      }
    } catch (_) {
      // No config yet — blank form is fine
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rentStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rent start date')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final response = await AuthService().post('/api/admin/rent/${widget.userId}', body: {
        'rentStartDate': _rentStartDate!.toIso8601String(),
        'penaltyStartDay': int.parse(_penaltyStartDayController.text.trim()),
        'monthlyRent': double.parse(_monthlyRentController.text.trim()),
        'penaltyPerDay': double.parse(_penaltyPerDayController.text.trim()),
        'penaltyEnabled': _penaltyEnabled,
      });

      if (!mounted) return;
      final data = jsonDecode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Saved')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _rentStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _rentStartDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
  backgroundColor: const Color(0xFF1A3A5C),
  foregroundColor: Colors.white,
  title: Text(widget.userName, style: const TextStyle(fontWeight: FontWeight.w700)),
  actions: [
    IconButton(
      icon: const Icon(Icons.history),
      tooltip: 'Payment History',
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentHistoryPage(
            userId: widget.userId,
            userName: widget.userName,
          ),
        ),
      ),
    ),
    IconButton(
      icon: const Icon(Icons.delete_outline),
      tooltip: 'Delete User',
      onPressed: _deleteUser,
    ),
  ],
),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
           : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPaymentRequestsSection(),
                  const SizedBox(height: 28),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // Rent Start Date
                    const Text('Rent Start Date', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A3A5C))),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD0C9BC), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Color(0xFF1A3A5C)),
                            const SizedBox(width: 12),
                            Text(
                              _rentStartDate == null
                                  ? 'Select start date'
                                  : '${_rentStartDate!.day}/${_rentStartDate!.month}/${_rentStartDate!.year}',
                              style: TextStyle(
                                fontSize: 15,
                                color: _rentStartDate == null ? const Color(0xFF9E9080) : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Monthly Rent
                    const Text('Monthly Rent Amount (₹)', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A3A5C))),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _monthlyRentController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'e.g. 8000',
                        prefixIcon: Icon(Icons.currency_rupee),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),

                    // Penalty Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Enable Penalty', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1A3A5C))),
                        Switch(
                          value: _penaltyEnabled,
                          activeColor: const Color(0xFFD4A843),
                          onChanged: (val) => setState(() => _penaltyEnabled = val),
                        ),
                      ],
                    ),

                    if (_penaltyEnabled) ...[
                      const SizedBox(height: 12),
                      const Text('Penalty Starts After (days)', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A3A5C))),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _penaltyStartDayController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'e.g. 5 days after due date',
                          prefixIcon: Icon(Icons.timer_outlined),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (v) => _penaltyEnabled && (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 18),
                      const Text('Penalty Per Day (₹)', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A3A5C))),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _penaltyPerDayController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'e.g. 50',
                          prefixIcon: Icon(Icons.currency_rupee),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (v) => _penaltyEnabled && (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ],

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveConfig,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A3A5C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          _isSaving ? 'Saving...' : 'Save Rent Configuration',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
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

  Widget _buildPaymentRequestsSection() {
    if (_isLoadingRequests) {
      return const Center(child: CircularProgressIndicator());
    }

    final pending = _paymentRequests.where((r) => r['status'] == 'Pending Verification').toList();

    if (pending.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD0C9BC)),
        ),
        child: const Text('No pending payment requests', style: TextStyle(color: Color(0xFF6B6154))),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pending Payment Requests', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A3A5C))),
        const SizedBox(height: 12),
        ...pending.map((req) {
          final isVerifying = _verifyingRequestId == req['_id'];
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD4A843)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(req['cycleMonthLabel'] ?? '', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1A3A5C))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Text('Pending', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Rent: ₹${req['monthlyRent']}', style: const TextStyle(fontSize: 13, color: Color(0xFF6B6154))),
                if ((req['penaltyAmount'] ?? 0) > 0)
                  Text('Penalty: ₹${req['penaltyAmount']}', style: const TextStyle(fontSize: 13, color: Colors.red)),
                Text('Total Paid: ₹${req['totalPaid']}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFFD4A843))),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isVerifying ? null : () => _verifyRequest(req['_id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3A5C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(isVerifying ? 'Verifying...' : 'Mark as Verified'),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}