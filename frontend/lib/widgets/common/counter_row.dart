import 'package:flutter/material.dart';

class CounterRow extends StatefulWidget {
  final String title;
  final String boldTitle;
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<int>? onChanged;

  const CounterRow({
    super.key,
    required this.title,
    required this.boldTitle,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    this.onChanged,
  });

  @override
  State<CounterRow> createState() => _CounterRowState();
}

class _CounterRowState extends State<CounterRow> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(CounterRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update the text if the value was changed externally (e.g. via +/- buttons)
    if (oldWidget.value != widget.value) {
      final newText = widget.value.toString();
      if (_controller.text != newText) {
        _controller.text = newText;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 15, color: Colors.grey[800]),
              children: [
                TextSpan(text: '${widget.title} '),
                TextSpan(
                  text: widget.boldTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCounterButton(
                icon: Icons.remove,
                onTap: widget.onDecrement,
                enabled: widget.value > 0,
              ),
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (val) {
                    if (widget.onChanged != null && val.isNotEmpty) {
                      final parsed = int.tryParse(val);
                      if (parsed != null) {
                        widget.onChanged!(parsed);
                      }
                    }
                  },
                ),
              ),
              _buildCounterButton(
                icon: Icons.add,
                onTap: widget.onIncrement,
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
