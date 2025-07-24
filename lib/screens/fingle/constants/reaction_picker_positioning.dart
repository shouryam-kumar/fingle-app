import 'package:flutter/material.dart';
import '../widgets/enhanced_reaction_picker.dart';

/// Utility class for calculating optimal positioning of reaction pickers
class ReactionPickerPositioning {
  /// Calculates the optimal X position for the reaction picker
  static double calculateOptimalX({
    required Offset buttonPosition,
    required Size buttonSize,
    required Size screenSize,
    required ReactionPickerLayout layout,
  }) {
    final isHorizontal = layout == ReactionPickerLayout.horizontal;

    if (isHorizontal) {
      // For horizontal layout, center the picker over the button
      const pickerWidth = 240.0; // More accurate width for 8 compact reactions
      double left =
          buttonPosition.dx + (buttonSize.width / 2) - (pickerWidth / 2);

      // Ensure picker stays on screen
      if (left < 10) {
        left = 10;
      }
      if (left + pickerWidth > screenSize.width - 10) {
        left = screenSize.width - pickerWidth - 10;
      }

      return left;
    } else {
      // For vertical layout, position to the side
      const pickerWidth = 60.0;
      const buttonToPickerGap = 4.0;
      double left = buttonPosition.dx - pickerWidth - buttonToPickerGap;

      // Ensure picker stays on screen
      if (left < 10) {
        left = buttonPosition.dx + buttonSize.width + buttonToPickerGap;
      }
      if (left + pickerWidth > screenSize.width - 10) {
        left = screenSize.width - pickerWidth - 10;
      }

      return left;
    }
  }

  /// Calculates the optimal Y position for the reaction picker
  static double calculateOptimalY({
    required Offset buttonPosition,
    required Size buttonSize,
    required Size screenSize,
    required ReactionPickerLayout layout,
  }) {
    final isHorizontal = layout == ReactionPickerLayout.horizontal;
    final pickerHeight = isHorizontal
        ? 48.0
        : 280.0; // More accurate height for horizontal picker

    double top;
    if (isHorizontal) {
      // Position above the button for horizontal layout
      top = buttonPosition.dy -
          pickerHeight -
          4.0; // 4px gap above button for tighter connection

      // If too close to top, position below instead
      if (top < 50) {
        top = buttonPosition.dy +
            buttonSize.height +
            4.0; // Position below button with same gap
      }
    } else {
      // Center vertically for vertical layout
      top = buttonPosition.dy - (pickerHeight / 2) + (buttonSize.height / 2);
    }

    // Ensure picker stays on screen
    if (top < 50) {
      top = 50; // Leave space for status bar
    }
    if (top + pickerHeight > screenSize.height - 100) {
      top =
          screenSize.height - pickerHeight - 100; // Leave space for navigation
    }

    return top;
  }
}
