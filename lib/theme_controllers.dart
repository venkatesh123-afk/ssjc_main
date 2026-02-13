import 'package:flutter/material.dart';

class StudentThemeController {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(
    ThemeMode.system,
  );

  static void toggleTheme() {
    themeMode.value = themeMode.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
  }

  void loadTheme() {}
}

class ThemeControllerWrapper extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeController;
  final Widget child;
  final ThemeData? lightTheme;
  final ThemeData? darkTheme;

  const ThemeControllerWrapper({
    super.key,
    required this.themeController,
    required this.child,
    this.lightTheme,
    this.darkTheme,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, mode, child) {
        final isDark =
            mode == ThemeMode.dark ||
            (mode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);
        return Theme(
          data: isDark
              ? (darkTheme ?? ThemeData.dark(useMaterial3: true))
              : (lightTheme ?? ThemeData.light(useMaterial3: true)),
          child: child!,
        );
      },
      child: child,
    );
  }
}
