import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const SettingsPage({
    Key? key,
    required this.currentThemeMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Options'),
      ),
      body: Column(
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('Light Theme'),
            value: ThemeMode.light,
            groupValue: currentThemeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                onThemeChanged(value);
                Navigator.of(context).pop();
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark Theme'),
            value: ThemeMode.dark,
            groupValue: currentThemeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                onThemeChanged(value);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
