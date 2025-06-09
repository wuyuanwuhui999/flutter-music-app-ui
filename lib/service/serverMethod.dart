import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_app/theme/ThemeColors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../model/CircleModel.dart';
import '../common/config.dart';
import '../model/CircleLikeModel.dart';
import '../model/FavoriteDirectoryModel.dart';
import '../model/MusicRecordModel.dart';
import '../api/api.dart';
import '../theme/ThemeSize.dart';
import '../utils/HttpUtil.dart';
import '../utils/LocalStorageUtils.dart';
import '../utils/crypto.dart';

//获取用户数据
Future<ResponseModel<dynamic>> getUserDataService() async {
  try {
    String token = await LocalStorageUtils.getToken(); //从缓存中获取
    HttpUtil.getInstance().setToken(token);
    Response response = await dio.get(servicePath["getUserData"]!);
    HttpUtil.getInstance().setToken(response.data['token']);
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    throw Error();
    // return ResponseModel.fromJson(null);
  }
}


//登录
Future<ResponseModel<dynamic>> loginService(
    String userAccount, String password) async {
  try {
    Response response = await dio.post(servicePath['login']!, data: {'userAccount':userAccount,'password':generateMd5(password)});
    HttpUtil.getInstance().setToken(response.data['token']);
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    throw Error();
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 更新用户信息
/// @date: 2021-04-20 23:57
Future<ResponseModel<int>> updateUserData(Map map) async {
  try {
    Response response = await dio.put(servicePath['updateUser']!, data: map);
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 更新用户信息
/// @date: 2025-04-05 19:59
Future<ResponseModel<int>>sendEmailVertifyCodeService(String email) async {
  try {
    Response response = await dio.post(servicePath['sendEmailVertifyCode']!,data:{'email':email});
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

Future<ResponseModel<dynamic>>resetPasswordService(String email,String password,String code) async {
  password = generateMd5(password);
  try {
    Response response = await dio.post(servicePath['resetPassword']!,data:{'email':email,'code':code,'password':password});
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 更新密码
/// @date: 2021-04-20 23:57
Future<ResponseModel<int>> updatePasswordService(String oldPassword,String newPassword) async {
  try {
    oldPassword = generateMd5(oldPassword);
    newPassword = generateMd5(newPassword);
    Response response = await dio.put(servicePath['updatePassword']!, data: {"oldPassword":oldPassword,"newPassword":newPassword});
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 更新密码
/// @date: 2021-04-20 23:57
Future<ResponseModel<dynamic>> loginByEmailService(String email,String code) async {
  try {
    Response response = await dio.post(servicePath['loginByEmail']!, data: {"email":email,"code":code});
    HttpUtil.getInstance().setToken(response.data['token']);
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 获取音乐搜索框关键词
/// @date: 2023-05-18 23:32
Future<ResponseModel<dynamic>> getKeyWordMusicService() async {
  try {
    Response response = await dio.get(servicePath['getKeywordMusic']!);
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 获取音乐分类
/// @date: 2023-05-29 22:57
Future<ResponseModel<List>> getMusicClassifyService() async {
  try {
    Response response = await dio.get(servicePath['getMusicClassify']!);
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 获取分类音乐列表
/// @date: 2023-05-25 22:45
/// @params isRedis是否从缓存中获取，首页数据没有是否喜欢字段，不用从缓存中获取，只有推荐页面才有
Future<ResponseModel<List<dynamic>>> getMusicListByClassifyIdService(
    int classifyId, int pageNum, int pageSize, int isRedis) async {
  try {
    Response response = await dio.get(
        "${servicePath['getMusicListByClassifyId']}?classifyId=$classifyId&pageNum=$pageNum&pageSize=$pageSize&isRedis=$isRedis");
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 获取分类音乐列表
/// @date: 2023-05-25 22:45
Future<ResponseModel<List>> getMusicAuthorListByCategoryIdService(
    int categoryId, int pageNum, int pageSize) async {
  try {
    Response response = await dio.get(
        "${servicePath['getMusicAuthorListByCategoryId']}?categoryId=$categoryId&pageNum=$pageNum&pageSize=$pageSize");
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 根据歌手id获取音乐列表
/// @date: 2024-08-24 11:44
Future<ResponseModel<List>> getMusicListByAuthorIdService(
    String authorId, int pageNum, int pageSize) async {
  try {
    Response response = await dio.get(
        "${servicePath['getMusicListByAuthorId']}?authorId=$authorId&pageNum=$pageNum&pageSize=$pageSize");
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 获取分类音乐列表
/// @date: 2023-05-25 22:45
Future<ResponseModel<List>> getCircleListByTypeService(
    CircleEnum type, int pageNum, int pageSize) async {
  try {
    Response response = await dio.get(
        "${servicePath['getCircleListByType']}?type=${type.toString().split('.').last}&pageNum=${pageNum}&pageSize=${pageSize}");
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 获取我关注的歌手
/// @date: 2023-07-09 11:29
Future<ResponseModel<List>> getFavoriteAuthorService(
    int pageNum, int pageSize) async {
  try {
    Response response = await dio.get(
        "${servicePath['getFavoriteAuthor']}?pageNum=${pageNum}&pageSize=${pageSize}");
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 新增我关注的歌手
/// @date: 2025-03-04 00:07
Future<ResponseModel<int>> insertFavoriteAuthorService(String authorId) async {
  try {
    Response response = await dio.post("${servicePath['insertFavoriteAuthor']}$authorId");
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 删除我关注的歌手
/// @date: 2025-03-04 00:07
Future<ResponseModel<int>> deleteFavoriteAuthorService(String authorId) async {
  try {
    Response response = await dio.delete("${servicePath['deleteFavoriteAuthor']}$authorId");
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 删除我关注的歌手
/// @date: 2025-03-04 00:07
Future<ResponseModel<List>> getMusicLikeService(
    int pageNum, int pageSize) async {
  try {
    Response response = await dio.get(
        "${servicePath['getMusicLike']}?pageNum=${pageNum}&pageSize=${pageSize}");
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 获取我关注的歌手
/// @date: 2023-07-09 11:29
Future<ResponseModel<List>> getMusicRecordService(
    int pageNum, int pageSize) async {
  try {
    Response response = await dio.get(
        "${servicePath['getMusicRecord']}?pageNum=${pageNum}&pageSize=${pageSize}");
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 获取我关注的歌手
/// @date: 2023-11-20 22:15
Future<ResponseModel<int>> insertMusicRecordService(
    MusicRecordModel musicModel) async {
  try {
    Response response = await dio.post(servicePath['insertMusicRecord']!,
        data: musicModel.toMap());
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 插入收藏
/// @date: 2024-01-05 22:26
Future<ResponseModel<int>> insertMusicLikeService(int musicId) async {
  try {
    Response response = await dio.post(servicePath['insertMusicLike']! + musicId.toString());
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 删除收藏
/// @date: 2024-01-05 23:44
Future<ResponseModel<int>> deleteMusicLikeService(int musicId) async {
  try {
    Response response =
        await dio.delete(servicePath['deleteMusicLike']! + musicId.toString());
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 删除收藏
/// @date: 2024-01-05 23:44
Future<ResponseModel<List>> queryMusicLikeService(
    int pageNum, int pageSize) async {
  try {
    Response response = await dio.get(
        "${servicePath['queryMusicLike']}?pageNum=${pageNum}&pageSize=${pageSize}");
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 搜索
/// @date: 2024-01-27 16:46
Future<ResponseModel<List>> searchMusicService(
    String keyword, int pageNum, int pageSize) async {
  try {
    Response response = await dio.get(
        "${servicePath['searchMusic']}?keyword=${keyword}&pageNum=${pageNum.toString()}&pageSize=${pageSize.toString()}");
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 获取歌手分类
/// @date: 2024-02-27 22:51
Future<ResponseModel<List>> getMusicAuthorCategoryService() async {
  try {
    Response response = await dio.get(servicePath['getMusicAuthorCategory']!);
    return ResponseModel<List>.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 点赞
/// @date: 2024-3-28 22:10
Future<ResponseModel> saveLikeService(CircleLikeModel circleLikeModel) async {
  try {
    Response response =
        await dio.post(servicePath['saveLike']!, data: circleLikeModel.toMap());
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 点赞
/// @date: 2024-3-28 22:10
Future<ResponseModel<int>> deleteLikeService(
    int relationId, CommentEnum type) async {
  try {
    Response response = await dio.delete(
        '${servicePath['deleteLike']}?relationId=${relationId.toString()}&type=${type.toString().split('.').last}');
    return ResponseModel<int>.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 点赞
/// @date: 2024-3-28 22:10
Future<ResponseModel<List>> getFavoriteDirectoryService(int musicId) async {
  try {
    Response response = await dio.get("${servicePath['getFavoriteDirectory']}?musicId=${musicId.toString()}");
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@description: 创建收藏夹
///@date: 2024-06-29 11:26
///@author wuwenqiang
Future<ResponseModel<Map>> insertFavoriteDirectoryService (FavoriteDirectoryModel favoriteDirectory)async {
  try {
    Response response = await dio.post(servicePath['insertFavoriteDirectory']!,data: favoriteDirectory.toMap());
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@description: 删除音乐收藏
///@date: 2025-03-04 00:04
///@author wuwenqiang
Future<ResponseModel<int>> deleteFavoriteDirectoryService (int favoriteId)async {
  try {
    Response response = await dio.delete("${servicePath['deleteFavoriteDirectory']}/$favoriteId");
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@description: 查询音乐是否已经收藏
///@date: 2024-06-25 22:02
///@author wuwenqiang
Future<ResponseModel<int>> isMusicFavoriteService (int musicId) async {
  try {
    Response response = await dio.get(servicePath['isMusicFavorite']! + musicId.toString());
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}


///@description: 添加音乐收藏
///@date: 2024-06-29 11:26
///@author wuwenqiang
Future<ResponseModel<int>> insertMusicFavoriteService (int musicId,List<int>favoriteList) async {
  try {
    Response response = await dio.post(servicePath['insertMusicFavorite']! + musicId.toString(),data: favoriteList.map((item) => {"favoriteId":item}).toList());
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@description: 发表说说
///@date: 2024-07-13 20:42
///@author wuwenqiang
Future<ResponseModel<int>> saveCircleService (CircleModel circleModel)async {
  try {
    Response response = await dio.post(servicePath['insertCircle']!,data: circleModel.toMap());
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@description: 根据收藏夹id查询音乐
///@date: 2024-07-13 20:42
///@author wuwenqiang
Future<ResponseModel<List>> getMusicListByFavoriteIdService (int favoriteId,int pageNum,int pageSize)async {
  try {
    Response response = await dio.get("${servicePath['getMusicListByFavoriteId']}?favoriteId=${favoriteId.toString()}&pageNum=${pageNum.toString()}&pageSize=${pageSize.toString()}");
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 获取一级评论
/// @date: 2021-10-28 22:01
Future<ResponseModel<List>> getTopCommentListService(
    int relationId, CommentEnum type, int pageNum,int pageSize) async {
  try {
    Response response = await dio.get(servicePath['getTopCommentList']!,
        queryParameters: {
          "relationId": relationId,
          "type": type.toString().split('.').last,
          "pageSize": pageSize,
          "pageNum": pageNum
        });
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}


///@author: wuwenqiang
///@description: 新增评论
/// @date: 2021-10-31 10:31
Future<ResponseModel<dynamic>> insertCommentService(Map commentMap) async {
  try {
    Response response =
    await dio.post(servicePath['insertCommentService']!, data: commentMap);
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    return ResponseModel.fromJson(null);
  }
}

///@author: wuwenqiang
///@description: 获取模型列表
/// @date: 2025-06-08 20:21
Future<ResponseModel<List<dynamic>>> getModelListService() async {
  try {
    Response response =
    await dio.get(servicePath['getModelList']!,);
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    throw Error();
  }
}

///@author: wuwenqiang
///@description: 获取历史对话
/// @date: 2025-06-09 19:39
Future<ResponseModel<List<dynamic>>> getChatHistoryService(int pageNum,int pageSize) async {
  try {
    Response response =
    await dio.get(servicePath['getChatHistory']!,queryParameters:{"pageNum":pageNum,"pageSize":pageSize});
    return ResponseModel.fromJson(response.data);
  } catch (e) {
    print('ERROR:======>${e}');
    throw Error();
  }
}
