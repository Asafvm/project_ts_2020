import 'package:cloud_firestore/cloud_firestore.dart';

class Site {
  String name;
  Address address;
  //List<Contact> contacts; //TBA

  Site({this.name, this.address});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address.toJson(),
    };
  }

  Site.fromJson(Map<String, dynamic> data)
      : name = data['name'].toString().trim(),
        address = Address.fromJson(data['address']);

  factory Site.fromFirestore(DocumentSnapshot documentSnapshot) {
    return Site.fromJson(documentSnapshot.data());
  }
}

class Address {
  final double latitude;
  final double longtitude;
  final String country;
  final String area;
  final String city;
  final String street;
  final String houseNumber;

  Address(this.latitude, this.longtitude,
      {this.country = '',
      this.area = '',
      this.city = '',
      this.street = '',
      this.houseNumber = ''});

  double get lat {
    return latitude;
  }

  double get lng {
    return longtitude;
  }

  @override
  String toString() {
    return '$street $houseNumber, $city, $country';
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': latitude,
      'lng': longtitude,
      'country': country ?? '',
      'area': area ?? '',
      'city': city ?? '',
      'street': street ?? '',
      'housenum': houseNumber ?? ''
    };
  }

  Address.fromJson(Map<String, dynamic> data)
      : latitude = double.parse(data['lat'].toString()),
        longtitude = double.parse(data['lng'].toString()),
        country = data['country'],
        area = data['area'],
        city = data['city'],
        street = data['street'],
        houseNumber = data['housenum'];

  factory Address.fromFirestore(DocumentSnapshot documentSnapshot) {
    return Address.fromJson(documentSnapshot.data());
  }
}
