import 'dart:io';

import 'package:flutter/material.dart';

class BoardHeader extends StatelessWidget {
  const BoardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 30, right: 30),
      height: 70,
      child: Row(
        children: [
          const Text("Lakhan's Board",
              style: TextStyle(
                  fontSize: 26,
                  color: Colors.black,
                  fontWeight: FontWeight.w900)),
          const Spacer(),
          Platform.isWindows || Platform.isLinux || Platform.isMacOS
              ? Row(
                  children: [
                    const Icon(
                      Icons.search,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    const Icon(
                      Icons.notifications,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    const Icon(
                      Icons.extension,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    GestureDetector(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(175, 123, 251, 1),
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.black)),
                        child: const Row(
                          children: [
                            Icon(Icons.add_circle_outlined),
                            Text("Create new",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              : Container()
        ],
      ),
    );
  }
}
