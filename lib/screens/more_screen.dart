import 'package:flutter/material.dart';

import '../widgets/placeholder_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'More',
      description: 'More will contain reports, checklists, settings, and later features.',
      icon: Icons.more_horiz,
    );
  }
}