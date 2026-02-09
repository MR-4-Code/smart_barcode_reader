import 'package:flutter/material.dart';
import 'package:smart_barcode_reader/smart_barcode_reader.dart';

import 'smart_barcode_reader/smart_barcode_reader.dart';

/// A widget that listens for keyboard events and processes them as barcode input.
///
/// Wraps the child widget with a [KeyboardListener] to capture key events and
/// forwards them to a [SmartBarCodeReader] for processing. Provides user feedback
/// via [UserFeedbackManager] for invalid inputs.
///
/// Usage:
/// ```dart
/// SmartBarCodeReaderWidget(
///   onBarcodeDetected: (code) => print('Barcode: $code'),
///   child: MyWidget(),
/// )
/// ```
///
/// [focusNode] is optional params
class SmartBarCodeReaderWidget extends StatefulWidget {
  final SmartBarCodeReaderOptions? options;

  final FocusNode? focusNode;
  final FocusScopeNode? focusScopeNode;

  final Widget? child;

  const SmartBarCodeReaderWidget({
    super.key,
    this.child,
    this.options,
    this.focusNode,
    this.focusScopeNode,
  });

  @override
  State<SmartBarCodeReaderWidget> createState() =>
      _SmartBarCodeReaderWidgetState();
}

class _SmartBarCodeReaderWidgetState extends State<SmartBarCodeReaderWidget> {
  late final SmartBarCodeReader _reader;
  late final FocusNode focusNode;
  late final FocusScopeNode focusScopeNode;

  @override
  void initState() {
    super.initState();
    focusScopeNode = widget.focusScopeNode ?? FocusScopeNode();
    focusNode = widget.focusNode ?? FocusNode();

    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        focusNode.requestFocus();
      }
    });

    final options = widget.options;

    //To setup barcode reader from [options]
    _reader = SmartBarCodeReader(
      onBarcodeDetected: (code) {
        if (code.isNotEmpty) {
          debugPrint('Barcode detected: $code');
          options?.onBarcodeDetected?.call(code);
        }
      },
      maxLength: options?.maxLength,
      minLength: options?.minLength,
      tolerance: options?.tolerance,
      feedbackManager: options?.userFeedbackManager,
      maxInterKeyDurationMs: options?.maxInterKeyDurationMs ?? 20,
      validCharPattern: options?.validCharPattern ?? RegExp(r'^[0-9]+$'),
      supportedFormats:
          options?.supportedFormats ??
          {BarcodeFormat.ean13, BarcodeFormat.upcA, BarcodeFormat.code128},
    );
  }

  @override
  void dispose() {
    _reader.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: focusScopeNode,
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          focusNode.requestFocus();
        }
      },
      child: KeyboardListener(
        autofocus: true,
        focusNode: focusNode,
        onKeyEvent: _reader.handleKeyEvent,
        child: widget.child ?? const SizedBox(),
      ),
    );
  }
}
