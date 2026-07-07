import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TenantDetailPage extends StatefulWidget {
  final String tenantId;
  final String tenantName;

  const TenantDetailPage({
    super.key,
    required this.tenantId,
    required this.tenantName,
  });

  @override
  State<TenantDetailPage> createState() => _TenantDetailPageState();
}

class _TenantDetailPageState extends State<TenantDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _monthlyRentController = TextEditingController();
  final _dueDaysController = TextEditingController();
  final _penaltyStartDayController = TextEditingController();
  final _penaltyPerDayController = TextEditingController();

  DateTime? _rentStartDate;
  bool _penaltyEnabled = true;
  bool _isLoading = true;
  bool _isSaving = false;

  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3000';
    return 'http://127.0.0.1:3000';
  }

  @override
  void initState() {
    super.initState();
    _loadRentConfig();
  }

  @override
  void dispose() {
    _monthlyRentController.dispose();
    _dueDaysController.dispose();
    _penaltyStartDayController.dispose();
    _penaltyPerDayController.dispose();
    super.dispose();
  }

  Future<void> _loadRentConfig() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/admin/rent/${widget.tenantId}'))
          .timeout(const Duration(seconds: 8));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _rentStartDate = DateTime.parse(data['rentStartDate']);
          _dueDaysController.text = data['dueDays'].toString();
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
      final response = await http.post(
        Uri.parse('$_baseUrl/api/admin/rent/${widget.tenantId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'rentStartDate': _rentStartDate!.toIso8601String(),
          'dueDays': int.parse(_dueDaysController.text.trim()),
          'penaltyStartDay': int.parse(_penaltyStartDayController.text.trim()),
          'monthlyRent': double.parse(_monthlyRentController.text.trim()),
          'penaltyPerDay': double.parse(_penaltyPerDayController.text.trim()),
          'penaltyEnabled': _penaltyEnabled,
        }),
      ).timeout(const Duration(seconds: 8));

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
        title: Text(widget.tenantName, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
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

                    // Due Days
                    const Text('Rent Due Days (after start date)', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A3A5C))),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _dueDaysController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'e.g. 10',
                        prefixIcon: Icon(Icons.calendar_month_outlined),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
            ),
    );
  }
}