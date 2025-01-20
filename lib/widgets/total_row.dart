import 'package:flutter/material.dart';

import '../utils/constants.dart';

class TotalRow extends StatelessWidget {
  final String label;
  final int amount;
  final String type;

  const TotalRow({
    super.key,
    required this.label,
    required this.amount,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                type == 'income' ? Icons.trending_up : Icons.trending_down,
                color: type == 'income' ? Colors.green : Colors.red,
                size: 32,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Text(
            convertToYenFormat(amount: amount),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
