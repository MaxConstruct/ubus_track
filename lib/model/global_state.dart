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
      case '5': return 'audios/5.wav';
      case '7': return 'audios/9.wav';
      case '9': return 'audios/2.wav';
      case '10': return 'audios/8.wav';
      case '12': return 'audios/12.wav';
      case '17': return 'audios/1.wav';
      case '18': return 'audios/4.wav';
      case '19': return 'audios/15.wav';
      case '20': return 'audios/17.wav';
      case '21': return 'audios/18.wav';
      case '22': return 'audios/19.wav';
      case '23': return 'audios/14.wav';
      case '24': return 'audios/11.wav';
      default: return 'n/a';
    }
  }

}