import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ApiUrl {
  static const String _baseUrl =
      'http://103.144.127.132:84/ithelpdesk/public/api';

  static String endpoint(String path) {
    return '$_baseUrl$path';
  }
}

class UserDataProvider with ChangeNotifier {
  String? accessToken;
  String? tokenType;
  String? id;
  String? name;
  String? email;
  String? role;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> loadUserData() async {
    var box = await Hive.openBox('userData');
    accessToken = box.get('accessToken')?.toString();
    tokenType = box.get('tokenType')?.toString();
    id = box.get('id')?.toString();
    name = box.get('name')?.toString();
    email = box.get('email')?.toString();
    role = box.get('role')?.toString();

    _isLoaded = true;
    notifyListeners();
  }

  String? getToken() {
    return accessToken;
  }

  String? getId() {
    return id;
  }
}

class CustomColors {
  static const Color first = Color(0xFF37C466);
  static const Color second = Color(0xFF21563A);
  static const Color third = Color(0xFFFF590D);
  static const Color putih = Colors.white;
  static const Color abu = Colors.white54;
  static const Color hitam = Colors.black;
}

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    _dio.options.baseUrl = ApiUrl._baseUrl;
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add token to headers if available
        String? token = Hive.box('userData').get('accessToken');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options); // continue
      },
      onError: (DioException e, handler) {
        // Handle errors globally
        return handler.next(e); // continue
      },
    ));
  }

  Future<Response> getRequest(String path) async {
    try {
      return await _dio.get(path);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> postRequest(String path, Map<String, dynamic> data) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> putRequest(String path, Map<String, dynamic> data) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteRequest(String path) async {
    try {
      return await _dio.delete(path);
    } catch (e) {
      rethrow;
    }
  }
}
