import 'package:flutter/material.dart';

final theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: AppColor.vermelho),
  useMaterial3: true,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.green[50],
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColor.carvao,
      fontSize: 24,
      letterSpacing: 2.5,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(12),
        backgroundColor: AppColor.vermelho,
        foregroundColor: Colors.green[300]),
  ),
);

class AppColor {
  static Color vermelho = const Color(0xFFC95853);
  static Color carvao = const Color(0xFF4D4A49);
  static Color verde = const Color(0xFF314F4F);
  static Color verdeClaro = const Color(0xFF34A853);
}
