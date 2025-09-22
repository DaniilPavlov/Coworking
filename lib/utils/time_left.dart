class TimeLeft {
  String timeLeft(DateTime due) {
    String retVal;
    final Duration timeUntilDue = due.difference(DateTime.now());
    final int daysUntil = timeUntilDue.inDays;
    final int hoursUntil = timeUntilDue.inHours - (daysUntil * 24);
    final int minUntil = timeUntilDue.inMinutes - (daysUntil * 24 * 60) - (hoursUntil * 60);
    if (daysUntil > 0) {
      retVal = 'дней: $daysUntil, часов: $hoursUntil, минут: $minUntil';
    } else if (hoursUntil > 0) {
      retVal = ' часов: $hoursUntil, минут: $minUntil';
    } else if (minUntil > 0) {
      retVal = ', минут: $minUntil';
    } else if (minUntil == 0) {
      retVal = 'До встречи осталось менее минуты';
    } else {
      retVal = 'Встреча уже началась!';
    }
    return retVal;
  }
}
