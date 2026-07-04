import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/custom_widgets.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;
  String? _selectedFlat;
  bool _isLoading = false;

  final List<String> _flats = [
    'Flat 101 – Ground Floor',
    'Flat 102 – Ground Floor',
    'Flat 201 – First Floor',
    'Flat 202 – First Floor',
    'Flat 301 – Second Floor',
    'Flat 302 – Second Floor',
  ];

  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000';
    }
    return 'http://127.0.0.1:5000';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3A5C),
        foregroundColor: Colors.white,
        title: const Text('New Registration', style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const SectionTitle(title: 'Create Your Account', sub: 'Fill in your details below'),
                const SizedBox(height: 28),
                const FieldLabel('Full Name'),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Your full name', prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 18),
                const FieldLabel('Mobile Number'),
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: '10-digit mobile number', prefixIcon: Icon(Icons.phone_outlined)),
                  validator: (v) => v == null || v.length < 10 ? 'Enter valid mobile number' : null,
                ),
                const SizedBox(height: 18),
                const FieldLabel('Email Address (optional)'),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'your@email.com', prefixIcon: Icon(Icons.email_outlined)),
                ),
                const SizedBox(height: 18),
                const FieldLabel('Select Your Flat / Unit'),
                DropdownButtonFormField<String>(
                  value: _selectedFlat,
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD0C9BC), width: 1.5)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD0C9BC), width: 1.5)),
                  ),
                  hint: const Text('Choose your flat', style: TextStyle(fontSize: 16, color: Color(0xFF9E9080))),
                  items: _flats.map((f) => DropdownMenuItem(value: f, child: Text(f, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => setState(() => _selectedFlat = v),
                  validator: (v) => v == null ? 'Please select your flat' : null,
                ),
                const SizedBox(height: 18),
                const FieldLabel('Set Password'),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Minimum 6 characters',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: _isLoading ? 'Registering...' : 'Register Now',
                  backgroundColor: const Color(0xFFD4A843),
                  onPressed: _isLoading
                      ? () {}
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);

                            try {
                              final response = await http
                                  .post(
                                    Uri.parse('$_baseUrl/api/register'),
                                    headers: {'Content-Type': 'application/json'},
                                    body: jsonEncode({
                                      'name': _nameController.text.trim(),
                                      'mobile': _mobileController.text.trim(),
                                      'email': _emailController.text.trim(),
                                      'flat': _selectedFlat,
                                      'password': _passwordController.text.trim(),
                                    }),
                                  )
                                  .timeout(const Duration(seconds: 8));

                              if (!mounted) return;

                              final data = jsonDecode(response.body);
                              if (response.statusCode == 201) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(data['message'] ?? 'Registration successful')),
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginPage()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(data['message'] ?? 'Registration failed')),
                                );
                              }
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Unable to connect to server: $e')),
                              );
                            } finally {
                              if (mounted) {
                                setState(() => _isLoading = false);
                              }
                            }
                          }
                        },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already registered?  ', style: TextStyle(fontSize: 15, color: Color(0xFF6B6154))),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                      child: const Text('Login', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A3A5C), decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}