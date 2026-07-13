import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class UserQueriesPage extends StatefulWidget {
  final String userId;
  final String userName;

  const UserQueriesPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserQueriesPage> createState() => _UserQueriesPageState();
}

class _UserQueriesPageState extends State<UserQueriesPage> {
  int _selectedTab = 0;
  bool _isLoading = false;
  bool _isSubmitting = false;
  List<dynamic> _queries = [];

  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchQueries();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchQueries() async {
    setState(() => _isLoading = true);
    try {
      final response = await AuthService().get('/api/query/user/${widget.userId}');

      if (!mounted) return;
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _queries = data['queries'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load queries: $e')),
      );
    }
  }

  Future<void> _submitQuery() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final response = await AuthService().post('/api/query', body: {
        'userId': widget.userId,
        'subject': _subjectController.text.trim(),
        'message': _messageController.text.trim(),
      });

      if (!mounted) return;
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _subjectController.clear();
        _messageController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Query submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isSubmitting = false);
        _fetchQueries();
        setState(() => _selectedTab = 1);
      } else {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to submit query')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to connect to server: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3A5C),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A843),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.question_answer_outlined,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'My Queries',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(width: 20),
              Expanded(
                child: _TabButton(
                  label: 'Submit Query',
                  isSelected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TabButton(
                  label: 'My Queries',
                  isSelected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedTab == 0 ? _buildSubmitForm() : _buildQueriesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.05 * 255).round()),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What do you need help with?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A3A5C),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Describe your issue and we\'ll get back to you.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B6154),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      hintText: 'e.g. Plumbing issue in bathroom',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF7F4EF),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a subject';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Message',
                      hintText: 'Describe your issue in detail...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF7F4EF),
                    ),
                    maxLines: 6,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a message';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitQuery,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3A5C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Submit Query',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
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

  Widget _buildQueriesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_queries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: const Color(0xFF6B6154).withAlpha((0.4 * 255).round()),
            ),
            const SizedBox(height: 16),
            const Text(
              'No queries yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B6154),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Submit your first query above!',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFAA9E90),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchQueries,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _queries.length,
        itemBuilder: (context, index) {
          final query = _queries[index];
          final isResolved = query['status'] == 'resolved';
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.05 * 255).round()),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        query['subject'] ?? 'No subject',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF1A3A5C),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isResolved
                            ? Colors.green.withAlpha((0.1 * 255).round())
                            : Colors.orange.withAlpha((0.1 * 255).round()),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isResolved ? Colors.green : Colors.orange,
                        ),
                      ),
                      child: Text(
                        isResolved ? 'Resolved' : 'Pending',
                        style: TextStyle(
                          color: isResolved ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  query['message'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B6154),
                    height: 1.4,
                  ),
                ),
                if (isResolved && query['adminReply'] != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A3A5C).withAlpha(
                            (0.1 * 255).round(),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.reply_outlined,
                          size: 16,
                          color: Color(0xFF1A3A5C),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Admin Reply',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A3A5C),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              query['adminReply'],
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B6154),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  _formatDate(query['createdAt']),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFAA9E90),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A3A5C) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF1A3A5C),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isSelected ? Colors.white : const Color(0xFF1A3A5C),
            ),
          ),
        ),
      ),
    );
  }
}
