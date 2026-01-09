// class DeliveryPartnerProfile {
//   bool? success;
//   String? message;
//   ProfileData? data;

//   DeliveryPartnerProfile({this.success, this.message, this.data});

//   factory DeliveryPartnerProfile.fromJson(Map<String, dynamic> json) {
//     return DeliveryPartnerProfile(
//       success: json["success"],
//       message: json["message"],
//       data: json["data"] != null ? ProfileData.fromJson(json["data"]) : null,
//     );
//   }
// }

// class ProfileData {
//   String? id;
//   String? name;
//   String? phone;
//   String? email;

//   // Basic Profile
//   String? dob;
//   String? gender;
//   Address? address;
//   String? profileImage;

//   // Vehicle
//   String? vehicleType;
//   String? vehicleNumber;

//   // KYC Numbers
//   String? aadhaarNumber;
//   String? panNumber;
//   String? drivingLicenseNumber;

//   List<BankDetail>? bankDetails;

//   // Old fields
//   Restaurant? restaurant;
//   bool? isActive;
//   bool? isOnline;
//   bool? isAvailable;
//   CurrentLocation? currentLocation;

//   Kyc? kyc;
//   int? totalOrders;
//   String? createdAt;

//   ProfileData({
//     this.id,
//     this.name,
//     this.phone,
//     this.email,
//     this.dob,
//     this.gender,
//     this.address,
//     this.profileImage,
//     this.vehicleType,
//     this.vehicleNumber,
//     this.aadhaarNumber,
//     this.panNumber,
//     this.drivingLicenseNumber,
//     this.bankDetails,
//     this.restaurant,
//     this.isActive,
//     this.isOnline,
//     this.isAvailable,
//     this.currentLocation,
//     this.kyc,
//     this.totalOrders,
//     this.createdAt,
//   });

//   factory ProfileData.fromJson(Map<String, dynamic> json) {
//     return ProfileData(
//       id: json["_id"],
//       name: json["name"],
//       phone: json["phone"] ?? json["mobile"],
//       email: json["email"],

//       dob: json["dob"],
//       gender: json["gender"],
//       profileImage: json["profileImage"],

//       // Address is an object
//       address: json["address"] != null ? Address.fromJson(json["address"]) : null,

//       vehicleType: json["vehicleType"],
//       vehicleNumber: json["vehicleNumber"],

//       // API puts KYC numbers inside: kyc → aadhaarNumber, panNumber...
//       aadhaarNumber: json["kyc"]?["aadhaarNumber"],
//       panNumber: json["kyc"]?["panNumber"],
//       drivingLicenseNumber: json["kyc"]?["drivingLicenseNumber"],

//       // KYC Full Object (documents)
//       kyc: json["kyc"] != null ? Kyc.fromJson(json["kyc"]) : null,

//       restaurant:
//           json["restaurant"] != null ? Restaurant.fromJson(json["restaurant"]) : null,

//       isActive: json["isActive"],
//       isOnline: json["isOnline"],
//       isAvailable: json["isAvailable"],

//       currentLocation: json["currentLocation"] != null
//           ? CurrentLocation.fromJson(json["currentLocation"])
//           : null,

//       totalOrders: json["totalOrders"],
//       createdAt: json["createdAt"],

//       bankDetails: json["bankDetails"] != null
//           ? List<BankDetail>.from(
//               json["bankDetails"].map((x) => BankDetail.fromJson(x)))
//           : [],
//     );
//   }
// }

// // ---------------- ADDRESS MODEL ----------------
// class Address {
//   String? line1;
//   String? line2;
//   String? city;
//   String? state;
//   String? pincode;

//   Address({this.line1, this.line2, this.city, this.state, this.pincode});

//   factory Address.fromJson(Map<String, dynamic> json) {
//     return Address(
//       line1: json["line1"],
//       line2: json["line2"],
//       city: json["city"],
//       state: json["state"],
//       pincode: json["pincode"],
//     );
//   }
// }

// // ---------------- KYC MODEL ----------------
// class Kyc {
//   String? aadhaarNumber;
//   String? panNumber;
//   String? drivingLicenseNumber;

//   KycDocuments? documents;
//   String? status;

//   Kyc({
//     this.aadhaarNumber,
//     this.panNumber,
//     this.drivingLicenseNumber,
//     this.documents,
//     this.status,
//   });

//   factory Kyc.fromJson(Map<String, dynamic> json) {
//     return Kyc(
//       aadhaarNumber: json["aadhaarNumber"],
//       panNumber: json["panNumber"],
//       drivingLicenseNumber: json["drivingLicenseNumber"],
//       status: json["status"],
//       documents: json["documents"] != null
//           ? KycDocuments.fromJson(json["documents"])
//           : null,
//     );
//   }
// }

// class KycDocuments {
//   String? aadhaarFront;
//   String? aadhaarBack;
//   String? panCard;
//   String? drivingLicense;

//   KycDocuments({
//     this.aadhaarFront,
//     this.aadhaarBack,
//     this.panCard,
//     this.drivingLicense,
//   });

