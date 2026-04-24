import 'package:flutter/material.dart';

import '../widgets/placeholder_screen.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Calendar',
      description: 'Calendar will show tasks and plans by date.',
      icon: Icons.calendar_month,
    );
  }
}