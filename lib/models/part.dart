import 'package:cloud_firestore/cloud_firestore.dart';

class Part {
  String id = "";
  String manifacturer;
  String reference;
  String altreference;
  String description;
  String model;
  double price;
  int mainStockMin;
  int personalStockMin;
  List<String> instrumentId;
  bool serialTracking;
  bool active;
  String imgUrl;

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

  List<String> getInstrumentId() {
    return this.instrumentId;
  }

  void setInstrumentId(List<String> instrumentId) {
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
      this.active = true,
      this.imgUrl = ""});

  Map<String, dynamic> toJson() => {
        'manifacturer': manifacturer ?? '',
        'reference': reference,
        'altreference': altreference,
        'instrumentId': instrumentId ?? [],
        'model': model ?? '',
        'description': description,
        'price': price ?? 0.0,
        'mainStockMin': mainStockMin ?? 0,
        'personalStockMin': personalStockMin ?? 0,
        'serialTracking': serialTracking ?? false,
        'active': active ?? true,
        'imgUrl': imgUrl,
      };

  Part.fromJson(Map<String, dynamic> data, String id)
      : id = id,
        manifacturer = data['manifacturer'].toString(),
        reference = data['reference'].toString(),
        altreference = data['altreference'].toString() ?? "",
        instrumentId =
            List<String>.from(data['instrumentId']) ?? List<String>.empty(),
        model = data['model'].toString() ?? "",
        description = data['description'].toString(),
        price = double.tryParse(data['price'].toString()) ?? 0.0,
        mainStockMin = data['mainStockMin'] ?? 0,
        personalStockMin = data['personalStockMin'] ?? 0,
        serialTracking = data['serialTracking'] ?? false,
        active = data['active'] ?? true,
        imgUrl = data['imgUrl'] ?? null;

  factory Part.fromFirestore(DocumentSnapshot documentSnapshot) {
    return Part.fromJson(documentSnapshot.data(), documentSnapshot.id);
  }
}
