import 'dart:convert';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import '../pages/MusicCategoryPage.dart';
import '../model/MusicAuthorModel.dart';
import '../pages/MusicAuthorListPage.dart';
import '../model/FavoriteDirectoryModel.dart';
import '../model/MusicModel.dart';
import '../pages/MusicFavoriteListPage.dart';
import '../pages/MusicSearchPage.dart';
import '../pages/NotFoundPage.dart';
import '../pages/MusicPlayerPage.dart';
import '../pages/MusicLyricPage.dart';
import '../pages/MusicIndexPage.dart';
import '../pages/MusicAuthorCategoryPage.dart';
import '../pages/MusicSharePage.dart';
import '../pages/MusicClassifyListPage.dart';
import '../model/MusicClassifyModel.dart';
import '../pages/LoginPage.dart';
import '../pages/ForgetPasswordPage.dart';
import '../pages/RecordMusicPage.dart';
import '../pages/ResetPasswordPage.dart';
import '../pages/UpdatePasswordPage.dart';
import '../pages/UserPage.dart';
import '../pages/RegisterPage.dart';
class Routes {
  static final FluroRouter router = FluroRouter();
  static void initRoutes() {
    /// 指定路由跳转错误返回页
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
          debugPrint('未找到目标页');
          return const NotFoundPage();
        });

    router.define('/MusicSearchPage', handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return MusicSearchPage(keyword:params['keyword']!.first);
    }));
    router.define('/LoginPage', handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const LoginPage();
    }));

    router.define('/MusicPlayerPage', handler: Handler(handlerFunc: (BuildContext? context, params) {
      return const MusicPlayerPage();
    }));
    router.define('/MusicLyricPage', handler: Handler(handlerFunc: (BuildContext? context, Map<String,List<String>> params) {
      return const MusicLyricPage();
    }));
    router.define('/MusicIndexPage', handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const MusicIndexPage();
    }));
    router.define('/MusicAuthorCategoryPage', handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const MusicAuthorCategoryPage();
    }));
    router.define('/MusicSharePage', handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return MusicSharePage(musicModel:MusicModel.fromJson(jsonDecode(params['musicItem']!.first)));
    }));
    router.define('/MusicFavoriteListPage', handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return MusicFavoriteListPage(favoriteDirectoryModel:FavoriteDirectoryModel.fromJson(jsonDecode(params['favoriteDirectoryModel']!.first)));
    }));
    router.define('/MusicClassifyListPage', handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return MusicClassifyListPage(musicClassifyModel:MusicClassifyModel.fromJson(jsonDecode(params['musicClassifyModel']!.first)));
    }));
    router.define('/MusicAuthorListPage', handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return MusicAuthorListPage(authorMode:MusicAuthorModel.fromJson(jsonDecode(params['authorModel']!.first)));
    }));
    router.define('/MusicCategoryPage', handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const MusicCategoryPage();
    }));
    router.define('/ForgetPasswordPage', handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return ForgetPasswordPage();
    }));
    router.define('/ResetPasswordPage', handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return ResetPasswordPage(email: json.decode(params['email']!.first));
    }));
    router.define('/UpdatePasswordPage', handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return UpdatePasswordPage();
    }));
    router.define('/UserPage', handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const UserPage();
    }));
    router.define('/RegisterPage', handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const RegisterPage();
    }));
    router.define('/RecordMusicPage', handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return const RecordMusicPage();
    }));
  }
}