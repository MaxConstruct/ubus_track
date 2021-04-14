import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:background_location/background_location.dart';
import 'package:ubustrackservice/model/global_state.dart';
import 'package:udp/udp.dart';

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


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          // backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: const Text('Location Service'),
          actions: [
            IconButton(icon: Icon(Icons.cancel_outlined, color: Colors.red,), onPressed: () async {
              final storage = FlutterSecureStorage();
              await storage.deleteAll();
              Navigator.pushReplacementNamed(context, '/lobby');
            })
          ],
        ),
        body: Center(
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            children: <Widget>[
              locationData("Latitude: " + latitude),
              locationData("Longitude: " + longitude),
              locationData("Altitude: " + altitude),
              locationData("Accuracy: " + accuracy),
              locationData("Bearing: " + bearing),
              locationData("Speed: " + speed),
              locationData("Time: " + time),
              locationData("heading: " + (tmp == null ?
              '0' : (tmp.heading * (math.pi / 180) * 1).toString())),
              Transform.rotate(
                angle: (tmp == null ? 0 : tmp.heading * (math.pi / 180) * 1),
                child: Icon(Icons.arrow_circle_up, size: 50,),
                // child: Image.asset('assets/compass.jpg'),
              ),
              locationData("Count: " + _counter.toString()),
              ElevatedButton(
                  onPressed: () async {
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
                    });
                  },
                  child: Text("Start Location Service")),
              ElevatedButton(
                  onPressed: () async {
                    await BackgroundLocation.stopLocationService();
                  },
                  child: Text("Stop Location Service")),
            ],
          ),
        )
    );
  }

  Widget locationData(String data) {
    return Text(
      data,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
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
    BackgroundLocation.stopLocationService();
    super.dispose();
  }

}