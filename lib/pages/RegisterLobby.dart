import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ubus_track/model/baseapi.dart';
import 'package:ubus_track/model/global_state.dart';
import 'package:ubus_track/model/staionModel.dart';

class LocationRegisterLobby extends StatefulWidget {
  @override
  _LocationRegisterLobbyState createState() => _LocationRegisterLobbyState();
}

class _LocationRegisterLobbyState extends State<LocationRegisterLobby> {

  TextEditingController _controller = TextEditingController();
  final storage = FlutterSecureStorage();

  Future<bool> checkKeyExist(String key) async {
    var response = await BaseAPI.getLocation();
    if(response.statusCode == 200) {
      Map<String, dynamic> loc = response.data;
      loc.keys.contains(key);
      return true;
    }
    return false;
  }

  void registerAction(String token) {
    _onLoading(token);
  }

  void _registerDevice(String token) {
    BaseAPI.registerDevice(token).then((val) async {
      if(val.statusCode == 200) {
        var res = val.data;
        print(res['id']);
        print(val.data);
        GlobalValue.uid = res['id'];
        await storage.write(key: 'uid', value: GlobalValue.uid.toString());
        await GlobalValue.initStation();

        Navigator.pushReplacementNamed(context, '/main');
      } else {
        Navigator.of(context).pop();
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error Code ${val.statusCode}'),
              // titleTextStyle: TextStyle(color: Colors.red),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text("${val.data}"),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }



  void _onLoading(String token) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            color: Colors.transparent,
            width: 100,
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            )
          ),
        );
      },
    );
    
    checkKeyExist(token).then((keyExist) async {
      if(keyExist) {
        GlobalValue.uid = token;
        await storage.write(key: 'uid', value: GlobalValue.uid.toString());
        await GlobalValue.initStation();
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        _registerDevice(token);
      }
    });
  }


  @override
  Widget build(BuildContext context) {

    var width = MediaQuery.of(context).size.width;
    var card = Container(
      width: 300,
      padding: EdgeInsets.all(10),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              // Text('Token',
              //   style: TextStyle(fontSize: 20),
              // ),
              Image.asset('assets/logo/logo.png', width: 200,),
              SizedBox(height: 20,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                child: TextField(
                    style: GoogleFonts.robotoMono(),
                  decoration: new InputDecoration(
                    hintText: 'Enter token key',
                      border: new OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6.0))
                      ),
                      labelText: 'Token'
                  ),
                  controller: _controller,
                ),
              ),
              ElevatedButton(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Register',)
                ),
                onPressed: () {
                  registerAction(_controller.value.text);
                },
              )
            ],
          ),
        ),

      ),
    );

    return Scaffold(
      body: Container(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            card,
          ],
        ),
      ),
    );
  }
}
