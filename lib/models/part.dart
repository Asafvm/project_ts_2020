import 'package:cloud_firestore/cloud_firestore.dart';

class Part {
  String manifacturer;
  String reference;
  String altreference;
  String description;
  String model;
  double price;
  int mainStockMin;
  int personalStockMin;
  String instrumentId;
  bool serialTracking;
  bool active;

  String getManifacturer() {
    return this.manifacturer;
  }

  void setManifacturer(String manifacturer) {
    this.manifacturer = manifacturer;
  }

  String getreference() {
    return this.reference;
  }

  void setReference(String reference) {
    this.reference = reference;
  }

  String getAltreference() {
    return this.altreference;
  }

  void setAltreference(String altreference) {
    this.altreference = altreference;
  }

  String getDescription() {
    return this.description;
  }

  void setDescription(String description) {
    this.description = description;
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

  int getmainStockMin() {
    return this.mainStockMin;
  }

  void setmainStockMin(int mainStockMin) {
    this.mainStockMin = mainStockMin;
  }

  int getpersonalStockMin() {
    return this.personalStockMin;
  }

  void setpersonalStockMin(int personalStockMin) {
    this.personalStockMin = personalStockMin;
  }

  String getInstrumentId() {
    return this.instrumentId;
  }

  void setInstrumentId(String instrumentId) {
    this.instrumentId = instrumentId;
  }

  bool getSerialTracking() {
    return this.serialTracking;
  }

  void setSerialTracking(bool serialTracking) {
    this.serialTracking = serialTracking;
  }

  bool isActive() {
    return this.active;
  }

  void setActive(bool active) {
    this.active = active;
  }

  Part(
      {this.manifacturer,
      this.reference,
      this.altreference = "",
      this.instrumentId,
      this.model = "",
      this.description,
      this.price = 0.0,
      this.mainStockMin = 0,
      this.personalStockMin = 0,
      this.serialTracking = false,
      this.active = true});

  Map<String, dynamic> toJson() => {
        'manifacturer': manifacturer ?? '',
        'reference': reference,
        'altreference': altreference,
        'InstrumentId': instrumentId ?? '',
        'model': model ?? '',
        'description': description,
        'price': price ?? 0,
        'mainStockMin': mainStockMin ?? 0,
        'personalStockMin': personalStockMin ?? 0,
        'serialTracking': serialTracking ?? false,
        'active': active ?? true,
      };

  Part.fromJson(Map<String, dynamic> data)
      : manifacturer = data['manifacturer'],
        reference = data['reference'],
        altreference = data['altreference'] ?? "",
        instrumentId = data['instrumentId'],
        model = data['model'] ?? "",
        description = data['description'],
        price = double.tryParse(data['price']) ?? 0.0,
        mainStockMin = data['mainStockMin'] ?? 0,
        personalStockMin = data['personalStockMin'] ?? 0,
        serialTracking = data['serialTracking'] ?? false,
        active = data['active'] ?? true;

  factory Part.fromFirestore(DocumentSnapshot documentSnapshot) {
    return Part.fromJson(documentSnapshot.data());
  }
}
