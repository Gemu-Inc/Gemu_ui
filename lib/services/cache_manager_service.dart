import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

abstract class CacheManagerService {
  Future<File> cacheMyPosts(String urlImage);
}

class CacheManagerExtends extends CacheManagerService {
  final BaseCacheManager _cacheManager;

  CacheManagerExtends(this._cacheManager);

  Future<File> cacheMyPosts(String urlImage) async {
    File? file;
    FileInfo? fileInfo = await _cacheManager.getFileFromCache(urlImage);

    if (fileInfo == null) {
      print('No in cache');
      file = await _cacheManager.getSingleFile(urlImage);
      print('Saving in cache');
    } else {
      print('Loading from cache');
      file = fileInfo.file;
    }
    return file;
  }
}
