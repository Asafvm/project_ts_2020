class Site {
  String name;
  Address address;

  Site({this.name, this.address});
}

class Address {
  final double latitude;
  final double longtitude;
  final String country;
  final String area;
  final String city;
  final String street;
  final int houseNumber;
  final int zipcode;

  Address(this.latitude, this.longtitude,
      [this.country = '',
      this.area = '',
      this.city = '',
      this.street = '',
      this.houseNumber = 0,
      this.zipcode = 0]);

  double get lat {
    return latitude;
  }

  double get lng {
    return longtitude;
  }
}
