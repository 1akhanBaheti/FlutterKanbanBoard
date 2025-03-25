import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CardWithTextField extends ConsumerStatefulWidget {
  const CardWithTextField({
    this.onCompleteEditing,
    super.key,
  });
  final void Function(String)? onCompleteEditing;
  @override
  ConsumerState<CardWithTextField> createState() => _TFieldState();
}

class _TFieldState extends ConsumerState<CardWithTextField> {
  var node = FocusNode();
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        hintText: 'Enter your text here',
        enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
        disabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
      ),
      autofocus: true,
      enabled: true,
      maxLines: 3,
      keyboardType: TextInputType.text,
      controller: _controller,
      focusNode: node,
      onFieldSubmitted: (text) => widget.onCompleteEditing?.call(text),
    );
  }
}
