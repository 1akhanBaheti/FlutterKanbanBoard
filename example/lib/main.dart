import 'package:flutter/material.dart';
import 'kanban/board_builder.dart';

void main() {
  runApp(
    const Example(),
  );
}

class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: KanbanCanvas(),
    );
  }
}
