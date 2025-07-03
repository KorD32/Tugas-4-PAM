import 'package:flutter/material.dart';

class SectionTitleWidget extends StatelessWidget {
  final String title;
  const SectionTitleWidget({required this.title, super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 14, 0, 8),
    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
  );
}
