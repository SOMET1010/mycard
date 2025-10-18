import 'package:flutter/material.dart';
import 'package:mycard/core/services/accessibility_service.dart';

/// Widget texte avec vérification d'accessibilité intégrée
class AccessibleText extends StatelessWidget {

  const AccessibleText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.softWrap,
    this.overflow,
    this.maxLines,
    this.semanticsLabel,
    this.isLargeText = false,
  });
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool? softWrap;
  final TextOverflow? overflow;
  final int? maxLines;
  final String? semanticsLabel;
  final bool isLargeText;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = _getAccessibleStyle(context);

    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
    );
  }

  TextStyle _getAccessibleStyle(BuildContext context) {
    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium!;

    // S'assurer que la taille du texte est accessible
    final accessibleSize = AccessibilityService.getAccessibleTextSize(
      baseStyle.fontSize ?? 14.0,
      isLargeText: isLargeText,
    );

    return baseStyle.copyWith(
      fontSize: accessibleSize,
      // S'assurer que le contraste est suffisant avec le fond
      color: _getAccessibleColor(context, baseStyle.color),
    );
  }

  Color? _getAccessibleColor(BuildContext context, Color? textColor) {
    if (textColor == null) return null;

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final bgColorValue = backgroundColor.toARGB32();
    final textColorValue = textColor.toARGB32();

    if (!AccessibilityService.hasSufficientContrast(textColorValue, bgColorValue, largeText: isLargeText)) {
      // Utiliser la couleur optimale pour le contraste
      return Color(AccessibilityService.getOptimalTextColor(bgColorValue));
    }

    return textColor;
  }
}

/// Widget pour les éléments interactifs accessibles
class AccessibleInteractive extends StatelessWidget {

  const AccessibleInteractive({
    super.key,
    required this.child,
    this.semanticsLabel,
    this.hint,
    this.minSize,
    this.onTap,
    this.onLongPress,
  });
  final Widget child;
  final String? semanticsLabel;
  final String? hint;
  final double? minSize;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    var wrappedChild = child;

    // S'assurer que l'élément a une taille minimale pour l'accessibilité
    if (minSize != null) {
      final minInteractiveSize = AccessibilityService.getMinimumInteractiveSize();
      if (minSize! < minInteractiveSize) {
        wrappedChild = SizedBox(
          width: minInteractiveSize,
          height: minInteractiveSize,
          child: Center(child: wrappedChild),
        );
      }
    }

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(8),
      child: Semantics(
        label: semanticsLabel,
        hint: hint,
        button: onTap != null,
        enabled: onTap != null,
        child: wrappedChild,
      ),
    );
  }
}

/// Widget pour vérifier et améliorer le contraste des conteneurs
class AccessibleContainer extends StatelessWidget {

  const AccessibleContainer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.decoration,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.semanticsLabel,
  });
  final Widget child;
  final Color? backgroundColor;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final effectiveDecoration = decoration ?? BoxDecoration(
      color: backgroundColor ?? Colors.transparent,
    );

    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: effectiveDecoration,
      child: semanticsLabel != null
          ? Semantics(
              label: semanticsLabel,
              container: true,
              child: child,
            )
          : child,
    );
  }
}