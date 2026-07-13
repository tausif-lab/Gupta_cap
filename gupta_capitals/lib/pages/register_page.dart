import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_widgets.dart';
import 'login_page.dart';
import 'user_dashboard.dart';

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
  String? _selectedFloor;
  String? _selectedRoom;
  bool _isLoading = false;
  bool _isLoadingFloors = true;

  List<dynamic> _floors = [];

  @override
  void initState() {
    super.initState();
    _fetchFloors();
  }

  Future<void> _fetchFloors() async {
    try {
      final response = await AuthService().get('/api/floor-configs', retries: 1);
      if (!mounted) return;
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _floors = data['floors'] ?? [];
          _isLoadingFloors = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingFloors = false);
    }
  }

  List<String> get _floorNames => _floors.map((f) => f['floor'] as String).toList();

  List<dynamic>? get _roomsForSelectedFloor {
    if (_selectedFloor == null) return null;
    final floor = _floors.firstWhere(
      (f) => f['floor'] == _selectedFloor,
      orElse: () => null,
    );
    if (floor == null) return null;
    return (floor['rooms'] as List<dynamic>?)?.cast<Map<String, dynamic>>();
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
                const FieldLabel('Select Floor'),
                DropdownButtonFormField<String>(
                  value: _selectedFloor,
                  isExpanded: true,
                  decoration: _dropdownDecoration(),
                  hint: Text(
                    _isLoadingFloors ? 'Loading floors...' : 'Choose floor',
                    style: const TextStyle(fontSize: 16, color: Color(0xFF9E9080)),
                  ),
                  items: _floorNames.map((f) => DropdownMenuItem(value: f, child: Text(f, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: _isLoadingFloors
                      ? null
                      : (v) => setState(() {
                            _selectedFloor = v;
                            _selectedRoom = null;
                          }),
                  validator: (v) => v == null ? 'Please select a floor' : null,
                ),
                const SizedBox(height: 18),
                const FieldLabel('Select Room / Unit'),
                DropdownButtonFormField<String>(
                  value: _selectedRoom,
                  isExpanded: true,
                  decoration: _dropdownDecoration(),
                  hint: Text(
                    _selectedFloor == null ? 'Select a floor first' : 'Choose room',
                    style: const TextStyle(fontSize: 16, color: Color(0xFF9E9080)),
                  ),
                  items: _roomsForSelectedFloor
                      ?.map((r) => DropdownMenuItem(
                            value: r['number'].toString(),
                            child: Text('Room ${r['number']} — ${r['type']}', overflow: TextOverflow.ellipsis),
                          ))
                      .toList() ?? [],
                  onChanged: _selectedFloor == null ? null : (v) => setState(() => _selectedRoom = v),
                  validator: (v) => v == null ? 'Please select a room' : null,
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
                              final roomInfo = _roomsForSelectedFloor
                                  ?.firstWhere((r) => r['number'].toString() == _selectedRoom);

                              final response = await AuthService().post(
                                '/api/register',
                                body: {
                                  'name': _nameController.text.trim(),
                                  'mobile': _mobileController.text.trim(),
                                  'email': _emailController.text.trim(),
                                  'floor': _selectedFloor,
                                  'room': _selectedRoom,
                                  'roomType': roomInfo?['type'] ?? 'Residential',
                                  'password': _passwordController.text.trim(),
                                },
                              );

                              if (!mounted) return;
                              final data = jsonDecode(response.body);
                              if (response.statusCode == 201) {
                                await AuthService().saveSession(
                                  token: data['token'],
                                  userId: data['user']['id'],
                                  userName: data['user']['name'],
                                  role: 'user',
                                );
                                if (!mounted) return;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UserDashboard(
                                      userId: data['user']['id'],
                                      userName: data['user']['name'],
                                    ),
                                  ),
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
                              if (mounted) setState(() => _isLoading = false);
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

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD0C9BC), width: 1.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD0C9BC), width: 1.5)),
    );
  }
}
