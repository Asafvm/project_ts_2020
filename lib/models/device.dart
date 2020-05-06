import 'package:cloud_firestore/cloud_firestore.dart';

class Device {
  final String manifacturer;
  final String codeNumber;
  final String codeName;
  final String model;
  final double price;

  Device(
      {this.manifacturer,
      this.codeNumber,
      this.codeName,
      this.model,
      this.price});

  Map<String, dynamic> toJson() => {
        'manifacturer': manifacturer,
        'codeNumber': codeNumber,
        'codeName': codeName,
        'model': model,
        'price': price,
      };

  Device.fromJson(Map<String, dynamic> data)
      : manifacturer = data['manifacturer'],
        codeNumber = data['codeNumber'],
        codeName = data['codeName'],
        model = data['model'],
        price = data['price'] as double;

  factory Device.fromFirestore(DocumentSnapshot documentSnapshot) {
    return Device.fromJson(documentSnapshot.data);
  }
}
