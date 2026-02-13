import 'package:flutter/material.dart';

class IssueOutingPage extends StatefulWidget {
  final String studentName;
  final String outingType;

  const IssueOutingPage({
    super.key,
    required this.studentName,
    required this.outingType,
  });

  @override
  State<IssueOutingPage> createState() => _IssueOutingPageState();
}

class _IssueOutingPageState extends State<IssueOutingPage> {
  String passType = "";

  static const Color dark1 = Color(0xFF1a1a2e);
  static const Color dark2 = Color(0xFF16213e);
  static const Color dark3 = Color(0xFF0f3460);
  static const Color purpleDark = Color(0xFF533483);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final headingStyle = TextStyle(
      color: isDark ? Colors.white : Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Issue Outing",
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

      // ---------------- BODY ----------------
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [dark1, dark2, dark3, purpleDark],
                )
              : LinearGradient(
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.10)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? Colors.white30 : Colors.grey.shade300,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF38EF7D), Color(0xFF3366E8)],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Issue New Outing",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text("Date *", style: headingStyle),
                  const SizedBox(height: 6),
                  _displayField("20/11/2025", isDark),

                  const SizedBox(height: 14),

                  Text("Pass Type *", style: headingStyle),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    children: [
                      _radio("Home Pass", isDark),
                      _radio("Outing Pass", isDark),
                      _radio("Self Outing", isDark),
                      _radio("Self Home", isDark),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Text("Select Student *", style: headingStyle),
                  const SizedBox(height: 6),
                  _displayField(
                    widget.studentName.isEmpty
                        ? "Select Student"
                        : widget.studentName,
                    isDark,
                  ),

                  const SizedBox(height: 14),

                  Text("Letter Photo *", style: headingStyle),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text("Take Photo"),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text("Out Time *", style: headingStyle),
                  const SizedBox(height: 6),
                  _displayField("07:12 PM", isDark),

                  const SizedBox(height: 14),

                  Text("Purpose *", style: headingStyle),
                  const SizedBox(height: 6),
                  _displayField("SELECT", isDark),

                  const SizedBox(height: 24),

                  Center(
                    child: SizedBox(
                      width: 180,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigoAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Outing Granted Successfully!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: const Text("Grant Outing",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- RADIO ----------------
  Widget _radio(String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: text,
          groupValue: passType,
          activeColor: isDark ? Colors.white : Colors.blue,
          onChanged: (v) => setState(() => passType = v!),
        ),
        Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ---------------- FIELD ----------------
  Widget _displayField(String value, bool isDark) {
    return Container(
      height: 48,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white30 : Colors.grey.shade400,
        ),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 15,
        ),
      ),
    );
  }
}
