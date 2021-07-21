import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String username;
  String email;
  String? imageUrl;
  DocumentReference ref;
  String? documentId;

  UserModel({
    required this.ref,
    this.documentId,
    required this.uid,
    required this.username,
    required this.email,
    this.imageUrl,
  });

  factory UserModel.fromMap(
      DocumentSnapshot snapshot, Map<String, dynamic> data) {
    return UserModel(
      ref: snapshot.reference,
      documentId: snapshot.id,
      uid: data['id'],
      username: data['username'],
      email: data['email'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': uid,
      'username': username,
      'imageUrl': imageUrl,
    };
  }
}
