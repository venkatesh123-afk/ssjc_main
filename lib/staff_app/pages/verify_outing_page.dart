import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VerifyOutingPage extends StatefulWidget {
  final String? name;
  final String? adm;
  final String? time;
  final String? status;
  final String? type;

  const VerifyOutingPage({
    super.key,
    this.name,
    this.adm,
    this.time,
    this.status,
    this.type,
  });

  @override
  State<VerifyOutingPage> createState() => _VerifyOutingPageState();
}

class _VerifyOutingPageState extends State<VerifyOutingPage> {
  final ImagePicker _picker = ImagePicker();
  File? _capturedImage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final darkGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1a1a2e),
        Color(0xFF16213e),
        Color(0xFF0f3460),
        Color(0xFF533483),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: MediaQuery.of(context).size.height, // ✅ full height
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: darkGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppTitle(context, isDark),
                const SizedBox(height: 28),

                /// ADMISSION NUMBER
                Center(
                  child: Text(
                    widget.adm ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// MAIN CARD
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRow("Student Name", widget.name ?? "-"),
                      _buildRow("Type", widget.type ?? "-"),
                      _buildRow("Time", widget.time ?? "-"),

                      const SizedBox(height: 20),

                      /// IMAGE PREVIEW
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: _capturedImage != null
                            ? Image.file(
                                _capturedImage!,
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                "assets/girl.jpg",
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      ),

                      const SizedBox(height: 20),

                      _buildTakePhotoButton(context),
                    ],
                  ),
                ),

                const SizedBox(height: 60), // ✅ instead of Spacer
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= APP TITLE =================
  Widget _buildAppTitle(BuildContext context, bool isDark) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Row(
        children: const [
          Icon(Icons.arrow_back, color: Colors.white),
          SizedBox(width: 8),
          Text(
            "Verify Outing",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            "$title : ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  // ================= TAKE PHOTO BUTTON =================
  Widget _buildTakePhotoButton(BuildContext context) {
    return InkWell(
      onTap: () => _showCaptureDialog(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF5A8DEE),
              Color(0xFF6A5AE0),
            ],
          ),
        ),
        child: const Center(
          child: Text(
            "Take Photo",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ================= DIALOG =================
  void _showCaptureDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF2C2F3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Capture Student Photo",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _dialogButton(
                    label: "Capture Photo",
                    gradient: const LinearGradient(
                      colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                    ),
                    onTap: () async {
                      await _captureFromCamera();
                      Navigator.pop(context);
                    },
                  ),
                  _dialogButton(
                    label: "Upload Photo",
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5A8DEE), Color(0xFF6A5AE0)],
                    ),
                    onTap: () async {
                      await _pickFromGallery();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= CAMERA =================
  Future<void> _captureFromCamera() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo != null) {
      setState(() => _capturedImage = File(photo.path));
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _capturedImage = File(image.path));
    }
  }

  Widget _dialogButton({
    required String label,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 170,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
