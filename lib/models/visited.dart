class Visited {
  late String user;
  late String pin;

  Visited(this.user, this.pin);

  Map<String, dynamic> asMap() {
    Map<String, dynamic> accountMap = {};
    accountMap["userID"] = user;
    accountMap["pin"] = pin;
    return accountMap;
  }
}
