// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/cupertino.dart';

class OrderSummaryItem extends StatelessWidget {
  const OrderSummaryItem({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF6F6F6F),
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          subtitle ?? '',
          style: const TextStyle(
            color: Color(0xFF190600),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
