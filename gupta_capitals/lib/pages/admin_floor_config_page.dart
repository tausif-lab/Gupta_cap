import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class AdminFloorConfigPage extends StatefulWidget {
  const AdminFloorConfigPage({super.key});

  @override
  State<AdminFloorConfigPage> createState() => _AdminFloorConfigPageState();
}

class _AdminFloorConfigPageState extends State<AdminFloorConfigPage> {
  bool _isLoading = true;
  bool _isSaving = false;
  List<Map<String, dynamic>> _floors = [];

  @override
  void initState() {
    super.initState();
    _fetchConfig();
  }

  Future<void> _fetchConfig() async {
    try {
      final response = await http
          .get(Uri.parse('${AuthService().baseUrl}/api/floor-configs'), headers: AuthService().headers)
          .timeout(const Duration(seconds: 8));

      if (!mounted) return;
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _floors = (data['floors'] as List<dynamic>?)
                  ?.map((f) => Map<String, dynamic>.from(f as Map))
                  .toList() ??
              [];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addFloor() {
    setState(() {
      _floors.add({'floor': '', 'rooms': <Map<String, String>>[]});
    });
  }

  void _removeFloor(int index) {
    setState(() {
      _floors.removeAt(index);
    });
  }

  void _addRoom(int floorIndex) {
    setState(() {
      final rooms = _floors[floorIndex]['rooms'] as List;
      rooms.add({'number': '', 'type': 'Residential'});
    });
  }

  void _removeRoom(int floorIndex, int roomIndex) {
    setState(() {
      final rooms = _floors[floorIndex]['rooms'] as List;
      rooms.removeAt(roomIndex);
    });
  }

  Future<void> _save() async {
    for (final floor in _floors) {
      if ((floor['floor'] as String).trim().isEmpty) {
        _showError('Please fill in all floor names');
        return;
      }
      for (final room in (floor['rooms'] as List)) {
        if ((room['number'] as String).trim().isEmpty) {
          _showError('Please fill in all room numbers');
          return;
        }
      }
    }

    setState(() => _isSaving = true);
    try {
      final response = await http
          .post(
            Uri.parse('${AuthService().baseUrl}/api/floor-configs'),
            headers: AuthService().headers,
            body: jsonEncode({'floors': _floors}),
          )
          .timeout(const Duration(seconds: 8));

      if (!mounted) return;
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Floor config saved successfully'), backgroundColor: Colors.green),
        );
        _fetchConfig();
      } else {
        _showError(data['message'] ?? 'Failed to save');
      }
    } catch (e) {
      _showError('Unable to connect: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3A5C),
        foregroundColor: Colors.white,
        title: const Text('Floor Configuration', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ...List.generate(_floors.length, (i) => _buildFloorCard(i)),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Floor'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A3A5C),
                      side: const BorderSide(color: Color(0xFF1A3A5C)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _addFloor,
                  ),
                  if (_floors.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4A843),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(_isSaving ? 'Saving...' : 'Save Configuration', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildFloorCard(int floorIndex) {
    final floor = _floors[floorIndex];
    final rooms = floor['rooms'] as List;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Floor Name',
                    hintText: 'e.g. Ground Floor',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  controller: TextEditingController(text: floor['floor']),
                  onChanged: (v) => floor['floor'] = v,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeFloor(floorIndex),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(rooms.length, (roomIndex) {
            final room = rooms[roomIndex] as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Room Number',
                        hintText: 'e.g. 1',
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      controller: TextEditingController(text: room['number']),
                      onChanged: (v) => room['number'] = v,
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: room['type'] ?? 'Residential',
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'Residential', child: Text('Residential')),
                      DropdownMenuItem(value: 'Commercial', child: Text('Commercial')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => room['type'] = v);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                    onPressed: () => _removeRoom(floorIndex, roomIndex),
                  ),
                ],
              ),
            );
          }),
          TextButton.icon(
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text('Add Room'),
            onPressed: () => _addRoom(floorIndex),
          ),
        ],
      ),
    );
  }
}
