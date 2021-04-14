import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_map/plugin_api.dart';

class BaseAPI {
  static const String ROOT = 'http://103.212.181.44:3500/';
  static const String register = 'v1/bus/scan';

  static BaseOptions options = new BaseOptions(
    baseUrl: ROOT,
    receiveDataWhenStatusError: true,
    // connectTimeout: 60*1000,
    // receiveTimeout: 60*1000,
    // sendTimeout: 60*1000,
  );
  static final Dio dio = new Dio(options);

  static Future<Response<String>> registerDevice(String token) async {
    try {
      return await dio.post(register, data: {
        "token": token
      });
    } on DioError catch (e) {
      if (e.response != null) {
        // Map<String, dynamic> res = jsonDecode(e.response.data);
        return Response(
          requestOptions: e.requestOptions,
          statusCode: e.response.statusCode,
          data: jsonDecode(e.response.data)['err_desc'],
        );
      } else {
        print(e.requestOptions);
        print(e.message);
      }
    }
  }
}