import 'dart:convert';

class AssignedOrderResponse {
  bool? success;
  OrderData? data;

  AssignedOrderResponse({this.success, this.data});

  factory AssignedOrderResponse.fromJson(Map<String, dynamic> json) {
    return AssignedOrderResponse(
      success: json['success'],
      data: json['data'] != null ? OrderData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data?.toJson()};
  }

  // ✅ ADD THIS (SOCKET SAFE JSON)
  Map<String, dynamic> toSocketJson() {
    return jsonDecode(jsonEncode(toJson()));
  }
}

class OrderData {
  Order? order;
  Customer? customer;
  DeliveryAddress? deliveryAddress;
  Restaurant? restaurant;
  List<OrderItem>? items;
  String? assignedAt;

  OrderData({
    this.order,
    this.customer,
    this.deliveryAddress,
    this.restaurant,
    this.items,
    this.assignedAt,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      order: json['order'] != null ? Order.fromJson(json['order']) : null,
      customer: json['customer'] != null
          ? Customer.fromJson(json['customer'])
          : null,
      deliveryAddress: json['deliveryAddress'] != null
          ? DeliveryAddress.fromJson(json['deliveryAddress'])
          : null,
      restaurant: json['restaurant'] != null
          ? Restaurant.fromJson(json['restaurant'])
          : null,
      items: json['items'] != null
          ? (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList()
          : null,
      assignedAt: json['assignedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order?.toJson(),
      'customer': customer?.toJson(),
      'deliveryAddress': deliveryAddress?.toJson(),
      'restaurant': restaurant?.toJson(),
      'items': items?.map((e) => e.toJson()).toList(),
      'assignedAt': assignedAt,
    };
  }
}

class Order {
  String? id;
  String? orderId;
  String? status;
  List<OrderTimeline>? timeline;
  num? total;
  Payment? payment;

  Order({
    this.id,
    this.orderId,
    this.status,
    this.timeline,
    this.total,
    this.payment,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderId: json['orderId'],
      status: json['status'],
      timeline: json['timeline'] != null
          ? (json['timeline'] as List)
                .map((e) => OrderTimeline.fromJson(e))
                .toList()
          : null,
      total: json['total'],
      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'status': status,
      'timeline': timeline?.map((e) => e.toJson()).toList(),
      'total': total,
      'payment': payment?.toJson(),
    };
  }
}

class OrderTimeline {
  String? status;
  String? at;

  OrderTimeline({this.status, this.at});

  factory OrderTimeline.fromJson(Map<String, dynamic> json) {
    return OrderTimeline(status: json['status'], at: json['at']);
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'at': at};
  }
}

class Payment {
  String? method;
  String? status;

  Payment({this.method, this.status});

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(method: json['method'], status: json['status']);
  }

  Map<String, dynamic> toJson() {
    return {'method': method, 'status': status};
  }
}

class Customer {
  String? name;
  String? phone;

  Customer({this.name, this.phone});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(name: json['name'], phone: json['phone']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'phone': phone};
  }
}

class DeliveryAddress {
  String? name;
  String? phone;
  String? addressLine;
  String? city;
  String? pincode;
  double? lat;
  double? lng;

  DeliveryAddress({
    this.name,
    this.phone,
    this.addressLine,
    this.city,
    this.pincode,
    this.lat,
    this.lng,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      name: json['name'],
      phone: json['phone'],
      addressLine: json['addressLine'],
      city: json['city'],
      pincode: json['pincode'],
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'addressLine': addressLine,
      'city': city,
      'pincode': pincode,
      'lat': lat,
      'lng': lng,
    };
  }
}

class Restaurant {
  String? id;
  String? name;

  Restaurant({this.id, this.name});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class OrderItem {
  ItemInfo? itemId;
  String? name;
  int? quantity;
  num? basePrice;
  List<dynamic>? addons;
  num? finalItemPrice;

  OrderItem({
    this.itemId,
    this.name,
    this.quantity,
    this.basePrice,
    this.addons,
    this.finalItemPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemId: json['itemId'] != null ? ItemInfo.fromJson(json['itemId']) : null,
      name: json['name'],
      quantity: json['quantity'],
      basePrice: json['basePrice'],
      addons: json['addons'],
      finalItemPrice: json['finalItemPrice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId?.toJson(),
      'name': name,
      'quantity': quantity,
      'basePrice': basePrice,
      'addons': addons,
      'finalItemPrice': finalItemPrice,
    };
  }
}

class ItemInfo {
  String? id;
  String? name;

  ItemInfo({this.id, this.name});

  factory ItemInfo.fromJson(Map<String, dynamic> json) {
    return ItemInfo(id: json['_id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name};
  }
}
