import 'package:flutter/material.dart';

class ListHeader extends StatelessWidget {
  const ListHeader({super.key, required this.title, required this.stateColor});
  final String title;
  final Color stateColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
              margin: const EdgeInsets.only(right: 10),
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: stateColor,
              )),
          Text(title,
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(
            height: 25,
            width: 25,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: Colors.black,
                )),
            child: const Icon(
              Icons.more_horiz,
              size: 16,
              color: Colors.black,
            ),
          )
        ],
      ),
    );
  }
}
