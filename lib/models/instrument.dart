import 'package:cloud_firestore/cloud_firestore.dart';

class Instrument {
  String _manifacturer;
  String _reference;
  String _codeName;
  String _model;
  double _price;

  String getManifacturer() {
    return this._manifacturer;
  }

  void setManifacturer(String manifacturer) {
    this._manifacturer = manifacturer == null ? "Unknown" : manifacturer;
  }

  String getReference() {
    return this._reference;
  }

  void setReference(String reference) {
    this._reference = reference;
  }

  String getCodeName() {
    return this._codeName;
  }

  void setCodeName(String codeName) {
    this._codeName = codeName;
  }

  String getModel() {
    return this._model;
  }

  void setModel(String model) {
    this._model = model;
  }

  double getPrice() {
    return this._price;
  }

  void setPrice(double price) {
    this._price = price;
  }

  Instrument() {
    _manifacturer = "";
    _reference = "";
    _codeName = "";
    _model = "";
    _price = 0.0;
  }

  Map<String, dynamic> toJson() => {
        'manifacturer': _manifacturer,
        'reference': _reference,
        'codeName': _codeName,
        'model': _model,
        'price': _price.toDouble(),
      };

  Instrument.fromJson(Map<String, dynamic> data)
      : _manifacturer = data['manifacturer'].toString().trim(),
        _reference = data['reference'].toString().trim(),
        _codeName = data['codeName'].toString().trim(),
        _model = data['model'].toString().trim(),
        _price = double.parse(data['price'].toString()); //stupid, but works

  factory Instrument.fromFirestore(DocumentSnapshot documentSnapshot) {
    return Instrument.fromJson(documentSnapshot.data());
  }
}
