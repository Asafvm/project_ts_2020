import 'package:cloud_firestore/cloud_firestore.dart';

class Device {
  final String manifacturer;
  final String reference;
  final String codeName;
  final String model;
  final double price;

  Device(
      {this.manifacturer,
      this.reference,
      this.codeName,
      this.model = "",
      this.price = 0.0});

  Map<String, dynamic> toJson() => {
        'manifacturer': manifacturer,
        'reference': reference,
        'codeName': codeName,
        'model': model,
        'price': price,
      };

  Device.fromJson(Map<String, dynamic> data)
      : manifacturer = data['manifacturer'],
        reference = data['reference'],
        codeName = data['codeName'],
        model = data['model'],
        price = data['price'] as double;

  factory Device.fromFirestore(DocumentSnapshot documentSnapshot) {
    return Device.fromJson(documentSnapshot.data);
  }
}
