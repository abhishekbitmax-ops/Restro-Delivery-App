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
  DeliveryPartnerData? data;

  DeliveryPartnerProfile({this.success, this.message, this.data});

  factory DeliveryPartnerProfile.fromJson(Map<String, dynamic> json) {
    return DeliveryPartnerProfile(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? DeliveryPartnerData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
  };
}

class DeliveryPartnerData {
  String? name;
  String? phone;
  String? email;
  String? profileImage;
  String? dob;
  String? gender;

  Vehicle? vehicle;
  Address? address;
  Kyc? kyc;

  bool? isActive;
  bool? isOnline;
  bool? isAvailable;
  String? status;

  Stats? stats;
  Earnings? earnings;
  Availability? availability;

  String? createdAt;
  String? lastOnlineAt;

  Restaurant? restaurant;

  DeliveryPartnerData({
    this.name,
    this.phone,
    this.email,
    this.profileImage,
    this.dob,
    this.gender,
    this.vehicle,
    this.address,
    this.kyc,
    this.isActive,
    this.isOnline,
    this.isAvailable,
    this.status,
    this.stats,
    this.earnings,
    this.availability,
    this.createdAt,
    this.lastOnlineAt,
    this.restaurant,
  });

  factory DeliveryPartnerData.fromJson(Map<String, dynamic> json) {
    return DeliveryPartnerData(
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      profileImage: json['profileImage'],
      dob: json['dob'],
      gender: json['gender'],
      vehicle: json['vehicle'] != null
          ? Vehicle.fromJson(json['vehicle'])
          : null,
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : null,
      kyc: json['kyc'] != null ? Kyc.fromJson(json['kyc']) : null,
      isActive: json['isActive'],
      isOnline: json['isOnline'],
      isAvailable: json['isAvailable'],
      status: json['status'],
      stats: json['stats'] != null ? Stats.fromJson(json['stats']) : null,
      earnings: json['earnings'] != null
          ? Earnings.fromJson(json['earnings'])
          : null,
      availability: json['availability'] != null
          ? Availability.fromJson(json['availability'])
          : null,
      createdAt: json['createdAt'],
      lastOnlineAt: json['lastOnlineAt'],
      restaurant: json['restaurant'] != null
          ? Restaurant.fromJson(json['restaurant'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'email': email,
    'profileImage': profileImage,
    'dob': dob,
    'gender': gender,
    'vehicle': vehicle?.toJson(),
    'address': address?.toJson(),
    'kyc': kyc?.toJson(),
    'isActive': isActive,
    'isOnline': isOnline,
    'isAvailable': isAvailable,
    'status': status,
    'stats': stats?.toJson(),
    'earnings': earnings?.toJson(),
    'availability': availability?.toJson(),
    'createdAt': createdAt,
    'lastOnlineAt': lastOnlineAt,
    'restaurant': restaurant?.toJson(),
  };
}

class Vehicle {
  String? type;
  String? number;
  String? model;

  Vehicle({this.type, this.number, this.model});

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      Vehicle(type: json['type'], number: json['number'], model: json['model']);

  Map<String, dynamic> toJson() => {
    'type': type,
    'number': number,
    'model': model,
  };
}

class Address {
  String? type;
  String? street;
  String? area;
  String? city;
  String? state;
  String? zipCode;
  Coordinates? coordinates;

  Address({
    this.type,
    this.street,
    this.area,
    this.city,
    this.state,
    this.zipCode,
    this.coordinates,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    type: json['type'],
    street: json['street'],
    area: json['area'],
    city: json['city'],
    state: json['state'],
    zipCode: json['zipCode'],
    coordinates: json['coordinates'] != null
        ? Coordinates.fromJson(json['coordinates'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'street': street,
    'area': area,
    'city': city,
    'state': state,
    'zipCode': zipCode,
    'coordinates': coordinates?.toJson(),
  };
}

class Coordinates {
  double? lat;
  double? lng;

  Coordinates({this.lat, this.lng});

  factory Coordinates.fromJson(Map<String, dynamic> json) => Coordinates(
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
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

  factory Kyc.fromJson(Map<String, dynamic> json) => Kyc(
    aadhaarNumber: json['aadhaarNumber'],
    panNumber: json['panNumber'],
    drivingLicenseNumber: json['drivingLicenseNumber'],
    documents: json['documents'] != null
        ? KycDocuments.fromJson(json['documents'])
        : null,
    status: json['status'],
  );

  Map<String, dynamic> toJson() => {
    'aadhaarNumber': aadhaarNumber,
    'panNumber': panNumber,
    'drivingLicenseNumber': drivingLicenseNumber,
    'documents': documents?.toJson(),
    'status': status,
  };
}

class KycDocuments {
  String? aadhaarFront;
  String? aadhaarBack;
  String? panCard;
  String? drivingLicense;
  String? vehicleRC;

  KycDocuments({
    this.aadhaarFront,
    this.aadhaarBack,
    this.panCard,
    this.drivingLicense,
    this.vehicleRC,
  });

  factory KycDocuments.fromJson(Map<String, dynamic> json) => KycDocuments(
    aadhaarFront: json['aadhaarFront'],
    aadhaarBack: json['aadhaarBack'],
    panCard: json['panCard'],
    drivingLicense: json['drivingLicense'],
    vehicleRC: json['vehicleRC'],
  );

  Map<String, dynamic> toJson() => {
    'aadhaarFront': aadhaarFront,
    'aadhaarBack': aadhaarBack,
    'panCard': panCard,
    'drivingLicense': drivingLicense,
    'vehicleRC': vehicleRC,
  };
}

class Stats {
  int? totalDeliveries;
  int? rating;
  int? onTimePercentage;

  Stats({this.totalDeliveries, this.rating, this.onTimePercentage});

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
    totalDeliveries: json['totalDeliveries'],
    rating: json['rating'],
    onTimePercentage: json['onTimePercentage'],
  );

  Map<String, dynamic> toJson() => {
    'totalDeliveries': totalDeliveries,
    'rating': rating,
    'onTimePercentage': onTimePercentage,
  };
}

class Earnings {
  int? today;
  int? thisWeek;
  int? total;

  Earnings({this.today, this.thisWeek, this.total});

  factory Earnings.fromJson(Map<String, dynamic> json) => Earnings(
    today: json['today'],
    thisWeek: json['thisWeek'],
    total: json['total'],
  );

  Map<String, dynamic> toJson() => {
    'today': today,
    'thisWeek': thisWeek,
    'total': total,
  };
}

class Availability {
  Map<String, DayAvailability>? days;

  Availability({this.days});

  factory Availability.fromJson(Map<String, dynamic> json) {
    final map = <String, DayAvailability>{};
    json.forEach((key, value) {
      map[key] = DayAvailability.fromJson(value);
    });
    return Availability(days: map);
  }

  Map<String, dynamic> toJson() =>
      days?.map((k, v) => MapEntry(k, v.toJson())) ?? {};
}

class DayAvailability {
  String? start;
  String? end;

  DayAvailability({this.start, this.end});

  factory DayAvailability.fromJson(Map<String, dynamic> json) =>
      DayAvailability(start: json['start'], end: json['end']);

  Map<String, dynamic> toJson() => {'start': start, 'end': end};
}

class Restaurant {
  String? id;
  String? name;
  Map<String, dynamic>? address;
  RestaurantLocation? location;

  Restaurant({this.id, this.name, this.address, this.location});

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
    id: json['id'],
    name: json['name'],
    address: json['address'],
    location: json['location'] != null
        ? RestaurantLocation.fromJson(json['location'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'location': location?.toJson(),
  };
}

class RestaurantLocation {
  String? type;
  Coordinates? coordinates;

  RestaurantLocation({this.type, this.coordinates});

  factory RestaurantLocation.fromJson(Map<String, dynamic> json) =>
      RestaurantLocation(
        type: json['type'],
        coordinates: json['coordinates'] != null
            ? Coordinates.fromJson(json['coordinates'])
            : null,
      );

  Map<String, dynamic> toJson() => {
    'type': type,
    'coordinates': coordinates?.toJson(),
  };
}

// order picked model class

class PickupOrderResponse {
  bool? success;
  String? message;
  PickupData? data;

  PickupOrderResponse({this.success, this.message, this.data});

  factory PickupOrderResponse.fromJson(Map<String, dynamic> json) {
    return PickupOrderResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? PickupData.fromJson(json['data']) : null,
    );
  }
}

class PickupData {
  String? orderId;
  String? currentStatus;
  String? pickedUpAt;
  List<PickupTimeline>? timeline;

  // Fallback fields (merged from assigned order)
  Map<String, dynamic>? customer;
  Map<String, dynamic>? deliveryAddress;
  List<dynamic>? items;
  dynamic totalAmount;

  PickupData({
    this.orderId,
    this.currentStatus,
    this.pickedUpAt,
    this.timeline,
    this.customer,
    this.deliveryAddress,
    this.items,
    this.totalAmount,
  });

  factory PickupData.fromJson(Map<String, dynamic> json) {
    return PickupData(
      orderId: json["orderId"] ?? json["order"]?["orderId"],
      currentStatus: json["currentStatus"],
      pickedUpAt: json["pickedUpAt"],

      timeline: json["timeline"] == null
          ? []
          : (json["timeline"] as List)
                .map((e) => PickupTimeline.fromJson(e))
                .toList(),

      // These come from PickupScreen merge
      customer: json["customer"],
      deliveryAddress: json["deliveryAddress"],
      items: json["items"],
      totalAmount: json["totalAmount"] ?? json["order"]?["total"],
    );
  }
}

class PickupTimeline {
  String? at;
  String? status;

  PickupTimeline({this.at, this.status});

  factory PickupTimeline.fromJson(Map<String, dynamic> json) {
    return PickupTimeline(at: json["at"]?.toString(), status: json["status"]);
  }
}


//assign order api model class 

