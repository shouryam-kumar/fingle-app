import 'package:flutter/material.dart';

/// Utility class for responsive design calculations
class ResponsiveUtils {
  // Breakpoints
  static const double mobileBreakpoint = 480.0;
  static const double tabletBreakpoint = 768.0;
  static const double desktopBreakpoint = 1024.0;

  /// Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.largeMobile;
    } else if (width < desktopBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    double? mobile,
    double? largeMobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(context);
    final width = MediaQuery.of(context).size.width;

    double padding;
    switch (deviceType) {
      case DeviceType.mobile:
        padding = mobile ?? width * 0.04; // 4% of screen width
        break;
      case DeviceType.largeMobile:
        padding = largeMobile ?? width * 0.05; // 5% of screen width
        break;
      case DeviceType.tablet:
        padding = tablet ?? width * 0.06; // 6% of screen width
        break;
      case DeviceType.desktop:
        padding = desktop ?? width * 0.08; // 8% of screen width
        break;
    }

    // Ensure padding doesn't exceed maximum values
    padding = padding.clamp(8.0, 32.0);

    return EdgeInsets.all(padding);
  }

  /// Get responsive horizontal padding
  static EdgeInsets getResponsiveHorizontalPadding(
    BuildContext context, {
    double? mobile,
    double? largeMobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(context);
    final width = MediaQuery.of(context).size.width;

    double padding;
    switch (deviceType) {
      case DeviceType.mobile:
        padding = mobile ?? width * 0.04;
        break;
      case DeviceType.largeMobile:
        padding = largeMobile ?? width * 0.05;
        break;
      case DeviceType.tablet:
        padding = tablet ?? width * 0.06;
        break;
      case DeviceType.desktop:
        padding = desktop ?? width * 0.08;
        break;
    }

    padding = padding.clamp(12.0, 48.0);

    return EdgeInsets.symmetric(horizontal: padding);
  }

  /// Get responsive vertical padding
  static EdgeInsets getResponsiveVerticalPadding(
    BuildContext context, {
    double? mobile,
    double? largeMobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(context);
    final height = MediaQuery.of(context).size.height;

    double padding;
    switch (deviceType) {
      case DeviceType.mobile:
        padding = mobile ?? height * 0.02;
        break;
      case DeviceType.largeMobile:
        padding = largeMobile ?? height * 0.025;
        break;
      case DeviceType.tablet:
        padding = tablet ?? height * 0.03;
        break;
      case DeviceType.desktop:
        padding = desktop ?? height * 0.04;
        break;
    }

    padding = padding.clamp(8.0, 32.0);

    return EdgeInsets.symmetric(vertical: padding);
  }

  /// Get responsive margin
  static EdgeInsets getResponsiveMargin(
    BuildContext context, {
    double? mobile,
    double? largeMobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(context);
    final width = MediaQuery.of(context).size.width;

    double margin;
    switch (deviceType) {
      case DeviceType.mobile:
        margin = mobile ?? width * 0.03;
        break;
      case DeviceType.largeMobile:
        margin = largeMobile ?? width * 0.04;
        break;
      case DeviceType.tablet:
        margin = tablet ?? width * 0.05;
        break;
      case DeviceType.desktop:
        margin = desktop ?? width * 0.06;
        break;
    }

    margin = margin.clamp(6.0, 24.0);

    return EdgeInsets.all(margin);
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    double? mobile,
    double? largeMobile,
    double? tablet,
    double? desktop,
    double? baseFontSize,
  }) {
    final deviceType = getDeviceType(context);
    final base = baseFontSize ?? 16.0;

    double fontSize;
    switch (deviceType) {
      case DeviceType.mobile:
        fontSize = mobile ?? base * 0.9;
        break;
      case DeviceType.largeMobile:
        fontSize = largeMobile ?? base;
        break;
      case DeviceType.tablet:
        fontSize = tablet ?? base * 1.1;
        break;
      case DeviceType.desktop:
        fontSize = desktop ?? base * 1.2;
        break;
    }

    return fontSize.clamp(12.0, 24.0);
  }

  /// Get responsive border radius
  static double getResponsiveBorderRadius(
    BuildContext context, {
    double? mobile,
    double? largeMobile,
    double? tablet,
    double? desktop,
    double? baseRadius,
  }) {
    final deviceType = getDeviceType(context);
    final base = baseRadius ?? 12.0;

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? base * 0.8;
      case DeviceType.largeMobile:
        return largeMobile ?? base;
      case DeviceType.tablet:
        return tablet ?? base * 1.2;
      case DeviceType.desktop:
        return desktop ?? base * 1.4;
    }
  }

  /// Check if device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get screen size percentage
  static double getScreenPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }
}

enum DeviceType {
  mobile,
  largeMobile,
  tablet,
  desktop,
}
