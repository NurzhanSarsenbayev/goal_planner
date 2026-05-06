import 'package:flutter/material.dart';

import '../../../../models/planner_task.dart';

class TodayTaskSection extends StatelessWidget {
  const TodayTaskSection({
    required this.title,
    required this.icon,
    required this.tasks,
    required this.itemBuilder,
    this.emptyText,
    super.key,
  });

  final String title;
  final IconData icon;
  final List<PlannerTask> tasks;
  final Widget Function(PlannerTask task) itemBuilder;
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (tasks.isEmpty)
          _EmptySectionText(text: emptyText ?? 'Nothing here.')
        else
          for (final task in tasks) ...[
            itemBuilder(task),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _EmptySectionText extends StatelessWidget {
  const _EmptySectionText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
