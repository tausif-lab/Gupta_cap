import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminQueriesPage extends StatefulWidget {
  const AdminQueriesPage({super.key});

  @override
  State<AdminQueriesPage> createState() => _AdminQueriesPageState();
}

class _AdminQueriesPageState extends State<AdminQueriesPage> {
  bool _isLoading = false;
  List<dynamic> _allQueries = [];
  List<dynamic> _filteredQueries = [];
  String _activeFilter = 'all';

  final _replyController = TextEditingController();

  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android)
      return 'http://10.0.2.2:3000';
    return 'http://127.0.0.1:3000';
  }

  @override
  void initState() {
    super.initState();
    _fetchQueries();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _fetchQueries() async {
    setState(() => _isLoading = true);
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/admin/queries'))
          .timeout(const Duration(seconds: 8));

      if (!mounted) return;
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _allQueries = data['queries'];
          _applyFilter();
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

  void _applyFilter() {
    if (_activeFilter == 'all') {
      _filteredQueries = List.from(_allQueries);
    } else {
      _filteredQueries = _allQueries
          .where((q) => q['status'] == _activeFilter)
          .toList();
    }
  }

  Future<void> _resolveQuery(String queryId) async {
    final reply = _replyController.text.trim();
    if (reply.isEmpty) return;

    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/api/admin/queries/$queryId/resolve'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'adminReply': reply}),
          )
          .timeout(const Duration(seconds: 8));

      if (!mounted) return;
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _replyController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Query resolved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchQueries();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to resolve query')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to connect to server: $e')),
      );
    }
  }

  void _showResolveDialog(Map<String, dynamic> query) {
    _replyController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resolve Query'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'From: ${query['userName'] ?? 'Unknown'}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Subject: ${query['subject'] ?? ''}',
              style: const TextStyle(color: Color(0xFF6B6154)),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F4EF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                query['message'] ?? '',
                style: const TextStyle(height: 1.4),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _replyController,
              decoration: InputDecoration(
                labelText: 'Your Reply',
                hintText: 'Type your response...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFF7F4EF),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_replyController.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                _resolveQuery(query['_id']);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A3A5C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Resolve'),
          ),
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
              'User Queries',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _activeFilter == 'all',
                  onTap: () {
                    setState(() {
                      _activeFilter = 'all';
                      _applyFilter();
                    });
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pending',
                  isSelected: _activeFilter == 'pending',
                  onTap: () {
                    setState(() {
                      _activeFilter = 'pending';
                      _applyFilter();
                    });
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Resolved',
                  isSelected: _activeFilter == 'resolved',
                  onTap: () {
                    setState(() {
                      _activeFilter = 'resolved';
                      _applyFilter();
                    });
                  },
                ),
                const Spacer(),
                Text(
                  '${_filteredQueries.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A3A5C),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredQueries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: const Color(0xFF6B6154).withAlpha(
                                (0.4 * 255).round(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No queries found',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B6154),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchQueries,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _filteredQueries.length,
                          itemBuilder: (context, index) {
                            final query = _filteredQueries[index];
                            final isResolved =
                                query['status'] == 'resolved';
                            return GestureDetector(
                              onTap: isResolved
                                  ? null
                                  : () => _showResolveDialog(
                                      Map<String, dynamic>.from(query),
                                    ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(
                                        (0.05 * 255).round(),
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor:
                                              const Color(0xFF1A3A5C),
                                          child: Text(
                                            (query['userName']?[0] ?? 'U')
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                query['userName'] ??
                                                    'Unknown',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: Color(0xFF1A3A5C),
                                                ),
                                              ),
                                              Text(
                                                query['subject'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF6B6154),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isResolved
                                                ? Colors.green.withAlpha(
                                                    (0.1 * 255).round(),
                                                  )
                                                : Colors.orange.withAlpha(
                                                    (0.1 * 255).round(),
                                                  ),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: isResolved
                                                  ? Colors.green
                                                  : Colors.orange,
                                            ),
                                          ),
                                          child: Text(
                                            isResolved
                                                ? 'Resolved'
                                                : 'Pending',
                                            style: TextStyle(
                                              color: isResolved
                                                  ? Colors.green
                                                  : Colors.orange,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      query['message'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF6B6154),
                                        height: 1.4,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (isResolved &&
                                        query['adminReply'] != null) ...[
                                      const SizedBox(height: 10),
                                      const Divider(height: 1),
                                      const SizedBox(height: 10),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1A3A5C)
                                                  .withAlpha(
                                                (0.1 * 255).round(),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.check_circle_outline,
                                              size: 16,
                                              color: Colors.green,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Reply sent',
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
                                    if (!isResolved) ...[
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () => _showResolveDialog(
                                            Map<String, dynamic>.from(query),
                                          ),
                                          icon: const Icon(
                                            Icons.reply_outlined,
                                            size: 16,
                                          ),
                                          label: const Text('Resolve'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF1A3A5C),
                                            foregroundColor: Colors.white,
                                            padding:
                                                const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 6),
                                    Text(
                                      _formatDate(query['createdAt']),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFAA9E90),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A3A5C) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1A3A5C)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color:
                isSelected ? Colors.white : const Color(0xFF1A3A5C),
          ),
        ),
      ),
    );
  }
}
