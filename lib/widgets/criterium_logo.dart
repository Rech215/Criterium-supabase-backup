import 'package:flutter/material.dart';

class CriteriumLogo extends StatelessWidget {
  final double size;
  const CriteriumLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
    );
  }
}
