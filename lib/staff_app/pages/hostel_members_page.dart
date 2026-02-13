import 'package:flutter/material.dart';
import 'package:student_app/staff_app/pages/assign_students_page.dart';
import '../widgets/search_field.dart';
import '../api/api_service.dart';

class HostelMembersPage extends StatefulWidget {
  const HostelMembersPage({super.key});

  @override
  State<HostelMembersPage> createState() => _HostelMembersPageState();
}

class _HostelMembersPageState extends State<HostelMembersPage> {
  // ================= DARK COLORS =================
  static const Color dark1 = Color(0xFF1a1a2e);
  static const Color dark2 = Color(0xFF16213e);
  static const Color dark3 = Color(0xFF0f3460);
  static const Color purpleDark = Color(0xFF533483);
  static const Color neon = Color(0xFF00FFF5);

  // ================= VIEW =================
  String _viewBy = 'Hostel Wise';
  final List<String> _viewOptions = [
    'Hostel Wise',
    'Floor Wise',
    'Room Wise',
    'Batch Wise',
  ];

  // ================= DYNAMIC WISE =================
  List<String> _wiseOptions = [];
  String _selectedWiseValue = '';

  // ================= SEARCH =================
  String _query = '';

  // ================= API STATE =================
  List<Map<String, dynamic>> _allMembers = []; // FULL API DATA

  bool _loading = false;
  String? _error;

  // ================= API CALL =================
  Future<void> _fetchMembers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await ApiService.getHostelMembers(type: 'room', param: '7');
      setState(() {
        _allMembers = data; // 🔥 store full data
        // initial visible list
        _buildWiseOptions(); // build dropdowns from FULL data
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _buildWiseOptions() {
    final Set<String> values = {};

    for (final m in _allMembers) {
      String? v;

      switch (_viewBy) {
        case 'Hostel Wise':
          v = m['hostel'];
          break;
        case 'Floor Wise':
          v = m['floor'];
          break;
        case 'Room Wise':
          v = m['room']?.toString();
          break;
        case 'Batch Wise':
          v = m['batch'];
          break;
      }

      if (v != null && v.trim().isNotEmpty) {
        values.add(v.trim());
      }
    }

    _wiseOptions = values.toList()..sort();
    _selectedWiseValue = _wiseOptions.isNotEmpty ? _wiseOptions.first : '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _allMembers.where((m) {
      final name = (m['student_name'] ?? '').toString().toLowerCase();
      final admNo = (m['admno'] ?? '').toString();
      final room = (m['room'] ?? '').toString();

      final matchesSearch =
          name.contains(_query.toLowerCase()) ||
          admNo.contains(_query) ||
          room.contains(_query);

      if (_selectedWiseValue.isEmpty) return matchesSearch;

      bool matchesWise = true;
      switch (_viewBy) {
        case 'Hostel Wise':
          matchesWise = m['hostel'] == _selectedWiseValue;
          break;
        case 'Floor Wise':
          matchesWise = m['floor'] == _selectedWiseValue;
          break;
        case 'Room Wise':
          matchesWise = m['room'].toString() == _selectedWiseValue;
          break;
        case 'Batch Wise':
          matchesWise = m['batch'] == _selectedWiseValue;
          break;
      }

      return matchesSearch && matchesWise;
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Hostel Members",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [dark1, dark2, dark3, purpleDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Column(
          children: [
            const SizedBox(height: 95),

            // ================= FILTER CARD =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withOpacity(0.18)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    _dropdown(context, _viewBy, _viewOptions, (v) {
                      setState(() {
                        _viewBy = v!;
                        _selectedWiseValue = '';
                        _buildWiseOptions(); // 🔥 rebuild from full data
                      });
                    }),
                    if (_wiseOptions.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _dropdown(
                        context,
                        _selectedWiseValue,
                        _wiseOptions,
                        (v) => setState(() => _selectedWiseValue = v!),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _fetchMembers,
                            icon: const Icon(Icons.search),
                            label: const Text('Get Students'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              foregroundColor:
                                  Colors.white, // ✅ text & icon color
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AssignStudentsPage(students: filtered),
                                ),
                              );
                              if (result == true) {
                                _fetchMembers();
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Assign Students'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1ABC9C),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ================= LIST =================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SearchField(
                      hint: 'Search by Name, Adm No, Room',
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: 10),
                    if (_loading)
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null)
                      Expanded(child: Center(child: Text(_error!)))
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final m = filtered[i];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: neon.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m['student_name'] ?? '—',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Adm No: ${m['admno'] ?? ''}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (m['branch'] != null)
                                          Text(
                                            'Branch: ${m['branch']}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: neon,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          (m['room'] ?? '').toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.orange,
                                              size: 20,
                                            ),
                                            onPressed: () => _editMember(m),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            onPressed: () => _deleteMember(m),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ACTIONS =================

  Future<void> _deleteMember(Map<String, dynamic> member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Member?"),
        content: Text(
          "Are you sure you want to remove ${member['student_name']} from this hostel?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("REMOVE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _loading = true);
      try {
        await ApiService.deleteHostelMember(sid: member['sid'].toString());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Member removed successfully")),
        );
        _fetchMembers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  void _editMember(Map<String, dynamic> member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssignStudentsPage(students: [member], isEdit: true),
      ),
    ).then((_) => _fetchMembers());
  }

  // ================= DROPDOWN =================
  Widget _dropdown(
    BuildContext context,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white24 : Theme.of(context).dividerColor,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: isDark ? dark3 : Theme.of(context).cardColor,
          icon: const Icon(Icons.arrow_drop_down, color: neon),
          items: items
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
