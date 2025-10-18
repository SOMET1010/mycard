/// Widget pour afficher une ligne d'information de contact
library;

import 'package:flutter/material.dart';

class ContactInfoRow extends StatelessWidget {
  const ContactInfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.label,
    this.iconColor,
    this.textColor,
    this.iconSize,
    this.textSize,
    this.onTap,
    this.showDivider = true,
  });
  final IconData icon;
  final String text;
  final String? label;
  final Color? iconColor;
  final Color? textColor;
  final double? iconSize;
  final double? textSize;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (iconColor ?? Theme.of(context).primaryColor)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? Theme.of(context).primaryColor,
                  size: iconSize ?? 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (label != null)
                      Text(
                        label!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: textSize ?? 16,
                        color: textColor ?? Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
      if (showDivider) const Divider(height: 1, thickness: 0.5, indent: 56),
    ],
  );
}
