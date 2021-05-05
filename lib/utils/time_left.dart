class TimeLeft {
  String timeLeft(DateTime due) {
    String retVal;
    Duration _timeUntilDue = due.difference(DateTime.now());
    int _daysUntil = _timeUntilDue.inDays;
    int _hoursUntil = _timeUntilDue.inHours - (_daysUntil * 24);
    int _minUntil =
        _timeUntilDue.inMinutes - (_daysUntil * 24 * 60) - (_hoursUntil * 60);
    if (_daysUntil > 0) {
      retVal = "дней: " +
          _daysUntil.toString() +
          ", часов: " +
          _hoursUntil.toString() +
          ", минут: " +
          _minUntil.toString();
    } else if (_hoursUntil > 0) {
      retVal = " часов: " +
          _hoursUntil.toString() +
          ", минут: " +
          _minUntil.toString();
    } else if (_minUntil > 0) {
      retVal = ", минут: " + _minUntil.toString();
    } else if (_minUntil == 0) {
      retVal = "До встречи осталось менее минуты";
    } else {
      retVal = "Ошибка";
    }
    return retVal;
  }
}
