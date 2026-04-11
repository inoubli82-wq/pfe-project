import 'package:flutter/material.dart';

class CounterRow extends StatelessWidget {
  final String title;
  final String boldTitle;
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CounterRow({
    super.key,
    required this.title,
    required this.boldTitle,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 15, color: Colors.grey[800]),
            children: [
              TextSpan(text: '$title '),
              TextSpan(
                text: boldTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              _buildCounterButton(
                icon: Icons.remove,
                onTap: onDecrement,
                enabled: value > 0,
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildCounterButton(
                icon: Icons.add,
                onTap: onIncrement,
                enabled: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? const Color(0xFF0C44A6) : Colors.grey[300],
        ),
      ),
    );
  }
}
