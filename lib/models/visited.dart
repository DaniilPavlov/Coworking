class Visited {
  String user;
  String pin;

  Visited(String user, String pin) {
    this.user = user;
    this.pin = pin;
  }

  Map<String, dynamic> asMap() {
    Map<String, dynamic> accountMap = Map();
    accountMap["userID"] = user;
    accountMap["pin"] = pin;
    return accountMap;
  }
}
