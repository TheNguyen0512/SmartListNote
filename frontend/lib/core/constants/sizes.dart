import 'package:flutter/material.dart';

class AppSizes {
  // Font sizes
  static const double fontSmall = 14.0;
  static const double fontMedium = 16.0;
  static const double fontLarge = 18.0;
  static const double fontTitle = 20.0;

  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Responsive size calculation
  static double getResponsiveSize(BuildContext context, double fraction) {
    final width = MediaQuery.of(context).size.width;
    return width * fraction;
  }

  // Card sizes
  static double cardPadding(BuildContext context) => paddingMedium;
  static double cardHeight(BuildContext context) =>
      getResponsiveSize(context, 0.15);
  static double cardRadius(BuildContext context) => 12.0;

  // Button sizes
  static double buttonWidth(BuildContext context) =>
      getResponsiveSize(context, 0.4);
  static double buttonHeight(BuildContext context) =>
      getResponsiveSize(context, 0.12);

  // Spacing
  static double spacingExtraSmall(BuildContext context) => paddingSmall / 2;
  static double spacingSmall(BuildContext context) => paddingSmall;
  static double spacingMedium(BuildContext context) => paddingMedium;
  static double spacingLarge(BuildContext context) => paddingLarge;

  // Radius for pill-shaped elements
  static double pillRadius(BuildContext context) => 50.0;

  // Icon sizes
  static double iconSmall(BuildContext context) => getResponsiveSize(context, 0.05);
  static double iconMedium(BuildContext context) => getResponsiveSize(context, 0.07);
  static double iconLarge(BuildContext context) => getResponsiveSize(context, 0.1);
  static double iconExtraLarge(BuildContext context) => getResponsiveSize(context, 0.15);
}
