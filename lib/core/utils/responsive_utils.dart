import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Screen size breakpoints
  static const double mobileSmall = 320;
  static const double mobileMedium = 375;
  static const double mobileLarge = 414;
  static const double tablet = 600;
  static const double desktop = 1024;

  // Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileSmall) return ScreenSize.xSmall;
    if (width < mobileMedium) return ScreenSize.small;
    if (width < mobileLarge) return ScreenSize.medium;
    if (width < tablet) return ScreenSize.large;
    if (width < desktop) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  // Get responsive font size
  static double getFontSize(BuildContext context, {
    required double baseSize,
    double? xSmallSize,
    double? smallSize,
    double? mediumSize,
    double? largeSize,
    double? tabletSize,
    double? desktopSize,
  }) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.xSmall:
        return xSmallSize ?? baseSize * 0.85;
      case ScreenSize.small:
        return smallSize ?? baseSize * 0.9;
      case ScreenSize.medium:
        return mediumSize ?? baseSize;
      case ScreenSize.large:
        return largeSize ?? baseSize;
      case ScreenSize.tablet:
        return tabletSize ?? baseSize * 1.1;
      case ScreenSize.desktop:
        return desktopSize ?? baseSize * 1.2;
    }
  }

  // Get responsive padding
  static EdgeInsets getPadding(BuildContext context, {
    required EdgeInsets basePadding,
    EdgeInsets? xSmallPadding,
    EdgeInsets? smallPadding,
    EdgeInsets? tabletPadding,
  }) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.xSmall:
        return xSmallPadding ?? basePadding * 0.7;
      case ScreenSize.small:
        return smallPadding ?? basePadding * 0.85;
      case ScreenSize.tablet:
      case ScreenSize.desktop:
        return tabletPadding ?? basePadding * 1.2;
      default:
        return basePadding;
    }
  }

  // Get responsive spacing
  static double getSpacing(BuildContext context, double baseSpacing) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.xSmall:
        return baseSpacing * 0.7;
      case ScreenSize.small:
        return baseSpacing * 0.85;
      case ScreenSize.tablet:
      case ScreenSize.desktop:
        return baseSpacing * 1.2;
      default:
        return baseSpacing;
    }
  }

  // Check if screen is small
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileMedium;
  }

  // Check if screen is tablet or larger
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= tablet;
  }

  // Get number of grid columns based on screen size
  static int getGridColumns(BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= desktop) return desktopColumns;
    if (width >= tablet) return tabletColumns;
    return mobileColumns;
  }
}

enum ScreenSize {
  xSmall,
  small,
  medium,
  large,
  tablet,
  desktop,
}

// Extension to multiply EdgeInsets
extension EdgeInsetsExtension on EdgeInsets {
  EdgeInsets operator *(double factor) {
    return EdgeInsets.only(
      left: left * factor,
      top: top * factor,
      right: right * factor,
      bottom: bottom * factor,
    );
  }
}