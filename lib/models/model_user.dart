class ModelUser {
  int _id;
  String _username;
  String _password;
  String _gender;
  String _emailId;
  ModelUser(this._username, this._password, this._gender, this._emailId);
  ModelUser.map(dynamic obj) {
    this._id = obj['id'];
    this._username = obj['username'];
    this._password = obj['password'];
    this._gender = obj['gender'];
    this._emailId = obj['emailid'];
  }
  int get id => _id;
  String get username => _username;
  String get password => _password;
  String get gender => _gender;
  String get emailid => _emailId;
  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['username'] = _username;
    map['password'] = _password;
    map['gender'] = _gender;
    map['emailid'] = _emailId;
    return map;
  }

  ModelUser.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._username = map['username'];
    this._password = map['password'];
    this._gender = map['gender'];
    this._emailId = map['emailid'];
  }
}
