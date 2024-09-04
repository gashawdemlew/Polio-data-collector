import 'package:flutter/material.dart';

class CustomColors {
  static MaterialColor materialtestColor1 = const MaterialColor(
    0xFF145DA0, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xFF145DA0), //10%
    },
  );

  static const Color primaryColor = Colors.teal;
  static const Color secondaryColor = Color.fromARGB(255, 36, 129, 204);
  static const Color aBackground = Color(0xE5E5E500);
  static const Color aSidebar = Color(0x7C01FF00);
  static const Color secondaryTextColor = Color.fromARGB(255, 36, 129, 204);
  static const Color testColor1 = Color.fromARGB(255, 10, 83,
      156); // Dark blue color  static const Color testColor2 = Color(0xFF0C2D48);
  static const Color testColor3 = Color(0xFF2E8BC0);
  static const Color testColor4 = Color(0xFFB1D4E0);
}