//   factory KycDocuments.fromJson(Map<String, dynamic> json) {
//     return KycDocuments(
//       aadhaarFront: json["aadhaarFront"],
//       aadhaarBack: json["aadhaarBack"],
//       panCard: json["panCard"],
//       drivingLicense: json["drivingLicense"],
//     );
//   }
// }

// // ---------------- RESTAURANT MODEL ----------------
// class Restaurant {
//   String? id;
//   String? name;

//   Restaurant({this.id, this.name});

//   factory Restaurant.fromJson(Map<String, dynamic> json) {
//     return Restaurant(
//       id: json["id"] ?? json["_id"],
//       name: json["name"],
//     );
//   }
// }

// // ---------------- CURRENT LOCATION ----------------
// class CurrentLocation {
//   String? type;
//   List<double>? coordinates;
//   String? updatedAt;

//   CurrentLocation({this.type, this.coordinates, this.updatedAt});

//   factory CurrentLocation.fromJson(Map<String, dynamic> json) {
//     return CurrentLocation(
//       type: json["type"],
//       coordinates: json["coordinates"] != null
//           ? List<double>.from(json["coordinates"].map((e) => e.toDouble()))
//           : [],
//       updatedAt: json["updatedAt"],
//     );
//   }
// }

// // ---------------- BANK DETAILS ----------------
// class BankDetail {
//   String? holderName;
//   String? accountNumber;
//   String? ifscCode;
//   String? mobile;
//   String? qrImage;

//   BankDetail({
//     this.holderName,
//     this.accountNumber,
//     this.ifscCode,
//     this.mobile,
//     this.qrImage,
//   });

//   factory BankDetail.fromJson(Map<String, dynamic> json) {
//     return BankDetail(
//       holderName: json["holderName"],
//       accountNumber: json["accountNumber"],
//       ifscCode: json["ifscCode"],
//       mobile: json["mobile"],
//       qrImage: json["qrImage"],
//     );
//   }
// }



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
  String? name;
  String? phone;
  String? email;
  String? profileImage;

  String? dob;
  String? gender;

  String? vehicleType;
  String? vehicleNumber;

  Address? address;
  Kyc? kyc;

  bool? isActive;
  bool? isOnline;
  bool? isAvailable;

  String? createdAt;
  String? lastOnlineAt;

  Restaurant? restaurant;

  ProfileData({
    this.name,
    this.phone,
    this.email,
    this.profileImage,
    this.dob,
    this.gender,
    this.vehicleType,
    this.vehicleNumber,
    this.address,
    this.kyc,
    this.isActive,
    this.isOnline,
    this.isAvailable,
    this.createdAt,
    this.lastOnlineAt,
    this.restaurant,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      name: json["name"],
      phone: json["phone"],
      email: json["email"],
      profileImage: json["profileImage"],

      dob: json["dob"],
      gender: json["gender"],

      vehicleType: json["vehicleType"],
      vehicleNumber: json["vehicleNumber"],

      address:
          json["address"] != null ? Address.fromJson(json["address"]) : null,

      kyc: json["kyc"] != null ? Kyc.fromJson(json["kyc"]) : null,

      isActive: json["isActive"],
      isOnline: json["isOnline"],
      isAvailable: json["isAvailable"],

      createdAt: json["createdAt"],
      lastOnlineAt: json["lastOnlineAt"],

      restaurant: json["restaurant"] != null
          ? Restaurant.fromJson(json["restaurant"])
          : null,
    );
  }
}

class Address {
  String? line1;
  String? line2;
  String? city;
  String? state;
  String? pincode;

  Address({
    this.line1,
    this.line2,
    this.city,
    this.state,
    this.pincode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      line1: json["line1"],
      line2: json["line2"],
      city: json["city"],
      state: json["state"],
      pincode: json["pincode"],
    );
  }
}

class Kyc {
  String? aadhaarNumber;
  String? panNumber;
  String? drivingLicenseNumber;

  KycDocuments? documents;
  String? status;

  Kyc({
    this.aadhaarNumber,
    this.panNumber,
    this.drivingLicenseNumber,
    this.documents,
    this.status,
  });

  factory Kyc.fromJson(Map<String, dynamic> json) {
    return Kyc(
      aadhaarNumber: json["aadhaarNumber"],
      panNumber: json["panNumber"],
      drivingLicenseNumber: json["drivingLicenseNumber"],
      status: json["status"],
      documents: json["documents"] != null
          ? KycDocuments.fromJson(json["documents"])
          : null,
    );
  }
}

class KycDocuments {
  String? aadhaarFront;
  String? aadhaarBack;
  String? panCard;
  String? drivingLicense;

  KycDocuments({
    this.aadhaarFront,
    this.aadhaarBack,
    this.panCard,
    this.drivingLicense,
  });

  factory KycDocuments.fromJson(Map<String, dynamic> json) {
    return KycDocuments(
      aadhaarFront: json["aadhaarFront"],
      aadhaarBack: json["aadhaarBack"],
      panCard: json["panCard"],
      drivingLicense: json["drivingLicense"],
    );
  }
}

class Restaurant {
  String? id;
  String? name;

  Restaurant({this.id, this.name});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json["id"] ?? json["_id"],
      name: json["name"],
    );
  }
}

