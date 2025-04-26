import 'package:flutter/material.dart';

/// A class responsible for providing user feedback for barcode scanning events.
///
/// This class uses Flutter's [ScaffoldMessenger] to display [SnackBar] notifications
/// for invalid or rejected barcode inputs, improving the user experience in POS systems.
///
/// Usage:
/// ```dart
/// UserFeedbackManager feedback = UserFeedbackManager(context);
/// feedback.showFeedback('Invalid barcode detected');
/// ```
class UserFeedbackManager {
  /// The build context used to access the ScaffoldMessenger.
  final BuildContext context;
  final TextStyle? style;
  final Duration duration;

  /// Constructor for [UserFeedbackManager].
  ///
  /// Parameters:
  /// - [context]: The Flutter build context for displaying SnackBars.
  UserFeedbackManager(this.context,
      {this.style, this.duration = const Duration(seconds: 2)});

  /// Displays a feedback message to the user via a SnackBar.
  ///
  /// Parameters:
  /// - [message]: The message to display (e.g., 'Invalid barcode').
  void showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message, style: style),
          duration: duration,
          behavior: SnackBarBehavior.floating),
    );
  }
}
