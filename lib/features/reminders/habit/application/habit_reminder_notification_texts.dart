class HabitReminderNotificationTexts {
  HabitReminderNotificationTexts({String habitReminderBody = 'Habit reminder'})
    : _habitReminderBody = habitReminderBody;

  String _habitReminderBody;

  String get habitReminderBody => _habitReminderBody;

  void update({required String habitReminderBody}) {
    _habitReminderBody = habitReminderBody;
  }
}
