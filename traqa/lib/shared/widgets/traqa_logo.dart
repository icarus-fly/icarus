import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TraqaLogo extends StatelessWidget {
  final double size;
  const TraqaLogo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logo/traqa_logo.svg',
      width: size,
      height: size,
    );
  }
}