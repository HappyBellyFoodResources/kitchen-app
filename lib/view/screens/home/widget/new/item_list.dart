// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ItemList extends StatelessWidget {
  const ItemList({
    super.key,
    required this.title,
    this.subtitle,
    this.isAddOn = false,
  });

  final String title;
  final String? subtitle;
  final bool isAddOn;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              isAddOn ? Icons.circle_outlined : Icons.circle_sharp,
              size: isAddOn ? 14 : 18,
              color: const Color(0xFF868686),
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                  fontSize: isAddOn ? 12 : 14,
                  fontWeight: isAddOn ? FontWeight.w500 : FontWeight.bold),
            ),
          ],
        ),
        Text(
          subtitle ?? '',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
