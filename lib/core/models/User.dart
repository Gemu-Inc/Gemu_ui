class User {
  String name;
  String uID;

  User.simple(this.name, this.uID);

  User({this.name, this.uID});

  User.empty();

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        uID = json['uID'];

  Map<String, dynamic> toJson() => {'name': name, 'uID': uID};
}
