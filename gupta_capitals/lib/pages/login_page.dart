import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_widgets.dart';
import 'register_page.dart';
import 'user_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
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
        title: const Text('User Login', style: TextStyle(fontWeight: FontWeight.w700)),
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
                const SectionTitle(title: 'Welcome Back', sub: 'Login to continue'),
                const SizedBox(height: 32),
                const FieldLabel('Mobile Number or Email'),
                TextFormField(
                  controller: _identifierController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'Enter mobile / email', prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => v == null || v.isEmpty ? 'Please enter your ID' : null,
                ),
                const SizedBox(height: 20),
                const FieldLabel('Password'),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Please enter password' : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot Password?', style: TextStyle(fontSize: 15, color: Color(0xFF1A3A5C), fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  text: _isLoading ? 'Logging in...' : 'Login',
                  onPressed: _isLoading
                      ? () {}
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            try {
                              final response = await AuthService().post(
                                '/api/login',
                                body: {
                                  'identifier': _identifierController.text.trim(),
                                  'password': _passwordController.text.trim(),
                                },
                              );

                              if (!mounted) return;
                              final data = jsonDecode(response.body);
                              if (response.statusCode == 200) {
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
                                  SnackBar(content: Text(data['message'] ?? 'Login failed')),
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
                    const Text("Don't have an account?  ", style: TextStyle(fontSize: 15, color: Color(0xFF6B6154))),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                      child: const Text('Register', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A3A5C), decoration: TextDecoration.underline)),
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
