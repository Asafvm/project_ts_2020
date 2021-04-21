import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';

class Site {
  String id;
  String name;
  Address address;
  List<Contact> contacts = [];

  Site({this.name, this.address});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address.toJson(),
    };
  }

  Site.fromJson(Map<String, dynamic> data, String id)
      : id = id,
        name = data['name'].toString().trim(),
        address = Address.fromJson(data['address']);

  factory Site.fromFirestore(DocumentSnapshot documentSnapshot) {
    return Site.fromJson(documentSnapshot.data(), documentSnapshot.id);
  }
}

class Room {
  String id = '';
  String building;
  String floor;
  String roomNumber;
  String roomTitle;
  String decription;
  List<String> instruments = [];

  Room({
    this.building = "",
    this.floor = "",
    this.roomNumber = "",
    this.roomTitle = "",
    this.decription = "",
  }) {
    this.instruments = [];
  }

  List<String> get getInstruments {
    return instruments;
  }

  void addInstrument(String instrumentId) {
    instruments.add(instrumentId);
  }

  @override
  String toString() {
    return '$building building, Floor: $floor, Room Number: $roomNumber';
  }

  Room.fromJson(Map<String, dynamic> data, String id)
      : id = id,
        building = data['building'],
        floor = data['floor'],
        roomNumber = data['roomNumber'],
        roomTitle = data['roomTitle'],
        decription = data['decription'],
        instruments =
            List<String>.from(data['instruments']) ?? [] as List<String>;

  factory Room.fromFirestore(DocumentSnapshot documentSnapshot) {
    return Room.fromJson(documentSnapshot.data(), documentSnapshot.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'building': building,
      'floor': floor,
      'roomNumber': roomNumber,
      'roomTitle': roomTitle,
      'decription': decription,
      'instruments': instruments ?? []
    };
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
