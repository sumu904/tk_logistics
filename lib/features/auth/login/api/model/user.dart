class User {
  int? id;
  String? username;
  String? email;
  String? token;
  int? designationId;
  String? firstName;
  String? lastName;
  bool? isActive;
  Null? access;
  Null? zone;
  String? image;
  Null? accessControl;
  String? userType;
  Null? homeLat;
  Null? homeLong;
  Null? ziId;
  Null? ciId;
  String? xwh;

  User(
      {this.id,
        this.username,
        this.email,
        this.token,
        this.designationId,
        this.firstName,
        this.lastName,
        this.isActive,
        this.access,
        this.zone,
        this.image,
        this.accessControl,
        this.userType,
        this.homeLat,
        this.homeLong,
        this.ziId,
        this.ciId,
        this.xwh});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    username = json['username'] ?? "";
    email = json['email'] ?? "";
    token = json['token'] ?? "";
    designationId = json['designation_id'] ?? 0;
    firstName = json['first_name'] ?? "";
    lastName = json['last_name'] ?? "";
    isActive = json['is_active'] ?? false;
    access = json['access'];  // Keep as is, since it's null in API
    zone = json['zone'];
    image = json['image'] ?? "";
    accessControl = json['access_control'];
    userType = json['user_type'] ?? "";
    homeLat = json['home_lat'];
    homeLong = json['home_long'];
    ziId = json['zi_id'];
    ciId = json['ci_id'];
    xwh = json['xwh'] ?? "";
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['email'] = this.email;
    data['token'] = this.token;
    data['designation_id'] = this.designationId;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['is_active'] = this.isActive;
    data['access'] = this.access;
    data['zone'] = this.zone;
    data['image'] = this.image;
    data['access_control'] = this.accessControl;
    data['user_type'] = this.userType;
    data['home_lat'] = this.homeLat;
    data['home_long'] = this.homeLong;
    data['zi_id'] = this.ziId;
    data['ci_id'] = this.ciId;
    data['xwh'] = this.xwh;
    return data;
  }
}