import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:background_location/background_location.dart';
import 'package:ubus_track/model/baseapi.dart';
import 'package:ubus_track/model/car_position.dart';
import 'package:ubus_track/model/global_state.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:ubus_track/model/staionModel.dart';


class LocationStreamService extends StatefulWidget {
  LocationStreamService({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _LocationStreamServiceState createState() => _LocationStreamServiceState();
}

class _LocationStreamServiceState extends State<LocationStreamService> {

  static int _counter = 0;
  static AudioCache audioCache = AudioCache();


  String latitude = "waiting...";
  String longitude = "waiting...";
  String altitude = "waiting...";
  String accuracy = "waiting...";
  String bearing = "waiting...";
  String speed = "waiting...";
  String time = "waiting...";
  CompassEvent tmp;
  double direction;
  Stream<CompassEvent> _stream;

  StreamSubscription<String> _positionStreamSubscription;

  startLocationService() async {
    setState(() {
      if (isStreamStatePause()) {
        _positionStreamSubscription.resume();
      }
    });
    await BackgroundLocation.stopLocationService();
    await BackgroundLocation.setAndroidNotification(
      title: "Background service is running",
      message: "UShuttle Bus is running in background",
      icon: "@mipmap/ic_launcher",
    );
    await BackgroundLocation.setAndroidConfiguration(0);
    await BackgroundLocation.startLocationService();
    await BackgroundLocation.getLocationUpdates((location) async {
      setState(() {
        this.latitude = location.latitude.toString();
        this.longitude = location.longitude.toString();
        this.accuracy = location.accuracy.toString();
        this.altitude = location.altitude.toString();
        this.bearing = location.bearing.toString();
        this.speed = location.speed.toString();
        this.time = DateTime.fromMillisecondsSinceEpoch(
            location.time.toInt())
            .toString();
        // sentLocation(latitude, longitude);
      }
      );
      tmp = await FlutterCompass.events.first;
      await connect(
        clientAddress: InternetAddress('103.212.181.44'),
        port: 44044,
        lat: location.latitude,
        lon: location.longitude,
        heading: getHeading(tmp),
      );
      _counter++;
      print(_counter);
      print(tmp.heading);
      print(GlobalValue.uid);
      print(latestStation);
    });
  }

  stopService() async {
    await BackgroundLocation.stopLocationService();
    _positionStreamSubscription.pause();
  }

  String latestStation = '';
  String previousStation = '';

  Stream<String> fetchLatestStation() async* {
    while (true) {
      // final response = await http.get('http://103.212.181.44:3500/location');

      // final response = await http.get('http://103.212.181.44:3500/location');
      final response = await BaseAPI.getLocation();
      if (response.statusCode == 200) {

        var data = response.data[GlobalValue.uid];
        var station = data['station'];
        if(station != null) {
          yield station;
        }
      } else {
        throw Exception('Failed to load post');
      }
      await Future.delayed(Duration(seconds: 2));
    }
  }


  bool isPlayAudio = false;
  bool isMute = false;
  Future<void> playLocal() async {
      var assets = GlobalValue.getVoiceAsset(latestStation);
      if (assets != 'n/a') {
        isPlayAudio = true;
        await audioCache.play(assets);
        isPlayAudio = false;
      }
  }

  onLogOutAction() async {
    final storage = FlutterSecureStorage();
    await storage.deleteAll();
    Navigator.pushReplacementNamed(context, '/lobby');
  }


  @override
  void initState() {
    super.initState();
    print(GlobalValue.stations);
    if (_positionStreamSubscription == null) {
      final positionStream = fetchLatestStation();
      _positionStreamSubscription = positionStream.handleError((error) {
        print('STREAM_ERROR: $error');
        _positionStreamSubscription.cancel();
        _positionStreamSubscription = null;
      }).listen((station) => setState(() {
        if(latestStation != station) {
          latestStation = station;
          if(!isPlayAudio) {
            playLocal();
          }
        }

      }));
      _positionStreamSubscription.pause();
    }
  }

  bool isStreamStatePause() {
    if (_positionStreamSubscription == null) return true;
    return _positionStreamSubscription.isPaused;
  }

  String getLatestStation() {
    if(GlobalValue.stations.keys.contains(latestStation)) {
      return GlobalValue.stations[latestStation].name;
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {

    var body = Container(
      // padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(vertical: 100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      await startLocationService();
                    },
                    child: Text("Start Service")),
                // SizedBox(width: 30,),
                ElevatedButton(
                    onPressed: () async {
                      await stopService();
                    },
                    style: ElevatedButton.styleFrom(primary: Colors.redAccent),
                    child: Text("Stop Service")),
                IconButton(
                    icon: Icon(isMute ? Icons.volume_off:Icons.volume_up,
                      color: isMute ? Colors.grey: GlobalValue.primaryColor,
                    ),
                    onPressed: () async {
                      setState(() {
                        isMute = !isMute;
                      });
                    }, ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text('Tracking Information', style: TextStyle(color: Colors.blueGrey),),
          ),
          Expanded(child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: ListView(
              children: [
                locationData('Station', getLatestStation(), icon: Icons.follow_the_signs),
                locationData("Heading Direction", (tmp == null ?
                '0' : (tmp.heading * (math.pi / 180) * 1).toString()),
                    trail: Transform.rotate(
                      angle: (tmp == null ? 0 : tmp.heading * (math.pi / 180) * 1),
                      child: Icon(Icons.navigation, size: 30, color: GlobalValue.primaryColor,),
                    ),
                    icon: Icons.near_me
                ),
                locationData("Accuracy",accuracy, icon: Icons.blur_on),
                locationData("Last Update", time, icon: Icons.history),
                locationData("Current Speed", speed, icon: Icons.speed),
                locationData("Latitude",latitude, icon: Icons.gps_fixed),
                locationData("Longitude",longitude, icon: Icons.gps_fixed),
                locationData("Altitude" ,altitude, icon: Icons.height),
                locationData("Count: ",'',
                    trail: Text(_counter.toString()),
                  icon: Icons.alarm_add
                ),
              ],
            ),
          ),),


        ],
      ),
    );

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          // backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Image.asset('assets/logo/logo.png', height: 45,),
          // title: Text('Location Service'),
          actions: [
            PopupMenuButton<int>(
              onSelected: (int result) {
                if(result == 0) {
                  onLogOutAction();
                }
              },
              icon: Icon(Icons.logout, color: Colors.red,),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text('Logout'),
                ),
              ],
            )
            // IconButton(icon: Icon(Icons.logout, color: Colors.red,), onPressed: onLogOutAction)
          ],
        ),
        body: body
    );
  }

  Widget locationData(String title, String subtitle, {Widget trail, IconData icon}) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: trail,
      ),
    );
  }

  Future<void> sentLocation(lat, lon) async {
    // var sender = await UDP.bind(Endpoint.unicast(InternetAddress('192.168.50.176'), port: Port(44044)));
    // await sender.send(jsonEncode({
    //   'bid': 1,
    //   'lat': lat,
    //   'lng': lon
    // }).codeUnits, Endpoint.broadcast(port: Port(44044)));
    // print("This is current Location" + location.longitude.toString());
    print('lat, lon');
    // connect(InternetAddress('192.168.50.176'), 44044, lat, lon);


  }

  Future<void> connect(
      {InternetAddress clientAddress,
      int port,
      lat,
      lon,
      double heading}) async {
    Future.wait([RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)]).then((values) {
      RawDatagramSocket udpSocket = values[0];
      udpSocket.listen((RawSocketEvent e) {
        print('$lat,\t$lon');
        switch(e) {
          case RawSocketEvent.read :
            Datagram dg = udpSocket.receive();
            if(dg != null) {
              dg.data.forEach((x) => print(x));
            }
            udpSocket.writeEventsEnabled = true;
            break;
          case RawSocketEvent.write :
            udpSocket.send(Utf8Codec().encode(jsonEncode({
              'bid': GlobalValue.uid,
              'lat': lat,
              'lng': lon,
              'head': heading,
            })), clientAddress, port);
            break;
          case RawSocketEvent.closed :
            print('Client disconnected.');
        }
      });
    });
  }

  double getHeading(CompassEvent compassEvent) {
    return compassEvent.heading;
  }

  @override
  void dispose() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription.cancel();
      _positionStreamSubscription = null;
    }
    BackgroundLocation.stopLocationService();
    super.dispose();
  }

}