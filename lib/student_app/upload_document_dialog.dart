import 'package:flutter/material.dart';

class UploadDocumentDialog extends StatefulWidget {
  final String initialCategory;

  const UploadDocumentDialog({super.key, required this.initialCategory});

  @override
  State<UploadDocumentDialog> createState() => _UploadDocumentDialogState();
}

class _UploadDocumentDialogState extends State<UploadDocumentDialog> {
  late String selectedType;

  final List<String> documentTypes = [
    "ID Proof (Aadhar, PAN, etc.)",
    "Academic (Marksheets, Certificates)",
    "Medical (Health Certificate)",
    "Hostel (Allocation, Consent Forms)",
    "Financial (Fee Receipts)",
    "Other Documents",
  ];

  @override
  void initState() {
    super.initState();
    selectedType = _mapCategory(widget.initialCategory);
  }

  String _mapCategory(String category) {
    switch (category) {
      case "ID Proof":
        return documentTypes[0];
      case "Academic":
        return documentTypes[1];
      case "Medical":
        return documentTypes[2];
      case "Hostel":
        return documentTypes[3];
      case "Financial":
        return documentTypes[4];
      default:
        return documentTypes[5];
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bg = isDark ? const Color(0xFF020617) : Colors.white;
    final Color border = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF020617);
    final Color textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF6B7280);

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 520,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Upload Document",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // DROP AREA
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: border, style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.upload,
                      size: 36,
                      color: const Color(0xFF2563EB),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Click or drag file to this area to upload",
                      style: TextStyle(fontSize: 14, color: textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Support for PDF, JPG, PNG, DOC, XLS. Max file size: 5MB",
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SELECT TYPE
              Text(
                "Select Document Type",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedType,
                items: documentTypes
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedType = value!);
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: border),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ACTIONS
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _simulateUpload,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    child: const Text("Upload Document"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _simulateUpload() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // Close loading indicator
        Navigator.pop(context); // Close upload dialog
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
            content: Text("Document uploaded successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }
}
