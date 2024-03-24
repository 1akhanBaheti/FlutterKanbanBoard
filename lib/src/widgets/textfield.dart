import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TField extends ConsumerStatefulWidget {
  const TField({super.key});

  @override
  ConsumerState<TField> createState() => _TFieldState();
}

class _TFieldState extends ConsumerState<TField> {
  var node = FocusNode();
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
          disabledBorder: OutlineInputBorder(borderSide: BorderSide.none)),
      autofocus: true,
      enabled: true,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      controller: _controller,
      focusNode: node,
    );
  }
}
