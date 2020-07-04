import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'area.dart';

class Part {
  final String manifacturer;
  final String serial;
  String altSerial;
  String description;
  String model;
  double price;
  Area area;
  int inStockMainStorage;
  int inStockPersonalStorage;
  int inStockMinReq;
  final String deviceId;
  bool active;

  String getManifacturer() {
    return this.manifacturer;
  }

  String getSerial() {
    return this.serial;
  }

  String getAltSerial() {
    return this.altSerial;
  }

  void setAltSerial(String altSerial) {
    this.altSerial = altSerial;
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

  Area getArea() {
    return this.area;
  }

  void setArea(Area area) {
    this.area = area;
  }

  int getInStockMainStorage() {
    return this.inStockMainStorage;
  }

  void setInStockMainStorage(int inStockMainStorage) {
    this.inStockMainStorage = inStockMainStorage;
  }

  int getInStockPersonalStorage() {
    return this.inStockPersonalStorage;
  }

  void setInStockPersonalStorage(int inStockPersonalStorage) {
    this.inStockPersonalStorage = inStockPersonalStorage;
  }

  int getInStockMinReq() {
    return this.inStockMinReq;
  }

  void setInStockMinReq(int inStockMinReq) {
    this.inStockMinReq = inStockMinReq;
  }

  String getDeviceId() {
    return this.deviceId;
  }

  bool isActive() {
    return this.active;
  }

  void setActive(bool active) {
    this.active = active;
  }

  Part(
      {@required this.manifacturer,
      @required this.serial,
      @required this.deviceId,
      this.model,
      this.altSerial,
      this.area,
      @required this.description,
      this.inStockMainStorage,
      this.inStockPersonalStorage,
      this.inStockMinReq,
      this.price,
      this.active});

//TODO: complete this def
  Map<String, dynamic> toJson() => {
        'manifacturer': manifacturer,
        'serial': serial,
        'altSerial': altSerial,
        'model': model,
        'deviceId': deviceId,
        'description': description,
        'price': price,
      };

  Part.fromJson(Map<String, dynamic> data)
      : manifacturer = data['manifacturer'],
        altSerial = data['altSerial'],
        serial = data['serial'],
        model = data['model'],
        deviceId = data['deviceId'],
        description = data['description'],
        price = data['price'] as double;

  factory Part.fromFirestore(DocumentSnapshot documentSnapshot) {
    return Part.fromJson(documentSnapshot.data);
  }
}
