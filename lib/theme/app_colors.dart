import 'package:flutter/material.dart';
import '../models/task.dart';

class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  static const background = Color(0xFF0F1117);
  static const surface = Color(0xFF1A1D27);
  static const surfaceElevated = Color(0xFF222636);
  static const primary = Color(0xFF6C63FF);
  static const primaryLight = Color(0xFF8B85FF);
  static const success = Color(0xFF34C759);
  static const danger = Color(0xFFFF453A);
  static const textPrimary = Color(0xFFF0F0F5);
  static const textSecondary = Color(0xFF9B9BB0);
  static const border = Color(0xFF2A2D3E);

  static const priorityColors = {
    Priority.high: Color(0xFFFF453A),
    Priority.medium: Color(0xFFFF9F0A),
    Priority.low: Color(0xFF34C759),
  };
}
