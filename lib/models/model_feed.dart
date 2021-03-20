class ModelFeed {
  String username;
  String uid;
  String uavatarUrl;
  String imageUrl;
  String desc;
  String date;
  String title;
  String favorite;
  ModelFeed(this.username, this.uid, this.uavatarUrl, this.imageUrl, this.desc,
      this.date, this.title);
  ModelFeed.map(dynamic obj) {
    this.username = obj['username'];
    this.uid = obj['password'];
    this.uavatarUrl = obj['gender'];
    this.imageUrl = obj['emailid'];
    this.desc = obj['desc'];
    this.date = obj['date'];
    this.title = obj['title'];
    this.favorite = obj['favorite'];
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
    map['date'] = date;
    map['title'] = title;
    map['favorite'] = favorite;
    return map;
  }

  ModelFeed.fromMap(Map<String, dynamic> map) {
    this.username = map['username'];
    this.uid = map['uid'];
    this.uavatarUrl = map['uavatarUrl'];
    this.imageUrl = map['imageUrl'];
    this.desc = map['desc'];
    this.date = map['date'];
    this.title = map['title'];
    this.favorite = map['favorite'];
  }
}
