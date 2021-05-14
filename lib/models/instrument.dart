import 'package:cloud_firestore/cloud_firestore.dart';

class Instrument {
  String id = "";
  String manifacturer = "";
  String reference = "";
  String codeName = "";
  String model = "";
  double price = 0.0;
  String imgUrl;

  Instrument() {
    id = "";
    manifacturer = "";
    reference = "";
    codeName = "";
    model = "";
    price = 0.0;
  }

  String getManifacturer() {
    return this.manifacturer;
  }

  void setManifacturer(String manifacturer) {
    this.manifacturer = manifacturer == null ? "Unknown" : manifacturer;
  }

  String getReference() {
    return this.reference;
  }

  void setReference(String reference) {
    this.reference = reference;
  }

  String getCodeName() {
    return this.codeName;
  }

  void setCodeName(String codeName) {
    this.codeName = codeName;
  }

  String getModel() {
    return this.model;
  }

  void setModel(String model) {
    this.model = model;
  }

  double getPrice() {
    return this.price;
  }

  void setPrice(double price) {
    this.price = price;
  }

  Map<String, dynamic> toJson() => {
        'manifacturer': manifacturer,
        'reference': reference,
        'codeName': codeName,
        'model': model,
        'price': price.toDouble(),
        'imgUrl': imgUrl,
      };

  Instrument.fromJson(Map<String, dynamic> data, String id)
      : id = id,
        manifacturer = data['manifacturer'].toString().trim(),
        reference = data['reference'].toString().trim(),
        codeName = data['codeName'].toString().trim(),
        model = data['model'].toString().trim(),
        price = double.parse(data['price'].toString()), //stupid, but works
        imgUrl = data['imgUrl'] ?? null;

  factory Instrument.fromFirestore(DocumentSnapshot documentSnapshot) {
    return Instrument.fromJson(documentSnapshot.data(), documentSnapshot.id);
  }
}
