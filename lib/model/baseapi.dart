import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_map/plugin_api.dart';
import 'dart:io';

enum Method {
  POST, GET, DELETE, PUT
}

class BaseAPI {
  static const String ROOT = 'https://ubus.scotty1944.net/';
  static const String register = 'v1/bus/scan';
  static const String locationURL = 'location';
  static const String stationURL = 'v1/station/list';

  static BaseOptions options = BaseOptions(
    headers: {
      HttpHeaders.userAgentHeader: 'dio',
      Headers.contentTypeHeader: Headers.jsonContentType,
      'Access-Control-Allow-Origin': '',
      'Cache-Control': 'no-cache'
    },
    baseUrl: ROOT,
    receiveDataWhenStatusError: true,
    connectTimeout: 20*1000,
    receiveTimeout: 20*1000,
    sendTimeout: 20*1000,
  );

  static final Dio dio = new Dio(options);

  static Future<Response> connect(Method method, String url, {data}) async {
    try {
      switch(method) {
        case Method.POST:
          return await dio.post(url, data: data);
        case Method.GET:
          return await dio.get(url);
        case Method.PUT:
          return await dio.put(url, data: data);
        case Method.DELETE:
          return await dio.delete(url, data: data);
        default:
          return Response(requestOptions: null, statusCode: 400, data: 'Your method was incorrect.');
      }
    } on DioError catch(e) {
      print(e);
      return Response(
        statusCode: e.response?.statusCode ?? 500,
        data: e.response != null ? jsonDecode(e.response?.data)['error'] : e.message,
        requestOptions: e.requestOptions,
      );
    }
  }

  static Future<Response<dynamic>> registerDevice(String token) async {
    return await connect(Method.POST, register, data: {'token': token});
  }

  static Future<Response> getLocation() async {
    return await connect(Method.GET, locationURL);
  }

  static Future<Response> getAllStation() async {
    return await connect(Method.GET, stationURL);
  }


}