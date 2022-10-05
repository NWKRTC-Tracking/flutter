class User {
  late String username;
  late String password;
  User({required this.username, required this.password});

  User.map(dynamic obj) {
    username = obj["username"];
    password = obj["password"];
  }

  String get _username => username;
  String get _password => password;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["username"] = username;
    map["password"] = password;

    return map;
  }
}