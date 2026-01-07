class DeliveryPartnerProfile {
  bool? success;
  String? message;
  ProfileData? data;

  DeliveryPartnerProfile({this.success, this.message, this.data});

  factory DeliveryPartnerProfile.fromJson(Map<String, dynamic> json) {
    return DeliveryPartnerProfile(
      success: json["success"],
      message: json["message"],
      data: json["data"] != null ? ProfileData.fromJson(json["data"]) : null,
    );
  }
}

class ProfileData {
  String? id;
  String? name;
  String? phone;
  String? email;
  String? vehicleType;
  Restaurant? restaurant;
  bool? isActive;
  bool? isOnline;
  bool? isAvailable;
  CurrentLocation? currentLocation;
  Kyc? kyc;
  int? totalOrders;
  String? createdAt;

  ProfileData({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.vehicleType,
    this.restaurant,
    this.isActive,
    this.isOnline,
    this.isAvailable,
    this.currentLocation,
    this.kyc,
    this.totalOrders,
    this.createdAt,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json["id"],
      name: json["name"],
      phone: json["phone"],
      email: json["email"],
      vehicleType: json["vehicleType"],
      restaurant:
          json["restaurant"] != null ? Restaurant.fromJson(json["restaurant"]) : null,
      isActive: json["isActive"],
      isOnline: json["isOnline"],
      isAvailable: json["isAvailable"],
      currentLocation: json["currentLocation"] != null
          ? CurrentLocation.fromJson(json["currentLocation"])
          : null,
      kyc: json["kyc"] != null ? Kyc.fromJson(json["kyc"]) : null,
      totalOrders: json["totalOrders"],
      createdAt: json["createdAt"],
    );
  }
}

class Restaurant {
  String? id;
  String? name;
  Map<String, dynamic>? address;
  Map<String, dynamic>? location;

  Restaurant({this.id, this.name, this.address, this.location});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json["id"],
      name: json["name"],
      address: json["address"] ?? {},
      location: json["location"] ?? {},
    );
  }
}

class CurrentLocation {
  String? type;
  List<double>? coordinates;
  String? updatedAt;

  CurrentLocation({this.type, this.coordinates, this.updatedAt});

  factory CurrentLocation.fromJson(Map<String, dynamic> json) {
    return CurrentLocation(
      type: json["type"],
      coordinates: json["coordinates"] != null
          ? List<double>.from(json["coordinates"].map((x) => x.toDouble()))
          : [],
      updatedAt: json["updatedAt"],
    );
  }
}

class Kyc {
  String? status;
  DocumentData? aadhaar;
  DocumentData? pan;
  DocumentData? drivingLicense;

  Kyc({this.status, this.aadhaar, this.pan, this.drivingLicense});

  factory Kyc.fromJson(Map<String, dynamic> json) {
    return Kyc(
      status: json["status"],
      aadhaar: json["aadhaar"] != null
          ? DocumentData.fromJson(json["aadhaar"])
          : null,
      pan: json["pan"] != null ? DocumentData.fromJson(json["pan"]) : null,
      drivingLicense: json["drivingLicense"] != null
          ? DocumentData.fromJson(json["drivingLicense"])
          : null,
    );
  }
}

class DocumentData {
  String? number;
  String? documentUrl;
  bool? verified;

  DocumentData({this.number, this.documentUrl, this.verified});

  factory DocumentData.fromJson(Map<String, dynamic> json) {
    return DocumentData(
      number: json["number"],
      documentUrl: json["documentUrl"],
      verified: json["verified"],
    );
  }
}
