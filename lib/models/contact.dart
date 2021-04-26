import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  String id = '';
  String firstName;
  String lastName;
  String email;
  String phone;

  Contact(
      {this.firstName, this.lastName, this.email, this.phone, this.id = ''});

  String getFullName({bool soreByFirstName = true}) {
    if (soreByFirstName)
      return '$firstName $lastName';
    else
      return '$lastName $firstName';
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
    };
  }

  Contact.fromJson(Map<String, dynamic> data, String id)
      : id = id,
        firstName = data['firstName'].toString().trim(),
        lastName = data['lastName'].toString().trim(),
        email = data['email'].toString().trim(),
        phone = data['phone'].toString().trim();

  factory Contact.fromFirestore(DocumentSnapshot documentSnapshot) {
    return Contact.fromJson(documentSnapshot.data(), documentSnapshot.id);
  }
}
