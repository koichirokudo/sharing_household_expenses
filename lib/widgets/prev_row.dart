import 'package:flutter/material.dart';

import '../utils/constants.dart';

class PrevRow extends StatelessWidget {
  final String label;
  final int amount;
  final String type;

  const PrevRow({
    super.key,
    required this.label,
    required this.amount,
    required this.type,
  });

  Color _determineTextColor(int amount, String type) {
    if (amount == 0) {
      return Colors.grey;
    }

    return amount > 0 ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, right: 16.0, left: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SizedBox(width: 180),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Text(
            amount > 0
                ? '+${convertToYenFormat(amount: amount)}'
                : convertToYenFormat(amount: amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _determineTextColor(amount, type),
            ),
          ),
        ],
      ),
    );
  }
}
