import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class ListFooter extends StatelessWidget {
  const ListFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
        color: Colors.black,
        child: const SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline_outlined,
                size: 20,
              ),
              SizedBox(
                width: 10,
              ),
              Text("Add a Task",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ));
  }
}
