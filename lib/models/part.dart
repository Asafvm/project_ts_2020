import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Part {
  String manifacturer;
  String reference;
  String altreference;
  String description;
  String model;
  double price;
  int mainStockMin;
  int personalStockMin;
  String InstrumentId;
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
    return this.InstrumentId;
  }

  void setInstrumentId(String InstrumentId) {
    this.InstrumentId = InstrumentId;
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
      {@required this.manifacturer,
      @required this.reference,
      this.altreference = "",
      @required this.InstrumentId,
      this.model = "",
      @required this.description,
      this.price = 0.0,
      this.mainStockMin = 0,
      this.personalStockMin = 0,
      this.serialTracking = false,
      this.active = true});

  Map<String, dynamic> toJson() => {
        'manifacturer': manifacturer,
        'reference': reference,
        'altreference': altreference,
        'InstrumentId': InstrumentId,
        'model': model,
        'description': description,
        'price': price,
        'mainStockMin': mainStockMin,
        'personalStockMin': personalStockMin,
        'serialTracking': serialTracking,
        'active': active,
      };

  Part.fromJson(Map<String, dynamic> data)
      : manifacturer = data['manifacturer'],
        reference = data['reference'],
        altreference = data['altreference'] ?? "",
        InstrumentId = data['InstrumentId'],
        model = data['model'] ?? "",
        description = data['description'],
        price = data['price'] as double ?? 0.0,
        mainStockMin = data['mainStockMin'] ?? 0,
        personalStockMin = data['personalStockMin'] ?? 0,
        serialTracking = data['serialTracking'] ?? false,
        active = data['active'] ?? true;

  factory Part.fromFirestore(DocumentSnapshot documentSnapshot) {
    return Part.fromJson(documentSnapshot.data);
  }
}
