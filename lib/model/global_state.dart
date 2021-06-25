import 'package:ubus_track/model/staionModel.dart';
import 'package:ubus_track/model/baseapi.dart';
import 'package:flutter/material.dart';

class GlobalValue {

  static const Color primaryColor = Color(0xFF0044FF);

  static String uid = '';

  static Map<String, StationPosition> stations = {};

  static Future<void> initStation() async {
    double ensureDouble(dynamic d) {
      if (d is String) return double.parse(d);
      return double.parse(d.toString());
    }

    Future<Map<String, StationPosition>> stationPosition() async {
      var response = await BaseAPI.getAllStation();
      Map<String, dynamic> map = response.data;

      return map.map<String, StationPosition>((key, value) => MapEntry(key, StationPosition(
          name: value['name'],
          lat: ensureDouble(value['lat']),
          lon: ensureDouble(value['lng']),
          radius: ensureDouble(value['radius']),
          desc: value['desc']
      )));
    }

    stations = await stationPosition();
  }

  static String getVoiceAsset(String stationID) {
    switch(stationID) {
      case '5': return 'audios/5.mp3';
      case '7': return 'audios/9.mp3';
      case '9': return 'audios/3.mp3';
      case '10': return 'audios/8.mp3';
      // case '12': return 'audios/12.mp3';
      // case '17': return 'audios/1.mp3';
      default: return 'n/a';
    }
  }

}