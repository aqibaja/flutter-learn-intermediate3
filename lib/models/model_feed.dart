class ModelFeed {
  String username;
  String uid;
  String uavatarUrl;
  String imageUrl;
  String desc;
  ModelFeed(this.username, this.uid, this.uavatarUrl, this.imageUrl, this.desc);
  ModelFeed.map(dynamic obj) {
    this.username = obj['username'];
    this.uid = obj['password'];
    this.uavatarUrl = obj['gender'];
    this.imageUrl = obj['emailid'];
    this.desc = obj['desc'];
  }
  /* String get username => username;
  String get uid => uid;
  String get uavatarUrl => uavatarUrl;
  String get imageUrl => imageUrl;
  String get desc => desc; */
  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['username'] = username;
    map['uid'] = uid;
    map['uavatarUrl'] = uavatarUrl;
    map['imageUrl'] = imageUrl;
    map['desc'] = desc;
    return map;
  }

  ModelFeed.fromMap(Map<String, dynamic> map) {
    this.username = map['username'];
    this.uid = map['uid'];
    this.uavatarUrl = map['uavatarUrl'];
    this.imageUrl = map['imageUrl'];
    this.desc = map['desc'];
  }
}
