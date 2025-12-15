import 'package:explorez_votre_ville/listeners/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeButton extends StatelessWidget {
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            style: ButtonStyle(),
            icon: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            label: Text("Theme"),
          ),
        );
      },
    );
  }
}
