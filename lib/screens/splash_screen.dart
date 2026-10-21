import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Branded loading screen shown while the database opens.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light,
    child: Container(
      color: const Color(0xFF00412E),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icon/app_icon_foreground.png',
            width: 150,
            height: 150,
            filterQuality: FilterQuality.medium,
          ),
          const SizedBox(height: 18),
          const Text(
            'Material Tracker',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Hitung muatan • catat rit',
            style: TextStyle(color: Color(0xFF96BF8A), fontSize: 13),
          ),
        ],
      ),
    ),
  );
}
