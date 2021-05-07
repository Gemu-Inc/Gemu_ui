import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class CloudStorageService {
  Future<CloudStorageResult> uploadImage(
      {required File imageToUpload, required String title}) async {
    var imageFileName = title;

    final Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('users/' + imageFileName);

    UploadTask uploadTask = firebaseStorageRef.putFile(imageToUpload);

    TaskSnapshot storageTaskSnapshot = await uploadTask;

    var downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();

    var url = downloadUrl.toString();
    print(url);
    return CloudStorageResult(imageUrl: url, imageFileName: imageFileName);
  }

  Future<CloudStorageResult> uploadImagePost(
      {required File imageToUpload, required String title}) async {
    var imageFileName = title;

    final Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('posts/' + imageFileName);

    UploadTask uploadTask = firebaseStorageRef.putFile(imageToUpload);

    TaskSnapshot storageTaskSnapshot = await uploadTask;

    var downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();

    var url = downloadUrl.toString();
    print(url);
    return CloudStorageResult(imageUrl: url, imageFileName: imageFileName);
  }

  Future deleteImage({required imageFileName}) async {
    final Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('users/' + imageFileName);

    try {
      await firebaseStorageRef.delete();
      return true;
    } catch (e) {
      return e.toString();
    }
  }
}

class CloudStorageResult {
  final String? imageUrl;
  final String? imageFileName;

  CloudStorageResult({this.imageUrl, this.imageFileName});
}
