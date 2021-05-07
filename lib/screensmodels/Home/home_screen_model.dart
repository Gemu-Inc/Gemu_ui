import 'package:Gemu/screensmodels/base_model.dart';
import 'package:Gemu/locator.dart';
import 'package:Gemu/services/dialog_service.dart';
import 'package:Gemu/services/navigation_service.dart';
import 'package:Gemu/services/database_service.dart';
import 'package:Gemu/services/cloud_storage_service.dart';
import 'package:Gemu/services/auth_service.dart';
import 'package:Gemu/models/post.dart';
import 'package:Gemu/models/user.dart';
import 'package:Gemu/constants/route_names.dart';

class HomeScreenModel extends BaseModel {
  final AuthService? _authService = locator<AuthService>();
  final NavigationService? _navigationService = locator<NavigationService>();
  final DatabaseService? _firestoreService = locator<DatabaseService>();
  final DialogService? _dialogService = locator<DialogService>();
  final CloudStorageService? _cloudStorageService =
      locator<CloudStorageService>();

  List<Post>? _posts;
  List<Post>? get posts => _posts;

  UserModel? _user;
  UserModel? get user => _user;

  void listenToPosts() {
    setBusy(true);

    _firestoreService!.listenToPostsRealTime().listen((postsData) {
      List<Post> updatedPosts = postsData;
      if (updatedPosts.length > 0) {
        _posts = updatedPosts;
        notifyListeners();
      }

      setBusy(false);
    });
  }

  Future<UserModel?> getUserPost(String uid) async {
    return await (_firestoreService!.getUser(uid));
  }
}
