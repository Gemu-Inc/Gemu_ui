import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:algolia/algolia.dart';

class UserModel {
  DocumentReference? ref;
  AlgoliaObjectReference? refAlgolia;
  String? documentId;
  String uid;
  String username;
  String? email;
  String? imageUrl;
  String? type;
  String privacy;

  UserModel(
      {this.ref,
      this.refAlgolia,
      this.documentId,
      required this.uid,
      required this.username,
      this.email,
      this.imageUrl,
      this.type,
      required this.privacy});

  factory UserModel.fromMap(
      DocumentSnapshot snapshot, Map<String, dynamic> data) {
    return UserModel(
        ref: snapshot.reference,
        documentId: snapshot.id,
        uid: data['id'],
        username: data['username'],
        email: data['email'],
        imageUrl: data['imageUrl'],
        privacy: data['privacy']);
  }

  factory UserModel.fromMapAlgolia(
      AlgoliaObjectSnapshot snapshot, Map<String, dynamic> data) {
    return UserModel(
        refAlgolia: snapshot.ref,
        uid: data["objectID"],
        username: data["username"],
        imageUrl: data["imageUrl"],
        type: data["type"],
        privacy: data["privacy"]);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': uid,
      'username': username,
      'imageUrl': imageUrl,
    };
  }
}
