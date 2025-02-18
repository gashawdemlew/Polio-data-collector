import 'package:flutter/material.dart';

/// A service for displaying attractive, dismissible messages as overlays.
class MessageService {
  static OverlayEntry? _currentEntry;

  /// Shows a message as an overlay at the top of the screen.
  ///
  /// The message can be a success, error, or informational message, indicated
  /// by the [type] parameter. The message will automatically disappear after
  /// the specified [duration].  The user can also dismiss the message by
  /// swiping it or tapping the close icon.
  ///
  /// Example:
  /// ```dart
  /// MessageService.showSuccess(context, 'Operation completed successfully!');
  /// ```
  static void showMessage(
    BuildContext context,
    String message, {
    MessageType type = MessageType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Remove existing overlay if any
    if (_currentEntry != null) {
      _removeMessage(context);
    }

    _currentEntry = OverlayEntry(
      builder: (context) => _MessageOverlay(
        message: message,
        type: type,
        onDismissed: () {
          _removeMessage(context);
        },
      ),
    );

    Overlay.of(context).insert(_currentEntry!);

    // Auto-dismiss after duration
    Future.delayed(duration, () {
      _removeMessage(context);
    });
  }

  /// Removes the currently displayed message overlay.
  static void _removeMessage(BuildContext context) {
    if (_currentEntry != null && _currentEntry!.mounted) {
      _currentEntry!.remove();
      _currentEntry = null;
    }
  }

  /// Shows an error message using the overlay.
  static void showError(BuildContext context, String message) {
    showMessage(context, message, type: MessageType.error);
  }

  /// Shows a success message using the overlay.
  static void showSuccess(BuildContext context, String message) {
    showMessage(context, message, type: MessageType.success);
  }

  /// Shows an informational message using the overlay.
  static void showInfo(BuildContext context, String message) {
    showMessage(context, message, type: MessageType.info);
  }
}

enum MessageType {
  success,
  error,
  info,
  warning,
}

/// The widget responsible for displaying the message overlay.
class _MessageOverlay extends StatefulWidget {
  final String message;
  final MessageType type;
  final VoidCallback onDismissed;

  const _MessageOverlay({
    Key? key,
    required this.message,
    required this.type,
    required this.onDismissed,
  }) : super(key: key);

  @override
  State<_MessageOverlay> createState() => _MessageOverlayState();
}

class _MessageOverlayState extends State<_MessageOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // Slightly longer animation
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -2), // Start further off-screen for drama!
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic, // More pronounced curve
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose(); // Call super.dispose() AFTER disposing of the controller.
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color backgroundColor;
    Color iconColor;
    IconData iconData;

    switch (widget.type) {
      case MessageType.success:
        backgroundColor = colorScheme.primaryContainer;
        iconColor = colorScheme.onPrimaryContainer;
        iconData = Icons.check_circle_outline;
        break;
      case MessageType.error:
        backgroundColor = colorScheme.errorContainer;
        iconColor = colorScheme.onErrorContainer;
        iconData = Icons.error_outline;
        break;
      case MessageType.info:
        backgroundColor = colorScheme.secondaryContainer;
        iconColor = colorScheme.onSecondaryContainer;
        iconData = Icons.info_outline;
        break;
      case MessageType.warning:
        backgroundColor = Colors.amber.shade200; // Customize warning color
        iconColor = Colors.black87; // Customize warning icon color
        iconData = Icons.warning_amber_outlined;
        break;
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          //Use SafeArea
          child: Material(
            // Wrap with Material for elevation
            elevation: 6, // Add a subtle shadow
            borderRadius: BorderRadius.circular(12),
            child: Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.horizontal,
              onDismissed: (direction) {
                widget.onDismissed();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        iconData,
                        color: iconColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            color: iconColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: iconColor),
                        onPressed: widget.onDismissed,
                        splashRadius: 20, // Improve tap feedback
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
