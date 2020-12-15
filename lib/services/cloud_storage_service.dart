import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class CloudStorageService {
  Future<CloudStorageResult> uploadImage(
      {@required File imageToUpload, @required String title}) async {
    var imageFileName = title;

    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('users/' + imageFileName);

    StorageUploadTask uploadTask = firebaseStorageRef.putFile(imageToUpload);

    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;

    var downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();

    if (uploadTask.isComplete) {
      var url = downloadUrl.toString();
      print(url);
      return CloudStorageResult(imageUrl: url, imageFileName: imageFileName);
    }
    return null;
  }

  Future deleteImage({@required imageFileName}) async {
    final StorageReference firebaseStorageRef =
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
  final String imageUrl;
  final String imageFileName;

  CloudStorageResult({this.imageUrl, this.imageFileName});
}
