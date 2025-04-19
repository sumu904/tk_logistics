class User {
  int? id;
  String? username;
  String? email;
  String? token;
  int? designationId;
  String? firstName;
  String? lastName;
  bool? isActive;
  dynamic access; // Changed from Null? to dynamic?
  dynamic zone;
  String? image;
  dynamic accessControl;
  String? userType;
  dynamic homeLat;
  dynamic homeLong;
  dynamic ziId;
  dynamic ciId;
  String? xwh;

  User({
    this.id,
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
    this.xwh,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    username = json['username'] ?? "";
    email = json['email'] ?? "";
    token = json['token'] ?? "";
    designationId = json['designation_id'] ?? 0;
    firstName = json['first_name'] ?? "";
    lastName = json['last_name'] ?? "";
    isActive = json['is_active'] ?? false;
    access = json['access']; // Now handles both null and non-null values
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
    return {
      'id': id,
      'username': username,
      'email': email,
      'token': token,
      'designation_id': designationId,
      'first_name': firstName,
      'last_name': lastName,
      'is_active': isActive,
      'access': access,
      'zone': zone,
      'image': image,
      'access_control': accessControl,
      'user_type': userType,
      'home_lat': homeLat,
      'home_long': homeLong,
      'zi_id': ziId,
      'ci_id': ciId,
      'xwh': xwh,
    };
  }
}
