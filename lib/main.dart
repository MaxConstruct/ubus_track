import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:background_location/background_location.dart';
import 'package:ubustrackservice/pages/RegisterLobby.dart';
import 'package:ubustrackservice/pages/locator_service_front.dart';
import 'package:udp/udp.dart';

import 'model/global_state.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      home: Loading(),
      onGenerateRoute: (settings) {
        var func = (page) => MaterialPageRoute(builder: (context) => page
        );
        switch (settings.name) {
          case '/lobby': return func(LocationRegisterLobby());
          case '/main': return func(LocationStreamService());
          default: return func(LocationRegisterLobby());
        }
      },
    );
  }
}

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {

  final storage = FlutterSecureStorage();

  Future<void> initApp(BuildContext context) async {
    bool hasKey = await storage.containsKey(key: 'uid');
    if(hasKey) {
      GlobalValue.uid = await storage.read(key: 'uid');
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      Navigator.pushReplacementNamed(context, '/lobby');
    }
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: width,
        child: FutureBuilder(
          future: initApp(context),
          builder: (context, snapshot) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Text('Loading...', style: TextStyle(
                fontSize: 20,
                color: Colors.blueGrey,
            ),),
            SizedBox(height: 50,),
            CircularProgressIndicator()
            ]);
          },
        ),
      ),
    );
  }
}


