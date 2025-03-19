import 'package:flutter/material.dart';

class ListHeader extends StatelessWidget {
  const ListHeader({
    super.key,
    required this.title,
    required this.stateColor,
  });
  final String title;
  final Color stateColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      color: Colors.transparent,
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            height: 10,
            width: 10,
            decoration: BoxDecoration(
              color: stateColor,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
