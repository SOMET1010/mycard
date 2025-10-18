/// Widget de bouton avec indicateur de chargement
library;
import 'package:flutter/material.dart';
import 'package:mycard/app/theme.dart';

class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.text,
    required this.isLoading,
    this.onPressed,
    this.style,
    this.icon,
    this.width,
    this.height,
  });

  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Widget? icon;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: style ?? ElevatedButton.styleFrom(
            backgroundColor: AppTheme.burntSienna,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppTheme.burntSienna.withValues(alpha: 0.5),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          child: _buildContent(),
        ),
      );

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}