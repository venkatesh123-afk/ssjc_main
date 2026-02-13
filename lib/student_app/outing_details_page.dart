import 'package:flutter/material.dart';
import 'package:student_app/student_app/full_image_view_page.dart';

class OutingDetailsPage extends StatelessWidget {
  final Map<String, dynamic> outing;

  const OutingDetailsPage({super.key, required this.outing});

  @override
  Widget build(BuildContext context) {
    // Parse data safely
    final dateStr = outing['out_date']?.toString() ?? '';
    final formattedDate = dateStr;

    final outTime = outing['outing_time'] ?? 'N/A';
    final _ = outing['in_report'] ?? 'N/A';
    final purpose = outing['purpose'] ?? 'N/A';
    final type = outing['outingtype'] ?? 'Self Outing';
    final status = outing['status']?.toString().toUpperCase() ?? 'PENDING';
    final isHomePass = type.toString().toLowerCase().contains('home');

    // Dynamic Data Mapping
    final _ = 'N/A'; // Destination not in new JSON
    final permissionId =
        outing['permission']?.toString() ?? outing['id']?.toString() ?? 'N/A';

    // Attempt to format created_at/updated_at if available, else fallback
    String createdAt = "N/A";
    if (outing['created_at'] != null) {
      try {
        final d = DateTime.parse(outing['created_at'].toString());
        createdAt = "${d.day} ${_month(d.month)} ${d.year} ${_formatTime(d)}";
      } catch (_) {
        createdAt = outing['created_at'].toString();
      }
    }

    String lastUpdated = "N/A";
    if (outing['updated_at'] != null) {
      try {
        final d = DateTime.parse(outing['updated_at'].toString());
        lastUpdated = "${d.day} ${_month(d.month)} ${d.year} ${_formatTime(d)}";
      } catch (_) {
        lastUpdated = outing['updated_at'].toString();
      }
    }

    // In Report Time logic
    final reportTime = outing['in_report'] ?? "Not Reported";

    final theme = Theme.of(context);
    final borderColor = theme.dividerColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔙 Back Button Row
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Outing Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// 🧾 Details Container
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: theme.brightness == Brightness.dark
                              ? 0.25
                              : 0.06,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      /// Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Details",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      /// ⬇️ Your existing content continues here
                      /// (grid rows, documents, footer, etc.)
                    ],
                  ),
                ),
              ),

              const Divider(height: 1),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grid Container
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _buildGridRow(
                            context,
                            "Date",
                            formattedDate,
                            "Outing Type",
                            type,
                            icon1: Icons.calendar_today_outlined,
                            isTypeBadge: true,
                            isHomePass: isHomePass,
                            borderColor: borderColor,
                          ),
                          _buildDivider(borderColor),
                          _buildGridRow(
                            context,
                            "Departure Time",
                            outTime,
                            "Return Time (Reported)",
                            reportTime,
                            icon1: Icons.access_time,
                            icon2: Icons.access_time,
                            borderColor: borderColor,
                          ),
                          _buildDivider(borderColor),
                          _buildGridRow(
                            context,
                            "Purpose",
                            purpose,
                            "Permission ID",
                            permissionId,
                            isIdBadge: true,
                            borderColor: borderColor,
                          ),
                          _buildDivider(borderColor),
                          _buildGridRow(
                            context,
                            "Status",
                            status,
                            "Created At",
                            createdAt,
                            isStatusBadge: true,
                            statusValue: status,
                            borderColor: borderColor,
                          ),
                          _buildDivider(borderColor),
                          // Last row for Updated Time
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Last Updated",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color:
                                              theme.textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        lastUpdated,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              theme.textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Documents Section
                    Text(
                      "Documents",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildDocumentCard(
                            context,
                            "Permission Letter",
                            Icons.description_outlined,
                            outing['letterpic']?.toString() ??
                                "https://via.placeholder.com/150?text=Permission+Letter",
                            borderColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDocumentCard(
                            context,
                            "Guardian Consent",
                            Icons.person_outline,
                            outing['guardianpic']?.toString() ??
                                "https://via.placeholder.com/150?text=Guardian+Consent",
                            borderColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Footer Action
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridRow(
    BuildContext context,
    String label1,
    String value1,
    String label2,
    String value2, {
    IconData? icon1,
    IconData? icon2,
    bool isTypeBadge = false,
    bool isHomePass = false,
    bool isStatusBadge = false,
    String? statusValue,
    bool isIdBadge = false,
    required Color borderColor,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: borderColor)),
              ),
              child: _buildCell(
                context,
                label1,
                value1,
                icon: icon1,
                isStatusBadge: isStatusBadge,
                statusValue: statusValue,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: _buildCell(
                context,
                label2,
                value2,
                icon: icon2,
                isTypeBadge: isTypeBadge,
                isHomePass: isHomePass,
                isIdBadge: isIdBadge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(
    BuildContext context,
    String label,
    String value, {
    IconData? icon,
    bool isTypeBadge = false,
    bool isHomePass = false,
    bool isStatusBadge = false,
    String? statusValue,
    bool isIdBadge = false,
  }) {
    final theme = Theme.of(context);
    final labelColor = theme.textTheme.bodyMedium?.color;
    final valueColor = theme.textTheme.bodyLarge?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: labelColor)),
        const SizedBox(height: 8),
        if (isTypeBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isHomePass
                  ? Colors.blue.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isHomePass ? Colors.blue : Colors.orange.shade700,
              ),
            ),
          )
        else if (isStatusBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusValue == 'APPROVED'
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusValue == 'APPROVED' ? Colors.green : Colors.red,
              ),
            ),
          )
        else if (isIdBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.pink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.pink.withValues(alpha: 0.2)),
            ),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.pink,
              ),
            ),
          )
        else
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: labelColor),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDivider(Color color) {
    return Container(height: 1, color: color);
  }

  Widget _buildDocumentCard(
    BuildContext context,
    String title,
    IconData icon,
    String imageUrl,
    Color borderColor,
  ) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon, size: 16, color: theme.textTheme.bodyMedium?.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          AspectRatio(
            aspectRatio: 1.5,
            child: Container(
              color: theme.brightness == Brightness.dark
                  ? Colors.grey.shade900
                  : Colors.grey.shade100,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: theme.disabledColor,
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FullImageViewPage(imageUrl: imageUrl, title: title),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Text(
                  "View Full Image",
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _month(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime d) {
    int hour = d.hour;
    final minute = d.minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return "$hour:$minute $ampm";
  }
}
