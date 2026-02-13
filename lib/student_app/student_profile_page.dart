import 'package:flutter/material.dart';
import 'package:student_app/student_app/services/student_profile_service.dart';
import 'package:student_app/student_app/student_app_bar.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _studentData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await StudentProfileService.getProfile();
      if (mounted) {
        setState(() {
          // Handle API response structure (checking if data is nested in 'data' key)
          if (data.containsKey('data') && data['data'] is Map) {
            _studentData = data['data'];
          } else {
            _studentData = data;
          }
          final imageUrl =
              _studentData?['photo_url'] ?? _studentData?['image'] ?? '';
          StudentProfileService.profileImageUrl.value = imageUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Theme Helpers
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  Color get bg => isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC);
  Color get card => isDark ? const Color(0xFF020617) : Colors.white;
  Color get border =>
      isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF020617);
  Color get textSecondary =>
      isDark ? const Color(0xFFCBD5E1) : const Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: const StudentAppBar(title: "Student Profile"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Error: $_errorMessage"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProfile,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            )
          : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    if (_studentData == null)
      return const Center(child: Text("No data available"));

    // Dynamic Data Extraction with Fallbacks
    final name =
        _studentData?['student_name'] ??
        _studentData?['name'] ??
        'Student Name';
    final rollNo =
        _studentData?['roll_no'] ?? _studentData?['admission_no'] ?? 'N/A';
    final course =
        _studentData?['course_name'] ?? _studentData?['class'] ?? 'N/A';
    final branch = _studentData?['branch_name'] ?? 'N/A';
    final email = _studentData?['email'] ?? 'N/A';
    final phone = _studentData?['mobile_no'] ?? _studentData?['phone'] ?? 'N/A';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Image Integration
                ValueListenableBuilder<String?>(
                  valueListenable: StudentProfileService.profileImageUrl,
                  builder: (context, imageUrl, _) {
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blueAccent, width: 3),
                        image: DecorationImage(
                          image:
                              (imageUrl != null && imageUrl.isNotEmpty
                                      ? NetworkImage(imageUrl)
                                      : const NetworkImage(
                                          "https://i.pravatar.cc/300",
                                        ))
                                  as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  rollNo,
                  style: TextStyle(
                    fontSize: 16,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                _detailRow(Icons.school, "Course", course),
                const SizedBox(height: 16),
                _detailRow(Icons.account_tree, "Branch", branch),
                const SizedBox(height: 16),
                _detailRow(Icons.email, "Email", email),
                const SizedBox(height: 16),
                _detailRow(Icons.phone, "Phone", phone),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blueAccent, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: textSecondary)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
